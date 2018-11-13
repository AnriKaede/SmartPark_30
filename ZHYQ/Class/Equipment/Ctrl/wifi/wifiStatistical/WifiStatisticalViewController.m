//
//  WifiStatisticalViewController.m
//  ZHYQ
//
//  Created by coder on 2018/10/25.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WifiStatisticalViewController.h"
#import "WifiCountTerminalCell.h"
#import "WifiCountTimeCell.h"
#import "WifiCountSpeedCell.h"
#import "WifiCountStrongCell.h"
#import "WifiInfoCountModel.h"

#import "WifiInfoCountModel.h"

@interface WifiStatisticalViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_shareTableView;
    
    WifiInfoCountModel *_infoCountModel;
}
@end

@implementation WifiStatisticalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
    
    [self loadWifiCountData];
}

- (void)_initView {

    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    
    _shareTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight) style:UITableViewStyleGrouped];
    _shareTableView.delegate = self;
    _shareTableView.dataSource = self;
    [self.view addSubview:_shareTableView];
    
    [_shareTableView registerNib:[UINib nibWithNibName:@"WifiCountTerminalCell" bundle:nil] forCellReuseIdentifier:@"WifiCountTerminalCell"];
    [_shareTableView registerNib:[UINib nibWithNibName:@"WifiCountTimeCell" bundle:nil] forCellReuseIdentifier:@"WifiCountTimeCell"];
    [_shareTableView registerNib:[UINib nibWithNibName:@"WifiCountSpeedCell" bundle:nil] forCellReuseIdentifier:@"WifiCountSpeedCell"];
    [_shareTableView registerNib:[UINib nibWithNibName:@"WifiCountStrongCell" bundle:nil] forCellReuseIdentifier:@"WifiCountStrongCell"];
}
- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 加载用户数据
- (void)loadWifiCountData {
    // 获取ap下用户列表,getDetail =device_id,layerId=楼层id,getAns="false"
    // 获取ap分析数据,getDetail =device,layerId=楼层id,getAns="true"
    NSString *urlStr;
    if(_isALl){
        urlStr = [NSString stringWithFormat:@"%@/wifi/getWifiUserDetail?getDetail=%@&layerId=%@&getAns=%@&start=&limit=",Main_Url, @"", @"", @"ALL"];
    }else {
        urlStr = [NSString stringWithFormat:@"%@/wifi/getWifiUserDetail?getDetail=%@&layerId=%@&getAns=%@&start=&limit=",Main_Url, _inDoorWifiModel.DEVICE_ID, _inDoorWifiModel.LAYER_ID, @"true"];
    }
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            NSDictionary *responseData = responseObject[@"responseData"];
            _infoCountModel = [[WifiInfoCountModel alloc] initWithDataDic:responseData];
            [_shareTableView reloadData];
        }
        
    } failure:^(NSError *error) {
        [self showHint:KRequestFailMsg];
    }];
}

#pragma mark UITableView协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        return 200;
    }else if(indexPath.section == 1){
        return 218;
    }else if(indexPath.section == 2){
        return 211;
    }else {
        return 142;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 50)];
    headerView.backgroundColor = [UIColor colorWithHexString:@"#EFEFEF"];
    
    NSArray *titles = @[@"终端类型",@"上网时长", @"接发速率", @"信号强弱"];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 15, 200, 20)];
    label.text = titles[section];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:17];
    label.textAlignment = NSTextAlignmentLeft;
    [headerView addSubview:label];
    
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        WifiCountTerminalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WifiCountTerminalCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.typeData = _infoCountModel.clientType;
        return cell;
    }else if (indexPath.section == 1) {
        WifiCountTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WifiCountTimeCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.timeData = _infoCountModel.onlineTime;
        return cell;
    }else if (indexPath.section == 2) {
        WifiCountSpeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WifiCountSpeedCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.speedData = _infoCountModel.sendAndRec;
        return cell;
    }else {
        WifiCountStrongCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WifiCountStrongCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.strongData = _infoCountModel.signalStrength;
        return cell;
    }
}

@end
