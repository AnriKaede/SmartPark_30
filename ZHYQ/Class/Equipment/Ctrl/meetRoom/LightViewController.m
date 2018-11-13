//
//  LightViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/4.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "LightViewController.h"
#import "ParkNightViewController.h"
#import "MeetRoomCenterViewController.h"

@interface LightViewController ()

@end

@implementation LightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNavItems];
    
//    self.title = @"智能照明";
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    self.tableView.tableFooterView = [UIView new];
}

-(void)initNavItems
{
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0){
        // 车库照明
        ParkNightViewController *parkNightVC = [[ParkNightViewController alloc] init];
        [self.navigationController pushViewController:parkNightVC animated:YES];
    }else if (indexPath.row == 1) {
        // 会议室
        MeetRoomCenterViewController *meetCenterVC = [[MeetRoomCenterViewController alloc] init];
        [self.navigationController pushViewController:meetCenterVC animated:YES];
    }
}

@end
