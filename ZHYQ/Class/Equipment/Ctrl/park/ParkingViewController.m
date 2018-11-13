//
//  ParkingViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/8.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ParkingViewController.h"

#import "IllegalMangeViewController.h"
#import "AppointmentParkCenViewController.h"
#import "CarBlackListViewController.h"
#import "ParkMgeCenterViewController.h"
#import "FindCarNoViewController.h"
#import "StopParkMangerViewController.h"
#import "ParkFee/ParkFeeViewController.h"

#import "wifiSticalCenterViewController.h"

@interface ParkingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *freNumPark;

@end

@implementation ParkingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _initNavItems];
    
    [self _initView];
    
    [self _loadData];
}

-(void)_initView
{
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    
    
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/status",ParkMain_Url];
    
    NSMutableDictionary *params = @{}.mutableCopy;
    [params setObject:KParkId forKey:@"parkId"];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        if([responseObject[@"success"] boolValue]){
            NSDictionary *dic = responseObject[@"data"];
            NSDictionary *parkDic = dic[@"park"];
            _freNumPark.text = [NSString stringWithFormat:@"剩余车位%@",parkDic[@"parkIdle"]];
        }
    } failure:^(NSError *error) {
        
    }];
}

-(void)_initNavItems
{
//    self.title = @"智慧停车";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            ParkMgeCenterViewController *parkManageCenterVC = [[ParkMgeCenterViewController alloc] init];
            [self.navigationController pushViewController:parkManageCenterVC animated:YES];
            break;
        }
        case 1:
        {
            // 预约管理
            StopParkMangerViewController *stopParkMangerVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"StopParkMangerViewController"];
            [self.navigationController pushViewController:stopParkMangerVC animated:YES];
            break;
        }
        case 2:
        {
            // 预约管理
            AppointmentParkCenViewController *parkManageCenterVC = [[AppointmentParkCenViewController alloc] init];
            [self.navigationController pushViewController:parkManageCenterVC animated:YES];
            break;
        }
        case 3:
        {
            // 车牌查询
            FindCarNoViewController *findVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"FindCarNoViewController"];
            [self.navigationController pushViewController:findVC animated:YES];
        }
            break;
        case 4:
        {
            IllegalMangeViewController *iMangeVC = [[IllegalMangeViewController alloc] init];
            [self.navigationController pushViewController:iMangeVC animated:YES];
        }
            break;
        case 5:
        {
            CarBlackListViewController *carBlVC = [[CarBlackListViewController alloc] init];
            [self.navigationController pushViewController:carBlVC animated:YES];
        }
            break;
        case 6:
        {
            ParkFeeViewController *parkFeeVC = [[ParkFeeViewController alloc] init];
            [self.navigationController pushViewController:parkFeeVC animated:YES];
        }
            break;
        default:
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 75*hScale;
    return height;
}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
