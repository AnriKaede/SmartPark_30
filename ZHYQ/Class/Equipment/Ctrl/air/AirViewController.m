//
//  AirViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "AirViewController.h"
#import "YQHeaderView.h"

#import "AirTableViewCell.h"

#import "AirModel.h"

@interface AirViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *_airData;
}

@property (nonatomic,strong) YQHeaderView *headerView;

@end

@implementation AirViewController

-(YQHeaderView *)headerView
{
    if (_headerView == nil) {
        _headerView = [[YQHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 85)];
        _headerView.backgroundColor = [UIColor colorWithHexString:@"1B82D1"];
    }
    return _headerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _airData = @[].mutableCopy;
    
    [self _initView];
    
    [self _initNavItems];
    
    [self _loadData];
}

-(void)_initView
{
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"AirTableViewCell" bundle:nil] forCellReuseIdentifier:@"AirTableViewCell"];
    self.tableView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight-64);
}

-(void)_initNavItems
{
//    self.title = @"通风";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
}

-(void)headerRereshing{
    [self _loadData];
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/equipment/getEquipmentList?deviceType=8",Main_Url];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        [self.tableView.mj_header endRefreshing];
        
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *resDic = responseObject[@"responseData"];
            
            NSString *openNum = [NSString stringWithFormat:@"%@", resDic[@"okEquipmentCount"]];
            NSString *errorNum = [NSString stringWithFormat:@"%@", resDic[@"errorEquipmentCount"]];
            NSString *downNum = [NSString stringWithFormat:@"%@", resDic[@"outEquipmentCount"]];
            
            _headerView.leftNumLab.text = openNum;
            _headerView.centerNumLab.text = errorNum;
            _headerView.rightNumLab.text = downNum;
            
            [_airData removeAllObjects];
            
            NSArray *equipmentList = resDic[@"equipmentList"];
            [equipmentList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                AirModel *model = [[AirModel alloc] initWithDataDic:obj];
                [_airData addObject:model];
            }];
            
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
        if(_airData.count <= 0){
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

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _airData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AirModel *airModel = _airData[indexPath.row];
    AirTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AirTableViewCell" forIndexPath:indexPath];
    cell.airModel = airModel;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 155;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 85;
}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
