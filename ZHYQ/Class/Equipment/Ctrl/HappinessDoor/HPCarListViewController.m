//
//  HPCarListViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/28.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "HPCarListViewController.h"
#import "HpCarCell.h"
#import "HpCarModel.h"
#import "ParkRecordCenViewController.h"

@interface HPCarListViewController ()<UITableViewDelegate, UITableViewDataSource, CYLTableViewPlaceHolderDelegate>
{
    UITableView *_carTableView;
    NSMutableArray *_carData;
    
    NSInteger _page;
    NSInteger _length;
    
    NoDataView *_noDataView;
}
@end

@implementation HPCarListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _carData = @[].mutableCopy;
    
    _page = 1;
    _length = 10;
    
    [self _initView];
    
    [self loadCarData];
}
- (void)_initView {
    self.view.backgroundColor = [UIColor colorWithHexString:@"#EFEFEF"];
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _carTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight - 40) style:UITableViewStylePlain];
    _carTableView.backgroundColor = [UIColor colorWithHexString:@"#EFEFEF"];
    _carTableView.delegate = self;
    _carTableView.dataSource = self;
    _carTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _carTableView.backgroundColor = [UIColor clearColor];
    [_carTableView registerNib:[UINib nibWithNibName:@"HpCarCell" bundle:nil] forCellReuseIdentifier:@"HpCarCell"];
    [self.view addSubview:_carTableView];
    
    _carTableView.estimatedRowHeight = 0;
    _carTableView.estimatedSectionHeaderHeight = 0;
    _carTableView.estimatedSectionFooterHeight = 0;
    
    _carTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self loadCarData];
    }];
    // 上拉刷新
    _carTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self loadCarData];
    }];

    _carTableView.mj_footer.hidden = YES;
}

-(void)_leftBarBtnItemClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 请求数据
- (void)loadCarData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/fumenController/getAllCarParking", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:[NSNumber numberWithInteger:_page] forKey:@"pageNumber"];
    [paramDic setObject:[NSNumber numberWithInteger:_length] forKey:@"pageSize"];
    NSString *paramStr = [Utils convertToJsonData:paramDic];
    NSDictionary *params = @{@"param":paramStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        
        [_carTableView.mj_header endRefreshing];
        [_carTableView.mj_footer endRefreshing];
        
        NSString *code = responseObject[@"code"];
        
        if (code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]) {
            NSArray *responseData = responseObject[@"responseData"];
            if(_page == 1){
                [_carData removeAllObjects];
            }
            
            if(responseData.count > 0){
                NSDictionary *dic = responseData.firstObject;
                NSArray *arr = dic[@"returnList"];
                if(arr.count > _length-1){
                    _carTableView.mj_footer.state = MJRefreshStateIdle;
                    _carTableView.mj_footer.hidden = NO;
                }else {
                    _carTableView.mj_footer.state = MJRefreshStateNoMoreData;
                    _carTableView.mj_footer.hidden = YES;
                }
                [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    HpCarModel *model = [[HpCarModel alloc] initWithDataDic:obj];
                    [_carData addObject:model];
                }];
            }
        }
        
        [_carTableView cyl_reloadData];
        
    } failure:^(NSError *error) {
        [_carTableView.mj_header endRefreshing];
        [_carTableView.mj_footer endRefreshing];
        
        if(_carData.count <= 0){
            [self showNoDataImage];
        }else {
            [self showHint:KRequestFailMsg];
        }
    }];
}

// 无网络重载
- (void)reloadTableData {
    [self loadCarData];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDateView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64 - 200)];
    return noDateView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark UITableView 协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _carData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 95;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HpCarCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HpCarCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.hpCarModel = _carData[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HpCarModel *hpCarModel = _carData[indexPath.row];
    
    ParkRecordCenViewController *parkRecordCenVC = [[ParkRecordCenViewController alloc] init];
    parkRecordCenVC.carNo = [NSString stringWithFormat:@"%@", hpCarModel.TRACE_CARNO];
    [self.navigationController pushViewController:parkRecordCenVC animated:YES];
}

@end
