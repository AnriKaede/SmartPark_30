//
//  OperateLogViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/13.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "OperateLogViewController.h"
#import "LogCell.h"
#import "NoDataView.h"
#import "OperateLogModel.h"
#import "DCSildeBarView.h"

#import "OperateDetailViewController.h"

#import "LogFilterView.h"

@interface OperateLogViewController ()<UITableViewDelegate, UITableViewDataSource, CYLTableViewPlaceHolderDelegate, LogFilterTimeDelegate>
{
    UITableView *_logTableView;
    NSMutableArray *_logData;
    
    NSInteger _page;
    NSInteger _length;
    
    NSMutableDictionary *_filterDic;
    
    LogFilterView *_logFilterView;
    UIButton *filtrateBtn;
}
@end

@implementation OperateLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _logData = @[].mutableCopy;
    _filterDic = @{}.mutableCopy;
    _page = 1;
    _length = 8;
    
    [self _initView];
    
    [_logTableView.mj_header beginRefreshing];
    
}

- (void)_initView {
    self.title = @"操作日志";
    
    filtrateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [filtrateBtn addTarget:self action:@selector(filtrateBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [filtrateBtn setImage:[UIImage imageNamed:@"nav_filter_down"] forState:UIControlStateNormal];
    [filtrateBtn setImage:[UIImage imageNamed:@"apt_filter_right_up"] forState:UIControlStateSelected];
    [filtrateBtn setTitle:@"筛选" forState:UIControlStateNormal];
    // button标题的偏移量
    filtrateBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -24, 0, filtrateBtn.imageView.bounds.size.width);
    // button图片的偏移量
    filtrateBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 37, 0, -filtrateBtn.titleLabel.bounds.size.width);
    [filtrateBtn sizeToFit];
    UIBarButtonItem *filtrateBtnItem = [[UIBarButtonItem alloc] initWithCustomView:filtrateBtn];
    
    self.navigationItem.rightBarButtonItem  = filtrateBtnItem;
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _logTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64) style:UITableViewStylePlain];
    _logTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _logTableView.tableFooterView = [UIView new];
    _logTableView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    _logTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _logTableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    _logTableView.dataSource = self;
    _logTableView.delegate = self;
    [self.view addSubview:_logTableView];
    
    _logTableView.estimatedRowHeight = 0;
    _logTableView.estimatedSectionHeaderHeight = 0;
    _logTableView.estimatedSectionFooterHeight = 0;
    
    [_logTableView registerNib:[UINib nibWithNibName:@"LogCell" bundle:nil] forCellReuseIdentifier:@"LogCell"];
    
    _logTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self _loadData];
    }];
    // 上拉刷新
    _logTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self _loadData];
    }];
//    _logTableView.mj_footer.automaticallyHidden = NO;
    _logTableView.mj_footer.hidden = YES;
    
    // 筛选视图
    _logFilterView = [[LogFilterView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    _logFilterView.filterTimeDelegate = self;
    [self.view addSubview:_logFilterView];
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)filtrateBtnClick {
    filtrateBtn.selected = !filtrateBtn.selected;
    //    [DCSildeBarView dc_showSildBarViewController:LogFilter];
    _logFilterView.hidden = !filtrateBtn.selected;
}

// 筛选通知
- (void)filterDataDic:(NSDictionary *)filterDic {
    _page = 1;
    [_logData removeAllObjects];
    
    [_logTableView reloadData];
    
    _filterDic = filterDic.mutableCopy;
    [_logTableView.mj_header beginRefreshing];
}

#pragma mark 加载数据
- (void)_loadData {
    /*
    入参 {“param”:
        “{
            "userId":"123"
            ,"pageNum":"1",
            "pageSize":"5",
            "startDate":"2018/2/6 16:14:58",
            "endDate":"2018/2/6 16:14:59",
            "userName":"sdf",
            "operateName":"开门",
            "operateDes":"打开门禁"
        }
     */
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/operateLog/getOperateLogList", Main_Url];
//    NSString *urlStr = [NSString stringWithFormat:@"%@/operateLog/getOperateLogList", @"http://192.168.1.127:8080/hntfEsb"];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:[NSNumber numberWithInteger:_page] forKey:@"pageNum"];
    [paramDic setObject:[NSNumber numberWithInteger:_length] forKey:@"pageSize"];
    
//    if([_filterDic.allKeys containsObject:@"userId"]){
//        [paramDic setObject:_filterDic[@"userId"] forKey:@"userId"];
//    }
    if([_filterDic.allKeys containsObject:@"userName"]){
        [paramDic setObject:_filterDic[@"userName"] forKey:@"userName"];
    }
    if([_filterDic.allKeys containsObject:@"startDate"]){
        [paramDic setObject:_filterDic[@"startDate"] forKey:@"startDate"];
    }
    if([_filterDic.allKeys containsObject:@"endDate"]){
        [paramDic setObject:_filterDic[@"endDate"] forKey:@"endDate"];
    }
    if([_filterDic.allKeys containsObject:@"operateDes"]){
        [paramDic setObject:_filterDic[@"operateDes"] forKey:@"operateDes"];
    }
//    if([_filterDic.allKeys containsObject:@"operateName"]){
//        [paramDic setObject:_filterDic[@"operateName"] forKey:@"operateName"];
//    }
    
    NSString *paramStr = [self convertToJsonData:paramDic];
    NSDictionary *params = @{@"param":paramStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        
        [_logTableView.mj_header endRefreshing];
        [_logTableView.mj_footer endRefreshing];
        
        NSNumber *code = responseObject[@"code"];
        
        if (code != nil && ![code isKindOfClass:[NSNull class]] && code.integerValue == 100) {
            if(_page == 1){
                [_logData removeAllObjects];
            }
            
            NSDictionary *dic = responseObject[@"extend"][@"pageInfo"];
            NSArray *arr = dic[@"list"];
            
            if(arr.count > _length-1){
                _logTableView.mj_footer.state = MJRefreshStateIdle;
                _logTableView.mj_footer.hidden = NO;
            }else {
                _logTableView.mj_footer.state = MJRefreshStateNoMoreData;
                _logTableView.mj_footer.hidden = YES;
            }
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                OperateLogModel *model = [[OperateLogModel alloc] initWithDataDic:obj];
                [_logData addObject:model];
            }];
            
            [_logTableView cyl_reloadData];
        }
        
    } failure:^(NSError *error) {
        [_logTableView.mj_header endRefreshing];
        [_logTableView.mj_footer endRefreshing];
        
        if(_logData.count <= 0){
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
    NoDataView *noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 60, KScreenWidth, KScreenHeight - 63)];
    return noDataView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark UItableView 协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _logData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 185;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LogCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogCell" forIndexPath:indexPath];
    cell.operateLogModel = _logData[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OperateLogModel *operateLogModel = _logData[indexPath.row];
    
    OperateDetailViewController *detailVC = [[UIStoryboard storyboardWithName:@"Personal" bundle:nil] instantiateViewControllerWithIdentifier:@"OperateDetailViewController"];
    detailVC.operateLogModel = operateLogModel;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (NSString *)convertToJsonData:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range];
    return mutStr;
}

#pragma mark 筛选
- (void)closeFilter {
    filtrateBtn.selected = NO;
}
- (void)resetFilter {
    [_filterDic removeAllObjects];
}
- (void)filterWithStart:(NSString *)startTime withEndTime:(NSString *)endTime withOperateMan:(NSString *)operateMan withOperateKey:(NSString *)operateKey {
    NSMutableDictionary *infoDic = @{@"startDate":startTime,
                                     @"endDate":endTime,
                                     }.mutableCopy;
    
    if(operateMan != nil && operateMan.length > 0){
        [infoDic setObject:operateMan forKey:@"userId"];
        [infoDic setObject:operateMan forKey:@"userName"];
    }
    if(operateKey != nil && operateKey.length > 0){
        [infoDic setObject:operateKey forKey:@"operateName"];
        [infoDic setObject:operateKey forKey:@"operateDes"];
    }
    
    [self filterDataDic:infoDic];
    [self closeFilter];
}

@end
