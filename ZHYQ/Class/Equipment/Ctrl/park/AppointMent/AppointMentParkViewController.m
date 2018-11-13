//
//  AppointMentParkViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/6/7.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "AppointMentParkViewController.h"
#import "AppointMentParkCell.h"
#import "AptListModel.h"
#import <CYLTableViewPlaceHolder.h>
#import "noDataView.h"
#import "AppointMentParkDetailViewController.h"
#import "AptingDetailViewController.h"
#import "AptSelAllView.h"

#import "CalculateHeight.h"

#import "UITabBar+CustomBadge.h"

@interface AppointMentParkViewController ()<UITableViewDelegate, UITableViewDataSource, CYLTableViewPlaceHolderDelegate, BatchAptDelegate, SpaceOpearteDelegate>
{
    UITableView *_aptTableView;
    
    NSMutableArray *_aptData;
    int _page;
    int _length;
    
    NoDataView *noDataView;
    
    NSMutableDictionary *_filterDic;
    
    NSString *_beginTime;
    NSString *_endTime;
    
    BOOL isApt; // 可选中取消数据标识，导航栏取消预约是否点击
    
    AptSelAllView *_aptSelAllView;
}
@end

@implementation AppointMentParkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _aptData = @[].mutableCopy;
    _page = 1;
    _length = 20;
    
    [self _initView];
    
    [_aptTableView.mj_header beginRefreshing];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetData) name:@"AppointMentParkResSet" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterDataDic:) name:@"AppointMentParkFilter" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batchCancel) name:@"BatchCancelApt" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelBatch) name:@"BatchCancelAptCancel" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(oprateRefresh) name:@"CancelAptSucess" object:nil];
}

- (void)_initView {
    
    _aptTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64 - 49) style:UITableViewStyleGrouped];
    _aptTableView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    _aptTableView.contentInset = UIEdgeInsetsMake(5, 0, 60, 0);
    _aptTableView.dataSource = self;
    _aptTableView.delegate = self;
    _aptTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _aptTableView.tableFooterView = [UIView new];
    [self.view addSubview:_aptTableView];
    
    // ios 11tableView闪动
    _aptTableView.estimatedRowHeight = 0;
    _aptTableView.estimatedSectionHeaderHeight = 0;
    _aptTableView.estimatedSectionFooterHeight = 0;
    
    [_aptTableView registerNib:[UINib nibWithNibName:@"AppointMentParkCell" bundle:nil] forCellReuseIdentifier:@"AppointMentParkCell"];
    
    _aptTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self _loadData];
    }];
    
    _aptTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self _loadData];
    }];
//    _aptTableView.mj_footer.automaticallyHidden = NO;
    _aptTableView.mj_footer.hidden = YES;
    
    // 无数据视图
    noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64-49)];
    noDataView.imgView.image = [UIImage imageNamed:@"no_message"];
    noDataView.label.text = @"暂时没有消息~";
    noDataView.label.textColor = [UIColor colorWithHexString:@"#1B82D1"];
    
    // 批量操作视图
    _aptSelAllView = [[AptSelAllView alloc] initWithFrame:CGRectMake(0, KScreenHeight - 64 - 60 - 60, KScreenWidth, 60)];
    _aptSelAllView.hidden = YES;
    _aptSelAllView.batchAptDelegate = self;
    [self.view addSubview:_aptSelAllView];
}

#pragma mark 重置数据
- (void)resetData {
    [_filterDic removeAllObjects];
    [_aptTableView.mj_header beginRefreshing];
    
}

#pragma mark 筛选通知
- (void)filterDataDic:(NSNotification *)notifacation {
    _page = 1;
    [_aptData removeAllObjects];
    
    [_aptTableView reloadData];
    
    _filterDic = notifacation.userInfo.mutableCopy;
    [_aptTableView.mj_header beginRefreshing];
    
}

#pragma mark 批量取消 选中
- (void)batchCancel {
    isApt = YES;
    [_aptTableView reloadData];
    
    _aptSelAllView.hidden = NO;
}

#pragma mark 批量取消 取消
- (void)cancelBatch {
    isApt = NO;
    [self updateModelSelect:NO];
    
    [_aptTableView reloadData];
    
    _aptSelAllView.hidden = YES;
}

#pragma mark 批量操作全选/点击取消协议
- (void)batchSelect:(BOOL)isSelect {
    // 改变model 中是否选择标识
    [self updateModelSelect:isSelect];
    
    [_aptTableView reloadData];
}
- (void)updateModelSelect:(BOOL)isSelect {
    [_aptData enumerateObjectsUsingBlock:^(AptListModel *aptListModel, NSUInteger idx, BOOL * _Nonnull stop) {
        aptListModel.isSelect = isSelect;
    }];
}
// 批量取消预约
- (void)batchClick {
    [self operationSpace:@"batchCancel"];
}

- (void)operationSpace:(NSString *)opreation {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/batchOperate", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    NSString *spaces = [self achieveSelSpaces];
    /*
    if(spaces == nil || spaces.length <= 0){
        [self showHint:@"暂无可取消预约"];
        [self cancelBatch];
        return;
    }
     */
    [paramDic setObject:spaces forKey:@"parkingSpaces"];
    [paramDic setObject:opreation forKey:@"batchOperate"];
    
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            // 发送操作成功通知, 刷新预约工单列表数据
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CancelAptSucess" object:nil];
            
            // 记录日志
            NSString *operateDes = [NSString stringWithFormat:@"批量取消预约车位：%@", [self achieveSelSpaceNames]];;
            [self logRecordTagId:[self achieveSelSpaces] withOperateName:@"批量取消预约车位" withOperateDes:operateDes withUrl:@"/parking/forceCancelOrder"];
            
            // 全部取消选中
            [self cancelBatch];
        }
        NSString *message = responseObject[@"message"];
        if(message != nil && ![message isKindOfClass:[NSNull class]]) {
            [self showHint:message];
        }
        
    }failure:^(NSError *error) {
        [self showHint:KRequestFailMsg];
    }];
}

- (NSString *)achieveSelSpaces {
    NSMutableString *parkingSpaces = @"".mutableCopy;
    [_aptData enumerateObjectsUsingBlock:^(AptListModel *aptListModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if(aptListModel.isSelect){
            [parkingSpaces appendFormat:@"%@,", aptListModel.orderModel.parkingSpaceId];
        }
    }];
    
    if(parkingSpaces.length > 1){
        [parkingSpaces deleteCharactersInRange:NSMakeRange(parkingSpaces.length - 1, 1)];
    }
    
    return parkingSpaces;
}
// 获取选中车位名
- (NSString *)achieveSelSpaceNames {
    NSMutableString *parkingSpaces = @"".mutableCopy;
    [_aptData enumerateObjectsUsingBlock:^(AptListModel *aptListModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if(aptListModel.isSelect){
            [parkingSpaces appendFormat:@"%@(%@),", aptListModel.orderModel.parkingSpaceName, aptListModel.orderModel.carNo];
        }
    }];
    
    if(parkingSpaces.length > 1){
        [parkingSpaces deleteCharactersInRange:NSMakeRange(parkingSpaces.length - 1, 1)];
    }
    
    return parkingSpaces;
}

#pragma mark 无网络通知
- (void)noNetworkSel {
    noDataView.hidden = NO;
    noDataView.imgView.image = [UIImage imageNamed:@"customvoice_networkerror"];
    noDataView.label.text = @"对不起,网络连接失败";
}

- (void)oprateRefresh {
    if(_appointMentParkStyle == AppointMentParkAll || _appointMentParkStyle == AppointMentParkIng){
        [self _loadData];
    }
}

- (void)_loadData {
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    
    // 0预约中 1入场 2取消 3超时取消 4完成
    NSString *aptType = @"";
    switch (_appointMentParkStyle) {
        case AppointMentParkCancel:
            aptType = @"2,3";
            break;
        case AppointMentParkIng:
            aptType = @"0";
            break;
        case AppointMentParkComplete:
            aptType = @"1,4";
            break;
        case AppointMentParkAll:
            aptType = @"0,1,2,3,4";
            break;
    }
    [paramDic setObject:aptType forKey:@"status"];
    
    if([_filterDic.allKeys containsObject:@"carNo"]){
        [paramDic setObject:_filterDic[@"carNo"] forKey:@"carNo"];
    }
    if([_filterDic.allKeys containsObject:@"startDate"]){
        [paramDic setObject:_filterDic[@"startDate"] forKey:@"beginTime"];
    }
    if([_filterDic.allKeys containsObject:@"endDate"]){
        [paramDic setObject:_filterDic[@"endDate"] forKey:@"endTime"];
    }
    
    [paramDic setObject:[NSNumber numberWithInt:_page] forKey:@"pageNumber"];
    [paramDic setObject:[NSNumber numberWithInt:_length] forKey:@"pageSize"];
    
    NSDictionary *param = @{@"param":[Utils convertToJsonData:paramDic]};
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/getAllParkingOrdersDetail", Main_Url];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [_aptTableView.mj_header endRefreshing];
        [_aptTableView.mj_footer endRefreshing];
        if([responseObject[@"code"] isEqualToString:@"1"]){
            if(_page == 1){
                [_aptData removeAllObjects];
            }
            
            if(responseObject[@"responseData"] == nil || [responseObject[@"responseData"] isKindOfClass:[NSNull class]]){
                return ;
            }
            
            NSArray *msgAry = responseObject[@"responseData"][@"items"];
            if(msgAry.count > 0){
                _aptTableView.mj_footer.state = MJRefreshStateIdle;
                _aptTableView.mj_footer.hidden = NO;
            }else {
                _aptTableView.mj_footer.state = MJRefreshStateNoMoreData;
                _aptTableView.mj_footer.hidden = YES;
            }
            
            [msgAry enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                AptListModel *aptListModel = [[AptListModel alloc] initWithDataDic:obj];
                NSString *cunrentTime = responseObject[@"responseData"][@"cunrentTime"];
                if(cunrentTime != nil && ![cunrentTime isKindOfClass:[NSNull class]]){
                    aptListModel.cunrentTime = cunrentTime;
                }
                [_aptData addObject:aptListModel];
            }];
        }else {
            [self showHint:responseObject[@"message"]];
        }
        noDataView.hidden = NO;
        [_aptTableView cyl_reloadData];
    } failure:^(NSError *error) {
        [_aptTableView.mj_header endRefreshing];
        [_aptTableView.mj_footer endRefreshing];
        noDataView.hidden = NO;
        [_aptTableView cyl_reloadData];
        [self showHint:KRequestFailMsg];
    }];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    noDataView.hidden = NO;
    return noDataView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark UItableView 协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _aptData.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 240;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AppointMentParkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AppointMentParkCell" forIndexPath:indexPath];
    cell.aptListModel = _aptData[indexPath.section];
    cell.isCancelApt = isApt;   // 在设置Model之后
    cell.spaceOpearteDelegate = self;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AptListModel *aptListModel = _aptData[indexPath.section];
    
    // 跳转详情
    if(aptListModel.orderModel.status != nil && ![aptListModel.orderModel.status isKindOfClass:[NSNull class]] && [aptListModel.orderModel.status isEqualToString:@"0"]){
        // 预约中
        AptingDetailViewController *aptingDelVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"AptingDetailViewController"];
        aptingDelVC.aptListModel = aptListModel;
        [self.navigationController pushViewController:aptingDelVC animated:YES];
    }else {
        AppointMentParkDetailViewController *aptDelVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"AppointMentParkDetailViewController"];
        aptDelVC.aptListModel = aptListModel;
        [self.navigationController pushViewController:aptDelVC animated:YES];
        
    }
    
}

#pragma mark cell协议 取消预约/开锁
- (void)cancelAptOpearte:(AptListModel *) aptListModel {
    if(_managerCancelAptDelegate && [_managerCancelAptDelegate respondsToSelector:@selector(cancelApt:)]){
        [_managerCancelAptDelegate cancelApt:aptListModel];
    }
    
}
- (void)openLockOpearte:(AptListModel *) aptListModel {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/forceOperateParkingLock", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:aptListModel.orderModel.parkingSpaceId forKey:@"parkingSpaceId"];
    [paramDic setObject:@"on" forKey:@"operateType"];
    
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            // 刷新tableView
            // 记录日志
            NSString *OperateName = [NSString stringWithFormat:@"打开车位锁 %@", aptListModel.orderModel.parkingSpaceName];
            [self logRecordTagId:aptListModel.orderModel.parkingSpaceId withOperateName:OperateName withOperateDes:OperateName withUrl:@"/parking/forceOperateParkingLock"];
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BatchCancelApt" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BatchCancelAptCancel" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CancelAptSucess" object:nil];
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
