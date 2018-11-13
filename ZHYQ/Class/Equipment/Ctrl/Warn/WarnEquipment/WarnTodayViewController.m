//
//  WarnTodayViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/20.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "WarnTodayViewController.h"
#import "AAChartView.h"
#import "WarnCell.h"

#import "WarnCakeView.h"

#import "ReportWarnViewController.h"

#import "WarnUnDealViewController.h"
#import "WarnUnReportViewController.h"
#import "WarnRepairIngViewController.h"
#import "WarnCutView.h"

#import "WranConfirmView.h"

#import "AppointBillViewController.h"

#define HeaderHeight 270

@interface WarnTodayViewController ()<CutDelegate, UIScrollViewDelegate, ScrollStopDelegate, WarnConfirmDelegate, ConfirmWramWindowDelegate>
{
    UIView *_contentView;
    UIScrollView *_bgScrollView;
    
    WarnCakeView *_headWarnView;    // 头部视图
    WarnCutView *_warnCutView;  // 切换控制器顶部视图
    
    WarnUnDealViewController *_unDealVC;
    WarnUnReportViewController *_unReportVC;
    WarnRepairIngViewController *_repairingVC;
    
    CGFloat childHeight;    // 头部视图高度
    
    NSMutableArray *_viewControllers;
    
    NSInteger _currentIndex;
    
    WranConfirmView *_wranConfirmView;
}
@end

@implementation WarnTodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _currentIndex = 0;
    
    [self _initView];
    
    [self _loadData];
    
    // 监听故障新增通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadData) name:@"WranPostSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadData) name:@"ReReportSuccess" object:nil];
}

- (void)_initView {
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 50, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"report_ repairs"] style:UIBarButtonItemStylePlain target:self action:@selector(reportRepairs)];
    
    
    //-----------------------------------------------
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kTopHeight)];
    [self.view addSubview:_contentView];
    
    // 背景滑动视图
    _bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight)];
    _bgScrollView.delegate = self;
    _bgScrollView.pagingEnabled = YES;
    _bgScrollView.bounces = NO;
    _bgScrollView.showsVerticalScrollIndicator = NO;
    _bgScrollView.showsHorizontalScrollIndicator = NO;
    _bgScrollView.contentSize = CGSizeMake(kScreenWidth * 3, _contentView.height);
    _bgScrollView.backgroundColor = [UIColor whiteColor];
    [_contentView addSubview:_bgScrollView];
    
    // 头部饼状图
    _headWarnView = [[WarnCakeView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, HeaderHeight)];
//    _headWarnView.alpha = 0.3;
    _headWarnView.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    [_contentView addSubview:_headWarnView];    // KVO监听childViewControllers view contentoffset
    
    // 中间table切换视图
    _warnCutView = [[WarnCutView alloc] initWithFrame:CGRectMake(0, _headWarnView.bottom, KScreenWidth, 50) withTitleDatas:@[@"未处理", @"待派单", @"处理中"]];
//    _warnCutView.alpha = 0.3;
    _warnCutView.cutDelegate = self;
    [_contentView addSubview:_warnCutView];
    
    // 下方childView
    childHeight = HeaderHeight + 50;
    
    _unDealVC = [[WarnUnDealViewController alloc] initWithHeaderHeight:childHeight];
    _unDealVC.confirmWramWindowDelegate = self;
    _unReportVC = [[WarnUnReportViewController alloc] initWithHeaderHeight:childHeight];
    _repairingVC = [[WarnRepairIngViewController alloc] initWithHeaderHeight:childHeight];
    
    _viewControllers = @[_unDealVC, _unReportVC, _repairingVC].mutableCopy;
    [_viewControllers enumerateObjectsUsingBlock:^(WarnBaseViewController *warnVC, NSUInteger idx, BOOL * _Nonnull stop) {
        warnVC.view.frame = CGRectMake(KScreenWidth*idx, 0, KScreenWidth, KScreenHeight - 64);
        warnVC.scrollStopDelegate = self;
        [self addChildViewController:warnVC];
        [_bgScrollView addSubview:warnVC.view];
        
        [warnVC.warnTableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    }];
    
    // 添加确认故障弹窗
    _wranConfirmView = [[WranConfirmView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64)];
    _wranConfirmView.warnConfirmDelegate = self;
    [self.view addSubview:_wranConfirmView];
}

-(void)_leftBarBtnItemClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 加载数据
- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/deviceAlarm/reportStatus", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    NSString *companyId = [[NSUserDefaults standardUserDefaults] objectForKey:KAdminCompanyId];
    if(companyId != nil){
        [paramDic setObject:companyId forKey:@"companyId"];
    }
    
    NSString *paramStr = [Utils convertToJsonData:paramDic];
    NSDictionary *params = @{@"param":paramStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            NSArray *data = responseObject[@"responseData"][@"items"];
            
            /*
             未处理：0
             待派单：3
             维修中：1
             */
            __block CGFloat undealCount, unsendCount, repairsingCount = 0;
            
            [data enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
                if([dic[@"ALARM_STATE"] isEqualToString:@"0"]){
                    NSNumber *countNum = dic[@"STATE_COUNT"];
                    undealCount = countNum.floatValue;
                }else if([dic[@"ALARM_STATE"] isEqualToString:@"3"]){
                    NSNumber *countNum = dic[@"STATE_COUNT"];
                    unsendCount = countNum.floatValue;
                }else if([dic[@"ALARM_STATE"] isEqualToString:@"1"]){
                    NSNumber *countNum = dic[@"STATE_COUNT"];
                    repairsingCount = countNum.floatValue;
                }
            }];
            
            [_headWarnView warnEquipmentNum:undealCount withSafeNum:unsendCount withMaintainNum:repairsingCount];
        }
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark 故障报修
- (void)reportRepairs {
    ReportWarnViewController *reportVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"ReportWarnViewController"];
    [self.navigationController pushViewController:reportVC animated:YES];
}

#pragma mark 切换协议
- (void)cutIndex:(NSInteger)index {
    _currentIndex = index;
    [_bgScrollView setContentOffset:CGPointMake(KScreenWidth * index, 0) animated:YES];
}

#pragma mark UIScrollView协议
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if(scrollView.contentOffset.y >= _headWarnView.height){
//        scrollView.contentOffset = CGPointMake(0, _headWarnView.height);
//        
//    }else {
//
//    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self postDealNotification:scrollView.contentOffset.x];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate){
        [self postDealNotification:scrollView.contentOffset.x];
    }
}
- (void)postDealNotification:(CGFloat)bottomX {
    NSInteger index = bottomX/KScreenWidth;
    _currentIndex = index;
    [_warnCutView setSelIndex:index withAnimation:YES];
    
    /*
    if(bottomY < _headWarnView.height){
        // 滑到头部，发送通知 使所有的子tableView contentOffset.y置为0
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WarnTopShowHeader" object:nil];
        
        _unDealVC.warnTableView.scrollEnabled = NO;
        _unReportVC.warnTableView.scrollEnabled = NO;
        _repairingVC.warnTableView.scrollEnabled = NO;
    }else {
        
        _unDealVC.warnTableView.scrollEnabled = YES;
        _unReportVC.warnTableView.scrollEnabled = YES;
        _repairingVC.warnTableView.scrollEnabled = YES;
    }
     */
}

#pragma mark KVO监听tableView滑动contentoffset
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSNumber *old = change[@"old"];
    CGPoint oldScrollViewPoint = old.CGPointValue;

    CGRect headerFrame = _headWarnView.frame;
    headerFrame.origin.y = -oldScrollViewPoint.y;
    _headWarnView.frame = headerFrame;
    
    if(oldScrollViewPoint.y < HeaderHeight){
        CGRect cutFrame = _warnCutView.frame;
        cutFrame.origin.y = -oldScrollViewPoint.y  + HeaderHeight;
        _warnCutView.frame = cutFrame;
        
//        _unDealVC.warnTableView.contentOffset = CGPointMake(0, oldScrollViewPoint.y);
//        _unReportVC.warnTableView.contentOffset = CGPointMake(0, oldScrollViewPoint.y);
//        _repairingVC.warnTableView.contentOffset = CGPointMake(0, oldScrollViewPoint.y);
    }else {
        _warnCutView.frame = CGRectMake(0, 0, KScreenWidth, _warnCutView.height);
    }
    
}

- (void)dealloc {
    [self removeKVOObserver];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"WranPostSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ReReportSuccess" object:nil];
}

#pragma mark UITableView滑动停止协议
- (void)stopScroll:(CGFloat)endY {
    if(endY < HeaderHeight){
        [_viewControllers enumerateObjectsUsingBlock:^(WarnBaseViewController *warnVC, NSUInteger idx, BOOL * _Nonnull stop) {
            if(idx != _currentIndex){
                [warnVC.warnTableView removeObserver:self forKeyPath:@"contentOffset"];
                
                [warnVC.warnTableView setContentOffset:CGPointMake(0, endY) animated:NO];
                
                [warnVC.warnTableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
            }
        }];
    }else {
        [_viewControllers enumerateObjectsUsingBlock:^(WarnBaseViewController *warnVC, NSUInteger idx, BOOL * _Nonnull stop) {
            if(idx != _currentIndex && warnVC.warnTableView.contentOffset.y < HeaderHeight){
                [warnVC.warnTableView removeObserver:self forKeyPath:@"contentOffset"];
                
                [warnVC.warnTableView setContentOffset:CGPointMake(0, HeaderHeight) animated:NO];
                
                [warnVC.warnTableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
            }
        }];
    }
    
    
}

#pragma mark 清除KVO
- (void)removeKVOObserver {
    for (WarnBaseViewController *viewController in _viewControllers) {
        @try {
            [viewController.warnTableView removeObserver:self forKeyPath:@"contentOffset"];
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    }
}

#pragma mark 创建无故障视图
- (UIView *)createFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 50)];
    footerView.backgroundColor = [UIColor clearColor];
    
    UIImageView *normalImgView = [[UIImageView alloc] initWithFrame:CGRectMake((KScreenWidth - 237)/2, 28, 237, 129)];
    normalImgView.image = [UIImage imageNamed:@"alarm_nodata"];
    [footerView addSubview:normalImgView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, normalImgView.bottom + 21, KScreenWidth, 17)];
    titleLabel.text = @"园区设备运行一切正常";
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [footerView addSubview:titleLabel];
    
    UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, titleLabel.bottom + 17, KScreenWidth, 18)];
    subTitleLabel.text = @"无故障设备！";
    subTitleLabel.textColor = [UIColor blackColor];
    subTitleLabel.font = [UIFont systemFontOfSize:17];
    subTitleLabel.textAlignment = NSTextAlignmentCenter;
    [footerView addSubview:subTitleLabel];
    
    return footerView;
}

#pragma mark 未处理控制器显示确认故障window协议
- (void)showConfirm:(WranUndealModel *)wranUndealModel {
    [_wranConfirmView showConfirm:wranUndealModel];
}
- (void)hidConfirm {
    
}

#pragma mark warnConfirmDelegate
- (void)ingore:(WranUndealModel *)wranUndealModel {
    NSString *urlStr = [NSString stringWithFormat:@"%@/deviceAlarm/abandonAlarm", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:KAdminUserId];
    if(userId != nil){
        [paramDic setObject:userId forKey:@"userId"];
    }
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:KLoginUserName];
    if(userName != nil){
        [paramDic setObject:userName forKey:@"userName"];
    }
//    NSString *companyId = [[NSUserDefaults standardUserDefaults] objectForKey:KAdminCompanyId];
//    if(companyId != nil){
//        [paramDic setObject:companyId forKey:@"companyId"];
//    }
    [paramDic setObject:wranUndealModel.alarmId forKey:@"alarmId"];
    
    NSString *paramStr = [Utils convertToJsonData:paramDic];
    NSDictionary *params = @{@"param":paramStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            // 忽略成功刷新故障列表
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WranPostSuccess" object:nil];
        }
        
        NSString *message = responseObject[@"message"];
        if(message != nil && ![message isKindOfClass:[NSNull class]]){
            [self showHint:message];
        }
        
        [_wranConfirmView hidConfirm];
    } failure:^(NSError *error) {
        [self showHint:KRequestFailMsg];
    }];
}
// 根据故障派单
- (void)sendBill:(WranUndealModel *)wranUndealModel {
    [_wranConfirmView hidConfirm];
    
    AppointBillViewController *appointVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"AppointBillViewController"];
    appointVC.appointState = AppointSend;
    appointVC.wranUndealModel = wranUndealModel;
    [self.navigationController pushViewController:appointVC animated:YES];
}


@end
