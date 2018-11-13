//
//  ParkRecordCenViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/29.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "ParkRecordCenViewController.h"
#import "ParkRecordViewController.h"
#import "DCSildeBarView.h"
#import "VisFilterView.h"
#import "ParkRecordFilterView.h"

#define topMenuCount 3

@interface ParkRecordCenViewController ()<FilterTimeDelegate>
{
    UIButton *filtrateBtn;
    ParkRecordFilterView *_parkRecordFilterView;
}
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@end

@implementation ParkRecordCenViewController

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
    
    
    filtrateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [filtrateBtn addTarget:self action:@selector(filtrateBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [filtrateBtn setImage:[UIImage imageNamed:@"nav_filter_down"] forState:UIControlStateNormal];
    [filtrateBtn setImage:[UIImage imageNamed:@"apt_filter_right_up"] forState:UIControlStateSelected];
    [filtrateBtn setTitle:@"筛选" forState:UIControlStateNormal];
    // button标题的偏移量
    filtrateBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -24, 0, filtrateBtn.imageView.bounds.size.width);
    // button图片的偏移量
    filtrateBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 37, 0, -filtrateBtn.titleLabel.bounds.size.width);
    [filtrateBtn sizeToFit];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:filtrateBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}
#pragma mark 筛选按钮
- (void)filtrateBtnClick {
    filtrateBtn.selected = !filtrateBtn.selected;
//    [DCSildeBarView dc_showSildBarViewController:ParkRecordFilter];
    _parkRecordFilterView.hidden = !filtrateBtn.selected;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"停车记录";
    
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
    
    // 筛选视图
    _parkRecordFilterView = [[ParkRecordFilterView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    _parkRecordFilterView.filterTimeDelegate = self;
    [self.view addSubview:_parkRecordFilterView];
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
            return [self parkRecordVC:ParkAll];
            break;
        }
        case 1:
        {
            return [self parkRecordVC:ParkIn];
            break;
        }
        case 2:
        {
            return [self parkRecordVC:ParkOut];
            break;
        }
    }
    return [UIViewController new];
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
            return @"全部";
            break;
            
        case 1:
            return @"已入场";
            break;
            
        case 2:
            return @"已出场";
            break;
            
        default:
            return @"";
            break;
    }
}

- (ParkRecordViewController *)parkRecordVC:(ParkStyle)parkType {
    ParkRecordViewController *parkVC = [[ParkRecordViewController alloc] init];
    parkVC.parkStyle = parkType;
    parkVC.carNo = _carNo;
    return parkVC;
}

#pragma mark 筛选
- (void)closeFilter {
    filtrateBtn.selected = NO;
    _parkRecordFilterView.hidden = YES;
}
- (void)resetFilter {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ParkRecordResSet" object:nil];
    [self closeFilter];
}
- (void)filterWithStart:(NSString *)startTime withEndTime:(NSString *)endTime {
    NSString *startDate = [startTime stringByReplacingOccurrencesOfString:@"-" withString:@""];
    startDate = [startDate stringByReplacingOccurrencesOfString:@":" withString:@""];
    startDate = [startDate stringByReplacingOccurrencesOfString:@":" withString:@""];
    startDate = [startDate stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *endDate = [endTime stringByReplacingOccurrencesOfString:@"-" withString:@""];
    endDate = [endDate stringByReplacingOccurrencesOfString:@":" withString:@""];
    endDate = [endDate stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSDictionary *infoDic = @{@"startDate":startDate,
                              @"endDate":endDate
                              };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ParkRecordFilter" object:nil userInfo:infoDic];
    [self closeFilter];
}

@end
