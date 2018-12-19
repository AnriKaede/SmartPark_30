//
//  HpDoorCenViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/17.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "HpDoorCenViewController.h"
#import "HpFaceViewController.h"
#import "HpCarViewController.h"
#import "HpMoreCenViewController.h"

#import "HpTopView.h"

#define topMenuCount 2

@interface HpDoorCenViewController ()

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

@end

@implementation HpDoorCenViewController
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
    self.menuHeight = 35;   // page导航栏高度
    
    self.titleColorSelected = [UIColor colorWithHexString:@"#1B82D1"];    // 标题选中颜色
    
    self.titleSizeNormal = 17;  // 未选中字体大小
    self.titleSizeSelected = 17;    // 选中字体大小
    
    self.menuBGColor = [UIColor colorWithHexString:@"#EFEFEF"];
    self.menuViewStyle = WMMenuViewStyleLine;   // 下方进度模式
    self.progressWidth = 70;    // 下方进度条宽度
    self.progressHeight = 3;    // 下方进度条高度
    self.menuItemWidth = KScreenWidth/topMenuCount;
    self.menuViewBottomSpace = 0.5;
    
    self.viewFrame = CGRectMake(0, 244*hScale, KScreenWidth, KScreenHeight - kTopHeight - 244*hScale);
    
    [self _loadView];
}

- (void)_loadView {
    self.statusBarStyle = UIStatusBarStyleLightContent;
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [self _createTopView];
    
    [self _createBottomMoreView];
}
- (void)_createTopView {
    HpTopView *topView = [[HpTopView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 240*hScale)];
    [self.view addSubview:topView];
}
- (void)_createBottomMoreView {
    UIImageView *moreImgView = [[UIImageView alloc] initWithFrame:CGRectMake(KScreenWidth - 22, KScreenHeight - kTopHeight - 27, 14, 14)];
    moreImgView.image = [UIImage imageNamed:@"list_right_narrow_blue"];
    [self.view addSubview:moreImgView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(moreImgView.left - 60, KScreenHeight - 35 - kTopHeight, 60, 35);
    [button setTitle:@"查看更多" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:button];
}
- (void)moreAction {
    HpMoreCenViewController *faceVC = [[HpMoreCenViewController alloc] init];
    faceVC.selectIndex = self.selectIndex;
    [self.navigationController pushViewController:faceVC animated:YES];
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"福门监控";
}

#pragma mark WMPageController 协议
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return topMenuCount;
}

- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            HpFaceViewController *faceVC = [[HpFaceViewController alloc] init];
            faceVC.isCount = YES;
            return faceVC;
            break;
        }
        case 1:
        {
            HpCarViewController *carVC = [[HpCarViewController alloc] init];
            carVC.isCount = YES;
            return carVC;
            break;
        }
    }
    return [UIViewController new];
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
            return @"人像记录";
            break;
            
        case 1:
            return @"车辆记录";
            break;
         
        default:
            return @"";
            break;
    }
}

@end
