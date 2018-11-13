//
//  OpenRecordViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/11.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "OpenRecordViewController.h"
#import "OpenRecordCell.h"

#import "OpenRecordModel.h"

#import "NoDataView.h"

@interface OpenRecordViewController ()<UITableViewDelegate, UITableViewDataSource, CYLTableViewPlaceHolderDelegate>
{
    UITableView *_openRecTableView;
    
//    NSMutableArray *_openRecData;
    
    NSInteger _page;
    NSInteger _length;
}

@property (nonatomic,strong) NSMutableArray *dataArr;

@end

@implementation OpenRecordViewController

-(NSMutableArray *)dataArr
{
    if (_dataArr == nil) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    _openRecData = @[].mutableCopy;
    
    _page = 1;
    _length = 10;
    
    [self _initView];
    
    [self _loadData];
}

- (void)_initView {
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _openRecTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-kTopHeight-60) style:UITableViewStyleGrouped];
    _openRecTableView.delegate = self;
    _openRecTableView.dataSource = self;
    [self.view addSubview:_openRecTableView];
    
    // ios 11tableView闪动
    _openRecTableView.estimatedRowHeight = 0;
    _openRecTableView.estimatedSectionHeaderHeight = 0;
    _openRecTableView.estimatedSectionFooterHeight = 0;
    
    [_openRecTableView registerNib:[UINib nibWithNibName:@"OpenRecordCell" bundle:nil] forCellReuseIdentifier:@"OpenRecordCell"];
    
    _openRecTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self _loadData];
    }];
    // 上拉刷新
    _openRecTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self _loadData];
    }];
//    _openRecTableView.mj_footer.automaticallyHidden = NO;
    _openRecTableView.mj_footer.hidden = YES;
}
- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)_loadData
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/visitor/getOpenDoorLog",Main_Url];
    
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:_deivedID forKey:@"tagId"];
    [param setObject:@"" forKey:@"startDay"];
    [param setObject:@"" forKey:@"endDay"];
    [param setObject:[NSNumber numberWithInteger:_page] forKey:@"page"];
    [param setObject:[NSNumber numberWithInteger:_length] forKey:@"line"];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [_openRecTableView.mj_header endRefreshing];
        [_openRecTableView.mj_footer endRefreshing];
        
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            
            if(_page == 1){
                [self.dataArr removeAllObjects];
            }
            
            NSDictionary *dic = responseObject[@"responseData"];
            NSArray *arr = dic[@"OpenLog"];
            
            if(arr.count > _length-1){
                _openRecTableView.mj_footer.state = MJRefreshStateIdle;
                _openRecTableView.mj_footer.hidden = NO;
            }else {
                _openRecTableView.mj_footer.state = MJRefreshStateNoMoreData;
                _openRecTableView.mj_footer.hidden = YES;
            }
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                OpenRecordModel *model = [[OpenRecordModel alloc] initWithDataDic:obj];
                [self.dataArr addObject:model];
            }];
        }
        [_openRecTableView cyl_reloadData];
    } failure:^(NSError *error) {
        [_openRecTableView.mj_header endRefreshing];
        [_openRecTableView.mj_footer endRefreshing];
        DLog(@"%@",error);
    }];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDateView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64-49)];
    return noDateView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark UItableView 协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArr.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 121;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5;
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
    OpenRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OpenRecordCell" forIndexPath:indexPath];
    cell.model = self.dataArr[indexPath.section];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end
