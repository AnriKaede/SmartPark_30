//
//  MonitorMenuView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/14.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "MonitorMenuView.h"
#import "ShowMenuView.h"
#import "PlayVideoViewController.h"
#import "PlaybackViewController.h"
//#import "DHDataCenter.h"

@interface MonitorMenuView()<MenuControlDelegate>
{
    ShowMenuView *_showMenuView;
    
    NSString *_menuTitle;   // 菜单标题
    NSString *_stateStr;    // 设备状态
    UIColor *_stateColor;   // 设备状态颜色
}
@end

@implementation MonitorMenuView

- (instancetype)init {
    self = [super init];
    if(self){
        [self _initView];
    }
    return self;
}

- (void)_initView {
    
    _menuTitle = @"视频监控";
    _stateStr = @"在线";
    
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

#pragma mark MenuControlDelegate
- (CGFloat)menuHeightInView:(NSInteger)index {
    switch (index) {
        case 0:
            return 40;
            break;
        case 1:
            return 80;
            break;
        case 2:
            return 50;
            break;
            
        default:
            return 0;
            break;
    }
}

- (NSInteger)menuNumInView {
    return 3;
}

- (NSString *)menuTitle:(NSInteger)index {
    switch (index) {
        case 0:
            return @"在线状态";
            break;
        case 1:
            return @"实时画面";
            break;
        case 2:
            return @"历史录像";
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
            return DefaultConMenu;
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

- (CGSize)imageSize:(NSInteger)index {
    if(index == 2){
        return CGSizeMake(30, 30);
    }
    return CGSizeMake(62, 62);
}

- (NSString *)imageName:(NSInteger)index {
    if(index == 1){
        return @"camera_play";
    }else if (index == 2) {
        return @"door_list_right_narrow";
    }
    return @"";
}

- (NSString *)menuMessage:(NSInteger)index {
    if(index == 0){
        return _stateStr;
    }else {
        return @"";
    }
}

- (UIColor *)menuMessageColor:(NSInteger)index {
    if(index == 0){
        return _stateColor;
    }
    return [UIColor blackColor];
}

- (void)didSelectMenu:(NSInteger)index {
    switch (index) {
        case 1:
        {
            // 播放视频
            if(_playMonitorDelegate && [_playMonitorDelegate respondsToSelector:@selector(playMonitorDelegate:)]){
                [_playMonitorDelegate playMonitorDelegate:_subDeviceModel];
            }
            break;
        }
            
        case 2:
        {
            // 播放视频回放
            if(_playMonitorDelegate && [_playMonitorDelegate respondsToSelector:@selector(playBackMonitorDelegate:)]){
                [_playMonitorDelegate playBackMonitorDelegate:_subDeviceModel];
            }
            break;
        }
            
    }
}

@end
