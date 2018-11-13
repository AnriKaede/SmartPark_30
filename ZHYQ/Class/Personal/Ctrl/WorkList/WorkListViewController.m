//
//  WorkListViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/19.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WorkListViewController.h"
#import "WorkListCell.h"
#import "BillListModel.h"

#import "WorkDetailViewController.h"
#import "CompleteConfirmViewController.h"

@interface WorkListViewController ()<UITableViewDelegate, UITableViewDataSource, WorkMethodDelegate>
{
    UITableView *_workTableView;
    NSMutableArray *_workData;
    
    NSInteger _page;
    NSInteger _length;
}
@end

@implementation WorkListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _page = 1;
    _length = 8;
    
    _workData = @[].mutableCopy;
    
    [self _initView];
    
    [self _loadData];
    
    if(_workListType == WorkAll || _workListType == WorkRepairsIng){
        // 维修中、全部接受退回工单成功通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:@"RejectRepairsSuccess" object:nil];
    }
    if(_workListType == WorkAll || _workListType == WorkRepairsIng || _workListType == WorkWaitConfirm){
        // 维修中、待确认、全部接受维修完成成功通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(repairsComplete:) name:@"BillRepairsComplete" object:nil];
    }
}

- (void)_initView {
    _workTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight - 60) style:UITableViewStyleGrouped];
    _workTableView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    _workTableView.delegate = self;
    _workTableView.dataSource = self;
    [self.view addSubview:_workTableView];
    
    [_workTableView registerNib:[UINib nibWithNibName:@"WorkListCell" bundle:nil] forCellReuseIdentifier:@"WorkListCell"];
    
    // ios 11tableView闪动
    _workTableView.estimatedRowHeight = 0;
    _workTableView.estimatedSectionHeaderHeight = 0;
    _workTableView.estimatedSectionFooterHeight = 0;
    
    _workTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self _loadData];
    }];
    // 上拉刷新
    _workTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self _loadData];
    }];
//    _workTableView.mj_footer.automaticallyHidden = NO;
    _workTableView.mj_footer.hidden = YES;
}

- (void)refreshData:(NSNotification *)notification {
    NSString *orderId = notification.userInfo[@"orderId"];
    [_workData enumerateObjectsUsingBlock:^(BillListModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        if([model.orderId isEqualToString:orderId]){
            [_workData removeObjectAtIndex:idx];
            [_workTableView deleteSection:idx withRowAnimation:UITableViewRowAnimationFade];
            
            *stop = YES;
        }
    }];
}

- (void)repairsComplete:(NSNotification *)notification {
    if(_workListType == WorkAll || _workListType == WorkRepairsIng){
        NSString *orderId = notification.userInfo[@"orderId"];
        [_workData enumerateObjectsUsingBlock:^(BillListModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            if([model.orderId isEqualToString:orderId]){
                [_workData removeObjectAtIndex:idx];
                [_workTableView deleteSection:idx withRowAnimation:UITableViewRowAnimationFade];
                
                *stop = YES;
            }
        }];
    }else {
        [self _loadData];
    }
}

#pragma mark 加载数据
- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/deviceAlarm/alarmOrders", Main_Url];
    
    /*
     WorkAll = 0,
     WorkRepairsIng,
     WorkWaitConfirm,
     WorkClose
     01 派单 02 处理中 03 完成  04无效,传空直未查询所有
     */
    
    NSString *orderState = @"";
    switch (_workListType) {
        case WorkAll:
            break;
            
        case WorkRepairsIng:
            orderState = @"02";
            break;
            
        case WorkWaitConfirm:
            orderState = @"03";
            break;
            
        case WorkClose:
            orderState = @"04";
            break;
    }
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:orderState forKey:@"orderState"];
    [paramDic setObject:[NSNumber numberWithInteger:_page] forKey:@"pageNumber"];
    [paramDic setObject:[NSNumber numberWithInteger:_length] forKey:@"pageSize"];
    [paramDic setObject:@"repair" forKey:@"orderRole"];
    
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        
        [_workTableView.mj_header endRefreshing];
        [_workTableView.mj_footer endRefreshing];
        
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            
            if(_page == 1){
                [_workData removeAllObjects];
            }
            
            NSArray *data = responseObject[@"responseData"][@"items"];
            
            if(data.count > _length-1){
                _workTableView.mj_footer.state = MJRefreshStateIdle;
                _workTableView.mj_footer.hidden = NO;
            }else {
                _workTableView.mj_footer.state = MJRefreshStateNoMoreData;
                _workTableView.mj_footer.hidden = YES;
            }
            
            [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                BillListModel *model = [[BillListModel alloc] initWithDataDic:obj];
                [_workData addObject:model];
            }];
            [_workTableView cyl_reloadData];
        }
    } failure:^(NSError *error) {
        [_workTableView.mj_header endRefreshing];
        [_workTableView.mj_footer endRefreshing];
        if(_workData.count <= 0){
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
    return _workData.count;
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
    WorkListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WorkListCell" forIndexPath:indexPath];
    cell.workListDelegate = self;
    if(_workData.count > indexPath.section){
        cell.billListModel = _workData[indexPath.section];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WorkDetailViewController *detailVC = [[UIStoryboard storyboardWithName:@"Personal" bundle:nil] instantiateViewControllerWithIdentifier:@"WorkDetailViewController"];
    if(_workData.count > indexPath.section){
        BillListModel *billListModel = _workData[indexPath.section];
        detailVC.orderId = billListModel.orderId;
    }
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark WorkMethodDelegate
- (void)bottomLeftMethod:(BillListModel *)billListModel {
    // 01 派单 02 处理中 03 完成  04无效
    if([billListModel.orderState isEqualToString:@"02"]){
        // 退回工单
        if(_workDelegate && [_workDelegate respondsToSelector:@selector(rejectBill:)]){
            [_workDelegate rejectBill:billListModel];
        }
    }else if([billListModel.orderState isEqualToString:@"03"] || [billListModel.orderState isEqualToString:@"04"]) {
        // 完成进度
        if(_workDelegate && [_workDelegate respondsToSelector:@selector(progressQuery:)]){
            [_workDelegate progressQuery:billListModel];
        }
    }
    
}

- (void)bottomRightMethod:(BillListModel *)billListModel {
    if([billListModel.orderState isEqualToString:@"02"]){
        CompleteConfirmViewController *comVC = [[UIStoryboard storyboardWithName:@"Personal" bundle:nil] instantiateViewControllerWithIdentifier:@"CompleteConfirmViewController"];
        comVC.billListModel = billListModel;
        [self.navigationController pushViewController:comVC animated:YES];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RejectRepairsSuccess" object:nil];
}

@end
