//
//  LockBluetool.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/2.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "LockBluetool.h"

#import "BabyBluetooth.h"
#import "BluetoothDeviceModel.h"
#import "WHLockScanUtils.h"
#import "WHBlueToothConstant.h"
#import "NSString+HexString.h"
#import "NSData+WHData.h"

@interface LockBluetool()
{
    NSString *_lockCode;
    
    NSString *_singalStrong;
}

@property (nonatomic, copy) OpenLockBlock openLockBlock;
@property (nonatomic, copy) DownLockBlock downLockBlock;

@property (nonatomic, strong) BluetoothDeviceModel *lock;

// 全局蓝牙管理对象
@property (nonatomic, strong) BabyBluetooth *baby;
/// 连接的外设
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *character;
@end
    
@implementation LockBluetool

static id _instace;

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [super allocWithZone:zone];
    });
    return _instace;
}

+ (instancetype)sharedBluetoothTool
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [[self alloc] init];
    });
    return _instace;
}

- (id)copyWithZone:(NSZone *)zone{
    return _instace;
}

#pragma mark 开始连接地锁蓝牙
- (void)beginConnectWithLockCode:(NSString *)lockCode {
    /// 测试二维码 需要时替换二维码
    self.lock = [[WHLockScanUtils sharedInstance]analyseQRCodeWithString:lockCode];
    self.baby = [BabyBluetooth shareBabyBluetooth];
    
    [self babyDelegate];
    
    if(self.baby != nil){
        [self.baby.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}

/// 设置扫描到设备的委托
- (void)babyDelegate {
    __weak typeof(self) weakSelf = self;
    
    /// 手机蓝牙是否开启
    [weakSelf.baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        switch (central.state) {
                /// 蓝牙打开
            case CBManagerStatePoweredOn:
                weakSelf.baby.scanForPeripherals().begin();
                break;
                /// 蓝牙未打开
            case CBManagerStatePoweredOff:
                if(weakSelf.bluetoothDelegate && [weakSelf.bluetoothDelegate respondsToSelector:@selector(bluetoothNotOpen)]){
                    [weakSelf.bluetoothDelegate bluetoothNotOpen];
                }
                break;
            default:
                break;
        }
    }];
    
    /// 扫描连接范围内的所有设备
    [self.baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        /// 根据蓝牙外设名建立连接
        if ([weakSelf.lock.name isEqualToString:peripheral.name]) {
            weakSelf.peripheral = peripheral;
            ///centralManager 蓝牙管理类
            [weakSelf.baby.centralManager connectPeripheral:weakSelf.peripheral options:nil];
        }
    }];
    /// 蓝牙连接成功回调
    [self.baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        /// 连接成功取消扫描 节约手机电量
        [weakSelf.baby cancelScan];
        
        if(weakSelf.bluetoothDelegate && [weakSelf.bluetoothDelegate respondsToSelector:@selector(connectSuccess)]){
            [weakSelf.bluetoothDelegate connectSuccess];
        }
        
        /// 发现服务
        [weakSelf.peripheral discoverServices:@[[CBUUID UUIDWithString:CONTROL_SERVICE_UUID]]];
        /// 读取蓝牙外设型号量
        [peripheral readRSSI];
        
    }];
    /// 获取连接设备的型号量
    [self.baby setBlockOnDidReadRSSI:^(NSNumber *RSSI, NSError *error) {
        NSLog(@"信号量%@",RSSI);
        /// 继续读取信号量(此方法才会一直回调)
        _singalStrong = [NSString stringWithFormat:@"信号量: %@",RSSI];
        [weakSelf.peripheral readRSSI];
    }];
    /// 取消扫描成功的回调
    [self.baby setBlockOnCancelScanBlock:^(CBCentralManager *centralManager) {
        NSLog(@"取消扫描成功");
    }];
    /// 发现蓝牙服务
    [self.baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        /// 遍历外设中的服务
        NSLog(@"发现服务");
        for (CBService *service in peripheral.services) {
            if ([service.UUID.UUIDString isEqualToString:CONTROL_SERVICE_UUID]) {
                [peripheral discoverCharacteristics:nil forService:service];
            }
        }
    }];
    /// 发现服务对应的特征
    [self.baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"发现特征");
        for (CBCharacteristic *character in service.characteristics) {
            /// 如果是可写特征(就验证秘钥)
            if ([character.UUID.UUIDString isEqualToString:WRITE_SERVICE_UUID]) {
                weakSelf.character = character;
                NSString *str = [NSString stringFromHexString:weakSelf.lock.passwordHash];
                NSLog(@"%@",[NSString stringFromHexString:weakSelf.lock.passwordHash]);
                NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
                [weakSelf.peripheral writeValue:data forCharacteristic:weakSelf.character type:CBCharacteristicWriteWithResponse];
            }else if ([character.UUID.UUIDString isEqualToString:NOTIFICATION_SERVICE_UUID]){
                [weakSelf.peripheral setNotifyValue:YES forCharacteristic:character];
            }
        }
    }];
    
    /// 验证秘钥的回调
    [self.baby setBlockOnDidUpdateNotificationStateForCharacteristic:^(CBCharacteristic *characteristic, NSError *error) {
        
        /// 验证秘钥是否成功
        if ([characteristic.value isEqual:[NSData dataWithBytes:PASSWORD_VERIFITY_SUCCESS_STATE length:4]]) {
            [weakSelf.peripheral writeValue:[NSData dataWithBytes:LOCK_SEARCH_KEEP length:4] forCharacteristic:weakSelf.character type:CBCharacteristicWriteWithResponse];
            NSLog(@"验证成功");
            
            if(weakSelf.bluetoothDelegate && [weakSelf.bluetoothDelegate respondsToSelector:@selector(verifySuccess)]){
                [weakSelf.bluetoothDelegate verifySuccess];
            }
            
        }else {
            /// 不成功就再次建立连接
//            [weakSelf.baby.centralManager connectPeripheral:weakSelf.peripheral options:nil];
            NSLog(@"验证失败");
            
            if(weakSelf.bluetoothDelegate && [weakSelf.bluetoothDelegate respondsToSelector:@selector(verifyFail)]){
                [weakSelf.bluetoothDelegate verifyFail];
            }
        }
    }];
    /// 读取数据（每次锁的状态改变都会来到这个方法）
    [self.baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        if ([characteristic.UUID.UUIDString isEqualToString:NOTIFICATION_SERVICE_UUID]) {
            /// 将data转为字符串
            NSString *lockStateStr = [NSData hexStringFromData:characteristic.value];
            if (lockStateStr.length > 0) {
                /// 获取电池电量
                NSString *lockState = [lockStateStr substringWithRange:NSMakeRange(4, 2)];
                NSString *stateStr;
                if ([lockState isEqualToString:LOCK_STATUS_UP]) {
                    stateStr = @"当前状态:升起";
                    
                    if(weakSelf.openLockBlock != nil){
                        weakSelf.openLockBlock(YES);
                    }
                    
                }else if([lockState isEqualToString:LOCK_STATUS_DOWN]) {
                    stateStr = @"当前状态:降下";
                    
                    if(weakSelf.downLockBlock != nil){
                        weakSelf.downLockBlock(YES);
                    }
                    
                }else {
                    stateStr = @"当前状态:降下";
                    
                    if(weakSelf.downLockBlock != nil){
                        weakSelf.downLockBlock(YES);
                    }
                }
                NSLog(@"++++++++++++ %@", stateStr);
                
            }
        }
    }];
    /// 连接失败
    [self.baby setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        [weakSelf.baby.centralManager connectPeripheral:peripheral options:nil];
        
        if(weakSelf.bluetoothDelegate && [weakSelf.bluetoothDelegate respondsToSelector:@selector(connectFail)]){
            [weakSelf.bluetoothDelegate connectFail];
        }
    }];
    /// 断开连接
    [self.baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
//        if (weakSelf.baby) {
//            [weakSelf.baby.centralManager connectPeripheral:peripheral options:nil];
//        }
        NSLog(@"断开连接");
    }];
}


#pragma mark 开锁
- (void)openLock:(OpenLockBlock)openLockBlock {
    _openLockBlock = openLockBlock;
    
    if(self.peripheral != nil){
        [self.peripheral writeValue:[NSData dataWithBytes:LOCK_UP length:4] forCharacteristic:self.character type:CBCharacteristicWriteWithResponse];
    }
}

#pragma mark 降下锁
- (void)downLock:(DownLockBlock)downLockBlock {
    _downLockBlock = downLockBlock;
    
    if(self.peripheral != nil){
        [self.peripheral writeValue:[NSData dataWithBytes:LOCK_DOWN length:4] forCharacteristic:self.character type:CBCharacteristicWriteWithResponse];
    }
}

#pragma mark 停止扫描
- (void)cancelScanBluetooth {
    [self.baby cancelScan];
}

#pragma mark 关闭连接
- (void)closeCOnnect {
    if(_peripheral != nil){
        [self.baby.centralManager cancelPeripheralConnection:_peripheral];
    }
}

@end
