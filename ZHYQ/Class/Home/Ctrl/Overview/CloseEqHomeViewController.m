//
//  CloseEqHomeViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/7.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "CloseEqHomeViewController.h"
#import "CloseEqHomeCell.h"
#import "OverUseListModel.h"
#import "OverCloseListViewController.h"

@interface CloseEqHomeViewController ()<UITableViewDelegate, UITableViewDataSource, CYLTableViewPlaceHolderDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_closeData;
    
    int _page;
    int _length;
}
@end

@implementation CloseEqHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _closeData = @[].mutableCopy;
    _page = 1;
    _length = 20;
    
    [self _initView];
    
    [_tableView.mj_header beginRefreshing];
}

- (void)_initView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _tableView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    [self.view addSubview:_tableView];
    
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    
    [_tableView registerNib:[UINib nibWithNibName:@"CloseEqHomeCell" bundle:nil] forCellReuseIdentifier:@"CloseEqHomeCell"];
    
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

    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parkSituation/shutdownList", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:[NSNumber numberWithInteger:_page] forKey:@"pageNumber"];
    [paramDic setObject:[NSNumber numberWithInteger:_length] forKey:@"pageSize"];
    
    NSString *paramStr = [Utils convertToJsonData:paramDic];
    NSDictionary *params = @{@"params":paramStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        
        [_tableView.mj_header endRefreshing];
        [_tableView.mj_footer endRefreshing];
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            if(_page == 1){
                [_closeData removeAllObjects];
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
                OverUseListModel *model = [[OverUseListModel alloc] initWithDataDic:obj];
                [_closeData addObject:model];
            }];
            
        }
        [_tableView cyl_reloadData];
        
    } failure:^(NSError *error) {
        [_tableView.mj_header endRefreshing];
        [_tableView.mj_footer endRefreshing];
        if(_closeData.count <= 0){
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
    return _closeData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
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
    OverUseListModel *model = _closeData[indexPath.row];
    
    CloseEqHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CloseEqHomeCell" forIndexPath:indexPath];
    
    cell.useModel = model;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OverUseListModel *model = _closeData[indexPath.row];
    OverCloseListViewController *listVC = [[OverCloseListViewController alloc] init];
    listVC.overUseListModel = model;
    [self.navigationController pushViewController:listVC animated:YES];
}
@end
