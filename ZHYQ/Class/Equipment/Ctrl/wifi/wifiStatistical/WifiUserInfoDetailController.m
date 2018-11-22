//
//  WifiUserInfoDetailController.m
//  ZHYQ
//
//  Created by coder on 2018/10/25.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WifiUserInfoDetailController.h"

@interface WifiUserInfoDetailController ()
{
    CGFloat btnY;
    
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UILabel *_groupLabel;
    __weak IBOutlet UILabel *_certifyTypeLabel;
    __weak IBOutlet UILabel *_deviceNameLabel;
    __weak IBOutlet UILabel *_ipLabel;
    __weak IBOutlet UILabel *_macLabel;
    __weak IBOutlet UILabel *_roleLabel;
    __weak IBOutlet UILabel *_wifiNameLabel;
    __weak IBOutlet UILabel *_vlanLabel;
    __weak IBOutlet UILabel *_pointNameLabel;
    __weak IBOutlet UILabel *_consultRateLabel;
    __weak IBOutlet UILabel *_sendLabel;
    __weak IBOutlet UILabel *_recvLabel;
    __weak IBOutlet UILabel *_onlineLabel;
    __weak IBOutlet UILabel *_terminalTypeLabel;
    __weak IBOutlet UILabel *_frequencyLabel;
    __weak IBOutlet UILabel *_agreementLabel;
    __weak IBOutlet UILabel *_reTransmitLabel;
    __weak IBOutlet UILabel *_mistakeLabel;
    __weak IBOutlet UILabel *_signalNumLabel;
    __weak IBOutlet UILabel *_signalStrongLabel;
    __weak IBOutlet UILabel *_networkCardLabel;
    __weak IBOutlet UILabel *_disasterTypeLabel;
    
}

@property (nonatomic,retain) UIButton *joinBlackListBtn;
@property (nonatomic,retain) UIButton *logoutBtn;

@end

@implementation WifiUserInfoDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#EFEFEF"];
    
    [self _initNavView];
    
//    [self creatDownBtn];
    
    [self fullData];
}

- (void)_initNavView {
    self.title = @"用户详情";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
}

-(void)_leftBarBtnItemClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)creatDownBtn
{
    self.joinBlackListBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, KScreenHeight-kTopHeight-60, KScreenWidth/2, 60)];
    self.joinBlackListBtn.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"scene_all_close_bg"]];
    [self.joinBlackListBtn setTitle:@"加入黑名单" forState:UIControlStateNormal];
    [self.joinBlackListBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.joinBlackListBtn addTarget:self action:@selector(joinBlackListBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView addSubview:self.joinBlackListBtn];
    [self.tableView bringSubviewToFront:self.joinBlackListBtn];
    btnY = (int)self.joinBlackListBtn.frame.origin.y;
    
    self.logoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(_joinBlackListBtn.right, _joinBlackListBtn.y, KScreenWidth/2, 60)];
    [self.logoutBtn setTitle:@"注销登陆" forState:UIControlStateNormal];
    [self.logoutBtn setTitleColor:[UIColor colorWithHexString:@"#CCFF00"] forState:UIControlStateNormal];
    self.logoutBtn.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    [self.logoutBtn addTarget:self action:@selector(logoutBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView addSubview:self.logoutBtn];
    [self.tableView bringSubviewToFront:self.logoutBtn];
    
}

- (void)fullData {
    _nameLabel.text = [NSString stringWithFormat:@"%@", _wifiUserModel.username];
    _groupLabel.text = [NSString stringWithFormat:@"%@", _wifiUserModel.group];
    _certifyTypeLabel.text = [NSString stringWithFormat:@"%@", _wifiUserModel.auth_type];
    _deviceNameLabel.text = [NSString stringWithFormat:@"%@", _wifiUserModel.computer];
    _ipLabel.text = [NSString stringWithFormat:@"%@", _wifiUserModel.ip];
    _macLabel.text = [NSString stringWithFormat:@"%@", _wifiUserModel.mac];
    _roleLabel.text = [NSString stringWithFormat:@"%@", _wifiUserModel.role];
    _wifiNameLabel.text = [NSString stringWithFormat:@"%@", _wifiUserModel.wlan];
    _vlanLabel.text = [NSString stringWithFormat:@"%@", _wifiUserModel.vlan];
    _pointNameLabel.text = [NSString stringWithFormat:@"%@", _wifiUserModel.ap];
    _consultRateLabel.text = [self speedValueStr:_wifiUserModel.consultRate.doubleValue];
    _sendLabel.text = [self speedValueStr:_wifiUserModel.send.doubleValue];
    _recvLabel.text = [self speedValueStr:_wifiUserModel.recv.doubleValue];
    _onlineLabel.text = [NSString stringWithFormat:@"%@", _wifiUserModel.onlineTime];
    _terminalTypeLabel.text = [NSString stringWithFormat:@"%@", _wifiUserModel.client];
    _frequencyLabel.text = [NSString stringWithFormat:@"%@", _wifiUserModel.channel];
    _agreementLabel.text = [NSString stringWithFormat:@"%@", _wifiUserModel.clientphy];
    _reTransmitLabel.text = [NSString stringWithFormat:@"%@ %%", _wifiUserModel.retrans];
    _mistakeLabel.text = [NSString stringWithFormat:@"%@ %%", _wifiUserModel.errorCodeRate];
    _signalNumLabel.text = [NSString stringWithFormat:@"%@", _wifiUserModel.signal];
    _signalStrongLabel.text = [NSString stringWithFormat:@"%@ dBm", _wifiUserModel.signalStrength];
    _networkCardLabel.text = [NSString stringWithFormat:@"%@", _wifiUserModel.nc_maker];
    _disasterTypeLabel.text = [NSString stringWithFormat:@"%@", _wifiUserModel.disaster_type];
}
- (NSString *)speedValueStr:(double)speed {
    NSString *speedStr;
    if(speed < 1024){
        // b
        speedStr = [NSString stringWithFormat:@"%.2f b", speed];
    }else if(speed > 1024 && speed < 1024*1024){
        // kb
        speedStr = [NSString stringWithFormat:@"%.2f kb", speed/1024.00];
    }else {
        // M
        speedStr = [NSString stringWithFormat:@"%.2f M", speed/(1024.00*1024.00)];
    }
    return speedStr;
}

#pragma mark 实现代理方法固定悬浮按钮的位置
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.joinBlackListBtn.frame = CGRectMake(0,btnY+self.tableView.contentOffset.y , kScreenWidth/2,60);
    self.logoutBtn.frame = CGRectMake(_joinBlackListBtn.right,self.joinBlackListBtn.y , kScreenWidth/2,60);
}

-(void)joinBlackListBtnAction
{
    
}

-(void)logoutBtnAction
{
    
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
