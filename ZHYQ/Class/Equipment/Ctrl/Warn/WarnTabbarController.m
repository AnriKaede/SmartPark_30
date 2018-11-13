//
//  WarnTabbarController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/20.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "WarnTabbarController.h"

@interface WarnTabbarController ()<UITabBarControllerDelegate>

@property (nonatomic, assign) UIStatusBarStyle StatusBarStyle;

@end

@implementation WarnTabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
};
- (UIStatusBarStyle)preferredStatusBarStyle{
    return _StatusBarStyle;
}

//动态更新状态栏颜色
-(void)setStatusBarStyle:(UIStatusBarStyle)StatusBarStyle{
    _StatusBarStyle=StatusBarStyle;
    [self setNeedsStatusBarAppearanceUpdate];
}
- (void)_initView {
//    self.title = @"设备故障";
    
    self.StatusBarStyle = UIStatusBarStyleLightContent;
    
    //未选中字体颜色
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#8e8e8e"],NSFontAttributeName:[UIFont systemFontOfSize:13]} forState:UIControlStateNormal];
    //选中字体颜色
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:CNavBgColor,NSFontAttributeName:[UIFont systemFontOfSize:13]} forState:UIControlStateSelected];
    self.delegate = self;
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 50, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    return YES;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    // 此协议方法执行完成 self.selectedIndex才会改变，故取反
    if(self.selectedIndex == 1){
        self.title = @"报警";
    }else if(self.selectedIndex == 0){
        self.title = @"报警";
    }
}

@end
