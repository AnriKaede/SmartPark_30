//
//  WaterMeterViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/11.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "WaterMeterViewController.h"
#import "EnergyConCell.h"
#import "WaterListModel.h"
#import "NoDataView.h"

@interface WaterMeterViewController ()<UITableViewDelegate, UITableViewDataSource, CYLTableViewPlaceHolderDelegate>
{
    UITableView *_waterTableView;
    
    NSMutableArray *_waterData;
}
@end

@implementation WaterMeterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _waterData = @[].mutableCopy;
    
    [self _initView];
    
    [self _loadData];
}

- (void)_initView {
    _waterTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64) style:UITableViewStyleGrouped];
    _waterTableView.delegate = self;
    _waterTableView.dataSource = self;
    [self.view addSubview:_waterTableView];
    
    [_waterTableView registerNib:[UINib nibWithNibName:@"EnergyConCell" bundle:nil] forCellReuseIdentifier:@"EnergyConCell"];
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/energy/list/water", Main_Url];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            [_waterData removeAllObjects];
            NSArray *items = responseObject[@"responseData"];
            [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                WaterListModel *waterModel = [[WaterListModel alloc] initWithDataDic:obj];
                [_waterData addObject:waterModel];
            }];
            
            [_waterTableView cyl_reloadData];
        }
        
    } failure:^(NSError *error) {
        if(_waterData.count <= 0){
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

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDateView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    return noDateView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark UItableView 协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _waterData.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 152;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EnergyConCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EnergyConCell" forIndexPath:indexPath];
    cell.waterListModel = _waterData[indexPath.section];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
