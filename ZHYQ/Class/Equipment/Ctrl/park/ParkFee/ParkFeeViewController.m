//
//  ParkFeeViewController.m
//  ZHYQ
//
//  Created by coder on 2018/10/24.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "ParkFeeViewController.h"
#import "ParkFeeListViewController.h"
#import "ParkFeeTopCell.h"
#import "ParkFeeSnapCell.h"

@interface ParkFeeViewController ()

@end

@implementation ParkFeeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNav];
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
        return cell;
    }else {
        ParkFeeSnapCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ParkFeeSnapCell" forIndexPath:indexPath];
        return cell;
    }
}

@end
