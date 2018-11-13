//
//  AppointMentParkDetailViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/6/7.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "AppointMentParkDetailViewController.h"
#import "ParkRecordCenViewController.h"
#import "CalculateHeight.h"

@interface AppointMentParkDetailViewController ()
{
    __weak IBOutlet UIImageView *_stateImgView;
    __weak IBOutlet UILabel *_stateLabel;
    
    __weak IBOutlet UILabel *_carnoLabel;
    __weak IBOutlet UILabel *_aptAdressLabel;
    __weak IBOutlet UILabel *_aptMsgLabel;
    
    __weak IBOutlet UIButton *_parkRecordBt;
    
    __weak IBOutlet UILabel *_userNameLabel;
    __weak IBOutlet UILabel *_phoneLabel;
    __weak IBOutlet UILabel *_aptCodeLabel;
    __weak IBOutlet UILabel *_aptTimeLabel;
    __weak IBOutlet UILabel *_aptRetainTimeLabel;
    
    __weak IBOutlet UILabel *_remarkLabel;
}
@end

@implementation AppointMentParkDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
}

- (void)_initView {
    self.title = @"预约详情";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 订单状态 0预约中 1入场 2取消 3超时取消 4完成
    NSString *status = _aptListModel.orderModel.status;
    if(status != nil && ![status isKindOfClass:[NSNull class]]){
        if([status isEqualToString:@"0"]){
            
        }else if([status isEqualToString:@"2"]){
            _stateImgView.image = [UIImage imageNamed:@"apt_park_cancel"];
            
            _stateLabel.text = @"预约已取消";
            _stateLabel.textColor = [UIColor colorWithHexString:@"#FFDAA6"];
            _aptMsgLabel.text = [NSString stringWithFormat:@"%@取消预约", _aptListModel.orderModel.updateTime];
        }else if([status isEqualToString:@"3"]){
            _stateImgView.image = [UIImage imageNamed:@"apt_park_overrun"];
            
            _stateLabel.text = @"超时未入场";
            _stateLabel.textColor = [UIColor colorWithHexString:@"#97FF96"];
            _aptMsgLabel.text = [NSString stringWithFormat:@"%@前未入场停车，车位已取消", _aptListModel.orderModel.invalidTime];
        }else if([status isEqualToString:@"1"]){
            _stateImgView.image = [UIImage imageNamed:@"apt_park_complete"];
            
            _stateLabel.text = @"车辆已入场";
            _stateLabel.textColor = [UIColor colorWithHexString:@"#DDFAFF"];
            _aptMsgLabel.text = [NSString stringWithFormat:@"%@已入场停车", _aptListModel.orderModel.updateTime];
            
            _parkRecordBt.hidden = NO;
        }else if([status isEqualToString:@"4"]) {
            // 已出厂
            _stateImgView.image = [UIImage imageNamed:@"apt_park_complete"];
            _stateLabel.text = @"车辆已出场";
            _stateLabel.textColor = [UIColor colorWithHexString:@"#DDFAFF"];
            _aptMsgLabel.text = [NSString stringWithFormat:@"%@已出场", _aptListModel.orderModel.updateTime];
            
            _parkRecordBt.hidden = NO;
        }
    }
    
    _carnoLabel.text = [NSString stringWithFormat:@"%@", _aptListModel.orderModel.carNo];
    
    _aptAdressLabel.text = [NSString stringWithFormat:@"预定车位 %@", _aptListModel.orderModel.parkingSpaceName];
    
    _aptCodeLabel.text = [NSString stringWithFormat:@"%@", _aptListModel.orderModel.orderId];
    _userNameLabel.text = [NSString stringWithFormat:@"%@(", _aptListModel.orderModel.custName];
    _phoneLabel.text = [NSString stringWithFormat:@"%@)", _aptListModel.orderModel.phone];
    _aptTimeLabel.text = [NSString stringWithFormat:@"%@", _aptListModel.orderModel.orderTime];
    _aptRetainTimeLabel.text = [NSString stringWithFormat:@"%@", _aptListModel.orderModel.invalidTime];
    
    _remarkLabel.text = [NSString stringWithFormat:@"%@", _aptListModel.orderModel.remark];
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 停车记录
- (IBAction)parkRecordAction:(id)sender {
    ParkRecordCenViewController *parkRecordCenVC = [[ParkRecordCenViewController alloc] init];
    parkRecordCenVC.carNo = [NSString stringWithFormat:@"%@", _aptListModel.orderModel.carNo];
    [self.navigationController pushViewController:parkRecordCenVC animated:YES];
}

#pragma mark UITableView 协议
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return 150;
            break;
            
        case 1:
            return 150;
            break;
        case 2:
        {
            CGFloat height = [CalculateHeight heightForString:_aptListModel.orderModel.remark fontSize:17 andWidth:(KScreenWidth - 34)];
            
            return 180 + height;
            break;
        }
            
        default:
            return 0;
            break;
    }
}

@end
