//
//  MonitorGroupViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/12.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "MonitorGroupViewController.h"
#import "TopMenuModel.h"
#import "FloorModel.h"
#import "EquipmentFloorCell.h"

#import "InDoorMonitorViewController.h"
#import "OutDoorMonitorViewController.h"

@interface MonitorGroupViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_groupTableView;
    
    NSMutableArray *_floorData;
    NSMutableArray *_entranceData;
    
    NSInteger _selGroupNum;
    
    NoDataView *_noDataView;
}
@end

@implementation MonitorGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _selGroupNum = -1;
    _floorData = @[].mutableCopy;
    _entranceData = @[].mutableCopy;
    
    [self _initView];
    
    [self _initFloorData];
}

- (void)_initView {
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _groupTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64) style:UITableViewStylePlain];
    _groupTableView.delegate = self;
    _groupTableView.dataSource = self;
    _groupTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _groupTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_groupTableView];
    
    [_groupTableView registerNib:[UINib nibWithNibName:@"EquipmentFloorCell" bundle:nil] forCellReuseIdentifier:@"EquipmentFloorCell"];
    
    // 无数据视图
    _noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight)];
    _noDataView.hidden = YES;
    [self.view addSubview:_noDataView];
}
- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

// 加载楼层数据
- (void)_initFloorData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/public/getTopBulidingList?areaId=1",Main_Url];
//    NSString *urlStr = [NSString stringWithFormat:@"%@/public/getTopBulidingList?areaId=-111",Main_Url];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            [_floorData removeAllObjects];
            
            NSArray *arr = responseObject[@"responseData"];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                TopMenuModel *model = [[TopMenuModel alloc] initWithDataDic:obj];
                [_floorData addObject:model];
            }];
            [_groupTableView reloadData];
        }
        if(_floorData.count <= 0){
            _noDataView.hidden = NO;
        }else {
            _noDataView.hidden = YES;
        }
    } failure:^(NSError *error) {
        if(_floorData.count <= 0){
            [self showNoDataImage];
        }else {
            [self showHint:KRequestFailMsg];
        }
    }];
}
// 无网络重载
- (void)reloadTableData {
    [self _initFloorData];
}

// 加载楼层门禁数据
- (void)_loadEntranceData:(NSString *)buildID {
    [self showHudInView:self.view hint:@""];
    NSString *urlStr = [NSString stringWithFormat:@"%@/public/getChildBulidingList?bulidId=%@&menuId=%@",Main_Url,buildID, _menuID];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        [_entranceData removeAllObjects];
        
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSArray *dataArr = responseObject[@"responseData"];
            [dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FloorModel *model = [[FloorModel alloc] initWithDataDic:obj];
                [_entranceData addObject:model];
            }];
        }
        
        [_groupTableView reloadData];
    } failure:^(NSError *error) {
        [self hideHud];
    }];
}

#pragma mark UITableView 协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _floorData.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == _selGroupNum){
        return _entranceData.count;
    }else {
        return 0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TopMenuModel *model = _floorData[section];
    
    CGFloat height = 60;
    UIColor *bgColor;
    BOOL isHidFlag;
    if(_selGroupNum == section){
        bgColor = [UIColor colorWithHexString:@"#e2e2e2"];
        isHidFlag = NO;
    }else {
        bgColor = [UIColor whiteColor];
        isHidFlag = YES;
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, height)];
    headerView.tag = 1000 + section;
    UITapGestureRecognizer *seccionTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(seccionAction:)];
    [headerView addGestureRecognizer:seccionTap];
    headerView.backgroundColor = bgColor;
    
    CGFloat flagHeight = 5;
    if(_selGroupNum == section){
        flagHeight = 20;
    }
    
    UIView *flagView = [[UIView alloc] initWithFrame:CGRectMake(8, (height - flagHeight)/2, 5, flagHeight)];
    //    flagView.hidden = isHidFlag;
    flagView.layer.cornerRadius = 2.5;
    flagView.backgroundColor = [UIColor colorWithHexString:@"#3a7af6"];
    [headerView addSubview:flagView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(flagView.right + 4, 0, KScreenWidth - 20, height)];
    label.text = model.BUILDING_NAME;
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:17];
    label.textAlignment = NSTextAlignmentLeft;
    [headerView addSubview:label];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, height - 0.5, KScreenWidth, 0.5)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    [headerView addSubview:lineView];
    
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EquipmentFloorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EquipmentFloorCell" forIndexPath:indexPath];
    cell.floorModel = _entranceData[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TopMenuModel *topModel = _floorData[indexPath.section];
    
    FloorModel *model = _entranceData[indexPath.row];
    // 跳转点位图
    if(topModel.IS_OUT.integerValue == 1){
        OutDoorMonitorViewController *outVC = [[OutDoorMonitorViewController alloc] init];
        [self.navigationController pushViewController:outVC animated:YES];
    }else {
        InDoorMonitorViewController *inVC = [[InDoorMonitorViewController alloc] init];
        inVC.floorModel = model;
        [self.navigationController pushViewController:inVC animated:YES];
    }
}

- (void)seccionAction:(UITapGestureRecognizer *)tap {
    NSInteger section = tap.view.tag - 1000;
    
    if(_selGroupNum == section){
        _selGroupNum = -1;
        
        [_groupTableView reloadData];
    }else {
        _selGroupNum = section;
        TopMenuModel *model = _floorData[section];
        [self _loadEntranceData:[NSString stringWithFormat:@"%@", model.BUILDING_ID]];
    }
    
}

@end
