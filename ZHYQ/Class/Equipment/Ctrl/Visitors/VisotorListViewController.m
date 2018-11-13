//
//  VisotorListViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/18.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "VisotorListViewController.h"

#import "VisitedViewController.h"
#import "ReservedViewController.h"
#import "VisSearchViewController.h"

#import "DCSildeBarView.h"
#import "VisFilterView.h"
#import "ReservedFilterView.h"

@interface VisotorListViewController ()<FilterTimeDelegate,ReservedFilterDelegate>
{
    UIButton *filtrateBtn;
    VisFilterView *_visFilterView;
    ReservedFilterView *_reservedFilterView;
}
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

@end

@implementation VisotorListViewController

//动态更新状态栏颜色
- (UIStatusBarStyle)preferredStatusBarStyle{
    return _statusBarStyle;
}

-(void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle{
    _statusBarStyle = statusBarStyle;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (instancetype)init {
    self = [super initWithViewControllerClasses:@[[VisitedViewController class], [ReservedViewController class]] andTheirTitles:@[@"已到访", @"已预约"]];
    if(self){
        [self _initView];
    }
    return self;
}

- (void)_initView {
    self.menuHeight = 50;   // page导航栏高度
    
    self.titleColorSelected = [UIColor colorWithHexString:@"#1B82D1"];    // 标题选中颜色
    
    self.titleSizeNormal = 16;  // 未选中字体大小
    self.titleSizeSelected = 16;    // 选中字体大小
    
    self.menuBGColor = [UIColor whiteColor];
    self.menuViewStyle = WMMenuViewStyleLine;   // 下方进度模式
    //    self.progressWidth = KScreenWidth/2 + 40;    // 下方进度条宽度
    self.progressWidth = KScreenWidth/2;    // 下方进度条宽度
    self.menuItemWidth = KScreenWidth/2;
    self.progressHeight = 5;    // 下方进度条高度
    self.menuViewBottomSpace = 0.5;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.statusBarStyle = UIStatusBarStyleLightContent;
    
    if(self.title == nil || self.title.length <= 0){
        self.title = @"访客";
    }
    
    [self _createView];
    
}
- (void)_createView {
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
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn addTarget:self action:@selector(searchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [searchBtn setImage:[UIImage imageNamed:@"search_icon"] forState:UIControlStateNormal];
    [searchBtn sizeToFit];
    UIBarButtonItem *searchBtnItem = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    
    filtrateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [filtrateBtn addTarget:self action:@selector(filtrateBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [filtrateBtn setImage:[UIImage imageNamed:@"nav_filter_down"] forState:UIControlStateNormal];
    [filtrateBtn setImage:[UIImage imageNamed:@"apt_filter_right_up"] forState:UIControlStateSelected];
    [filtrateBtn setTitle:@"筛选" forState:UIControlStateNormal];
    // button标题的偏移量
    filtrateBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -24, 0, filtrateBtn.imageView.bounds.size.width);
    // button图片的偏移量
    filtrateBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 37, 0, -filtrateBtn.titleLabel.bounds.size.width);
    [filtrateBtn sizeToFit];
    UIBarButtonItem *filtrateBtnItem = [[UIBarButtonItem alloc] initWithCustomView:filtrateBtn];
    
    self.navigationItem.rightBarButtonItems  = @[filtrateBtnItem];
    
    for (int i=1; i<2; i++) {
        UIImageView *hLineView = [[UIImageView alloc] init];
        hLineView.image = [UIImage imageNamed:@"LED_seperateline_blue"];
        hLineView.frame = CGRectMake(KScreenWidth/2 * i, 15, 0.5, 32);
        [self.menuView addSubview:hLineView];
    }
    
    // 筛选视图
    _visFilterView = [[VisFilterView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    _visFilterView.filterTimeDelegate = self;
    [self.view addSubview:_visFilterView];
    [_visFilterView changeBeginTimeText:@"到访时间" withEndText:@"离开时间"];
    
    _reservedFilterView = [[ReservedFilterView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    _reservedFilterView.reservedFilterDelegate = self;
    [self.view addSubview:_reservedFilterView];
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchBtnClick:(id)sender {
    VisSearchViewController *visSearVC = [[VisSearchViewController alloc] init];
    [self.navigationController pushViewController:visSearVC animated:YES];
}

- (void)filtrateBtnClick:(id)sender
{
    filtrateBtn.selected = !filtrateBtn.selected;
//    [DCSildeBarView dc_showSildBarViewController:VersionFilter];
    if(self.selectIndex == 0){
        _visFilterView.hidden = !filtrateBtn.selected;
    }else {
        _reservedFilterView.hidden = !filtrateBtn.selected;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 筛选
- (void)closeFilter {
    filtrateBtn.selected = NO;
    _visFilterView.hidden = YES;
}
- (void)resetFilter {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VisitorResSet" object:nil];
    [self closeFilter];
}
- (void)filterWithStart:(NSString *)startTime withEndTime:(NSString *)endTime withVisName:(NSString *)visName{
    NSDictionary *infoDic = @{@"startTime":startTime,
                              @"endTime":endTime,
                              @"visitorName":visName
                              };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VisitorFilter" object:nil userInfo:infoDic];
    [self closeFilter];
}

#pragma mark 预约筛选
- (void)reservedCloseFilter {
    filtrateBtn.selected = NO;
    _reservedFilterView.hidden = YES;
    [self.view endEditing:YES];
}
- (void)reservedResetFilter {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReservedVisitorResSet" object:nil];
    [self reservedCloseFilter];
}
- (void)filterWithStart:(NSString *)startTime withEndTime:(NSString *)endTime withOperateMan:(NSString *)operateMan withOperateKey:(NSString *)operateKey {
    NSDictionary *infoDic = @{@"startTime":startTime,
                              @"endTime":endTime,
                              @"visitorName":operateMan,
                              @"carNo":operateKey
                              };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReservedVisitorFilter" object:nil userInfo:infoDic];
    [self reservedCloseFilter];
}

@end
