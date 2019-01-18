//
//  ParkFeeViewController.m
//  ZHYQ
//
//  Created by coder on 2018/10/24.
//  Copyright © 2018年 焦平. All rights reserved.
//

typedef enum {
    ParkFeeDay = 0,
    ParkFeeWeek,
    ParkFeeMonth
}ParkFeeType;

#import "ParkFeeViewController.h"
#import "ParkFeeListViewController.h"
#import "ParkFeeTopCell.h"
#import "ParkFeeSnapCell.h"

#import "ParkFeeCountModel.h"

@interface ParkFeeViewController ()<ParkFeeDateFilterDelegate>
{
    ParkFeeCountModel *_parkFeeCountModel;
    NSMutableArray *_itemsData;
}
@end

@implementation ParkFeeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _itemsData = @[].mutableCopy;
    
    [self initNav];
    
    [self _loadData:ParkFeeDay];
}

-(void)initNav{
    self.title = @"收费概况";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *rightBtn = [[UIButton alloc] init];
    rightBtn.frame = CGRectMake(0, 0, 40, 40);
    [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [rightBtn setImage:[UIImage imageNamed:@"parkfee_nav_right"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(_rightBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ParkFeeTopCell" bundle:nil] forCellReuseIdentifier:@"ParkFeeTopCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ParkFeeSnapCell" bundle:nil] forCellReuseIdentifier:@"ParkFeeSnapCell"];
    
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)_rightBarBtnItemClick
{
    ParkFeeListViewController *parkFeeListVc = [[ParkFeeListViewController alloc] init];
    [self.navigationController pushViewController:parkFeeListVc animated:YES];
}

- (void)_loadData:(ParkFeeType)parkFeeType {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/chargeStatistics", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    if(parkFeeType == ParkFeeDay){
        [paramDic setObject:@"day" forKey:@"timeType"];
    }else if(parkFeeType == ParkFeeWeek){
        [paramDic setObject:@"week" forKey:@"timeType"];
    }else if(parkFeeType == ParkFeeMonth){
        [paramDic setObject:@"month" forKey:@"timeType"];
    }
    
    NSString *paramStr = [Utils convertToJsonData:paramDic];
    NSDictionary *params = @{@"params":paramStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            
            NSDictionary *responseData = responseObject[@"responseData"];
            _parkFeeCountModel = [[ParkFeeCountModel alloc] initWithDataDic:responseData];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        
    } failure:^(NSError *error) {
        [self showHint:KRequestFailMsg];
    }];
    
    [self loadSnapData:parkFeeType];
}

- (void)loadSnapData:(ParkFeeType)parkFeeType {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/periodStatistics", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    if(parkFeeType == ParkFeeDay){
        [paramDic setObject:@"day" forKey:@"timeType"];
    }else if(parkFeeType == ParkFeeWeek){
        [paramDic setObject:@"week" forKey:@"timeType"];
    }else if(parkFeeType == ParkFeeMonth){
        [paramDic setObject:@"month" forKey:@"timeType"];
    }
    
    NSString *paramStr = [Utils convertToJsonData:paramDic];
    NSDictionary *params = @{@"params":paramStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            
            NSDictionary *responseData = responseObject[@"responseData"];
            NSArray *items = responseData[@"items"];
            _itemsData = items.mutableCopy;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        }
        
    } failure:^(NSError *error) {
        [self showHint:KRequestFailMsg];
    }];
}

#pragma mark UITableView协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        return 350;
    }else {
        return 214;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return 0.1;
    }
    return 50;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return [UIView new];
    }
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 50)];
    headerView.backgroundColor = [UIColor colorWithHexString:@"#EFEFEF"];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 80, 20)];
    label.text = @"收费统计";
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:17];
    label.textAlignment = NSTextAlignmentLeft;
    [headerView addSubview:label];
    
    return headerView;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        ParkFeeTopCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ParkFeeTopCell" forIndexPath:indexPath];
        cell.parkFeeCountModel = _parkFeeCountModel;
        cell.filterDelegate = self;
        return cell;
    }else {
        ParkFeeSnapCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ParkFeeSnapCell" forIndexPath:indexPath];
        cell.items = _itemsData;
        return cell;
    }
}

#pragma mark 日周月切换协议
- (void)filterDelegate:(FilterDateStyle)filterDateStyle {
    switch (filterDateStyle) {
        case FilterDay:
            {
                [self _loadData:ParkFeeDay];
                break;
            }
        case FilterWeek:
        {
            [self _loadData:ParkFeeWeek];
            break;
        }
        case FilterMonth:
        {
            [self _loadData:ParkFeeMonth];
            break;
        }
    }
}

@end
