//
//  RepairsPeopleViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2018/4/19.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "RepairsPeopleViewController.h"
#import "CRSearchBar.h"
#import "RepairsPeopleCell.h"

#import "RepairsManModel.h"

@interface RepairsPeopleViewController ()<UISearchBarDelegate, CYLTableViewPlaceHolderDelegate>
{
    NSMutableArray *_listData;
    NSMutableArray *_tempAry;
    
    __weak IBOutlet CRSearchBar *searchBar;
}

@end

@implementation RepairsPeopleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _listData = @[].mutableCopy;
    _tempAry = @[].mutableCopy;
    
    [self _initNavItems];
    
    [self _initView];
    
    [self _loadData];
}

-(void)_initNavItems
{
    self.title = @"选择维修人";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    searchBar.delegate = self;
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)_initView
{
    searchBar.leftImage = [UIImage imageNamed:@"icon_search"];
    searchBar.placeholderColor = [UIColor colorWithHexString:@"#E2E2E2"];
    searchBar.placeholder = @"请输入维修人名字";
    searchBar.delegate = self;
    searchBar.backgroundColor = [UIColor whiteColor];
    searchBar.backgroundImage = [UIImage imageWithColor:[UIColor clearColor]];
    searchBar.searchTextPositionAdjustment = UIOffsetMake(0, 2);
//    [searchBar becomeFirstResponder];
    
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.bounces = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"RepairsPeopleCell" bundle:nil] forCellReuseIdentifier:@"RepairsPeopleCell"];
    
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/deviceAlarm/repairList", Main_Url];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            NSArray *data = responseObject[@"responseData"][@"items"];
            [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                RepairsManModel *model = [[RepairsManModel alloc] initWithDataDic:obj];
                [_listData addObject:model];
                [_tempAry addObject:model];
            }];
            [self.tableView cyl_reloadData];
        }
    } failure:^(NSError *error) {
        [self showHint:KRequestFailMsg];
    }];
}

// 无网络重载
- (void)reloadTableData {
    [self _loadData];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight - 60)];
    noDataView.backgroundColor = [UIColor whiteColor];
    return noDataView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tempAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RepairsPeopleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RepairsPeopleCell" forIndexPath:indexPath];
    if(_tempAry.count > indexPath.row){
        cell.repairsManModel = _tempAry[indexPath.row];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 61;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(_selRepairManDelegate && [_selRepairManDelegate respondsToSelector:@selector(selRepairMan:)]){
        RepairsManModel *repairsManModel = _tempAry[indexPath.row];
        [_selRepairManDelegate selRepairMan:repairsManModel];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 搜索按钮点击
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [_tempAry removeAllObjects];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@",searchBar.text];
    
    [_listData enumerateObjectsUsingBlock:^(RepairsManModel *repairsManModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if(searchBar.text == nil || searchBar.text.length <= 0){
            [_tempAry addObject:repairsManModel];
        }else {
            BOOL isContain = [pred evaluateWithObject:repairsManModel.USER_NAME];
            if (isContain) {
                [_tempAry addObject:repairsManModel];
            }
        }
    }];
    
    [self.tableView reloadData];
}

@end
