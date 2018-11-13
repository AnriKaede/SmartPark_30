//
//  VisSearchViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/24.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "VisSearchViewController.h"
#import "CRSearchBar.h"
#import "VisitorFinishModel.h"
#import "NoDataView.h"
#import "VisitedTableViewCell.h"

@interface VisSearchViewController ()<UISearchBarDelegate,UITableViewDelegate, UITableViewDataSource, isArraiveCallTelePhoneDelegate>
{
    CRSearchBar *_searchBar;
    NSMutableArray *_visData;
    
    UITableView *_visTableView;
    
    NSInteger _page;
    NSInteger _length;
    
    NoDataView *noDateView;
}
@end

@implementation VisSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _visData = @[].mutableCopy;
    _page = 1;
    _length = 10;
    
    [self _initView];
}

- (void)_initView {
    self.title = @"访客搜索";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _searchBar = [[CRSearchBar alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 50)];
    _searchBar.leftImage = [UIImage imageNamed:@"icon_search"];
    _searchBar.placeholderColor = [UIColor colorWithHexString:@"#E2E2E2"];
    _searchBar.placeholder = @"请输入访客姓名";
    _searchBar.delegate = self;
    _searchBar.backgroundColor = [UIColor clearColor];
    _searchBar.backgroundImage = [UIImage imageWithColor:[UIColor clearColor]];
    _searchBar.searchTextPositionAdjustment = UIOffsetMake(0, 2);
    [_searchBar becomeFirstResponder];
    [self.view addSubview:_searchBar];
    
    _visTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _searchBar.bottom, KScreenWidth, KScreenHeight - _searchBar.bottom) style:UITableViewStylePlain];
    _visTableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    _visTableView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    _visTableView.tableFooterView = [UIView new];
    _visTableView.delegate = self;
    _visTableView.dataSource = self;
    [_visTableView registerNib:[UINib nibWithNibName:@"VisitedTableViewCell" bundle:nil] forCellReuseIdentifier:@"VisitedTableViewCell"];
    [self.view addSubview:_visTableView];
    
    _visTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self _loadData];
    }];
    // 上拉刷新
    _visTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self _loadData];
    }];
//    _visTableView.mj_footer.automaticallyHidden = NO;
    _visTableView.mj_footer.hidden = YES;
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark searchBar delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_visData removeAllObjects];
    _page = 1;
    
    [self.view endEditing:YES];
    [self _loadData];
}

#pragma mark 加载数据
- (void)_loadData {
//    if(_searchBar.text == nil || _searchBar.text.length <= 0){
//        [self showHint:@"请输入访客姓名"];
//        return;
//    }
    
    // 请求访客数据
    NSString *urlStr = [NSString stringWithFormat:@"%@/visitor/detail",Main_Url];
    
    NSMutableDictionary *searchParam = @{}.mutableCopy;
    [searchParam setObject:[NSNumber numberWithInteger:_length] forKey:@"pageSize"];
    [searchParam setObject:[NSNumber numberWithInteger:_page] forKey:@"pageNumber"];
    [searchParam setObject:@"0" forKey:@"type"];
    [searchParam setObject:_searchBar.text forKey:@"visitorName"];
    
    NSString *jsonStr = [Utils convertToJsonData:searchParam];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        
        [self removeNoDataImage];
        noDateView.hidden = NO;
        
        [_visTableView.mj_header endRefreshing];
        [_visTableView.mj_footer endRefreshing];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSArray *items = responseObject[@"responseData"][@"items"];
            if(items.count > _length-1){
                _visTableView.mj_footer.state = MJRefreshStateIdle;
                _visTableView.mj_footer.hidden = NO;
            }else {
                _visTableView.mj_footer.state = MJRefreshStateNoMoreData;
                _visTableView.mj_footer.hidden = YES;
            }
            if(_page == 1){
                [_visData removeAllObjects];
            }
            [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                VisitorFinishModel *model = [[VisitorFinishModel alloc] initWithDataDic:obj];
                [_visData addObject:model];
            }];
        }
        
        [_visTableView cyl_reloadData];
        
    } failure:^(NSError *error) {
        [_visTableView.mj_header endRefreshing];
        [_visTableView.mj_footer endRefreshing];
        
        noDateView.hidden = YES;
        if(_visData.count <= 0){
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
    noDateView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 60)];
    return noDateView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark UITableView 协议
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _visData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VisitedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VisitedTableViewCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.visitorFinishModel = _visData[indexPath.row];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 275;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

#pragma mark 拨打电话代理
-(void)isArraiveCallTelePhone:(NSString *)telephone
{
    //获取目标号码字符串,转换成URL
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",telephone]];
    //调用系统方法拨号
    [kApplication openURL:url];
}

@end
