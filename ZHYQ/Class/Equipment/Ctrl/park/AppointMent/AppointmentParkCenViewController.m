//
//  AppointmentParkCenViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/6/7.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "AppointmentParkCenViewController.h"
#import "AppointMentParkViewController.h"
#import "DCSildeBarView.h"
#import "AptFilterView.h"
#import "AptCancelView.h"

#import "AptListModel.h"

#define topMenuCount 4

@interface AppointmentParkCenViewController ()<ManagerCancelAptDelegate, WindowChooseDelegate>
{
    UIButton *_rightBtn;
    UIButton *_filterButton;
    AptFilterView *_filterView;
    AptCancelView *_aptCancelView;
    
    AptListModel *_aptListModel;
}
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@end

@implementation AppointmentParkCenViewController

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
    self.menuViewLayoutMode = WMMenuViewLayoutModeLeft;
    //    self.progressWidth = KScreenWidth/2 + 40;    // 下方进度条宽度
    self.progressWidth = KScreenWidth/(topMenuCount + 1);    // 下方进度条宽度
    self.progressHeight = 5;    // 下方进度条高度
    self.menuItemWidth = KScreenWidth/(topMenuCount + 1);
    self.menuViewBottomSpace = 0.5;
    
    // 筛选视图
    _filterView = [[AptFilterView alloc] initWithFrame:CGRectMake(0, 65, KScreenWidth, KScreenHeight - 64 - 65)];
    _filterView.hidden = YES;
    [self.view addSubview:_filterView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"预约管理";
    
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
        hLineView.frame = CGRectMake(KScreenWidth/(topMenuCount + 1) * i, 15, 0.5, 32);
        [self.menuView addSubview:hLineView];
    }
    
    _filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _filterButton.frame = CGRectMake(KScreenWidth - 75, 14, 66, 33);
    [_filterButton setTitle:@"筛选" forState:UIControlStateNormal];
    [_filterButton setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
    [_filterButton setImage:[UIImage imageNamed:@"apt_filter_right"] forState:UIControlStateNormal];
    // button标题的偏移量
    _filterButton.titleEdgeInsets = UIEdgeInsetsMake(0, -_filterButton.imageView.bounds.size.width+2, 0, _filterButton.imageView.bounds.size.width);
    // button图片的偏移量
    _filterButton.imageEdgeInsets = UIEdgeInsetsMake(0, _filterButton.titleLabel.bounds.size.width + 4, 0, -_filterButton.titleLabel.bounds.size.width);
    
    [_filterButton addTarget:self action:@selector(filterAction) forControlEvents:UIControlEventTouchUpInside];
    [self.menuView addSubview:_filterButton];
    _filterButton.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    _filterButton.layer.borderWidth = 0.8;
    _filterButton.layer.cornerRadius = 8;
    
    _rightBtn = [[UIButton alloc] init];
    _rightBtn.frame = CGRectMake(0, 0, 40, 40);
    _rightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [_rightBtn setTitle:@"批量取消" forState:UIControlStateNormal];
    [_rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_rightBtn addTarget:self action:@selector(_rightBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBarBt = [[UIBarButtonItem alloc] initWithCustomView:_rightBtn];
    self.navigationItem.rightBarButtonItem = rightBarBt;
    
    // 重置、确定筛选通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetData) name:@"AppointMentParkResSet" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterDataDic:) name:@"AppointMentParkFilter" object:nil];
    
    // 确认取消弹窗
    _aptCancelView = [[AptCancelView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight)];
    _aptCancelView.chooseDelegate = self;
    [self.view addSubview:_aptCancelView];
}
#pragma mark 批量取消预约按钮
- (void)_rightBarBtnItemClick {
    //    [DCSildeBarView dc_showSildBarViewController:AppointMentParkFilter];
    
    _rightBtn.selected = !_rightBtn.selected;
    if(_rightBtn.selected){
        self.selectIndex = 1;
        
        [_rightBtn setTitle:@"取消" forState:UIControlStateNormal];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BatchCancelApt" object:nil];
    }else {
        [_rightBtn setTitle:@"批量取消" forState:UIControlStateNormal];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BatchCancelAptCancel" object:nil];
    }
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 筛选按钮点击
- (void)filterAction {
    [self.view endEditing:YES];
    _filterButton.selected = !_filterButton.selected;
    if(_filterButton.selected){
        _filterButton.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
        [_filterButton setImage:[UIImage imageNamed:@"apt_filter_right_up"] forState:UIControlStateNormal];
        [_filterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        _filterView.hidden = NO;
    }else {
        _filterButton.backgroundColor = [UIColor whiteColor];
        [_filterButton setImage:[UIImage imageNamed:@"apt_filter_right"] forState:UIControlStateNormal];
        [_filterButton setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
        
        _filterView.hidden = YES;
    }
}

#pragma mark WMPageController 协议
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return topMenuCount ;
}

- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            return [self appointMentParkVC:AppointMentParkAll];
            break;
        }
        case 1:
        {
            return [self appointMentParkVC:AppointMentParkIng];
            break;
        }case 2:
        {
            return [self appointMentParkVC:AppointMentParkComplete];
            break;
        }case 3:
        {
            return [self appointMentParkVC:AppointMentParkCancel];
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
            return @"预约中";
            break;
            
        case 2:
            return @"已完成";
            break;
            
        case 3:
            return @"已取消";
            break;
            
        default:
            return @"";
            break;
    }
}

- (AppointMentParkViewController *)appointMentParkVC:(AppointMentParkStyle)appointMentParkStyle {
    AppointMentParkViewController *appointMentParkVC = [[AppointMentParkViewController alloc] init];
    appointMentParkVC.appointMentParkStyle = appointMentParkStyle;
    appointMentParkVC.managerCancelAptDelegate = self;
    return appointMentParkVC;
}

#pragma mark 重置数据
- (void)resetData {
    _filterView.hidden = YES;
    
   [self recoverFilterBt];
}

#pragma mark 筛选通知
- (void)filterDataDic:(NSNotification *)notifacation {
    _filterView.hidden = YES;
    
    [self recoverFilterBt];
}
- (void)recoverFilterBt {
    _filterButton.selected = NO;
    
    _filterButton.backgroundColor = [UIColor whiteColor];
    [_filterButton setImage:[UIImage imageNamed:@"apt_filter_right"] forState:UIControlStateNormal];
    [_filterButton setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
}

#pragma mark 取消预约协议
- (void)cancelApt:(AptListModel *)aptListModel {
    [_aptCancelView showWindow:aptListModel.orderModel.parkingSpaceId];
    _aptListModel = aptListModel;
}

#pragma mark 取消预约弹窗确认协议
- (void)confirmComplete:(NSString *)orderId withRemark:(NSString *)remark {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/forceCancelOrder", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:orderId forKey:@"parkingSpaceId"];
    [paramDic setObject:remark forKey:@"remark"];
    
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            // 发送通知 刷新tableView 全部和预约中
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CancelAptSucess" object:nil];
            
            // 记录日志
            NSString *OperateName = [NSString stringWithFormat:@"取消 %@ 预约 %@", _aptListModel.orderModel.carNo, _aptListModel.orderModel.parkingSpaceName];;
            [self logRecordTagId:_aptListModel.orderModel.parkingSpaceId withOperateName:OperateName withOperateDes:OperateName withUrl:@"/parking/forceCancelOrder"];
        }
        NSString *message = responseObject[@"message"];
        if(message != nil && ![message isKindOfClass:[NSNull class]]) {
            [self showHint:message];
        }
    }failure:^(NSError *error) {
        
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AppointMentParkResSet" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AppointMentParkFilter" object:nil];
}

#pragma mark 记录日志
- (void)logRecordTagId:(NSString *)tagId withOperateName:(NSString *)operateName withOperateDes:(NSString *)operateDes withUrl:(NSString *)operateUrl {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:[NSString stringWithFormat:@"%@", operateName] forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:[NSString stringWithFormat:@"%@", operateDes] forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:operateUrl forKey:@"operateUrl"];//操作url
    //    [logDic setObject:@"" forKey:@"operateLocation"];//操作地点
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:tagId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"预约管理" forKey:@"operateDeviceName"];//操作设备名  模块
    //    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

@end
