//
//  IllegalMangeViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/8.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "IllegalMangeViewController.h"
#import "YQTabbar.h"
#import "RootNavigationController.h"
#import "UITabBar+CustomBadge.h"

#import "IllegalPhotoViewController.h"
#import "IllegalListViewController.h"

@interface IllegalMangeViewController ()<UITabBarControllerDelegate>
{
    UIButton *_commitBt;
}
@property (nonatomic, assign) UIStatusBarStyle StatusBarStyle;
@end

@implementation IllegalMangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;

    self.StatusBarStyle = UIStatusBarStyleLightContent;
    
    //初始化tabbar
    [self setUpTabBar];
    //添加子控制器
    [self setUpAllChildViewController];
    
    [self _initNavItems];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return _StatusBarStyle;
}

//动态更新状态栏颜色
-(void)setStatusBarStyle:(UIStatusBarStyle)StatusBarStyle{
    _StatusBarStyle=StatusBarStyle;
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void)_initNavItems
{
    self.title = @"违停拍照";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _commitBt = [UIButton buttonWithType:UIButtonTypeCustom];
    _commitBt.frame = CGRectMake(0, 0, 60, 35);
    [_commitBt setTitle:@"提交" forState:UIControlStateNormal];
    [_commitBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_commitBt addTarget:self action:@selector(commitBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_commitBt];
}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)commitBtnClick {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IllegalCommit" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark ————— 初始化TabBar —————
-(void)setUpTabBar{
    //设置背景色 去掉分割线
    [self setValue:[YQTabbar new] forKey:@"tabBar"];
    [self.tabBar setBackgroundColor:YQTabbarColor];
    [self.tabBar setBackgroundImage:[UIImage new]];
}

#pragma mark - ——————— 初始化VC ————————
-(void)setUpAllChildViewController{
    NSMutableArray *vcs = @[].mutableCopy;
    IllegalPhotoViewController *homeVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"IllegalPhotoViewController"];
    [self setupChildViewController:homeVC title:@"违停拍照" imageName:@"_park_illigal_nav_shooting_normal_icon" seleceImageName:@"park_illigal_nav_shooting_select_icon"];
    [vcs addObject:[[RootNavigationController alloc] initWithRootViewController:homeVC]];
//    [vcs addObject:homeVC];
    
    IllegalListViewController *msgVC = [[IllegalListViewController alloc] init];
    [self setupChildViewController:msgVC title:@"违停记录" imageName:@"park_illigal_nav_list_normal_icon" seleceImageName:@"_park_illigal_nav_list_select_icon"];
    [vcs addObject:[[RootNavigationController alloc] initWithRootViewController:msgVC]];
//    [vcs addObject:msgVC];
    
    self.viewControllers = vcs;
}

-(void)setupChildViewController:(UIViewController*)controller title:(NSString *)title imageName:(NSString *)imageName seleceImageName:(NSString *)selectImageName{
    controller.title = title;
    controller.tabBarItem.title = title;//跟上面一样效果
    controller.tabBarItem.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    controller.tabBarItem.selectedImage = [[UIImage imageNamed:selectImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //未选中字体颜色
    [controller.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:KBlackColor,NSFontAttributeName:SYSTEMFONT(10.0f)} forState:UIControlStateNormal];
    
    //选中字体颜色
    [controller.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:CNavBgColor,NSFontAttributeName:SYSTEMFONT(10.0f)} forState:UIControlStateSelected];
    
}

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    if(self.selectedIndex == 0){
        self.title = @"违停拍照";
        _commitBt.hidden = NO;
    }else if(self.selectedIndex == 1){
        self.title = @"违停记录";
        _commitBt.hidden = YES;
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [super setSelectedIndex:selectedIndex];
    
    if(selectedIndex == 1){
        _commitBt.hidden = YES;
    }
}

-(void)setRedDotWithIndex:(NSInteger)index isShow:(BOOL)isShow{
    if (isShow) {
        [self.tabBar setBadgeStyle:kCustomBadgeStyleRedDot value:0 atIndex:index];
    }else{
        [self.tabBar setBadgeStyle:kCustomBadgeStyleNone value:0 atIndex:index];
    }
}

- (BOOL)shouldAutorotate {
    return [self.selectedViewController shouldAutorotate];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return [self.selectedViewController supportedInterfaceOrientations];
}

@end
