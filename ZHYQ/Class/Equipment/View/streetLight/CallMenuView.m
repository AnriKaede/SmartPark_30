//
//  CallMenuView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "CallMenuView.h"
#import "ShowMenuView.h"

@interface CallMenuView()<MenuControlDelegate>
{
    ShowMenuView *_showMenuView;
    
    NSString *_menuTitle;   // 菜单标题
    NSString *_stateStr;    // 设备状态
    UIColor *_stateColor;   // 设备状态颜色
}
@end

@implementation CallMenuView

- (instancetype)init {
    self = [super init];
    if(self){
        [self _initView];
    }
    return self;
}

- (void)_initView {
    
    _menuTitle = @"一键呼叫";
    _stateStr= @"正常开启中";
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
    return 1;
}

- (NSString *)menuTitle:(NSInteger)index {
    return @"状态";
}

- (NSString *)menuTitleViewText {
    return _menuTitle;
}

- (ShowMenuStyle)menuViewStyle:(NSInteger)index {
    return DefaultConMenu;
}

- (NSString *)menuMessage:(NSInteger)index {
    return _stateStr;
}

- (UIColor *)menuMessageColor:(NSInteger)index {
    return _stateColor;
}

@end
