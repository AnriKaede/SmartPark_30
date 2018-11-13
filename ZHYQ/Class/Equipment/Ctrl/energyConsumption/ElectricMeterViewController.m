//
//  ElectricMeterViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/11.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ElectricMeterViewController.h"
#import "EnergyConCell.h"
#import "NoDataView.h"

#import "ElectricListModel.h"
#import "ElectricInfoModel.h"

@interface ElectricMeterViewController ()<UITableViewDelegate, UITableViewDataSource, CYLTableViewPlaceHolderDelegate>
{
    UITableView *_electricTableView;
    
    NSMutableArray *_groupData;
    
    NSInteger _selGroupNum;
}
@end

@implementation ElectricMeterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _groupData = @[].mutableCopy;
    
    _selGroupNum = -1;
    
    [self _initView];
    
    [self _loadData];
}

- (void)_initView {
    _electricTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64) style:UITableViewStyleGrouped];
    _electricTableView.delegate = self;
    _electricTableView.dataSource = self;
    [self.view addSubview:_electricTableView];
    
    [_electricTableView registerNib:[UINib nibWithNibName:@"EnergyConCell" bundle:nil] forCellReuseIdentifier:@"EnergyConCell"];
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/energy/list/electricity", Main_Url];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            [_groupData removeAllObjects];
            NSArray *items = responseObject[@"responseData"];
            [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ElectricListModel *model = [[ElectricListModel alloc] initWithDataDic:obj];
                [_groupData addObject:model];
            }];
            
            [_electricTableView reloadData];
        }
        
    } failure:^(NSError *error) {
        if(_groupData.count <= 0){
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
    return _groupData.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == _selGroupNum){
        ElectricListModel *model = _groupData[section];
        if(model.deviceList != nil){
            return model.deviceList.count;
        }else {
            return 0;
        }
    }else {
        return 0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 152;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ElectricListModel *electricListModel = _groupData[section];
    
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
    label.text = electricListModel.energyName;
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
    EnergyConCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EnergyConCell" forIndexPath:indexPath];
    cell.topLineView.hidden = NO;

    ElectricListModel *electricListModel = _groupData[indexPath.section];
    ElectricInfoModel *electricInfoModel = electricListModel.deviceList[indexPath.row];
    cell.electricInfoModel = electricInfoModel;
    
    return cell;
}

- (void)seccionAction:(UITapGestureRecognizer *)tap {
    NSInteger section = tap.view.tag - 1000;
    
    if(_selGroupNum == section){
        _selGroupNum = -1;
        
        [_electricTableView reloadData];
    }else {
        _selGroupNum = section;
//        TopMenuModel *model = _floorData[section];
//        [self _loadEntranceData:[NSString stringWithFormat:@"%@", model.BUILDING_ID]];
        [_electricTableView reloadData];
    }
}

@end
