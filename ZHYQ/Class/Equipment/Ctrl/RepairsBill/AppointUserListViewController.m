//
//  AppointUserListViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/3/16.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "AppointUserListViewController.h"
#import <Hyphenate/Hyphenate.h>
#import "EaseMessageViewController.h"
#import "AppointChatUserModel.h"
#import "IMUserQuery.h"

@interface AppointUserListViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_tableView;
    NSMutableArray *_traceData;
    int _page;
    int _length;
}
@end

@implementation AppointUserListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _traceData = @[].mutableCopy;
    _page = 1;
    _length = 15;
    
    [self _initView];
    
    [self _loadData];
}

- (void)_initView {
    self.title = @"用户列表";
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, KScreenWidth, KScreenHeight - kTopHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _tableView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    _tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_tableView];
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UserListCell"];
    
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    
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

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/pubSystemManage/querySystemUser", Main_Url];
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:[NSNumber numberWithInteger:_page] forKey:@"offset"];
    [paramDic setObject:[NSNumber numberWithInteger:_length] forKey:@"limit"];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:paramDic progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        
        [_tableView.mj_header endRefreshing];
        [_tableView.mj_footer endRefreshing];
        
        NSArray *rows = responseObject[@"rows"];
        if(rows != nil && ![rows isKindOfClass:[NSNull class]]){
            if(_page == 1){
                [_traceData removeAllObjects];
            }
            
            if(rows.count > _length-1){
                _tableView.mj_footer.state = MJRefreshStateIdle;
                _tableView.mj_footer.hidden = NO;
            }else {
                _tableView.mj_footer.state = MJRefreshStateNoMoreData;
                _tableView.mj_footer.hidden = YES;
            }
            
            [rows enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                AppointChatUserModel *model = [[AppointChatUserModel alloc] initWithDataDic:obj];
                [_traceData addObject:model];
            }];
            [_tableView cyl_reloadData];
        }
    } failure:^(NSError *error) {
        [_tableView.mj_header endRefreshing];
        [_tableView.mj_footer endRefreshing];
        if(_traceData.count <= 0){
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _traceData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
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
    AppointChatUserModel *model = _traceData[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserListCell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", model.userName];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self IMChat:indexPath];
}

- (void)IMChat:(NSIndexPath *)indexPath {
    AppointChatUserModel *model = _traceData[indexPath.row];
#warning 环信聊天
    //聊天类型:EMConversationTypeChat
    EaseMessageViewController *chatController = [[EaseMessageViewController alloc] initWithConversationChatter:model.loginName conversationType:EMConversationTypeChat];
    chatController.title = model.userName;
    [self.navigationController pushViewController:chatController animated:YES];
}

@end
