//
//  WifiMenuView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/14.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "WifiMenuView.h"
#import "ShowMenuView.h"
#import "WifiInfoModel.h"

@interface WifiMenuView()<MenuControlDelegate>
{
    ShowMenuView *_showMenuView;
    
    NSString *_menuTitle;   // 菜单标题
    NSString *_stateStr;    // 设备状态
    UIColor *_stateColor;   // 设备状态颜色
    BOOL _isRuning; // 是否正常开启
    NSString *_locationStr; // 坐标位置
    NSString *_acceptSpedd; // 网速
    NSString *_sendSpedd; // 网速
    NSString *_accessNum; // 接入量
    
    WifiInfoModel *_wifiInfoModel;
}
@end

@implementation WifiMenuView

- (instancetype)init {
    self = [super init];
    if(self){
        [self _initView];
    }
    return self;
}

- (void)_initView {
    
    _menuTitle = [NSString stringWithFormat:@"WiFi"];
//    _isRuning = YES;
//    _stateStr= @"正常开启中";
//    _stateColor = [UIColor colorWithHexString:@"#189517"];
//    _acceptSpedd = @"28.60 b";
//    _sendSpedd = @"8.40 b";
//    _accessNum = @"2";
    
    // 创建点击菜单视图
    _showMenuView = [[ShowMenuView alloc] init];
    _showMenuView.hidden = YES;
//    _showMenuView.menuDelegate = self;
    [[UIApplication sharedApplication].delegate.window addSubview:_showMenuView];
}

- (void)showMenu {
    _showMenuView.hidden = NO;
    [_showMenuView reloadMenuData];
}
- (void)hidMenu {
    _showMenuView.hidden = YES;
}

- (void)setSubDeviceModel:(SubDeviceModel *)subDeviceModel {
    _subDeviceModel = subDeviceModel;
    
    // 加载wifi数据
    [self loadWifiData];
    
    _menuTitle = subDeviceModel.DEVICE_NAME;
    _showMenuView.menuDelegate = self;
}

- (void)setStreetLightModel:(StreetLightModel *)streetLightModel {
    _streetLightModel = streetLightModel;
    
    _locationStr = [NSString stringWithFormat:@"%@", streetLightModel.DEVICE_NAME];
}

#pragma mark 加载单个设备数据
- (void)loadWifiData {
    // layerid 室外固定20
    NSString *urlStr = [NSString stringWithFormat:@"%@/wifi/getWifiListDetail?layerId=%@&AP=%@",Main_Url, @"20", _subDeviceModel.DEVICE_ID];
//    NSString *urlStr = [NSString stringWithFormat:@"%@/wifi/getWifiListDetail?layerId=%@&AP=%@",Main_Url, @"4", @"683"];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            NSDictionary *responseData = responseObject[@"responseData"];
            NSArray *wifiList = responseData[@"wifiList"];
            if(wifiList != nil && [wifiList isKindOfClass:[NSArray class]] && wifiList.count > 0){
                _wifiInfoModel = [[WifiInfoModel alloc] initWithDataDic:wifiList.firstObject];
                
                _locationStr = [NSString stringWithFormat:@"%@", _subDeviceModel.DEVICE_NAME];
                _acceptSpedd = [NSString stringWithFormat:@"%@", [self speedValueStr:_wifiInfoModel.recv.doubleValue]];
                _sendSpedd = [NSString stringWithFormat:@"%@", [self speedValueStr:_wifiInfoModel.send.doubleValue]];
                _accessNum = [NSString stringWithFormat:@"%@", _wifiInfoModel.usercount];
                
                [_showMenuView reloadMenuData];
            }
        }
        
    } failure:^(NSError *error) {
        
    }];
}
- (NSString *)speedValueStr:(double)speed {
    NSString *speedStr;
    if(speed < 1024){
        // b
        speedStr = [NSString stringWithFormat:@"%.2f b", speed];
    }else if(speed > 1024 && speed < 1024*1024){
        // kb
        speedStr = [NSString stringWithFormat:@"%.2f kb", speed/1024.00];
    }else {
        // M
        speedStr = [NSString stringWithFormat:@"%.2f M", speed/(1024.00*1024.00)];
    }
    return speedStr;
}

#pragma mark MenuControlDelegate
- (CGFloat)menuHeightInView:(NSInteger)index {
    if(index == 0 || index == 1 || index == 2){
        return 45;
    }else{
        return 40;
    }
}
- (CGSize)imageSize:(NSInteger)index {
    return CGSizeMake(32, 32);
}
- (NSInteger)menuNumInView {
    return 7;
}

- (NSString *)menuTitle:(NSInteger)index {
    switch (index) {
        case 0:
            return @"重启设备";
            break;
        case 1:
            return @"开启射频";
            break;
        case 2:
            return @"关闭射频";
            break;
        case 3:
            return @"位置";
            break;
        case 4:
            return @"接收速率";
            break;
        case 5:
            return @"发送速率";
            break;
        case 6:
            return @"接入用户数";
            break;
            
        default:
            return @"";
            break;
    }
}

- (UIColor *)menuTitleColor:(NSInteger)index {
    return [UIColor blackColor];
}

- (NSString *)menuTitleViewText {
    return _menuTitle;
}

- (ShowMenuStyle)menuViewStyle:(NSInteger)index {
    switch (index) {
        case 0:
            return ImgConMenu;
            break;
        case 1:
            return ImgConMenu;
            break;
        case 2:
            return ImgConMenu;
            break;
            
        default:
            return DefaultConMenu;
            break;
    }
}
- (NSString *)imageName:(NSInteger)index {
    if(index == 0){
        return @"led_restart_icon";
    }else if(index == 1){
        return @"led_play_icon";
    }else if(index == 2){
        return @"led_close_icon";
    }else if(index == 6){
//        return @"wifi_list";
    }
    return @"";
}
- (NSString *)menuMessage:(NSInteger)index {
    if(index == 3){
        return _locationStr;
    }else if(index == 4){
        return _acceptSpedd;
    }else if(index == 5){
        return _sendSpedd;
    }else if(index == 6){
        return _accessNum;
    }else {
        return @"";
    }
}

- (void)didSelectMenu:(NSInteger)index {
    if(index == 0){
        [self wifiControl:0];
    }else if(index == 1){
        [self wifiControl:1];
    }else if(index == 2){
        [self wifiControl:2];
    }else if(index == 6){
//        [self goWifiUser];
    }
}

#pragma mark 调用开关wifi接口
- (void)wifiControl:(NSInteger)conType {
    // conType: 0重启，1开射频，2关射频
    NSString *operation;
    if(conType == 0){
        operation = @"reboot";
    }else if(conType == 1){
        operation = @"enable_radio";
    }else if(conType == 2){
        operation = @"disable_radio";
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@/wifi/setWifiState?layerId=%@&operation=%@&mode=%@&deviceId=%@",Main_Url, @"20", operation, @"all", _subDeviceModel.DEVICE_ID];
//    NSString *urlStr = [NSString stringWithFormat:@"%@/wifi/setWifiState?layerId=%@&operation=%@&mode=%@&deviceId=%@",Main_Url, @"4", operation, @"all", @"683"];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        NSNumber *success = responseObject[@"success"];
        if(!success.boolValue){
            if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]] ) {
//                [self showHint:responseObject[@"message"]];
                NSLog(@"%@", responseObject[@"message"]);
            }
        }else {
            [_showMenuView reloadMenuData];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

@end
