//
//  LEDViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "LEDViewController.h"
#import "YQHeaderView.h"
#import "LEDCell.h"
#import "MsgPostViewController.h"
#import "LedListModel.h"

#import "NoDataView.h"

#import "ParkTimeViewController.h"

#import "NewLEDCell.h"
#import "LEDScreenShotViewController.h"

typedef enum {
    OpenLed = 0,
    CloseLed,
    OpenPC,
    RestartPC,
    ClosePC,
    ResumeDefault,
    
    OpenStreetLED,
    CLoseStreetLED,
    RestartStreetPC
}LEDOperateType;

@interface LEDViewController ()<UITableViewDelegate, UITableViewDataSource, CYLTableViewPlaceHolderDelegate,LEDListDelegate>
{
    __weak IBOutlet YQHeaderView *_headerView;
    __weak IBOutlet UITableView *_tableView;
    
    NSMutableArray *_ledData;
    
    NSInteger _page;
    NSInteger _length;
}
@end

@implementation LEDViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [self _loadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _ledData = @[].mutableCopy;
    
    _page = 1;
    _length = 3;
    
    [self _initView];
    
    [_tableView.mj_header beginRefreshing];
}

- (void)_initView {
//    self.title = @"LED屏";
    
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
    [rightBtn setImage:[UIImage imageNamed:@"LED_publish_icon"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(_rightBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    _headerView.backgroundColor = [UIColor colorWithHexString:@"1B82D1"];
    _headerView.leftLab.text = @"开启";
    _headerView.leftNumLab.text = @"0";
    
    _headerView.centerLab.text = @"关闭";
    _headerView.centerNumLab.text = @"0";
    
    _headerView.rightLab.text = @"故障";
    _headerView.rightNumLab.text = @"0";
    
    _tableView.tableFooterView = [UIView new];
    _tableView.separatorColor = [UIColor clearColor];
//    [_tableView registerNib:[UINib nibWithNibName:@"LEDCell" bundle:nil] forCellReuseIdentifier:@"LEDCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"NewLEDCell" bundle:nil] forCellReuseIdentifier:@"NewLEDCell"];
    
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self _loadData];
    }];
    // 上拉刷新
    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self _loadData];
    }];
    _tableView.mj_footer.hidden = YES;
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)_rightBarBtnItemClick {
    MsgPostViewController *ledPostMsgVC = [[MsgPostViewController alloc] init];
    [self.navigationController pushViewController:ledPostMsgVC animated:YES];
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/equipment/getLedScreenList",Main_Url];
    
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:@"all" forKey:@"type"];
    [param setObject:[NSNumber numberWithInteger:_page] forKey:@"pageNumber"];
    [param setObject:[NSNumber numberWithInteger:_length] forKey:@"pageSize"];
    NSDictionary *paramDic =@{@"param":[Utils convertToJsonData:param]};
    [[NetworkClient sharedInstance] POST:urlStr dict:paramDic progressFloat:nil succeed:^(id responseObject) {
        [_tableView.mj_header endRefreshing];
        [self removeNoDataImage];
        
        [_tableView.mj_header endRefreshing];
        [_tableView.mj_footer endRefreshing];
        if([responseObject[@"code"] isEqualToString:@"1"]) {
            if(_page == 1){
                [_ledData removeAllObjects];
            }
            NSArray *responseData = responseObject[@"responseData"][@"ledScreenList"];
            if(responseData.count > _length-1){
                _tableView.mj_footer.state = MJRefreshStateIdle;
                _tableView.mj_footer.hidden = NO;
            }else {
                _tableView.mj_footer.state = MJRefreshStateNoMoreData;
                _tableView.mj_footer.hidden = YES;
            }
            [responseData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                LedListModel *model = [[LedListModel alloc] initWithDataDic:obj];
                [_ledData addObject:model];
            }];
            
            NSNumber *errorCount = responseObject[@"responseData"][@"errorCount"];
            _headerView.rightNumLab.text = [NSString stringWithFormat:@"%@", errorCount];
            
            NSNumber *okCount = responseObject[@"responseData"][@"okCount"];
            _headerView.leftNumLab.text = [NSString stringWithFormat:@"%@", okCount];
            
            NSNumber *outCount = responseObject[@"responseData"][@"outCount"];
            _headerView.centerNumLab.text = [NSString stringWithFormat:@"%@", outCount];
            
            [_tableView cyl_reloadData];
        }
        
    } failure:^(NSError *error) {
        [_tableView.mj_header endRefreshing];
        [_tableView.mj_footer endRefreshing];
        
        if(_ledData.count <= 0){
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

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDateView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64)];
    return noDateView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark UITableView协议
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    return _ledData.count;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSArray *arr = _ledData[section];
//    return arr.count;
    return _ledData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 248;
//    LedListModel *ledListModel = _ledData[indexPath.row];
//    if([ledListModel.type isEqualToString:@"1"]){
//        return 175;
//    }
    return 205;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    LEDCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LEDCell" forIndexPath:indexPath];
//    cell.ledListModel = _ledData[indexPath.row];
//    cell.ledSwitchDelegate = self;
    
    NewLEDCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewLEDCell" forIndexPath:indexPath];
    cell.ledListModel = _ledData[indexPath.row];
    cell.delegate = self;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    return 45;
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 45)];
    view.backgroundColor = [UIColor colorWithHexString:@"#EFEFEF"];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(11, 18, 120, 17)];
    lab.textColor = [UIColor blackColor];
    lab.textAlignment = NSTextAlignmentLeft;
    lab.text = @"123";
    [view addSubview:lab];
    
//    return view;
    return [UIView new];
}

/*
#pragma mark 开关协议
- (void)ledSwitch:(LedListModel *)ledListModel withOn:(BOOL)on {
    if([ledListModel.type isEqualToString:@"1"]){
        // 可控制
        [self switchLight:ledListModel withOn:on];
    }else {
        [self showHint:@"此LED屏不支持开关操作"];
        
        NSInteger index = [_ledData indexOfObject:ledListModel];
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
}
- (void)switchLight:(LedListModel *)ledListModel withOn:(BOOL)on {
    NSString *urlStr = [NSString stringWithFormat:@"%@/roadLamp/controlLed",Main_Url];
    
    NSMutableDictionary *searchParam = @{}.mutableCopy;
    [searchParam setObject:ledListModel.tagid forKey:@"uid"];
    if(on){
        [searchParam setObject:@"ON" forKey:@"operateType"];
    }else {
        [searchParam setObject:@"OFF" forKey:@"operateType"];
    }
    
    NSString *jsonStr = [Utils convertToJsonData:searchParam];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            // 调列表接口刷新
            [self _loadData];
            
            // 成功
            if(on){
                ledListModel.status = @"1";
            }else {
                ledListModel.status = @"0";
            }
            
            // 记录日志
            NSString *operate;
            if(on){
                operate = [NSString stringWithFormat:@"LED屏\"%@\"开", ledListModel.deviceName];
            }else {
                operate = [NSString stringWithFormat:@"LED屏\"%@\"关", ledListModel.deviceName];
            }
            [self logRecordOperate:operate withTagid:ledListModel.tagid];
        }else {
            if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
                [self showHint:responseObject[@"message"]];
            }
        }
        
        NSInteger index = [_ledData indexOfObject:ledListModel];
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
    } failure:^(NSError *error) {
        
    }];
}
 */


- (void)logRecordOperate:(NSString *)operate withTagid:(NSString *)tagId {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:operate forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:operate forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"udpController/sendMsgToUdpSer" forKey:@"operateUrl"];//操作url
    [logDic setObject:tagId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"LED屏" forKey:@"operateDeviceName"];//操作设备名  模块
    
    [LogRecordObj recordLog:logDic];
}

#pragma mark 新LED操作协议
// 截屏
- (void)lookScreenShotWithModel:(LedListModel*)ledListModel {
    LEDScreenShotViewController *ledScreenVc = [[LEDScreenShotViewController alloc] init];
    if([ledListModel.type isEqualToString:@"1"]){
        // 路灯屏
        ledScreenVc.isStreetLight = YES;
    }
    ledScreenVc.ledListModel = ledListModel;
    [self.navigationController pushViewController:ledScreenVc animated:YES];
}
- (void)ledSwitch:(BOOL)on withModel:(LedListModel*)ledListModel {
    if([ledListModel.type isEqualToString:@"1"]){
        // 路灯屏
        [self streetOperate:on withModel:ledListModel];
    }else {
        if(on){
            [self operateLed:OpenLed withModel:ledListModel];
        }else {
            [self operateLed:CloseLed withModel:ledListModel];
        }
    }
    ledListModel.status = on ? @"1" : @"0";
}
- (void)ledPlay:(LedListModel*)ledListModel {
    NSInteger index = [_ledData indexOfObject:ledListModel];
    UITableViewCell *cellView = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [self alertOperate:@"是否确定开启设备主机" withBolck:^{
        [self operateLed:OpenPC withModel:ledListModel];
    } withShowView:cellView==nil?_headerView:cellView];
}
- (void)ledRestart:(LedListModel*)ledListModel {
    NSInteger index = [_ledData indexOfObject:ledListModel];
    UITableViewCell *cellView = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [self alertOperate:@"是否确定重启设备主机" withBolck:^{
        if([ledListModel.type isEqualToString:@"1"]){
            [self streetRestart:ledListModel];
        }else {
            [self operateLed:RestartPC withModel:ledListModel];
        }
    } withShowView:cellView==nil?_headerView:cellView];
}
- (void)ledClose:(LedListModel*)ledListModel {
    NSInteger index = [_ledData indexOfObject:ledListModel];
    UITableViewCell *cellView = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [self alertOperate:@"是否确定关闭设备主机" withBolck:^{
        [self operateLed:ClosePC withModel:ledListModel];
    } withShowView:cellView==nil?_headerView:cellView];
}
- (void)resumeDefault:(LedListModel*)ledListModel {
    NSInteger index = [_ledData indexOfObject:ledListModel];
    UITableViewCell *cellView = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [self alertOperate:@"是否确定恢复默认节目" withBolck:^{
        [self operateLed:ResumeDefault withModel:ledListModel];
    } withShowView:cellView==nil?_headerView:cellView];
}

- (void)operateLed:(LEDOperateType)operateType withModel:(LedListModel *)ledListModel {
    NSString *urlStr;
    if(operateType == OpenPC){
        urlStr = [NSString stringWithFormat:@"%@/udpController/sendWakeOnlan",Main_Url];
    }else {
        urlStr = [NSString stringWithFormat:@"%@/udpController/sendMsgToUdpSer",Main_Url];
    }
    
    NSMutableDictionary *searchParam = @{}.mutableCopy;
    [searchParam setObject:ledListModel.deviceId forKey:@"deviceId"];
    [searchParam setObject:[self conOperateType:operateType] forKey:@"instructions"];
    
//    NSString *jsonStr = [Utils convertToJsonData:searchParam];
//    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:searchParam progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            // 调列表接口刷新
//            [self _loadData];
            
            // 成功
            // 记录日志
            [self operateLog:operateType withModel:ledListModel];
        }
        if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
            [self showHint:responseObject[@"message"]];
        }
        
        NSInteger index = [_ledData indexOfObject:ledListModel];
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)operateLog:(LEDOperateType)operateType withModel:(LedListModel *)ledListModel {
    NSString *operate;
    switch (operateType) {
        case OpenLed:
        {
            ledListModel.status = @"1";
            operate = [NSString stringWithFormat:@"LED屏\"%@\"开", ledListModel.deviceName];
            break;
        }
        case CloseLed:
        {
            ledListModel.status = @"0";
            operate = [NSString stringWithFormat:@"LED屏\"%@\"关", ledListModel.deviceName];
            break;
        }
        case OpenPC:
        {
            operate = [NSString stringWithFormat:@"LED屏电脑\"%@\"开", ledListModel.deviceName];
            break;
        }
        case RestartPC:
        {
            operate = [NSString stringWithFormat:@"LED电脑\"%@\"重启", ledListModel.deviceName];
            break;
        }
        case ClosePC:
        {
            operate = [NSString stringWithFormat:@"LED屏电脑\"%@\"关", ledListModel.deviceName];
            break;
        }
        case OpenStreetLED:
        {
            operate = [NSString stringWithFormat:@"路灯LED屏\"%@\"开", ledListModel.deviceName];
            break;
        }
        case CLoseStreetLED:
        {
            operate = [NSString stringWithFormat:@"路灯LED屏\"%@\"关", ledListModel.deviceName];
            break;
        }
        case RestartStreetPC:
        {
            operate = [NSString stringWithFormat:@"路灯LED主机\"%@\"重启", ledListModel.deviceName];
            break;
        }
            
        default:
            break;
    }
    [self logRecordOperate:operate withTagid:ledListModel.tagid];
}

- (NSString *)conOperateType:(LEDOperateType)operateType {
    NSString *operate;
    switch (operateType) {
        case OpenLed:
        {
            operate = @"OPENLED";
            break;
        }
        case CloseLed:
        {
            operate = @"CLOSELED";
            break;
        }
        case OpenPC:
        {
            operate = @"START";
            break;
        }
        case RestartPC:
        {
            operate = @"REBOOT";
            break;
        }
        case ClosePC:
        {
            operate = @"SHUTDOWN";
            break;
        }
        case ResumeDefault:
        {
            operate = @"UPDATEPLAY";
            break;
        }
            
        default:
            break;
    }
    
    return operate;
}

- (void)alertOperate:(NSString *)message withBolck:(void(^)(void))certain withShowView:(UIView *)showView {
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *removeAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        certain();
    }];
    [alertCon addAction:cancelAction];
    [alertCon addAction:removeAction];
    if (alertCon.popoverPresentationController != nil) {
        alertCon.popoverPresentationController.sourceView = showView;
        alertCon.popoverPresentationController.sourceRect = showView.bounds;
    }
    [self presentViewController:alertCon animated:YES completion:^{
    }];
}

#pragma mark 路灯屏 操作
- (void)streetOperate:(BOOL)onOff withModel:(LedListModel *)ledListModel {
    NSString *urlStr = [NSString stringWithFormat:@"%@/roadLamp/openAndStopScreen",Main_Url];
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:ledListModel.tagid forKey:@"tagId"];
    LEDOperateType operateType;
    if(onOff){
        // 开
        [param setObject:[NSNumber numberWithBool:YES] forKey:@"arg1"];
        operateType = OpenStreetLED;
    }else {
        // 关
        [param setObject:[NSNumber numberWithBool:NO] forKey:@"arg1"];
        operateType = CLoseStreetLED;
    }
    
    NSString *jsonParam = [Utils convertToJsonData:param];
    NSDictionary *params = @{@"param":jsonParam};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            // 调列表接口刷新
            // 成功
            // 记录日志
            [self operateLog:operateType withModel:ledListModel];
            
            ledListModel.mainstatus = [NSString stringWithFormat:@"%d", onOff];
        }
        if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
            [self showHint:responseObject[@"message"]];
        }
        
        NSInteger index = [_ledData indexOfObject:ledListModel];
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
    } failure:^(NSError *error) {
        
    }];
}
- (void)streetRestart:(LedListModel *)ledListModel {
    NSString *urlStr = [NSString stringWithFormat:@"%@/roadLamp/restartScreen",Main_Url];
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:ledListModel.tagid forKey:@"tagId"];
    LEDOperateType operateType = RestartStreetPC;
    
    NSString *jsonParam = [Utils convertToJsonData:param];
    NSDictionary *params = @{@"param":jsonParam};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            // 调列表接口刷新
            // 成功
            // 记录日志
            [self operateLog:operateType withModel:ledListModel];
        }
        if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
            [self showHint:responseObject[@"message"]];
        }
        
        NSInteger index = [_ledData indexOfObject:ledListModel];
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
    } failure:^(NSError *error) {
        
    }];
}

@end
