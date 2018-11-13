//
//  AuthorityViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/11.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "AuthorityViewController.h"
#import "AuthorityListCell.h"
#import "NoDataView.h"
#import "AuthModel.h"

@interface AuthorityViewController ()<UITableViewDelegate, UITableViewDataSource,CYLTableViewPlaceHolderDelegate,reloadDelegate>
{
    UITableView *_openRecTableView;
    
    NSInteger _page;
    NSInteger _length;
}

@property (nonatomic,strong) NSMutableArray *dataArr;

@end

@implementation AuthorityViewController

-(NSMutableArray *)dataArr
{
    if (_dataArr == nil) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _page = 1;
    _length = 16;
    
    [self _initView];
    
    [self _loadData];
}

- (void)_initView {
    self.title = [NSString stringWithFormat:@"%@权限明细", _doorName];
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _openRecTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, KScreenWidth, KScreenHeight-kTopHeight-60) style:UITableViewStylePlain];
    _openRecTableView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    _openRecTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _openRecTableView.separatorColor = [UIColor clearColor];
    _openRecTableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    _openRecTableView.delegate = self;
    _openRecTableView.dataSource = self;
    [self.view addSubview:_openRecTableView];
    
    // ios 11tableView闪动
    _openRecTableView.estimatedRowHeight = 0;
    _openRecTableView.estimatedSectionHeaderHeight = 0;
    _openRecTableView.estimatedSectionFooterHeight = 0;
    
    [_openRecTableView registerNib:[UINib nibWithNibName:@"AuthorityListCell" bundle:nil] forCellReuseIdentifier:@"AuthorityListCell"];
    
    _openRecTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self _loadData];
    }];
    _openRecTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self _loadData];
    }];
}
- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)_loadData
{
    //    [self showHudInView:self.view hint:@""];
    NSString *urlStr = [NSString stringWithFormat:@"%@/visitor/getOpenDoorAuth",Main_Url];
    
    NSMutableDictionary *param =@{}.mutableCopy;
    [param setObject:_deivedID forKey:@"doorDeviceId"];
    [param setObject:[NSNumber numberWithInteger:_page] forKey:@"page"];
    [param setObject:[NSNumber numberWithInteger:_length] forKey:@"line"];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [_openRecTableView.mj_header endRefreshing];
        [_openRecTableView.mj_footer endRefreshing];
        
        //        [self hideHud];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *dataDic = responseObject[@"responseData"];
            NSArray *Arr = dataDic[@"AuthList"];
            
            if(_page == 1){
                [self.dataArr removeAllObjects];
            }
            if(Arr.count > _length-1){
                _openRecTableView.mj_footer.state = MJRefreshStateIdle;
                _openRecTableView.mj_footer.hidden = NO;
            }else {
                _openRecTableView.mj_footer.state = MJRefreshStateNoMoreData;
                _openRecTableView.mj_footer.hidden = YES;
            }
            
            [Arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                AuthModel *model = [[AuthModel alloc] initWithDataDic:obj];
                [self.dataArr addObject:model];
            }];
            
        }
        [_openRecTableView cyl_reloadData];
    } failure:^(NSError *error) {
        //        [self hideHud];
        [_openRecTableView.mj_header endRefreshing];
        [_openRecTableView.mj_footer endRefreshing];
    }];
}

#pragma mark UItableView 协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
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
    AuthorityListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AuthorityListCell" forIndexPath:indexPath];
    cell.model = self.dataArr[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDateView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64-49)];
    noDateView.delegate = self;
    return noDateView;
}

-(void)reload
{
    [self _loadData];
}

@end
