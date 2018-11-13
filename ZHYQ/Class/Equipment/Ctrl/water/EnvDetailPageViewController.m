//
//  EnvDetailPageViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/2/28.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "EnvDetailPageViewController.h"
#import "EnvDetDataViewController.h"
#import "EnvDetLineViewController.h"

@interface EnvDetailPageViewController ()
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@end

@implementation EnvDetailPageViewController

//动态更新状态栏颜色
- (UIStatusBarStyle)preferredStatusBarStyle{
    return _statusBarStyle;
}
-(void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle{
    _statusBarStyle = statusBarStyle;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (instancetype)init {
    self = [super init];
    if(self){
        [self _initView];
    }
    return self;
}
- (void)_initView {
    self.menuHeight = 60;   // page导航栏高度
    
    self.titleColorSelected = [UIColor colorWithHexString:@"#1B82D1"];    // 标题选中颜色
    
    self.titleSizeNormal = 15;  // 未选中字体大小
    self.titleSizeSelected = 15;    // 选中字体大小
    
    self.menuBGColor = [UIColor whiteColor];
    self.menuViewStyle = WMMenuViewStyleLine;   // 下方进度模式
    //    self.progressWidth = KScreenWidth/2 + 40;    // 下方进度条宽度
    self.progressWidth = KScreenWidth/2;    // 下方进度条宽度
    self.progressHeight = 5;    // 下方进度条高度
    self.menuItemWidth = KScreenWidth/2;
    self.menuViewBottomSpace = 0.5;
    
    //    self.delegate = self;
    //    self.dataSource = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _evnDataModel.device_name;
    
    self.statusBarStyle = UIStatusBarStyleLightContent;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.menuHeight, KScreenWidth, 0.5)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#E2E2E2"];
    [self.menuView addSubview:lineView];
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    for (int i=1; i<2; i++) {
        UIImageView *hLineView = [[UIImageView alloc] init];
        hLineView.image = [UIImage imageNamed:@"LED_seperateline_blue"];
        hLineView.frame = CGRectMake(KScreenWidth/2 * i, 15, 0.5, 32);
        [self.menuView addSubview:hLineView];
    }
    
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark WMPageController 协议
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return 2;
}

- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    if(index == 0){
        EnvDetDataViewController *envDelVC = [[EnvDetDataViewController alloc] init];
        envDelVC.evnDataModel = _evnDataModel;
        return envDelVC;
    }else {
        EnvDetLineViewController *lineVC = [[EnvDetLineViewController alloc] init];
        lineVC.evnDataModel = _evnDataModel;
        return lineVC;
    }
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    if(index == 0){
        return @"数据";
    }else {
        return @"曲线";
    }
}

@end
