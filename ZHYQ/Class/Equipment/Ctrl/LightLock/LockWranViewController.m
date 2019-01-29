//
//  LockWranViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/21.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "LockWranViewController.h"
#import "CommncWranCell.h"
#import "CommncWranModel.h"

@interface LockWranViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_tableView;
    NSInteger _page;
    NSInteger _length;
    
    NSMutableArray *_wranData;
    
    UILabel *_allNumLabel;
    
    NSNumber *_total;
}
@end

@implementation LockWranViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _wranData = @[].mutableCopy;
    
    [self _initView];
    [self _loadData];
}

- (void)_initView {
    self.title = @"告警信息";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    [self.view addSubview:_tableView];
    
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    
    [_tableView registerNib:[UINib nibWithNibName:@"CommncWranCell" bundle:nil] forCellReuseIdentifier:@"CommncWranCell"];
    
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
-(void)_leftBarBtnItemClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/iot/alarm", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:[NSNumber numberWithInteger:_page] forKey:@"pageNumber"];
    [paramDic setObject:[NSNumber numberWithInteger:_length] forKey:@"pageSize"];
    
    
    
    NSString *paramStr = [Utils convertToJsonData:paramDic];
    NSDictionary *params = @{@"param":paramStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        
        [_tableView.mj_header endRefreshing];
        [_tableView.mj_footer endRefreshing];
        
        NSString *code = responseObject[@"code"];
        
        if (code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]) {
            if(_page == 1){
                [_wranData removeAllObjects];
            }
            
            NSDictionary *dic = responseObject[@"responseData"];
            NSArray *arr = dic[@"list"];
            
            NSNumber *total = dic[@"total"];
            if(total != nil && ![total isKindOfClass:[NSNull class]]){
                _allNumLabel.text = [NSString stringWithFormat:@"%@", total];
                _total = total;
            }
            
            if(arr.count > _length-1){
                _tableView.mj_footer.state = MJRefreshStateIdle;
                _tableView.mj_footer.hidden = NO;
            }else {
                _tableView.mj_footer.state = MJRefreshStateNoMoreData;
                _tableView.mj_footer.hidden = YES;
            }
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CommncWranModel *model = [[CommncWranModel alloc] initWithDataDic:obj];
                [_wranData addObject:model];
            }];
            
        }
        [_tableView cyl_reloadData];
        
    } failure:^(NSError *error) {
        [_tableView.mj_header endRefreshing];
        [_tableView.mj_footer endRefreshing];
        
        if(_wranData.count <= 0){
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

#pragma mark UItableView协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _wranData.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 195;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(section != 0){
        return [UIView new];
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 42)];
    headerView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(11, 12, 20, 20)];
    imgView.image = [UIImage imageNamed:@"cell_wran_icon"];
    [headerView addSubview:imgView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imgView.right + 6, 11, 70, 20)];
    label.text = @"告警总数:";
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentLeft;
    [headerView addSubview:label];
    
    _allNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(label.right + 5, 11, 200, 20)];
    _allNumLabel.textColor = [UIColor colorWithHexString:@"#E60012"];
    _allNumLabel.font = [UIFont systemFontOfSize:16];
    _allNumLabel.textAlignment = NSTextAlignmentLeft;
    _allNumLabel.text = [NSString stringWithFormat:@"%@", _total];
    [headerView addSubview:_allNumLabel];
    
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return 42;
    }
    return 7;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommncWranModel *model = _wranData[indexPath.section];
    
    CommncWranCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommncWranCell" forIndexPath:indexPath];
    
    cell.wranModel = model;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
