//
//  WranHomeViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/7.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "WranHomeViewController.h"
#import "WranHomeCell.h"
#import "OverDetailWranModel.h"

@interface WranHomeViewController ()<UITableViewDelegate, UITableViewDataSource, CYLTableViewPlaceHolderDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_wranData;
    
    int _page;
    int _length;
}
@end

@implementation WranHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _wranData = @[].mutableCopy;
    _page = 1;
    _length = 10;
    
    [self _initView];
    
    [self _loadData];
}

- (void)_initView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight - 60) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _tableView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    [self.view addSubview:_tableView];
    
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    
    [_tableView registerNib:[UINib nibWithNibName:@"WranHomeCell" bundle:nil] forCellReuseIdentifier:@"WranHomeCell"];
    
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self _loadData];
    }];
    // 上拉刷新
    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self _loadData];
    }];
    _tableView.mj_footer.hidden = YES;
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parkSituation/alarmList", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    if(_alarmModel.alarmLevelId != nil){
        [paramDic setObject:_alarmModel.alarmLevelId forKey:@"alarmLevelId"]; // 0离线 1在线
    }
    [paramDic setObject:[NSNumber numberWithInteger:_page] forKey:@"pageNumber"];
    [paramDic setObject:[NSNumber numberWithInteger:_length] forKey:@"pageSize"];
    
    NSString *paramStr = [Utils convertToJsonData:paramDic];
    NSDictionary *params = @{@"param":paramStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        
        [_tableView.mj_header endRefreshing];
        [_tableView.mj_footer endRefreshing];
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            if(_page == 1){
                [_wranData removeAllObjects];
            }
            
            NSArray *data = responseObject[@"responseData"];
            if(data.count > _length-1){
                _tableView.mj_footer.state = MJRefreshStateIdle;
                _tableView.mj_footer.hidden = NO;
            }else {
                _tableView.mj_footer.state = MJRefreshStateNoMoreData;
                _tableView.mj_footer.hidden = YES;
            }
            
            [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                OverDetailWranModel *model = [[OverDetailWranModel alloc] initWithDataDic:obj];
                [_wranData addObject:model];
            }];
            
            [_tableView cyl_reloadData];
        }
        
    } failure:^(NSError *error) {
        [_tableView.mj_header endRefreshing];
        [_tableView.mj_footer endRefreshing];
        if(_wranData.count <= 0){
            [self showNoDataImageWithY:60];
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
    NoDataView *noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 60, KScreenWidth, KScreenHeight - 63)];
    return noDataView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark UItableView协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _wranData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    OverDetailWranModel *model = _wranData[indexPath.row];
    
    NSString *text = [NSString stringWithFormat:@"%@", model.alarmInfo];
    CGFloat height = [Utils getStringHeightWithText:text fontSize:17 viewWidth:KScreenWidth];
    
    return 84 + height;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OverDetailWranModel *model = _wranData[indexPath.row];
    
    WranHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WranHomeCell" forIndexPath:indexPath];
    
    cell.detailWranModel = model;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
