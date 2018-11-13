//
//  FrontGroundViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "FrontGroundViewController.h"

#import "YQHeaderView.h"
#import "ShowMenuView.h"

#import "FrontGroundTableViewCell.h"
#import "OpenFrontGroundTabCell.h"
#import "FgUnParkTableViewCell.h"

#import "ParkLockModel.h"

#import "LockBluetool.h"

#import "NoDataView.h"

@interface FrontGroundViewController ()<UITableViewDelegate,UITableViewDataSource, LockDelegate, LockBluetoothDelegate, CYLTableViewPlaceHolderDelegate>
{
    ShowMenuView *_showMenuView;
    
    NSMutableArray *_parkData;
    
    NSIndexPath *_selIndexPath;
    
    NSIndexPath *_tempIndexPath;
    
//    LockBluetool *_lockBluetooth;
    
    NSTimer *_cancelTimer;
}

@property (nonatomic,strong) YQHeaderView *headerView;
@property (nonatomic,strong) UITableView *tabView;

@end

@implementation FrontGroundViewController

-(YQHeaderView *)headerView
{
    if (_headerView == nil) {
        _headerView = [[YQHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 85)];
        _headerView.backgroundColor = [UIColor colorWithHexString:@"1B82D1"];
    }
    return _headerView;
}

-(UITableView *)tabView
{
    if (_tabView == nil) {
        _tabView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tabView.dataSource = self;
        //        _tabView.bounces = NO;
        _tabView.delegate = self;
        _tabView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tabView.showsVerticalScrollIndicator = NO;
        _tabView.showsHorizontalScrollIndicator = NO;
        _tabView.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
        [_tabView registerNib:[UINib nibWithNibName:@"FrontGroundTableViewCell" bundle:nil] forCellReuseIdentifier:@"FrontGroundTableViewCell"];
        [_tabView registerNib:[UINib nibWithNibName:@"OpenFrontGroundTabCell" bundle:nil] forCellReuseIdentifier:@"OpenFrontGroundTabCell"];
        [_tabView registerNib:[UINib nibWithNibName:@"FgUnParkTableViewCell" bundle:nil] forCellReuseIdentifier:@"FgUnParkTableViewCell"];
        _tabView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    }
    return _tabView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _parkData = @[].mutableCopy;
    
    [self _initView];
    
    [self _initTableView];
    
    [self _loadData];
}

-(void)_initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.headerView];
    
    _headerView.leftLab.text = @"升起";
    _headerView.centerLab.text = @"降下";
}

-(void)_initTableView
{
    [self.view addSubview:self.tabView];
    _tabView.frame = CGRectMake(0, CGRectGetMaxY(_headerView.frame), KScreenWidth, KScreenHeight-CGRectGetMaxY(_headerView.frame) - 64);
    _tabView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self _loadData];
    }];
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/park/lock/seatLock",ParkMain_Url];
    NSMutableDictionary *param = @{}.mutableCopy;
//    [param setObject:@"" forKey:@"token"];
    [param setObject:KParkId forKey:@"parkId"];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        [_tabView.mj_header endRefreshing];
        if([responseObject[@"success"] boolValue]){
            [_parkData removeAllObjects];
            NSArray *data = responseObject[@"data"];
            __block NSInteger upNum = 0;
            __block NSInteger downNum = 0;
            __block NSInteger breakdownNum = 0;
            [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ParkLockModel *model = [[ParkLockModel alloc] initWithDataDic:obj];
                // 0空闲(降下) 1占用(降下) 2预约中(升起)  92异常(不能操作)
                if([model.lockFlag isEqualToString:@"2"]){
                    upNum ++;
                }else if([model.lockFlag isEqualToString:@"0"] || [model.lockFlag isEqualToString:@"1"]) {
                    downNum ++;
                }else if ([model.lockFlag isEqualToString:@"92"]) {
                    breakdownNum ++;
                }
                
                [_parkData addObject:model];
            }];
            
            // 更新headerView状态
            _headerView.leftNumLab.text = [NSString stringWithFormat:@"%ld", (long)upNum];
            _headerView.centerNumLab.text = [NSString stringWithFormat:@"%ld", (long)downNum];
            _headerView.rightNumLab.text = [NSString stringWithFormat:@"%ld", (long)breakdownNum];
            
            
        }else {
            [self showHint:responseObject[@"message"]];
        }
        
        [self.tabView cyl_reloadData];
    } failure:^(NSError *error) {
        [_tabView.mj_header endRefreshing];
        if(_parkData.count <= 0){
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
    NoDataView *noDateView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64-49)];
    return noDateView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark tableview delegate and datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _parkData.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ParkLockModel *model = _parkData[section];
    if(_selIndexPath != nil && _selIndexPath.section == section){
        if ([model.lockFlag isEqualToString:@"0"]) {    // 暂用区分 0 未上锁
            return 2;
        }else { // 上锁
            return 3;
        }
    }else {
        return 1;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *rowCell;
    if (indexPath.row == 0) {
        FrontGroundTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FrontGroundTableViewCell" forIndexPath:indexPath];
        if(indexPath == _selIndexPath){
            cell.headerLineView.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
            cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#f9fcff"];
        }else {
            cell.headerLineView.backgroundColor = [UIColor whiteColor];
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
        cell.parkLockModel = _parkData[indexPath.section];
        rowCell = cell;
    }else if (indexPath.row == 1){
        FgUnParkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FgUnParkTableViewCell" forIndexPath:indexPath];
        if(indexPath.section == _selIndexPath.section){
            cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#f9fcff"];
        }else {
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
        cell.lockDelegate = self;
        cell.parkLockModel = _parkData[indexPath.section];
        rowCell = cell;
    }else{
        OpenFrontGroundTabCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OpenFrontGroundTabCell" forIndexPath:indexPath];
        if(indexPath.section == _selIndexPath.section){
            cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#f9fcff"];
        }else {
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
        cell.parkLockModel = _parkData[indexPath.section];
        rowCell = cell;
    }
    
    return rowCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 70;
    }else if (indexPath.row == 1){
        return 40;
    }else{
        return 45;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row > 0){  // 只能点击seccion为0 缩放
        return;
    }
    
    if(indexPath == _selIndexPath){
        _selIndexPath = nil;
        [tableView reloadData];
        
        [[LockBluetool sharedBluetoothTool] closeCOnnect];
        
        return;
    }
    
    if(_selIndexPath != nil){
        [[LockBluetool sharedBluetoothTool] closeCOnnect];
    }
    
    LockBluetool *lockBluetool = [LockBluetool sharedBluetoothTool];
    
    ParkLockModel *model = _parkData[indexPath.section];
    if(model.lockSecret == nil || [model.lockSecret isKindOfClass:[NSNull class]]){
        return;
    }
    [lockBluetool beginConnectWithLockCode:model.lockSecret];

    lockBluetool.bluetoothDelegate = self;
    // 连接过程中加蒙层 防止点击 
    [self showHudInView:self.view hint:@""];

    // 验证成功才展开
    _tempIndexPath = indexPath;
//    _selIndexPath = indexPath;
//    [tableView reloadData];
    
    // 定时器设置超时
    _cancelTimer = [NSTimer scheduledTimerWithTimeInterval:20 block:^(NSTimer * _Nonnull timer) {
        [[LockBluetool sharedBluetoothTool] cancelScanBluetooth];
        [self hideHud];
        _cancelTimer = nil;
    } repeats:NO];
}

#pragma mark Switch LockDelegate协议  地锁操作
- (void)parkLock:(YQSwitch *)yqSwitch {
    NSString *operation = @"";
    
    // 开关锁
    if(!yqSwitch.on){
        operation = @"1";   // 1 升锁
    }else {
        operation = @"2";   // 2 降锁
    }
    
    ParkLockModel *parkLockModel = _parkData[_selIndexPath.section];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/park/lock/operation", ParkMain_Url];
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:parkLockModel.lockId forKey:@"lockId"];
    [param setObject:operation forKey:@"operationStatus"];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        if([responseObject[@"success"] boolValue]){
            if([operation isEqualToString:@"1"]){
                // 升锁
                [self showHudInView:self.view hint:@""];
                [[LockBluetool sharedBluetoothTool] openLock:^(BOOL isSuccess) {
                    if(isSuccess){
                        [self hideHud];
                        [self lockSuccess:operation withLockId:parkLockModel.lockId withLockName:parkLockModel.lockName];
                    }
                }];
            }else if([operation isEqualToString:@"2"]) {
                // 降锁
                [self showHudInView:self.view hint:@""];
                [[LockBluetool sharedBluetoothTool] downLock:^(BOOL isSuccess) {
                    if(isSuccess){
                        [self hideHud];
                        [self lockSuccess:operation withLockId:parkLockModel.lockId withLockName:parkLockModel.lockName];
                    }
                }];
            }
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark 操作地锁成功
- (void)lockSuccess:(NSString *)operation withLockId:(NSString *)lockId withLockName:(NSString *)lockName {
    ParkLockModel *parkLockModel = _parkData[_selIndexPath.section];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/park/lock/detail", ParkMain_Url];
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:parkLockModel.lockId forKey:@"lockId"];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        if([responseObject[@"success"] boolValue]){
            NSLog(@"%@", responseObject[@"message"]);
            [self _loadData];
            
            // 记录日志
            NSString *logOperation;
            if([operation isEqualToString:@"1"]){
                // 升锁
                logOperation = [NSString stringWithFormat:@"\"%@\"升锁", lockName];
            }else if([operation isEqualToString:@"2"]) {
                // 降锁
                logOperation = [NSString stringWithFormat:@"\"%@\"降锁", lockName];
            }
            [self logRecord:logOperation withLockId:lockId];
        }
    } failure:^(NSError *error) {
        
    }];
}
- (void)logRecord:(NSString *)operation withLockId:(NSString *)lockId {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:operation forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:operation forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"park/lock/detail" forKey:@"operateUrl"];//操作url
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:lockId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"停车" forKey:@"operateDeviceName"];//操作设备名  模块
//    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

- (void)bluetoothNotOpen {
//    [self showHint:@"请先打开手机蓝牙"];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请先打开手机蓝牙" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

// 连接蓝牙设备成功/失败。 未连接成功不可发送指令。会产生奔溃
- (void)connectFail {
    NSLog(@"连接失败");
    [self hideHud];
}
// 可能回调多次
- (void)connectSuccess {
    NSLog(@"连接成功");
    [self hideHud];
}

// 连接成功验证蓝牙设备秘钥。 未验证成功不可发送指令。指令无效
// 验证失败会重新验证，可能会调多次
- (void)verifyFail {
    NSLog(@"验证失败");
    [self hideHud];
}
- (void)verifySuccess {
    NSLog(@"验证成功");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _selIndexPath = _tempIndexPath;
        [_tabView reloadData];
        [self hideHud];
    });
    
}

#pragma mark 关闭页面断开连接
- (void)dealloc {
    [[LockBluetool sharedBluetoothTool] closeCOnnect];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
//    [[LockBluetool sharedBluetoothTool] closeCOnnect];
}

@end
