//
//  WorkListCenViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/19.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WorkListCenViewController.h"
#import "WorkListViewController.h"

#import "RepairProgressView.h"

#import "RepairProgressView.h"
#import "RejectBillView.h"

#import "BillListModel.h"

#define topMenuCount 4

@interface WorkListCenViewController ()<WorkListMethodDelegate,RejectWindowChooseDelegate>
{
    RepairProgressView *_progressView;
    RejectBillView *_rejectBillView;
}
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@end

@implementation WorkListCenViewController

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
    
    self.title = @"维修工单";
    
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
    
    // 处理进度弹层
    _progressView = [[RepairProgressView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight)];
    [self.view addSubview:_progressView];
    
    // 退回工单弹窗
    _rejectBillView = [[RejectBillView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight)];
    _rejectBillView.chooseDelegate = self;
    [self.view addSubview:_rejectBillView];
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
            return [self workListVC:WorkAll];
            break;
        }
        case 1:
        {
            return [self workListVC:WorkRepairsIng];
            break;
        }case 2:
        {
            return [self workListVC:WorkWaitConfirm];
            break;
        }case 3:
        {
            return [self workListVC:WorkClose];
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
            return @"处理中";
            break;
            
        case 2:
            return @"待确认";
            break;
            
        case 3:
            return @"已结束";
            break;
            
        default:
            return @"";
            break;
    }
}

- (WorkListViewController *)workListVC:(WorkListType)workListType {
    WorkListViewController *workVC = [[WorkListViewController alloc] init];
    workVC.workListType = workListType;
    workVC.workDelegate = self;
    return workVC;
}

#pragma mark WorkListMethodDelegate
- (void)progressQuery:(BillListModel *)billListModel {
    [_progressView showProgress:billListModel.orderId];
}

- (void)rejectBill:(BillListModel *)billListModel {
    [_rejectBillView showRejectView:billListModel.orderId];
}

#pragma mark RejectWindowChooseDelegate退回工单协议
- (void)cancel {
    
}
- (void)confirmReject:(NSString *)orderId withRemark:(NSString *)remark {
    // 确认退回
    NSString *urlStr = [NSString stringWithFormat:@"%@/deviceAlarm/rejectOrderByRepairman", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:orderId forKey:@"orderId"];
    [paramDic setObject:remark forKey:@"remark"];
    
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            [_rejectBillView hidRejectView];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RejectRepairsSuccess" object:nil userInfo:@{@"orderId":orderId}];
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
