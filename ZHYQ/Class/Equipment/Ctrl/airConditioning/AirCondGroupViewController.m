//
//  AirCondGroupViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/12.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "AirCondGroupViewController.h"
#import "TopMenuModel.h"
#import "FloorModel.h"
#import "EquipmentFloorCell.h"

#import "AirConditionViewController.h"

#import "AirBatchCenViewController.h"

@interface AirCondGroupViewController ()<UITableViewDelegate, UITableViewDataSource, CYLTableViewPlaceHolderDelegate>
{
    UITableView *_groupTableView;
    
    NSMutableArray *_entranceData;
}
@end

@implementation AirCondGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _entranceData = @[].mutableCopy;
    
    [self _initView];
    
    [self _loadEntranceData];
}

- (void)_initView {
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 80, 20);
    rightButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [rightButton setTitle:@"批量操作" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(batchAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    _groupTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64) style:UITableViewStylePlain];
    _groupTableView.delegate = self;
    _groupTableView.dataSource = self;
    _groupTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _groupTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_groupTableView];
    
    [_groupTableView registerNib:[UINib nibWithNibName:@"EquipmentFloorCell" bundle:nil] forCellReuseIdentifier:@"EquipmentFloorCell"];
}
- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)batchAction {
    AirBatchCenViewController *batchVC = [[AirBatchCenViewController alloc] init];
    batchVC.menuID = _menuID;
    [self.navigationController pushViewController:batchVC animated:YES];
}

// 加载楼层空调数据
- (void)_loadEntranceData {
    [self showHudInView:self.view hint:@""];
    NSString *urlStr = [NSString stringWithFormat:@"%@/public/getChildBulidingList?bulidId=%@&menuId=%@",Main_Url, @"-11", _menuID];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        [self hideHud];
        [_entranceData removeAllObjects];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSArray *dataArr = responseObject[@"responseData"];
            [dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FloorModel *model = [[FloorModel alloc] initWithDataDic:obj];
                [_entranceData addObject:model];
            }];
        }
        [_groupTableView cyl_reloadData];
    } failure:^(NSError *error) {
        [self hideHud];
        if(_entranceData.count <= 0){
            [self showNoDataImage];
        }else {
            [self showHint:KRequestFailMsg];
        }
    }];
}
// 无网络重载
- (void)reloadTableData {
    [self _loadEntranceData];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight)];
    return noDataView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark UITableView 协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _entranceData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat height = 60;
    UIColor *bgColor;
    BOOL isHidFlag;
    bgColor = [UIColor colorWithHexString:@"#e2e2e2"];
    isHidFlag = NO;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, height)];
    headerView.tag = 1000 + section;
    headerView.backgroundColor = bgColor;
    
    CGFloat flagHeight = 20;
    
    UIView *flagView = [[UIView alloc] initWithFrame:CGRectMake(8, (height - flagHeight)/2, 5, flagHeight)];
    flagView.layer.cornerRadius = 2.5;
    flagView.backgroundColor = [UIColor colorWithHexString:@"#3a7af6"];
    [headerView addSubview:flagView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(flagView.right + 4, 0, KScreenWidth - 20, height)];
    label.text = @"研发楼";
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
    FloorModel *model = _entranceData[indexPath.row];
    // 跳转点位图
    AirConditionViewController *inVC = [[AirConditionViewController alloc] init];
    inVC.floorModel = model;
    [self.navigationController pushViewController:inVC animated:YES];
}

@end
