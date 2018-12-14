//
//  MeetPageViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/19.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "MeetPageViewController.h"
#import "MeetWebViewController.h"
#import "SingleControlViewController.h"
#import "MeetRoomViewController.h"

@interface MeetPageViewController ()
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@end

@implementation MeetPageViewController

//动态更新状态栏颜色
- (UIStatusBarStyle)preferredStatusBarStyle{
    return _statusBarStyle;
}
-(void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle{
    _statusBarStyle = statusBarStyle;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (instancetype)initWithModel:(MeetRoomGroupModel *)model {
    _model = model;
//    self = [super initWithViewControllerClasses:@[[MeetWebViewController class], [SingleControlViewController class], [MeetRoomViewController class]] andTheirTitles:@[@"720度全景", @"单独控制", @"场景模式"]];
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
    if([_model.ROOM_ID isEqualToString:@"109"]){
        self.progressWidth = KScreenWidth/3;    // 下方进度条宽度
        self.menuItemWidth = KScreenWidth/3;
    }else {
        self.progressWidth = KScreenWidth/2;    // 下方进度条宽度
        self.menuItemWidth = KScreenWidth/2;
    }
    self.progressHeight = 5;    // 下方进度条高度
    self.menuViewBottomSpace = 0.5;
    
    self.scrollEnable = NO;
    
//    self.delegate = self;
//    self.dataSource = self;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //隐藏返回按钮
    self.navigationItem.hidesBackButton = YES;
    //禁止页面左侧滑动返回，注意，如果仅仅需要禁止此单个页面返回，还需要在viewWillDisapper下开放侧滑权限
    // 禁用返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%@", _model.ROOM_NAME];
    
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
    
    int index = 2;
    if([_model.ROOM_ID isEqualToString:@"109"]){
        index = 3;
    }
    for (int i=1; i<index; i++) {
        UIImageView *hLineView = [[UIImageView alloc] init];
        hLineView.image = [UIImage imageNamed:@"LED_seperateline_blue"];
        hLineView.frame = CGRectMake(KScreenWidth/index * i, 15, 0.5, 32);
        [self.menuView addSubview:hLineView];
    }
    
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark WMPageController 协议
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    if([_model.ROOM_ID isEqualToString:@"109"]){
        return 3;
    }else {
        return 2;
    }
}

- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    if(index == 0){
        SingleControlViewController *singVC = [[SingleControlViewController alloc] init];
        singVC.model = _model;
        return singVC;
    }else if(index == 1){
        MeetRoomViewController *meetVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"MeetRoomViewController"];
        meetVC.model = _model;
        return meetVC;
    }else {
        MeetWebViewController *webVC = [[MeetWebViewController alloc] init];
        webVC.model = _model;
        return webVC;
    }
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    if(index == 0){
        return @"单独控制";
    }else if(index == 1){
        return @"场景模式";
    }else {
        return @"720度全景";
    }
}

@end
