//
//  OperateDetailViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/2/23.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "OperateDetailViewController.h"

@interface OperateDetailViewController ()
{
    __weak IBOutlet UILabel *_timeLabel;
    
    __weak IBOutlet UILabel *_usernameLabel;
    __weak IBOutlet UILabel *_useridLabel;
    __weak IBOutlet UILabel *_userDeviceNameLabel;
    __weak IBOutlet UILabel *_userDeviceIdLabel;
    
    __weak IBOutlet UILabel *_deviceNameLabel;
    __weak IBOutlet UILabel *_deviceIdLabel;
    __weak IBOutlet UILabel *_operateNameLabel;
    __weak IBOutlet UILabel *_operateDesLabel;
}
@end

@implementation OperateDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
}

- (void)_initView {
    self.title = @"操作日志详情";
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _timeLabel.text = [self timeStrWithScince:_operateLogModel.operateTime];
    
    _usernameLabel.text = [NSString stringWithFormat:@"%@", _operateLogModel.userName];
    _useridLabel.text = [NSString stringWithFormat:@"%@", _operateLogModel.userId];
    _userDeviceNameLabel.text = [NSString stringWithFormat:@"%@", _operateLogModel.deviceName];
    _userDeviceIdLabel.text = [NSString stringWithFormat:@"%@", _operateLogModel.deviceId];
    
    _deviceNameLabel.text = [NSString stringWithFormat:@"%@", _operateLogModel.operateDeviceName];
    _deviceIdLabel.text = [NSString stringWithFormat:@"%@", _operateLogModel.operateDeviceId];
    _operateNameLabel.text = [NSString stringWithFormat:@"%@", _operateLogModel.operateName];
    _operateDesLabel.text = [NSString stringWithFormat:@"%@", _operateLogModel.operateDes];
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return 0;
    }
    return 17;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (NSString *)timeStrWithScince:(NSNumber *)scince {
    NSTimeInterval timeInt = scince.integerValue/1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInt];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *dateStr = [formatter stringFromDate:date];
    
    return dateStr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
