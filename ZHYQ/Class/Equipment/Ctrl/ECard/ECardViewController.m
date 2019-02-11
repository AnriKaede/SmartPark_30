//
//  ECardViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/11.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ECardViewController.h"
#import "YQHeaderView.h"
#import "ECardListCell.h"
#import "ECardEditViewController.h"
#import "CRSearchBar.h"
#import "NoDataView.h"

#import "ECardInfoModel.h"

@interface ECardViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, CYLTableViewPlaceHolderDelegate>
{
    __weak IBOutlet YQHeaderView *_yqHeader;
    
    __weak IBOutlet UITableView *_eCardTableView;
    
    __weak IBOutlet CRSearchBar *_searchBar;
    
    NSMutableArray *_eCardData;

    NSInteger _page;
    NSInteger _length;
    
    NoDataView *noDateView;
}
@end

@implementation ECardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _eCardData = @[].mutableCopy;
    _page = 1;
    _length = 15;
    
    [self _initView];
}

- (void)_initView {
//    self.title = @"一卡通";
    // 添加渐变色
    [NavGradient viewAddGradient:_yqHeader];
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    /*
    UIButton *rightBtn = [[UIButton alloc] init];
    rightBtn.frame = CGRectMake(0, 0, 40, 40);
    [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [rightBtn setImage:[UIImage imageNamed:@"search_icon"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(_rightBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
     */
    
    _searchBar.leftImage = [UIImage imageNamed:@"icon_search"];
    _searchBar.placeholderColor = [UIColor colorWithHexString:@"#E2E2E2"];
    _searchBar.placeholder = @"请输入员工姓名或工号";
    _searchBar.delegate = self;
    _searchBar.backgroundColor = [UIColor clearColor];
    _searchBar.backgroundImage = [UIImage imageWithColor:[UIColor clearColor]];
    _searchBar.searchTextPositionAdjustment = UIOffsetMake(0, 2);
    [_searchBar becomeFirstResponder];
    
    _eCardTableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    
    // ios 11tableView闪动
    _eCardTableView.estimatedRowHeight = 0;
    _eCardTableView.estimatedSectionHeaderHeight = 0;
    _eCardTableView.estimatedSectionFooterHeight = 0;
    
    _eCardTableView.tableFooterView = [UIView new];
    
    [_eCardTableView registerNib:[UINib nibWithNibName:@"ECardListCell" bundle:nil] forCellReuseIdentifier:@"ECardListCell"];
    
    _eCardTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self _loadData];
    }];
    // 上拉刷新
    _eCardTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self _loadData];
    }];
//    _eCardTableView.mj_footer.automaticallyHidden = NO;
    _eCardTableView.mj_footer.hidden = YES;
    
}
- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)_rightBarBtnItemClick {
    
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    noDateView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - _searchBar.bottom - 64)];
    return noDateView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark UItableView 协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _eCardData.count;
//    return 15;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 61;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
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
    ECardListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ECardListCell" forIndexPath:indexPath];
    cell.eCardInfoModel = _eCardData[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    ECardEditViewController *eCardVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"ECardEditViewController"];
    ECardEditViewController *eCardVC = [[ECardEditViewController alloc] initWithStyle:UITableViewStylePlain];
    eCardVC.eCardInfoModel = _eCardData[indexPath.row];
    [self.navigationController pushViewController:eCardVC animated:YES];
}

#pragma mark searchBar delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_eCardData removeAllObjects];
    _page = 1;
    
    [self.view endEditing:YES];
    [self _loadData];
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parkCard/users",Main_Url];
    
    NSMutableDictionary *searchParam = @{}.mutableCopy;
    [searchParam setObject:_searchBar.text forKey:@"basePerName"];
    [searchParam setObject:[NSNumber numberWithInteger:_length] forKey:@"pageSize"];
    [searchParam setObject:[NSNumber numberWithInteger:_page] forKey:@"pageNumber"];
    
    NSString *jsonStr = [Utils convertToJsonData:searchParam];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        
        [_eCardTableView.mj_header endRefreshing];
        [_eCardTableView.mj_footer endRefreshing];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSArray *items = responseObject[@"responseData"][@"items"];
            if(items.count > _length-1){
                _eCardTableView.mj_footer.state = MJRefreshStateIdle;
                _eCardTableView.mj_footer.hidden = NO;
            }else {
                _eCardTableView.mj_footer.state = MJRefreshStateNoMoreData;
                _eCardTableView.mj_footer.hidden = YES;
            }
            if(_page == 1){
                [_eCardData removeAllObjects];
            }
            [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ECardInfoModel *model = [[ECardInfoModel alloc] initWithDataDic:obj];
                [_eCardData addObject:model];
            }];
        }
        
        noDateView.hidden = NO;
        [_eCardTableView cyl_reloadData];
    } failure:^(NSError *error) {
        [_eCardTableView.mj_header endRefreshing];
        [_eCardTableView.mj_footer endRefreshing];
        
        noDateView.hidden = YES;
        
        if(_eCardData.count <= 0){
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

@end
