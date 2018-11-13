//
//  StopParkMangerViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/9/28.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "StopParkMangerViewController.h"
#import "YQTabbar.h"
#import "RootNavigationController.h"

#import "ParkTop10ViewController.h"
#import "LongParkViewController.h"

@interface StopParkMangerViewController ()<UITabBarControllerDelegate>
@property (nonatomic, assign) UIStatusBarStyle StatusBarStyle;
@end

@implementation StopParkMangerViewController

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
    self.title = @"停车管理-久停TOP10";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
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
- (void)setUpAllChildViewController {
    NSArray *titles = @[@"停留TOP10", @"久停明细"];
    NSArray *norImgs = @[@"park_top10_tabbar_nor", @"long_park_tabbar_nor"];
    NSArray *selImgs = @[@"park_top10_tabbar_sel", @"long_park_tabbar_sel"];
    [self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self setupChildViewController:obj title:titles[idx] imageName:norImgs[idx] seleceImageName:selImgs[idx]];
    }];
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
        self.title = @"停车管理-停留TOP10";
    }else if(self.selectedIndex == 1){
        self.title = @"停车管理-久停明细";
    }
}

- (BOOL)shouldAutorotate {
    return [self.selectedViewController shouldAutorotate];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return [self.selectedViewController supportedInterfaceOrientations];
}
@end
