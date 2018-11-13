//
//  MessageCenViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/29.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "MessageCenViewController.h"
#import "MessageViewController.h"
#import "DCSildeBarView.h"

#import "MsgFilterView.h"

#define topMenuCount 3

@interface MessageCenViewController ()<MsgFilterTimeDelegate>
{
    NSString *_loginOneTitle;
    NSString *_warnTwoTitle;
    NSString *_billThreeTitle;
    
    MsgFilterView *_msgFilterView;
    UIButton *filtrateBtn;
}
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@end

@implementation MessageCenViewController

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
- (void)fullMsgTitle {
    if(_loginUnreadNum > 0){
        if(_loginUnreadNum > 99){
            _loginOneTitle = [NSString stringWithFormat:@"异常登录(99+)"];
        }else {
            _loginOneTitle = [NSString stringWithFormat:@"异常登录(%d)", _loginUnreadNum];
        }
    }else {
        _loginOneTitle = [NSString stringWithFormat:@"异常登录"];
    }
    if(_warnUnreadNum > 0){
        if(_warnUnreadNum > 99){
            _warnTwoTitle = [NSString stringWithFormat:@"告警消息(99+)"];
        }else {
            _warnTwoTitle = [NSString stringWithFormat:@"告警消息(%d)", _warnUnreadNum];
        }
    }else {
        _warnTwoTitle = [NSString stringWithFormat:@"告警消息"];
    }
    if(_billUnreadNum > 0){
        if(_billUnreadNum > 99){
            _billThreeTitle = [NSString stringWithFormat:@"派单消息(99+)"];
        }else {
            _billThreeTitle = [NSString stringWithFormat:@"派单消息(%d)", _billUnreadNum];
        }
    }else {
        _billThreeTitle = [NSString stringWithFormat:@"派单消息"];
    }
    
    [self updateTitle:_loginOneTitle atIndex:0];
    [self updateTitle:_warnTwoTitle atIndex:1];
    [self updateTitle:_billThreeTitle atIndex:2];
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
    
    self.scrollEnable = NO;
    
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
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:filtrateBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}
#pragma mark 筛选按钮
- (void)filtrateBtnClick:(id)sender
{
    filtrateBtn.selected = !filtrateBtn.selected;
    //    [DCSildeBarView dc_showSildBarViewController:MessageFilter];
    _msgFilterView.hidden = !filtrateBtn.selected;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"消息";
    
    [self fullMsgTitle];
    
    [self _loadView];
    
    // 添加通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadViewMsgCount:) name:@"reloadViewMsgCount" object:nil];
}
- (void)reloadViewMsgCount:(NSNotification *)notification {
    NSDictionary *paramDic = notification.userInfo;
    NSNumber *loginUnreadNum = paramDic[@"LoginUnreadNum"];
    if(loginUnreadNum != nil){
        _loginUnreadNum = loginUnreadNum.intValue;
    }
    NSNumber *warnUnreadNum = paramDic[@"WarnUnreadNum"];
    if(warnUnreadNum != nil){
        _warnUnreadNum = warnUnreadNum.intValue;
    }
    NSNumber *billUnreadNum = paramDic[@"BillUnreadNum"];
    if(billUnreadNum != nil){
        _billUnreadNum = billUnreadNum.intValue;
    }
    
    [self fullMsgTitle];
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
    
    for (int i=1; i<topMenuCount; i++) {
        UIImageView *hLineView = [[UIImageView alloc] init];
        hLineView.image = [UIImage imageNamed:@"LED_seperateline_blue"];
        hLineView.frame = CGRectMake(KScreenWidth/topMenuCount * i, 15, 0.5, 32);
        [self.menuView addSubview:hLineView];
    }
    
    // 筛选视图
    _msgFilterView = [[MsgFilterView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    _msgFilterView.filterTimeDelegate = self;
    [self.view addSubview:_msgFilterView];
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
            return [self messageVC:LoginMessage];
            break;
        }
        case 1:
        {
            return [self messageVC:WranMessage];
            break;
        }case 2:
        {
            return [self messageVC:BillMessage];
            break;
        }
    }
    return [UIViewController new];
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
            return _loginOneTitle;
            break;
            
        case 1:
            return _warnTwoTitle;
            break;
            
        case 2:
            return _billThreeTitle;
            break;
            
        default:
            return @"";
            break;
    }
}

- (MessageViewController *)messageVC:(MessageType)messageType {
    MessageViewController *msgVC = [[MessageViewController alloc] init];
    msgVC.messageType = messageType;
    return msgVC;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadViewMsgCount" object:nil];
}

#pragma mark 筛选
- (void)closeFilter {
    filtrateBtn.selected = NO;
    _msgFilterView.hidden = YES;
}
- (void)resetFilter {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MessageResSet" object:nil];
    [self closeFilter];
}
- (void)filterWithStart:(NSString *)startTime withEndTime:(NSString *)endTime withState:(NSString *)msgState {
    NSMutableDictionary *infoDic = @{@"startDate":startTime,
                              @"endDate":endTime
                              }.mutableCopy;
    if(msgState != nil){
        [infoDic setObject:msgState forKey:@"UnReadMsg"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MessageFilter" object:nil userInfo:infoDic];
    [self closeFilter];
}

@end
