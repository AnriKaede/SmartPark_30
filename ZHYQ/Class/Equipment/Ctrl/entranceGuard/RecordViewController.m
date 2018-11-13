//
//  RecordViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/21.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "RecordViewController.h"
#import "OpenRecordViewController.h"
#import "RemoteOpenViewController.h"
#import "SearchRecordViewController.h"

@interface RecordViewController ()

@property (nonatomic, strong) NSArray *titleData;
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

@end

@implementation RecordViewController

//动态更新状态栏颜色
- (UIStatusBarStyle)preferredStatusBarStyle{
    return _statusBarStyle;
}
-(void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle{
    _statusBarStyle = statusBarStyle;
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark 标题数组
- (NSArray *)titleData {
    if (!_titleData) {
        _titleData = @[@"员工卡开门", @"远程开门"];
    }
    return _titleData;
}

#pragma mark 初始化代码
- (instancetype)init {
    if (self = [super init]) {
        self.titleSizeNormal = 15;
        self.titleSizeSelected = 15;
        self.titleColorSelected = [UIColor colorWithHexString:@"#1B82D1"];
        self.menuViewStyle = WMMenuViewStyleLine;
        self.menuItemWidth = [UIScreen mainScreen].bounds.size.width / self.titleData.count;
        self.menuHeight = 60;
        self.menuViewBottomSpace = 0;
        self.progressHeight = 5;
        self.progressColor = [UIColor colorWithHexString:@"#1B82D1"];
    }
    return self;
}

#pragma mark - Datasource & Delegate

#pragma mark 返回子页面的个数
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.titleData.count;
}

#pragma mark 返回某个index对应的页面
- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    switch (index) {
        case 0:{
            OpenRecordViewController *cardVC = [[OpenRecordViewController alloc] init];
            cardVC.title = @"一卡通开门";
            cardVC.deivedID = _tagID;
            return cardVC;
            
        }
            break;
            
        default:
        {
            RemoteOpenViewController *remoteVC = [[RemoteOpenViewController alloc] init];
            remoteVC.title = @"远程开门";
            remoteVC.deivedID = _deivedID;
            return remoteVC;
        }
            break;
    }
}

#pragma mark 返回index对应的标题
- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    
    return self.titleData[index];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initNavItems];
    
    [self _initView];
    
    self.statusBarStyle = UIStatusBarStyleLightContent;
}

-(void)_initNavItems
{
    self.view.backgroundColor = [UIColor colorWithHexString:@"#E2E2E2"];
    
    self.title = [NSString stringWithFormat:@"%@开门记录", _doorName];
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(navSearch)];
    
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)_initView
{
    for (int i=1; i<2; i++) {
        UIImageView *hLineView = [[UIImageView alloc] init];
        hLineView.image = [UIImage imageNamed:@"LED_seperateline_blue"];
        hLineView.frame = CGRectMake(KScreenWidth/2 * i, 15, 0.5, 32);
        [self.menuView addSubview:hLineView];
    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.menuHeight, KScreenWidth, 0.5)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#E2E2E2"];
    [self.menuView addSubview:lineView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)navSearch {
    SearchRecordViewController *searchVC = [[SearchRecordViewController alloc] init];
    if([self.currentViewController isKindOfClass:[OpenRecordViewController class]]){
        // 一卡通开门查询
        searchVC.openType = Ecard;
        searchVC.tagID = _tagID;
    }else {
        // 远程开门查询
        searchVC.openType = RemoteOpen;
        searchVC.deivedID = _deivedID;
    }
    [self.navigationController pushViewController:searchVC animated:YES];
}
@end
