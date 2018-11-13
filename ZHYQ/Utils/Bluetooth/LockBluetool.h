//
//  LockBluetool.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/2.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^OpenLockBlock)(BOOL isSuccess);
typedef void(^DownLockBlock)(BOOL isSuccess);

@protocol LockBluetoothDelegate <NSObject>

- (void)bluetoothNotOpen;

// 连接蓝牙设备成功/失败。 未连接成功不可发送指令。会产生奔溃
- (void)connectFail;
- (void)connectSuccess;     // 可能回调多次

// 连接成功验证蓝牙设备秘钥。 未验证成功不可发送指令。指令无效
- (void)verifyFail;         // 验证失败会重新验证，可能会调多次
- (void)verifySuccess;

@end

@interface LockBluetool : NSObject

+ (instancetype)sharedBluetoothTool;

- (void)beginConnectWithLockCode:(NSString *)lockCode;

- (void)openLock:(OpenLockBlock)openLockBlock;
- (void)downLock:(DownLockBlock)downLockBlock;

- (void)cancelScanBluetooth;

- (void)closeCOnnect;

@property (nonatomic,assign) id<LockBluetoothDelegate> bluetoothDelegate;

@end
