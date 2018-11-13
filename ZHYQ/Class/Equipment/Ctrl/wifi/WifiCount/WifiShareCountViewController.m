//
//  WifiShareCountViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/10/25.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WifiShareCountViewController.h"
#import "WifiShareTopCell.h"
#import "WifiAddUserCell.h"
#import "WifiSpeedCell.h"
#import "WifiStateCell.h"
#import "WifiInfoCountModel.h"

@interface WifiShareCountViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_shareTableView;
    
    NSMutableArray *_addUserData;
    NSMutableArray *_speedData;
    
    WifiInfoCountModel *_infoCountModel;
    NSString *_allUserCount;
}
@end

@implementation WifiShareCountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _addUserData = @[].mutableCopy;
    _speedData = @[].mutableCopy;
    
    [self _initView];
    
    [self loadWifiCountData];
    [self loadAllUserData];
}

- (void)_initView {
    self.title = @"Wifi共享";
    
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
    
    [_shareTableView registerNib:[UINib nibWithNibName:@"WifiShareTopCell" bundle:nil] forCellReuseIdentifier:@"WifiShareTopCell"];
    [_shareTableView registerNib:[UINib nibWithNibName:@"WifiAddUserCell" bundle:nil] forCellReuseIdentifier:@"WifiAddUserCell"];
    [_shareTableView registerNib:[UINib nibWithNibName:@"WifiSpeedCell" bundle:nil] forCellReuseIdentifier:@"WifiSpeedCell"];
    [_shareTableView registerNib:[UINib nibWithNibName:@"WifiStateCell" bundle:nil] forCellReuseIdentifier:@"WifiStateCell"];
}
- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 加载用户数据
- (void)loadWifiCountData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/wifi/getWifiUserDetail?getDetail=%@&layerId=%@&getAns=%@&start=&limit=",Main_Url, @"", @"", @"ALL"];
    
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
#pragma mark 加载当前在线用户数
- (void)loadAllUserData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/wifi/getWifiUserDetail?getDetail=%@&layerId=%@&getAns=%@&start=&limit=",Main_Url, @"ALL", @"", @""];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            _allUserCount = [NSString stringWithFormat:@"%@", responseObject[@"responseData"][@"total"]];
            [_shareTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
    } failure:^(NSError *error) {
        [self showHint:KRequestFailMsg];
    }];
}

#pragma mark UITableView协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
//    return 4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        return 255;
    }else if(indexPath.section == 1){
        return 214;
    }
//    else if(indexPath.section == 2){
//        return 175;
//    }
    else {
        return 117;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return 0;
    }else {
        return 50;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return [UIView new];
    }
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 50)];
    headerView.backgroundColor = [UIColor colorWithHexString:@"#EFEFEF"];
    
//    NSArray *titles = @[@"新增用户数", @"实时速率", @"接入点状态"];
    NSArray *titles = @[@"新增用户数", @"接入点状态"];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 15, 200, 20)];
    label.text = titles[section - 1];
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
        WifiShareTopCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WifiShareTopCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.clientData = _infoCountModel.clientType;
        cell.allUserCount = _allUserCount;
        return cell;
    }else if (indexPath.section == 1) {
        WifiAddUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WifiAddUserCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userData = _infoCountModel.addNewUser;
        return cell;
    }
    /*
    else if (indexPath.section == 2) {
        WifiSpeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WifiSpeedCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
     */
    else {
        WifiStateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WifiStateCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.apNumModel = _infoCountModel.APNum;
        return cell;
    }
}

@end
