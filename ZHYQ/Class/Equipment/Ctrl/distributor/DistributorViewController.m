//
//  DistributorViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/8/15.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "DistributorViewController.h"
#import "DistributorCell.h"
#import "DistributorModel.h"

@interface DistributorViewController ()<UITableViewDelegate, UITableViewDataSource, CYLTableViewPlaceHolderDelegate>
{
    __weak IBOutlet UILabel *_normalLabel;
    __weak IBOutlet UILabel *_outTempLabel;
    __weak IBOutlet UILabel *_tripLabel;
    __weak IBOutlet UILabel *_failLabel;
    
    __weak IBOutlet UITableView *_distributorTableView;
    
    NSMutableArray *_disData;
}
@end

@implementation DistributorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _disData = @[].mutableCopy;
    
    [self _initView];
    
    [self _loadData];
}

- (void)_initView {
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _distributorTableView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    _distributorTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_distributorTableView registerNib:[UINib nibWithNibName:@"DistributorCell" bundle:nil] forCellReuseIdentifier:@"DistributorCell"];
    
    _distributorTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self _loadData];
    }];
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/airConditioner/lowVoltageStatus", Main_Url];
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        [_distributorTableView.mj_header endRefreshing];
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            [_disData removeAllObjects];
            // 成功
            _normalLabel.text = [NSString stringWithFormat:@"%@", responseObject[@"responseData"][@"okCount"]];
            _outTempLabel.text = [NSString stringWithFormat:@"%@", responseObject[@"responseData"][@"overCount"]];
            _tripLabel.text = [NSString stringWithFormat:@"%@", responseObject[@"responseData"][@"tripCount"]];
            _failLabel.text = [NSString stringWithFormat:@"%@", responseObject[@"responseData"][@"errorCount"]];
            
            NSArray *deviceInfos = responseObject[@"responseData"][@"deviceInfos"];
            [deviceInfos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DistributorModel *model = [[DistributorModel alloc] initWithDataDic:obj];
                [self stateJudgement:model];
                [_disData addObject:model];
            }];
            [_distributorTableView cyl_reloadData];
            
        }else {
            NSString *message = responseObject[@"message"];
            if(message != nil && ![message isKindOfClass:[NSNull class]]){
                [self showHint:message];
            }
        }
    } failure:^(NSError *error) {
        [_distributorTableView.mj_header endRefreshing];
        if(_disData.count <= 0){
            [self showNoDataImage];
        }else {
            [self showHint:KRequestFailMsg];
        }
    }];
}
// 无网络重载
- (void)reloadTableData {
    [self _loadData];
}

- (UIView *)makePlaceHolderView {
    NoDataView *nodataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, _distributorTableView.height)];
    return nodataView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _disData.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DistributorModel *model = _disData[section];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 40)];
    headerView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 10, KScreenWidth - 100, 20)];
    titleLabel.text = model.deviceName;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [headerView addSubview:titleLabel];
    
    UILabel *stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth - 110, 10, 100, 20)];
    stateLabel.text = model.stateText;
    if([model.stateType isEqualToString:@"1"]){
        stateLabel.textColor = [UIColor colorWithHexString:@"#1B82D1"];
    }else {
        stateLabel.textColor = [UIColor colorWithHexString:@"#FF4359"];
    }
    stateLabel.font = [UIFont systemFontOfSize:17];
    stateLabel.textAlignment = NSTextAlignmentRight;
    [headerView addSubview:stateLabel];
    
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DistributorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DistributorCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.distributorModel = _disData[indexPath.section];
    return cell;
}

#pragma mark 判断是否正常
- (void)stateJudgement:(DistributorModel *)distributorModel {
    NSArray *stateArray = distributorModel.tagArray;
    __block NSString *stateStr = @"正常";
    __block NSString *stateType = @"1";    // 1:正常，2:超温，3:故障，4:跳闸
    [stateArray enumerateObjectsUsingBlock:^(MeetRoomStateModel *stateModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if(idx >= 1 && idx <= 3 && stateModel.value != nil && ![stateModel.value isKindOfClass:[NSNull class]] && [stateModel.value isEqualToString:@"1"]){
            if(idx == 1) {
                stateStr = @"超温";
                stateType = @"2";
            }else if(idx == 2) {
                stateStr = @"故障";
                stateType = @"3";
            }else if(idx == 3) {
                stateStr = @"跳闸";
                stateType = @"4";
            }
        }
        if(idx == 4) {
            distributorModel.ATemp = [NSString stringWithFormat:@"%@", stateModel.value];
        }
        if(idx == 5) {
            distributorModel.BTemp = [NSString stringWithFormat:@"%@", stateModel.value];
        }
        if(idx == 6) {
            distributorModel.CTemp = [NSString stringWithFormat:@"%@", stateModel.value];
        }
        if(idx == 7) {
            distributorModel.hisHeightTemp = [NSString stringWithFormat:@"%@", stateModel.value];
        }
    }];
    distributorModel.stateType = stateType;
    distributorModel.stateText = stateStr;
}

@end
