//
//  MonthMeterViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/11.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "MonthMeterViewController.h"
#import "MonthMeterCell.h"
#import "NoDataView.h"
#import "MonthMeterModel.h"

@interface MonthMeterViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_monthMeterTableView;
    NSMutableArray *_monthMeterData;
    
    NSInteger _page;
    NSInteger _length;
}
@end

@implementation MonthMeterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _monthMeterData = @[].mutableCopy;
    
    _page = 1;
    _length = 15;
    
    [self _initView];
    
    [self _loadData];
}

- (void)_initView {
    if(_waterListModel != nil){
        self.title = @"水表每月抄表";
    }else {
        self.title = @"电表每月抄表";
    }
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _monthMeterTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64) style:UITableViewStyleGrouped];
    _monthMeterTableView.delegate = self;
    _monthMeterTableView.dataSource = self;
    [self.view addSubview:_monthMeterTableView];
    
    _monthMeterTableView.estimatedRowHeight = 0;
    _monthMeterTableView.estimatedSectionHeaderHeight = 0;
    _monthMeterTableView.estimatedSectionFooterHeight = 0;
    
    [_monthMeterTableView registerNib:[UINib nibWithNibName:@"MonthMeterCell" bundle:nil] forCellReuseIdentifier:@"MonthMeterCell"];
    
    _monthMeterTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self _loadData];
    }];
    // 上拉刷新
    _monthMeterTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self _loadData];
    }];
//    _monthMeterTableView.mj_footer.automaticallyHidden = NO;
    _monthMeterTableView.mj_footer.hidden = YES;
}
- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/energy/detail", Main_Url];
    
    NSMutableDictionary *searchParam = @{}.mutableCopy;
    if(_waterListModel != nil){
        [searchParam setObject:_waterListModel.tagid forKey:@"tagid"];
    }else if (_electricInfoModel != nil) {
        [searchParam setObject:_electricInfoModel.tagid forKey:@"tagid"];
    }
    [searchParam setObject:[NSNumber numberWithInteger:_length] forKey:@"pageSize"];
    [searchParam setObject:[NSNumber numberWithInteger:_page] forKey:@"pageNumber"];
    
    NSString *jsonStr = [Utils convertToJsonData:searchParam];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [_monthMeterTableView.mj_header endRefreshing];
        [_monthMeterTableView.mj_footer endRefreshing];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            if(_page == 1){
                [_monthMeterData removeAllObjects];
            }
            NSArray *items = responseObject[@"responseData"];
            if(items.count > _length-1){
                _monthMeterTableView.mj_footer.state = MJRefreshStateIdle;
                _monthMeterTableView.mj_footer.hidden = NO;
            }else {
                _monthMeterTableView.mj_footer.state = MJRefreshStateNoMoreData;
                _monthMeterTableView.mj_footer.hidden = YES;
            }
            [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                MonthMeterModel *monthMeterModel = [[MonthMeterModel alloc] initWithDataDic:obj];
                [_monthMeterData addObject:monthMeterModel];
            }];
            
            [_monthMeterTableView cyl_reloadData];
        }
        
    } failure:^(NSError *error) {
        [_monthMeterTableView.mj_header endRefreshing];
        [_monthMeterTableView.mj_footer endRefreshing];
    }];
    
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
    return _monthMeterData.count;
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
    MonthMeterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MonthMeterCell" forIndexPath:indexPath];
    cell.monthMeterModel = _monthMeterData[indexPath.section];
    if(_waterListModel != nil){
        cell.isWater = YES;
    }else {
        cell.isWater = NO;
    }
    return cell;
}

@end
