//
//  ParkRecordViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/29.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "ParkRecordViewController.h"
#import "ParkDetailMsgController.h"
#import "CarRecordModel.h"
#import "ParkAllRcordTableViewCell.h"

@interface ParkRecordViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    int _page;
    int _length;
    
    NSMutableArray *_recordData;
    UITableView *_parkTableView;
    
    NSMutableDictionary *_filterDic;
}

@end

@implementation ParkRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _recordData = @[].mutableCopy;
    _page = 1;
    _length = 10;
    
    [self _initView];
    
    [_parkTableView.mj_header beginRefreshing];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetData) name:@"ParkRecordResSet" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterDataDic:) name:@"ParkRecordFilter" object:nil];
}

-(void)_initView
{
    self.view.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    if (kDevice_Is_iPhoneX) {
        _parkTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight - 65-17) style:UITableViewStylePlain];
    }else{
        _parkTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight- 65) style:UITableViewStylePlain];
    }
    _parkTableView.tableFooterView = [UIView new];
    _parkTableView.delegate = self;
    _parkTableView.dataSource = self;
    _parkTableView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    [self.view addSubview:_parkTableView];
    
    // ios 11tableView闪动
    _parkTableView.estimatedRowHeight = 0;
    _parkTableView.estimatedSectionHeaderHeight = 0;
    _parkTableView.estimatedSectionFooterHeight = 0;
    
    [_parkTableView registerNib:[UINib nibWithNibName:@"ParkAllRcordTableViewCell" bundle:nil] forCellReuseIdentifier:@"ParkAllRcordTableViewCell"];
    
    _parkTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self _loadBindCarData];
    }];
    // 上拉刷新
    _parkTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self _loadBindCarData];
    }];
//    _parkTableView.mj_footer.automaticallyHidden = NO;
    _parkTableView.mj_footer.hidden = YES;
}

// 重置数据
- (void)resetData {
    [_filterDic removeAllObjects];
    [_parkTableView.mj_header beginRefreshing];
}

// 筛选通知
- (void)filterDataDic:(NSNotification *)notifacation {
    _page = 1;
    [_recordData removeAllObjects];
    
    [_parkTableView reloadData];
    
    _filterDic = notifacation.userInfo.mutableCopy;
    [_parkTableView.mj_header beginRefreshing];
}

#pragma mark 请求绑定车辆信息
- (void)_loadBindCarData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/getParkingInfo", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:_carNo forKey:@"carNo"];
    
    NSString *traceResult = @"";
    if(_parkStyle == ParkIn){
        traceResult = @"90";
    }else if(_parkStyle == ParkOut){
        traceResult = @"00";
    }else if(_parkStyle == ParkAppointment){
        // 预约
        [_parkTableView.mj_header endRefreshing];
        [_parkTableView.mj_footer endRefreshing];
        [_parkTableView cyl_reloadData];
        return;
    }
    [paramDic setObject:traceResult forKey:@"traceResult"];
    
    if([_filterDic.allKeys containsObject:@"startDate"]){
        [paramDic setObject:_filterDic[@"startDate"] forKey:@"startTime"];
    }
    if([_filterDic.allKeys containsObject:@"endDate"]){
        [paramDic setObject:_filterDic[@"endDate"] forKey:@"endTime"];
    }
    [paramDic setObject:[NSNumber numberWithInt:_page] forKey:@"pageNumber"];
    [paramDic setObject:[NSNumber numberWithInt:_length] forKey:@"pageSize"];
    
    NSDictionary *params = @{@"param":[Utils convertToJsonData:paramDic]};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        [_parkTableView.mj_header endRefreshing];
        [_parkTableView.mj_footer endRefreshing];
        
        if(responseObject[@"code"] != nil && ![responseObject[@"code"] isKindOfClass:[NSNull class]] && [responseObject[@"code"] isEqualToString:@"1"] ){
            NSArray *responseData = responseObject[@"responseData"];
            if(_page == 1){
                [_recordData removeAllObjects];
            }
            if(responseData.count > 0){
                _parkTableView.mj_footer.state = MJRefreshStateIdle;
                _parkTableView.mj_footer.hidden = NO;
            }else {
                _parkTableView.mj_footer.state = MJRefreshStateNoMoreData;
                _parkTableView.mj_footer.hidden = YES;
            }
            [responseData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CarRecordModel *carRecordModel = [[CarRecordModel alloc] initWithDataDic:obj];
                [_recordData addObject:carRecordModel];
            }];
        }else {
            NSString *message = responseObject[@"message"];
            if(message != nil && ![message isKindOfClass:[NSNull class]]){
                [self showHint:message];
            }
        }
        [_parkTableView cyl_reloadData];
        
    } failure:^(NSError *error) {
        [_parkTableView.mj_header endRefreshing];
        [_parkTableView.mj_footer endRefreshing];
    }];
    
}

#pragma mark 无数据协议
#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 60, KScreenWidth, KScreenHeight - 64 - 60)];
    return noDataView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark UItableView 协议
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _recordData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ParkAllRcordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ParkAllRcordTableViewCell" forIndexPath:indexPath];
    cell.carRecordModel = _recordData[indexPath.row];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 180;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ParkDetailMsgController *parkMsgVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"ParkDetailMsgController"];
    parkMsgVC.carRecordModel = _recordData[indexPath.row];
    [self.navigationController pushViewController:parkMsgVC animated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ParkRecordResSet" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ParkRecordFilter" object:nil];
}

@end
