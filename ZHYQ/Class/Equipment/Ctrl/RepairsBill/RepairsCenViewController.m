//
//  RepairsCenViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/17.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "RepairsCenViewController.h"
#import "RepairsListViewController.h"
#import "AppointBillViewController.h"

#import "RepairProgressView.h"
#import "BillConfirmView.h"

#define topMenuCount 5

@interface RepairsCenViewController ()<RepairDelegate, WindowChooseDelegate>
{
    RepairProgressView *_progressView;
    BillConfirmView *_billConfirmView;
}
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@end

@implementation RepairsCenViewController

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
    
//    self.scrollEnable = NO;
    
    //    self.delegate = self;
    //    self.dataSource = self;
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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"repairs_bill"] style:UIBarButtonItemStylePlain target:self action:@selector(repairsBill)];
    
    for (int i=1; i<topMenuCount; i++) {
        UIImageView *hLineView = [[UIImageView alloc] init];
        hLineView.image = [UIImage imageNamed:@"LED_seperateline_blue"];
        hLineView.frame = CGRectMake(KScreenWidth/topMenuCount * i, 15, 0.5, 32);
        [self.menuView addSubview:hLineView];
    }
    
    // 处理进度弹层
    _progressView = [[RepairProgressView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight)];
    [self.view addSubview:_progressView];
    
    // 确认完成弹窗
    _billConfirmView = [[BillConfirmView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight)];
    _billConfirmView.chooseDelegate = self;
    [self.view addSubview:_billConfirmView];
    
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 维修派单
- (void)repairsBill {
    AppointBillViewController *appointVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"AppointBillViewController"];
    appointVC.appointState = AppointSend;
    [self.navigationController pushViewController:appointVC animated:YES];
}

#pragma mark WMPageController 协议
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return 5;
}

- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            return [self repairsListVC:RepairsAll];
            break;
        }
        case 1:
        {
            return [self repairsListVC:RepairsUnReceive];
            break;
        }case 2:
        {
            return [self repairsListVC:RepairsIng];
            break;
        }case 3:
        {
            return [self repairsListVC:RepairsComplete];
            break;
        }case 4:
        {
            return [self repairsListVC:RepairsClose];
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
            return @"待派单";
            break;
            
        case 2:
            return @"处理中";
            break;
            
        case 3:
            return @"已完成";
            break;
            
        case 4:
            return @"已结束";
            break;
            
        default:
            return @"";
            break;
    }
}

- (RepairsListViewController *)repairsListVC:(RepairsType)repairsType {
    RepairsListViewController *repairVC = [[RepairsListViewController alloc] init];
    repairVC.repairsType = repairsType;
    repairVC.repairDelegate = self;
    return repairVC;
}

#pragma mark 弹层协议
- (void)progressQuery:(BillListModel *)billListModel {
    [_progressView showProgress:billListModel.orderId];
}

- (void)billComplete:(BillListModel *)billListModel {
    [_billConfirmView showProgress:billListModel.orderId];
}

#pragma mark WindowChooseDelegate驳回/确认完成协议
- (void)reject:(NSString *)orderId withRemark:(NSString *)remark {
    // 驳回
    NSString *urlStr = [NSString stringWithFormat:@"%@/deviceAlarm/rejectOrderByAssignor", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:orderId forKey:@"orderId"];
    [paramDic setObject:remark forKey:@"remark"];
    
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            [_billConfirmView hidProgress];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RejectCompleteBillSuccess" object:nil userInfo:@{@"orderId":orderId}];
        }
        NSString *message = responseObject[@"message"];
        if(message != nil && ![message isKindOfClass:[NSNull class]]){
            [self showHint:message];
        }
    } failure:^(NSError *error) {
        [self showHint:KRequestFailMsg];
    }];
}
- (void)confirmComplete:(NSString *)orderId withRemark:(NSString *)remark {
    // 确认完成
    NSString *urlStr = [NSString stringWithFormat:@"%@/deviceAlarm/confirmOrder", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:orderId forKey:@"orderId"];
    [paramDic setObject:remark forKey:@"remark"];
    
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            // 确认完成 成功
            [_billConfirmView hidProgress];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BillCompleteConfirm" object:nil userInfo:@{@"orderId":orderId}];
        }
        NSString *message = responseObject[@"message"];
        if(message != nil && ![message isKindOfClass:[NSNull class]]){
            [self showHint:message];
        }
    } failure:^(NSError *error) {
        [self showHint:KRequestFailMsg];
    }];
}

@end
