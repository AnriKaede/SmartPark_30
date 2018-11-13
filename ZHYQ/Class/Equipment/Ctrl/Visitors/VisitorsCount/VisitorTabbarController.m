//
//  VisitorTabbarController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/17.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "VisitorTabbarController.h"
#import "InTimeVisitorViewController.h"
#import "VisitorCountViewController.h"

#import "YQTabbar.h"
#import "RootNavigationController.h"
#import "UITabBar+CustomBadge.h"

#import "VisotorListViewController.h"

@interface VisitorTabbarController ()<UITabBarControllerDelegate>
{
    UIButton *rightBtn;
}
@property (nonatomic, assign) UIStatusBarStyle StatusBarStyle;

@end

@implementation VisitorTabbarController

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
    self.title = @"今日访客";
    
    self.StatusBarStyle = UIStatusBarStyleLightContent;
    
    //未选中字体颜色
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#8e8e8e"],NSFontAttributeName:[UIFont systemFontOfSize:13]} forState:UIControlStateNormal];
    //选中字体颜色
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:CNavBgColor,NSFontAttributeName:[UIFont systemFontOfSize:13]} forState:UIControlStateSelected];
    self.delegate = self;
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    rightBtn = [[UIButton alloc] init];
    rightBtn.hidden = YES;
    rightBtn.frame = CGRectMake(0, 0, 40, 40);
    [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [rightBtn setImage:[UIImage imageNamed:@"_nav_visitorlist_icon"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)rightBtnClick {
    VisotorListViewController *visitorVC = [[VisotorListViewController alloc] init];
    [self.navigationController pushViewController:visitorVC animated:YES];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    return YES;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    // 此协议方法执行完成 self.selectedIndex才会改变，故取反
    if(self.selectedIndex == 1){
        rightBtn.hidden = YES;
        self.title = @"今日访客";
    }else if(self.selectedIndex == 0){
        rightBtn.hidden = NO;
        self.title = @"访客统计";
    }
}
@end
