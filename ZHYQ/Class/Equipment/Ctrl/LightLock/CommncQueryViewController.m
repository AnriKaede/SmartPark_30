//
//  CommncQueryViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/24.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "CommncQueryViewController.h"
#import "EquipmQueryCell.h"

@interface CommncQueryViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UIView *_topView;
    UITableView *_tableView;
    
    NSMutableArray *_traceData;
    
    int _page;
    int _length;
}
@end

@implementation CommncQueryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _traceData = @[].mutableCopy;
    
    [self _initNavItems];
    [self _initView];
}

-(void)_initNavItems {
    self.title = @"实时查询";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}
-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_initView {
    [self _createTopView];
    
    [self _createTableView];
}
- (void)_createTopView {
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 44)];
    // 添加透明层
    [NavGradient viewAddGradient:_topView];
    [self.view addSubview:_topView];
    
    NSArray *titles = @[@"属性编码", @"属性名称", @"属性值", @"上报时间 "];
    CGFloat itemWidth = KScreenWidth/4;
    [titles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(idx*itemWidth, 0, itemWidth, 44)];
        label.text = titles[idx];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentCenter;
        [_topView addSubview:label];
        
        UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(idx*itemWidth - 1, 13, 1, 17)];
        lineImgView.image = [UIImage imageNamed:@"weather_sep"];
        [_topView addSubview:lineImgView];
    }];
}

- (void)_createTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, KScreenWidth, KScreenHeight - kTopHeight - _topView.height) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _tableView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    _tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_tableView];
    
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    
    [_tableView registerClass:[EquipmQueryCell class] forCellReuseIdentifier:@"EquipmQueryCell"];
    
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self _loadData];
    }];
    // 上拉刷新
    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self _loadData];
    }];
    _tableView.mj_footer.hidden = YES;
}

- (void)_loadData {
    
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

#pragma mark UItableView协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return _traceData.count;
    return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    FaceListModel *model = _traceData[indexPath.row];
    
    EquipmQueryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EquipmQueryCell" forIndexPath:indexPath];
    
//    cell.faceListModel = model;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
