//
//  EnvDetDataViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/2/28.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "EnvDetDataViewController.h"
#import "NoDataView.h"
#import "EnvTimeCell.h"
#import "EvnDelModel.h"

@interface EnvDetDataViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_evnTableView;
    NSMutableArray *_evnData;
    
    NSInteger _page;
    NSInteger _length;
}
@end

@implementation EnvDetDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _evnData = @[].mutableCopy;
    
    _page = 1;
    _length = 10;
    
    [self _initView];
    
    [self _loadData];
}

- (void)_initView {
    self.view.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _evnTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64 - 60) style:UITableViewStylePlain];
    _evnTableView.tableFooterView = [UIView new];
    _evnTableView.backgroundColor = [UIColor whiteColor];
    _evnTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _evnTableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    _evnTableView.delegate = self;
    _evnTableView.dataSource = self;
    [self.view addSubview:_evnTableView];
    
    // ios 11tableView闪动
    _evnTableView.estimatedRowHeight = 0;
    _evnTableView.estimatedSectionHeaderHeight = 0;
    _evnTableView.estimatedSectionFooterHeight = 0;
    
    [_evnTableView registerNib:[UINib nibWithNibName:@"EnvTimeCell" bundle:nil] forCellReuseIdentifier:@"EnvTimeCell"];
    
    _evnTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self _loadData];
    }];
    
    _evnTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self _loadData];
    }];
//    _evnTableView.mj_footer.automaticallyHidden = NO;
    _evnTableView.mj_footer.hidden = YES;
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 加载数据
- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/irrigation/sensor/info",Main_Url];
    
    NSMutableDictionary *searchParam = @{}.mutableCopy;
    [searchParam setObject:[NSNumber numberWithInteger:_length] forKey:@"pagesize"];
    [searchParam setObject:[NSNumber numberWithInteger:_page] forKey:@"pagenum"];
    [searchParam setObject:_evnDataModel.device_id forKey:@"device_id"];
    
//    NSString *jsonStr = [Utils convertToJsonData:searchParam];
//    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:searchParam progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        
        [_evnTableView.mj_header endRefreshing];
        [_evnTableView.mj_footer endRefreshing];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSArray *items = responseObject[@"responseData"];
            if(items.count > _length-1){
                _evnTableView.mj_footer.state = MJRefreshStateIdle;
                _evnTableView.mj_footer.hidden = NO;
            }else {
                _evnTableView.mj_footer.state = MJRefreshStateNoMoreData;
                _evnTableView.mj_footer.hidden = YES;
            }
            if(_page == 1){
                [_evnData removeAllObjects];
            }
            [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                EvnDelModel *model = [[EvnDelModel alloc] initWithDataDic:obj];
                [_evnData addObject:model];
            }];
        }
        
        [_evnTableView cyl_reloadData];
        
    } failure:^(NSError *error) {
        [_evnTableView.mj_header endRefreshing];
        [_evnTableView.mj_footer endRefreshing];
        
        if(_evnData.count <= 0){
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
    NoDataView *noDateView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64)];
    return noDateView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}


#pragma mark UITableView 协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _evnData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EnvTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EnvTimeCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.evnDelModel = _evnData[indexPath.row];
    cell.evnDataModel = _evnDataModel;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
