//
//  WifiBatchAptController.m
//  ZHYQ
//
//  Created by coder on 2018/10/25.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WifiBatchAptController.h"
#import "WifiUserBatchAptCell.h"
#import "CRSearchBar.h"

@interface WifiBatchAptController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
{
    UITableView *_aptTableView;
    CRSearchBar *_searchBar;
    UIButton *_joinBlackListBtn;
    UIButton *_logoutBtn;
}

@end

@implementation WifiBatchAptController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initNavView];
    
    _searchBar = [[CRSearchBar alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 44)];
    _searchBar.leftImage = [UIImage imageNamed:@"icon_search"];
    _searchBar.placeholderColor = [UIColor colorWithHexString:@"#E2E2E2"];
    _searchBar.placeholder = @"请输入用户名查询";
    _searchBar.delegate = self;
    _searchBar.backgroundColor = [UIColor clearColor];
    _searchBar.backgroundImage = [UIImage imageWithColor:[UIColor clearColor]];
    _searchBar.searchTextPositionAdjustment = UIOffsetMake(0, 2);
    [self.view addSubview:_searchBar];
    
    _aptTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, KScreenWidth, KScreenHeight-kTopHeight-44-60) style:UITableViewStylePlain];
    _aptTableView.tableFooterView = [UIView new];
    _aptTableView.backgroundColor = [UIColor colorWithHexString:@"#EFEFEF"];
    _aptTableView.delegate = self;
    _aptTableView.dataSource = self;
    _aptTableView.separatorColor = [UIColor clearColor];
    _aptTableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    [self.view addSubview:_aptTableView];
    
    [_aptTableView registerNib:[UINib nibWithNibName:@"WifiUserBatchAptCell" bundle:nil] forCellReuseIdentifier:@"WifiUserBatchAptCell"];
    
    UIButton *joinBlackListBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, KScreenHeight-kTopHeight-60, KScreenWidth/2, 60)];
    joinBlackListBtn.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"scene_all_close_bg"]];
    [joinBlackListBtn setTitle:@"加入黑名单" forState:UIControlStateNormal];
    [joinBlackListBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:joinBlackListBtn];
    _joinBlackListBtn = joinBlackListBtn;
    
    UIButton *logoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(joinBlackListBtn.right, joinBlackListBtn.y, KScreenWidth/2, 60)];
    [logoutBtn setTitle:@"注销登陆" forState:UIControlStateNormal];
    [logoutBtn setTitleColor:[UIColor colorWithHexString:@"#CCFF00"] forState:UIControlStateNormal];
    logoutBtn.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    [self.view addSubview:logoutBtn];
    _logoutBtn = logoutBtn;

}

- (void)_initNavView {
    self.title = @"批量编辑";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *rightBtn = [[UIButton alloc] init];
    rightBtn.frame = CGRectMake(0, 0, 60, 40);
    [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [rightBtn setTitle:@"全选" forState:UIControlStateNormal];
    [rightBtn setTitle:@"全不选" forState:UIControlStateSelected];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(_rightBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)_leftBarBtnItemClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)_rightBarBtnItemClick:(id)sender
{
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WifiUserBatchAptCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WifiUserBatchAptCell" forIndexPath:indexPath];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.001;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

@end
