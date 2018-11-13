//
//  EnvDataViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/2/28.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "EnvDataViewController.h"
#import "NoDataView.h"
#import "EnvDetailPageViewController.h"
#import "EvnDataModel.h"
#import "EvnDataCell.h"

@interface EnvDataViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_evnTableView;
    NSMutableArray *_evnData;
}
@end

@implementation EnvDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _evnData = @[].mutableCopy;
    
    [self _initView];
    
    [self _loadData];
}

- (void)_initView {
    self.title = @"环境数据";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _evnTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64) style:UITableViewStylePlain];
    _evnTableView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    _evnTableView.tableFooterView = [UIView new];
    _evnTableView.delegate = self;
    _evnTableView.dataSource = self;
    _evnTableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    _evnTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.view addSubview:_evnTableView];
    
    [_evnTableView registerNib:[UINib nibWithNibName:@"EvnDataCell" bundle:nil] forCellReuseIdentifier:@"EvnDataCell"];
    
    _evnTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self _loadData];
    }];
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/irrigation/sensor",Main_Url];
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        
        [_evnTableView.mj_header endRefreshing];
        [_evnData removeAllObjects];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSArray *responseData = responseObject[@"responseData"];
            
            [responseData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                EvnDataModel *model = [[EvnDataModel alloc] initWithDataDic:obj];
                [_evnData addObject:model];
            }];
        }
        [_evnTableView reloadData];
    } failure:^(NSError *error) {
        [_evnTableView.mj_header endRefreshing];
        
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
    return 80;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EvnDataCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EvnDataCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.evnDataModel = _evnData[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EvnDataModel *evnDataModel = _evnData[indexPath.row];
    
    EnvDetailPageViewController *envDetailPageVC = [[EnvDetailPageViewController alloc] init];
    envDetailPageVC.evnDataModel = evnDataModel;
    [self.navigationController pushViewController:envDetailPageVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
