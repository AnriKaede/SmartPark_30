//
//  RepairsListViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/17.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "RepairsListViewController.h"
#import "RepairListCell.h"
#import "AppointBillViewController.h"

@interface RepairsListViewController ()<UITableViewDelegate, UITableViewDataSource, RepairMethodDelegate, CYLTableViewPlaceHolderDelegate>
{
    UITableView *_billTableView;
    NSMutableArray *_billData;
    
    NSInteger _page;
    NSInteger _length;
}
@end

@implementation RepairsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _page = 1;
    _length = 8;
    
    _billData = @[].mutableCopy;
    
    [self _initView];
    
    [self _loadData];
    
    if(_repairsType == RepairsComplete || _repairsType == RepairsClose || _repairsType == RepairsAll){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:@"BillCompleteConfirm" object:nil];
    }

    if(_repairsType == RepairsComplete || _repairsType == RepairsUnReceive || _repairsType == RepairsAll){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rejectCompleteBill:) name:@"RejectCompleteBillSuccess" object:nil];
    }
    
    if(_repairsType == RepairsIng || _repairsType == RepairsUnReceive || _repairsType == RepairsAll){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reReport:) name:@"ReReportSuccess" object:nil];
    }
    
    if(_repairsType == RepairsAll || _repairsType == RepairsIng){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadData) name:@"WranPostSuccess" object:nil];
    }
    
}

- (void)_initView {
    _billTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight - 60) style:UITableViewStyleGrouped];
    _billTableView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    _billTableView.delegate = self;
    _billTableView.dataSource = self;
    [self.view addSubview:_billTableView];
    
    [_billTableView registerNib:[UINib nibWithNibName:@"RepairListCell" bundle:nil] forCellReuseIdentifier:@"RepairListCell"];
    
    // ios 11tableView闪动
    _billTableView.estimatedRowHeight = 0;
    _billTableView.estimatedSectionHeaderHeight = 0;
    _billTableView.estimatedSectionFooterHeight = 0;
    
    _billTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self _loadData];
    }];
    // 上拉刷新
    _billTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self _loadData];
    }];
//    _billTableView.mj_footer.automaticallyHidden = NO;
    _billTableView.mj_footer.hidden = YES;
}

#pragma mark 接受确认完成 关闭工单通知刷新数据
- (void)refreshData:(NSNotification *)notification  {
    if(_repairsType == RepairsComplete){
        NSString *orderId = notification.userInfo[@"orderId"];
        [_billData enumerateObjectsUsingBlock:^(BillListModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            if([model.orderId isEqualToString:orderId]){
                [_billData removeObjectAtIndex:idx];
                [_billTableView deleteSection:idx withRowAnimation:UITableViewRowAnimationFade];
                
                *stop = YES;
            }
        }];
    }else {
        [self _loadData];
    }
}

#pragma mark 接受驳回完成通知
- (void)rejectCompleteBill:(NSNotification *)notification  {
    if(_repairsType == RepairsComplete){
        NSString *orderId = notification.userInfo[@"orderId"];
        [_billData enumerateObjectsUsingBlock:^(BillListModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            if([model.orderId isEqualToString:orderId]){
                [_billData removeObjectAtIndex:idx];
                [_billTableView deleteSection:idx withRowAnimation:UITableViewRowAnimationFade];
                
                *stop = YES;
            }
        }];
    }else {
        [self _loadData];
    }
}
#pragma mark 接受再派单完成通知
- (void)reReport:(NSNotification *)notification  {
    if(_repairsType == RepairsUnReceive){
        NSString *orderId = notification.userInfo[@"orderId"];
        [_billData enumerateObjectsUsingBlock:^(BillListModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            if([model.orderId isEqualToString:orderId]){
                [_billData removeObjectAtIndex:idx];
                [_billTableView deleteSection:idx withRowAnimation:UITableViewRowAnimationFade];
                
                *stop = YES;
            }
        }];
    }else {
        [self _loadData];
    }
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/deviceAlarm/alarmOrders", Main_Url];
    
    /*
    RepairsAll = 0,
    RepairsUnReceive,
    RepairsIng,
    RepairsComplete,
    RepairsClose
    01 派单 02 处理中 03 完成  04无效,传空直未查询所有
     */
    
    NSString *orderState = @"";
    switch (_repairsType) {
        case RepairsAll:
            break;
            
        case RepairsUnReceive:
            orderState = @"01";
            break;
            
        case RepairsIng:
            orderState = @"02";
            break;
            
        case RepairsComplete:
            orderState = @"03";
            break;
            
        case RepairsClose:
            orderState = @"04";
            break;
    }
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:orderState forKey:@"orderState"];
    [paramDic setObject:[NSNumber numberWithInteger:_page] forKey:@"pageNumber"];
    [paramDic setObject:[NSNumber numberWithInteger:_length] forKey:@"pageSize"];
    [paramDic setObject:@"distribute" forKey:@"orderRole"];
    
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        
        [_billTableView.mj_header endRefreshing];
        [_billTableView.mj_footer endRefreshing];
        
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            
            if(_page == 1){
                [_billData removeAllObjects];
            }
            
            NSArray *data = responseObject[@"responseData"][@"items"];
            
            if(data.count > _length-1){
                _billTableView.mj_footer.state = MJRefreshStateIdle;
                _billTableView.mj_footer.hidden = NO;
            }else {
                _billTableView.mj_footer.state = MJRefreshStateNoMoreData;
                _billTableView.mj_footer.hidden = YES;
            }
            
            [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                BillListModel *model = [[BillListModel alloc] initWithDataDic:obj];
                [_billData addObject:model];
            }];
            [_billTableView cyl_reloadData];
        }
    } failure:^(NSError *error) {
        [_billTableView.mj_header endRefreshing];
        [_billTableView.mj_footer endRefreshing];
        if(_billData.count <= 0){
            [self showNoDataImage];
        }else {
            [self showHint:KRequestFailMsg];
        }
        
    }];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight - 60)];
    noDataView.backgroundColor = [UIColor whiteColor];
    return noDataView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

// 无网络重载
- (void)reloadTableData {
    [self _loadData];
}

#pragma mark UITableView协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _billData.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 225;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return 12;
    }else {
        return 5;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RepairListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RepairListCell" forIndexPath:indexPath];
    cell.repairMethodDelegate = self;
    if(_billData.count > indexPath.section){
        cell.billListModel = _billData[indexPath.section];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_billData.count <= indexPath.section){
        return;
    }
    BillListModel *billListModel = _billData[indexPath.section];
    
    [self goDetailVC:billListModel];
}

- (void)goDetailVC:(BillListModel *)billListModel {
    AppointBillViewController *appointVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"AppointBillViewController"];
    
    //01 派单 02 处理中 03 完成  04无效,传空直未查询所有
    if([billListModel.orderState isEqualToString:@"01"]){
        appointVC.appointState = AppointUnDeal;
    }else if([billListModel.orderState isEqualToString:@"02"]){
        appointVC.appointState = AppointRepairing;
    }else if([billListModel.orderState isEqualToString:@"03"]){
        appointVC.appointState = AppointComplete;
    }else if([billListModel.orderState isEqualToString:@"04"]){
        appointVC.appointState = AppointClose;
    }
    appointVC.billListModel = billListModel;
    [self.navigationController pushViewController:appointVC animated:YES];
}

#pragma mark RepairMethodDelegate
- (void)progressMethod:(BillListModel *)billListModel {
    [self.view endEditing:YES];
    // 判断是完成状态 实现
    if(_repairDelegate && [_repairDelegate respondsToSelector:@selector(progressQuery:)]){
        [_repairDelegate progressQuery:billListModel];
    }
}

- (void)rightMethod:(BillListModel *)billListModel {
    [self.view endEditing:YES];
    // 判断是完成状态 实现
    if([billListModel.orderState isEqualToString:@"03"] && _repairDelegate && [_repairDelegate respondsToSelector:@selector(billComplete:)]){
        [_repairDelegate billComplete:billListModel];
    }else if([billListModel.orderState isEqualToString:@"01"]){
        [self goDetailVC:billListModel];
    }
}

- (void)dealloc {
    if(_repairsType == RepairsComplete || _repairsType == RepairsClose || _repairsType == RepairsAll){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BillCompleteConfirm" object:nil];
    }
    
    if(_repairsType == RepairsComplete || _repairsType == RepairsUnReceive || _repairsType == RepairsAll){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RejectCompleteBillSuccess" object:nil];
    }
    
    if(_repairsType == RepairsIng || _repairsType == RepairsUnReceive || _repairsType == RepairsAll){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ReReportSuccess" object:nil];
    }
    
    if(_repairsType == RepairsAll || _repairsType == RepairsIng){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"WranPostSuccess" object:nil];
    }
    
}

@end
