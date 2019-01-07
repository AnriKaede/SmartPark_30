//
//  CheckHomeCenViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/7.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "CheckHomeCenViewController.h"
#import "CheckTaskHomeViewController.h"

#define topMenuCount 2

@interface CheckHomeCenViewController ()
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@end

@implementation CheckHomeCenViewController

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
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    for (int i=1; i<topMenuCount; i++) {
        UIImageView *hLineView = [[UIImageView alloc] init];
        hLineView.image = [UIImage imageNamed:@"LED_seperateline_blue"];
        hLineView.frame = CGRectMake(KScreenWidth/topMenuCount * i, 15, 0.5, 32);
        [self.menuView addSubview:hLineView];
    }
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark WMPageController 协议
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return topMenuCount;
}

- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            return [self taskListVC:UnActionTask];
            break;
        }
        case 1:
        {
            return [self taskListVC:CompleteTask];
            break;
        }
    }
    return [UIViewController new];
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
            return @"未执行任务";
            break;
            
        case 1:
            return @"待执行任务";
            break;
            
        default:
            return @"";
            break;
    }
}

- (CheckTaskHomeViewController *)taskListVC:(HomeCheckTaskType)taskType {
    CheckTaskHomeViewController *repairVC = [[CheckTaskHomeViewController alloc] init];
    repairVC.checkTaskType = taskType;
    return repairVC;
}

@end
