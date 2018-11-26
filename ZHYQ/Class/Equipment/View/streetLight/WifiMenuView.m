//
//  WifiMenuView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/14.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "WifiMenuView.h"
#import "ShowMenuView.h"

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
    _isRuning = YES;
    _stateStr= @"正常开启中";
    _stateColor = [UIColor colorWithHexString:@"#189517"];
    _acceptSpedd = @"28.60 b";
    _sendSpedd = @"8.40 b";
    _accessNum = @"2";
    
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
    
    _menuTitle = subDeviceModel.DEVICE_NAME;
    
    _showMenuView.menuDelegate = self;
}

- (void)setStreetLightModel:(StreetLightModel *)streetLightModel {
    _streetLightModel = streetLightModel;
    
    _locationStr = [NSString stringWithFormat:@"%@", streetLightModel.DEVICE_NAME];
}

#pragma mark MenuControlDelegate
- (CGFloat)menuHeightInView:(NSInteger)index {
    switch (index) {
        case 0:
            return 60;
            break;
        case 1:
            return 40;
            break;
        case 2:
            return 40;
            break;
        case 3:
            return 40;
            break;
        case 4:
            return 40;
            break;
            
        default:
            return 0;
            break;
    }
}

- (NSInteger)menuNumInView {
    return 5;
}

- (NSString *)menuTitle:(NSInteger)index {
    switch (index) {
        case 0:
            return _stateStr;
            break;
        case 1:
            return @"位置";
            break;
        case 2:
            return @"接收速率";
            break;
        case 3:
            return @"发送速率";
            break;
        case 4:
            return @"接入量";
            break;
            
        default:
            return @"";
            break;
    }
}

- (UIColor *)menuTitleColor:(NSInteger)index {
    if(index == 0){
        return _stateColor;
    }else {
        return [UIColor blackColor];
    }
}

- (NSString *)menuTitleViewText {
    return _menuTitle;
}

- (ShowMenuStyle)menuViewStyle:(NSInteger)index {
    switch (index) {
        case 0:
            return SwitchConMenu;
            break;
        case 1:
            return DefaultConMenu;
            break;
        case 2:
            return DefaultConMenu;
            break;
        case 3:
            return DefaultConMenu;
            break;
        case 4:
            return DefaultConMenu;
            break;
            
        default:
            return DefaultConMenu;
            break;
    }
}

- (BOOL)isSwitch:(NSInteger)index {
    return _isRuning;
}

- (NSString *)menuMessage:(NSInteger)index {
    if(index == 1){
        return _locationStr;
    }else if(index == 2){
        return _acceptSpedd;
    }else if(index == 3){
        return _sendSpedd;
    }else if(index == 4){
        return _accessNum;
    }else {
        return @"";
    }
}

// 监控开关协议
- (void)switchState:(NSInteger)index withSwitch:(BOOL)isOn {
    if([_stateStr isEqualToString:@"设备故障"]){
        return;
    }
    
    _isRuning = isOn;
    if(isOn){
        _stateStr = @"正常开启中";
        _stateColor = [UIColor colorWithHexString:@"#189517"];
        _acceptSpedd = @"28.60 b";
        _sendSpedd = @"8.40 b";
        _accessNum = @"2";
    }else {
        _stateStr = @"离线";
        _stateColor = [UIColor blackColor];
        _acceptSpedd = @"0.0 b";
        _sendSpedd = @"0.0 b";
        _accessNum = @"0";
    }
    
    [_showMenuView reloadMenuData];
}

- (void)didSelectMenu:(NSInteger)index {
    switch (index) {
        case 4:
        {
            
        }
            
    }
}

@end
