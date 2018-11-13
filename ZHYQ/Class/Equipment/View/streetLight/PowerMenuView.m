//
//  PowerMenuView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "PowerMenuView.h"
#import "ShowMenuView.h"

@interface PowerMenuView()<MenuControlDelegate>
{
    ShowMenuView *_showMenuView;
    
    NSString *_menuTitle;   // 菜单标题
    NSString *_stateStr;    // 设备状态
    UIColor *_stateColor;   // 设备状态颜色
    NSString *_powerStr;   // 已耗电量
}
@end

@implementation PowerMenuView

- (instancetype)init {
    self = [super init];
    if(self){
        [self _initView];
    }
    return self;
}

- (void)_initView {
    
    _menuTitle = @"充电桩";
    _stateStr= @"正常开启中";
    _powerStr= @"7kw";
    _stateColor = [UIColor colorWithHexString:@"#189517"];
    
    // 创建点击菜单视图
    _showMenuView = [[ShowMenuView alloc] init];
    _showMenuView.hidden = YES;
    _showMenuView.menuDelegate = self;
    [[UIApplication sharedApplication].delegate.window addSubview:_showMenuView];
}

- (void)showMenu {
    _showMenuView.hidden = NO;
    [_showMenuView reloadMenuData];
}
- (void)hidMenu {
    _showMenuView.hidden = YES;
}

#pragma mark MenuControlDelegate
- (CGFloat)menuHeightInView:(NSInteger)index {
    return 40;
}

- (NSInteger)menuNumInView {
    return 2;
}

- (NSString *)menuTitle:(NSInteger)index {
    if(index == 0){
        return @"使用状态";
    }else {
        return @"已耗电量";
    }
}

- (NSString *)menuTitleViewText {
    return _menuTitle;
}

- (ShowMenuStyle)menuViewStyle:(NSInteger)index {
    return DefaultConMenu;
}

- (NSString *)menuMessage:(NSInteger)index {
    if(index == 0){
        return  _stateStr;
    }else {
        return _powerStr;
    }
}

- (UIColor *)menuMessageColor:(NSInteger)index {
    if(index == 0){
        return _stateColor;
    }else {
        return [UIColor blackColor];
    }
}


@end
