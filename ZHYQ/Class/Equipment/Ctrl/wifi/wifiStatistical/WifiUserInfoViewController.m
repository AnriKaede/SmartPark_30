//
//  WifiUserInfoViewController.m
//  ZHYQ
//
//  Created by coder on 2018/10/25.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WifiUserInfoViewController.h"
#import "WifiUserInfoCell.h"
#import "CRSearchBar.h"
#import "WifiUserInfoDetailController.h"
#import "WifiUserModel.h"

@interface WifiUserInfoViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
{
    UITableView *_aptTableView;
    NSMutableArray *_userData;
    CRSearchBar *_searchBar;
    
    int _page;
    int _length;
}

@end

@implementation WifiUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _userData = @[].mutableCopy;
    
    _page = 0;
    _length = 10;
    
    [self _initView];
    
    [self loadWifiUserData];
}

- (void)_initView {
    _searchBar = [[CRSearchBar alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 44)];
    _searchBar.leftImage = [UIImage imageNamed:@"icon_search"];
    _searchBar.placeholderColor = [UIColor colorWithHexString:@"#E2E2E2"];
    _searchBar.placeholder = @"请输入用户名查询";
    _searchBar.delegate = self;
    _searchBar.backgroundColor = [UIColor clearColor];
    _searchBar.backgroundImage = [UIImage imageWithColor:[UIColor clearColor]];
    _searchBar.searchTextPositionAdjustment = UIOffsetMake(0, 2);
    _searchBar.hidden = YES;
    [self.view addSubview:_searchBar];
    
//    _aptTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, KScreenWidth, KScreenHeight - kTopHeight - 44) style:UITableViewStylePlain];
    _aptTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight) style:UITableViewStylePlain];
    _aptTableView.tableFooterView = [UIView new];
    _aptTableView.backgroundColor = [UIColor colorWithHexString:@"#EFEFEF"];
    _aptTableView.delegate = self;
    _aptTableView.dataSource = self;
    _aptTableView.separatorColor = [UIColor clearColor];
    _aptTableView.contentInset = UIEdgeInsetsMake(6, 0, 0, 0);
    [self.view addSubview:_aptTableView];
    _aptTableView.estimatedRowHeight = 0;
    _aptTableView.estimatedSectionHeaderHeight = 0;
    _aptTableView.estimatedSectionFooterHeight = 0;
    
    [_aptTableView registerNib:[UINib nibWithNibName:@"WifiUserInfoCell" bundle:nil] forCellReuseIdentifier:@"WifiUserInfoCell"];
    
    _aptTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 0;
        [self loadWifiUserData];
    }];
    _aptTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self loadWifiUserData];
    }];
    //    _tabView.mj_footer.automaticallyHidden = NO;
    _aptTableView.mj_footer.hidden = YES;
}

#pragma mark 加载用户数据
- (void)loadWifiUserData {
    // 获取ap下用户列表,getDetail =device_id,layerId=楼层id,getAns="false"
    // 获取ap分析数据,getDetail =device,layerId=楼层id,getAns="true"
    NSString *urlStr;
    NSString *searchStr;
    if(_searchBar.text != nil && _searchBar.text.length > 0){
        searchStr = _searchBar.text;
    }else {
        searchStr = @"ALL";
    }
    if(_isALl){
        urlStr = [NSString stringWithFormat:@"%@/wifi/getWifiUserDetail?getDetail=%@&layerId=%@&getAns=%@&start=%d&limit=%d",Main_Url, searchStr, @"", @"", _page*_length, _length];
    }else {
        urlStr = [NSString stringWithFormat:@"%@/wifi/getWifiUserDetail?getDetail=%@&layerId=%@&getAns=%@&start=%d&limit=%d",Main_Url, _inDoorWifiModel.DEVICE_ID, _inDoorWifiModel.LAYER_ID, @"false", _page*_length, _length];
    }
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        [_aptTableView.mj_header endRefreshing];
        [_aptTableView.mj_footer endRefreshing];
        
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            NSDictionary *responseData = responseObject[@"responseData"];
            NSArray *wifiList = responseData[@"WifiUserList"];
            
            if(_page == 0){
                [_userData removeAllObjects];
            }
            if(wifiList.count > _length-1){
                _aptTableView.mj_footer.state = MJRefreshStateIdle;
                _aptTableView.mj_footer.hidden = NO;
            }else {
                _aptTableView.mj_footer.state = MJRefreshStateNoMoreData;
                _aptTableView.mj_footer.hidden = YES;
            }
            
            [wifiList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                WifiUserModel *wifiUserModel = [[WifiUserModel alloc] initWithDataDic:obj];
                [_userData addObject:wifiUserModel];
            }];
            [_aptTableView cyl_reloadData];
        }
        
    } failure:^(NSError *error) {
        [_aptTableView.mj_header endRefreshing];
        [_aptTableView.mj_footer endRefreshing];
        if(_userData.count <= 0){
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
    [self loadWifiUserData];
}

#pragma mark UITableView协议
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _userData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WifiUserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WifiUserInfoCell" forIndexPath:indexPath];
    cell.wifiUserModel = _userData[indexPath.row];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.001;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WifiUserInfoDetailController *wifiUserInfoDetailVc = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"WifiUserInfoDetailController"];
    wifiUserInfoDetailVc.wifiUserModel = _userData[indexPath.row];
    [self.navigationController pushViewController:wifiUserInfoDetailVc animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
    _page = 0;
    [self loadWifiUserData];
}

@end
