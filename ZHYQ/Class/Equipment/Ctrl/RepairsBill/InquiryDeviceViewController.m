//
//  InquiryDeviceViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2018/4/19.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "InquiryDeviceViewController.h"
#import "CRSearchBar.h"
#import "InquiryDeviceTableViewCell.h"

#import "DeviceInfoModel.h"

@interface InquiryDeviceViewController ()<UISearchBarDelegate>
{
    __weak IBOutlet CRSearchBar *searchBar;
    NSMutableArray *_deviceData;
    
    NSInteger _page;
    NSInteger _length;
    
    NSString *_deviceName;
    
    NoDataView *_noDataView;
}

@end

@implementation InquiryDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _deviceData = @[].mutableCopy;
    _deviceName = @"";
    
    _page = 1;
    _length = 15;
    
    [self _initNavItems];
    
    [self _initView];
    
    [self _loadData];
}

-(void)_initNavItems
{
    self.title = @"设备ID查询";
    
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

-(void)_initView
{
    searchBar.leftImage = [UIImage imageNamed:@"icon_search"];
    searchBar.placeholderColor = [UIColor colorWithHexString:@"#E2E2E2"];
    searchBar.placeholder = @"请输入设备关键字";
    searchBar.delegate = self;
    searchBar.backgroundColor = [UIColor whiteColor];
    searchBar.backgroundImage = [UIImage imageWithColor:[UIColor clearColor]];
    searchBar.searchTextPositionAdjustment = UIOffsetMake(0, 2);
//    [searchBar becomeFirstResponder];
    
    // ios 11tableView闪动
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    self.tableView.tableFooterView = [UIView new];
//    self.tableView.bounces = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"InquiryDeviceTableViewCell" bundle:nil] forCellReuseIdentifier:@"InquiryDeviceTableViewCell"];
    
    /*
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self _loadData];
    }];
     */
    // 上拉刷新
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self _loadData];
    }];
//    self.tableView.mj_footer.automaticallyHidden = NO;
    self.tableView.mj_footer.hidden = YES;
    
    _noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 100, KScreenWidth, KScreenHeight - kTopHeight - 100)];
    _noDataView.hidden = YES;
    _noDataView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_noDataView];
}

- (void)_loadData {
    /*
    if(_page == 1){
        [_billData removeAllObjects];
    }
    
    NSArray *data = responseObject[@"responseData"][@"items"];
    
    if(data.count > _length-1){
        self.tableView.mj_footer.state = MJRefreshStateIdle;
    }else {
        self.tableView.mj_footer.state = MJRefreshStateNoMoreData;
    }
     */
    NSString *urlStr = [NSString stringWithFormat:@"%@/deviceView/queryDeviceListPageByName", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:_deviceName forKey:@"deviceName"];
    [paramDic setObject:[NSNumber numberWithInteger:_page] forKey:@"pageNumber"];
    [paramDic setObject:[NSNumber numberWithInteger:_length] forKey:@"pageSize"];
    
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] GET:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            
            if(_page == 1){
                [_deviceData removeAllObjects];
            }
            
            NSArray *data = responseObject[@"responseData"][@"items"];
            
            if(data.count > _length-1){
                self.tableView.mj_footer.state = MJRefreshStateIdle;
            }else {
                self.tableView.mj_footer.state = MJRefreshStateNoMoreData;
            }
            
            [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DeviceInfoModel *model = [[DeviceInfoModel alloc] initWithDataDic:obj];
                [_deviceData addObject:model];
            }];
            [self.tableView reloadData];
            
            if(_deviceData.count <= 0){
                _noDataView.hidden = NO;
            }else {
                _noDataView.hidden = YES;
            }
        }
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [self showHint:KRequestFailMsg];
    }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _deviceData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InquiryDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InquiryDeviceTableViewCell" forIndexPath:indexPath];
    if(_deviceData.count > indexPath.row){    
        cell.deviceInfoModel = _deviceData[indexPath.row];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 61;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_selDeviceDelegate && [_selDeviceDelegate respondsToSelector:@selector(selDevice:)]){
        [_selDeviceDelegate selDevice:_deviceData[indexPath.row]];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView.contentOffset.y <= 0){
        scrollView.contentOffset = CGPointMake(0, 0);
    }
}

#pragma mark 搜索按钮点击
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
    
    _deviceName = searchBar.text;
    _page = 1;
    [self _loadData];
}

@end
