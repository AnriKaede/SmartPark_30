//
//  MealCenViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/5.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "MealCenViewController.h"
#import "MealNumViewController.h"

#define topMenuCount 4

@interface MealCenViewController ()

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@end

@implementation MealCenViewController
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
    
    self.titleSizeNormal = 17;  // 未选中字体大小
    self.titleSizeSelected = 17;    // 选中字体大小
    
    self.menuBGColor = [UIColor whiteColor];
    self.menuViewStyle = WMMenuViewStyleLine;   // 下方进度模式
    //    self.progressWidth = KScreenWidth/2 + 40;    // 下方进度条宽度
    self.progressWidth = KScreenWidth/topMenuCount;    // 下方进度条宽度
    self.progressHeight = 5;    // 下方进度条高度
    self.menuItemWidth = KScreenWidth/topMenuCount;
    self.menuViewBottomSpace = 0.5;
    
    self.viewFrame = CGRectMake(0, 150, KScreenWidth, KScreenHeight - kTopHeight - 150);
    
    [self _loadView];
}

- (void)_loadView {
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
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 150)];
    imgView.image = [UIImage imageNamed:@"get_meal_top"];
    [self.view addSubview:imgView];
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"取餐叫号";
}

#pragma mark WMPageController 协议
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return topMenuCount;
}

- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            return [self mealVCWithIndex:index];
            break;
        }
        case 1:
        {
            return [self mealVCWithIndex:index];
            break;
        }
        case 2:
        {
            return [self mealVCWithIndex:index];
            break;
        }
        case 3:
        {
            return [self mealVCWithIndex:index];
            break;
        }
    }
    return [UIViewController new];
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
            return @"1-16号";
            break;
            
        case 1:
            return @"17-32号";
            break;
            
        case 2:
            return @"33-48号";
            break;
            
        case 3:
            return @"49-50号";
            break;
            
        default:
            return @"";
            break;
    }
}

- (MealNumViewController *)mealVCWithIndex:(NSInteger)index {
    MealNumViewController *mealVC = [[MealNumViewController alloc] init];
    mealVC.index = index;
    return mealVC;
}

@end
