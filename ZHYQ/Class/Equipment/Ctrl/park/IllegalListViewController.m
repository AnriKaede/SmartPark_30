//
//  IllegalListViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/8.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "IllegalListViewController.h"
#import "IllegalListTabCell.h"
#import "IllegaListModel.h"

#import "YQSearchBar.h"

#import "CalculateHeight.h"
#import "IllegalDetailViewController.h"

#import "NoDataView.h"

@interface IllegalListViewController ()<UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate, CYLTableViewPlaceHolderDelegate>
{
    NSMutableArray *_illegaData;
    
    int _page;
    int _length;
}
@property (nonatomic,strong) UITableView *tabView;

@end

@implementation IllegalListViewController

-(UITableView *)tabView
{
    if (_tabView == nil) {
        _tabView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tabView.dataSource = self;
//        _tabView.bounces = NO;
        _tabView.delegate = self;
        _tabView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tabView.showsVerticalScrollIndicator = NO;
        _tabView.showsHorizontalScrollIndicator = NO;
        _tabView.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    }
    return _tabView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    
    _illegaData = @[].mutableCopy;
    _page = 0;
    _length = 10;
    
    [self _initView];
    
    [self _loadData:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:@"RefreshIllegaList" object:nil];
}

-(void)_initView
{
    self.view.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    
    YQSearchBar *searchBar = [[YQSearchBar alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 44)];
    searchBar.placeholder = @"请输入车牌号";
    [searchBar setImage:[UIImage imageNamed:@"search_icon"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    searchBar.delegate = self;
    [self.view addSubview:searchBar];
    
    [self.view addSubview:self.tabView];
    [_tabView registerNib:[UINib nibWithNibName:@"IllegalListTabCell" bundle:nil] forCellReuseIdentifier:@"IllegalListTabCell"];
    _tabView.frame = CGRectMake(0, CGRectGetMaxY(searchBar.frame), KScreenWidth, KScreenHeight-64-CGRectGetMaxY(searchBar.frame)-49);
    _tabView.contentInset = UIEdgeInsetsMake(5, 0, 5, 0);
    
    _tabView.estimatedRowHeight = 0;
    _tabView.estimatedSectionHeaderHeight = 0;
    _tabView.estimatedSectionFooterHeight = 0;
    
    _tabView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 0;
        [self _loadData:nil];
    }];
    // 上拉刷新
    _tabView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self _loadData:nil];
    }];
//    _tabView.mj_footer.automaticallyHidden = NO;
    _tabView.mj_footer.hidden = YES;
}

- (void)refreshData {
    _page = 0;
    [self _loadData:nil];
}

- (void)_loadData:(NSString *)carno {
    NSString *illegaUrl = [NSString stringWithFormat:@"%@/operaIllegal/getIllegalLogs", ParkMain_Url];
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setValue:[NSNumber numberWithInt:_page * _length] forKey:@"start"];
    [param setValue:[NSNumber numberWithInt:_length] forKey:@"length"];
    if(carno != nil && carno.length > 0){
        [param setValue:carno forKey:@"illegalCarno"];
    }
    [[NetworkClient sharedInstance] POST:illegaUrl dict:param progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        [_tabView.mj_header endRefreshing];
        [_tabView.mj_footer endRefreshing];
        
        if([responseObject[@"success"] boolValue]){
            // 判断是否是搜索
            if(carno != nil && carno.length > 0){
                _page = 0;
            }
            
            if(_page == 0){
                [_illegaData removeAllObjects];
            }
            NSArray *data = responseObject[@"data"][@"data"];
            if(data.count > _length-1){
                _tabView.mj_footer.state = MJRefreshStateIdle;
                _tabView.mj_footer.hidden = NO;
            }else {
                _tabView.mj_footer.state = MJRefreshStateNoMoreData;
                _tabView.mj_footer.hidden = YES;
            }
            
            [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                IllegaListModel *model = [[IllegaListModel alloc] initWithDataDic:obj];
                if(model.illegalContent != nil && ![model.illegalContent isKindOfClass:[NSNull class]]){
                    model.illegalContent = [NSString stringWithFormat:@"违停说明：%@",model.illegalContent];
                }else {
                    model.illegalContent = [NSString stringWithFormat:@"违停说明："];
                }
                [_illegaData addObject:model];
            }];
            [self.tabView cyl_reloadData];
        }
        
    } failure:^(NSError *error) {
        [_tabView.mj_header endRefreshing];
        [_tabView.mj_footer endRefreshing];
        if(_illegaData.count <= 0){
            [self showNoDataImage];
        }else {
            [self showHint:KRequestFailMsg];
        }
    }];
}
// 无网络重载
- (void)reloadTableData {
    [self _loadData:nil];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDateView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64-49)];
    return noDateView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark tableview delegate and datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _illegaData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IllegalListTabCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IllegalListTabCell" forIndexPath:indexPath];
    cell.illegaListModel = _illegaData[indexPath.row];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IllegaListModel *illegaListModel = _illegaData[indexPath.row];
    CGFloat conHeight;
    if(illegaListModel.illegalContent != nil && ![illegaListModel.illegalContent isKindOfClass:[NSNull class]]){
        conHeight = [CalculateHeight heightForString:illegaListModel.illegalContent fontSize:16 andWidth:KScreenWidth - 20];
    }else {
        conHeight = 10;
    }
    return 80 + conHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view endEditing:YES];
    
    IllegaListModel *illegaListModel = _illegaData[indexPath.row];
    IllegalDetailViewController *illDelVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"IllegalDetailViewController"];
    illDelVC.illegaListModel = illegaListModel;
//    [self.navigationController pushViewController:illDelVC animated:YES];
    illDelVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:[[RootNavigationController alloc] initWithRootViewController:illDelVC] animated:YES completion:^{
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark searchBar delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
    [self _loadData:searchBar.text];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RefreshIllegaList" object:nil];
}

@end
