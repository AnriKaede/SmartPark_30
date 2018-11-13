//
//  BatchAptViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/6/19.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BatchAptViewController.h"
#import "ParkSpaceModel.h"
#import "ParkAreaModel.h"
#import "BatchLockCell.h"
#import "AptCancelView.h"

@interface BatchAptViewController ()<UITableViewDelegate, UITableViewDataSource, WindowChooseDelegate>
{
    UITableView *_aptTableView;
    NSMutableArray *_aptParkData;
    
    UIView *_bottomView;
    
    AptCancelView *_aptCancelView;
}
@end

@implementation BatchAptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initNavView];
    
    [self _initView];
    
    [self _loadData];
    
    _aptParkData = @[].mutableCopy;
}

- (void)_initNavView {
    self.title = @"批量操作车位锁";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *rightBtn = [[UIButton alloc] init];
    rightBtn.frame = CGRectMake(0, 0, 60, 40);
    [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [rightBtn setTitle:@"全选" forState:UIControlStateNormal];
    [rightBtn setTitle:@"全不选" forState:UIControlStateSelected];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(_rightBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)_leftBarBtnItemClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)_rightBarBtnItemClick:(UIButton *)button {
    button.selected = !button.selected;
    
    [_aptParkData enumerateObjectsUsingBlock:^(ParkAreaModel *parkAreaModel, NSUInteger idx, BOOL * _Nonnull stop) {
        parkAreaModel.isDisplay = button.selected;
        [parkAreaModel.parkSpaces enumerateObjectsUsingBlock:^(ParkSpaceModel *parkSpaceModel, NSUInteger idx, BOOL * _Nonnull stop) {
            parkSpaceModel.isSelect = button.selected;
        }];
    }];
    [_aptTableView reloadData];
}

- (void)_initView {
    _aptTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64 - 60) style:UITableViewStylePlain];
    _aptTableView.tableFooterView = [UIView new];
    _aptTableView.backgroundColor = [UIColor whiteColor];
    _aptTableView.delegate = self;
    _aptTableView.dataSource = self;
    [self.view addSubview:_aptTableView];
    
    [_aptTableView registerNib:[UINib nibWithNibName:@"BatchLockCell" bundle:nil] forCellReuseIdentifier:@"BatchLockCell"];
    
    [self _createBottomView];
    
    // 确认取消弹窗
    _aptCancelView = [[AptCancelView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight)];
    _aptCancelView.chooseDelegate = self;
    [_aptCancelView setAlertTitle:@"禁止确认"];
    [_aptCancelView setAlertMessage:@"禁止预约将取消车位已有的预约订单，车位不再为员工保留，请确认是否批量禁止？"];
    [self.view insertSubview:_aptCancelView aboveSubview:_bottomView];
}
- (void)_createBottomView {
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, KScreenHeight - 64 - 60, KScreenWidth, 60)];
    [self.view insertSubview:_bottomView aboveSubview:_aptTableView];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, KScreenWidth/2, 60);
    [leftButton setBackgroundImage:[UIImage imageNamed:@"scene_all_close_bg"] forState:UIControlStateNormal];
    [leftButton setTitle:@"批量开放" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(batchOpenAction) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:leftButton];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(KScreenWidth/2, 0, KScreenWidth/2, 60);
    rightButton.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    [rightButton setTitle:@"批量禁止" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor colorWithHexString:@"#CCFF00"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(batchProhibitAction) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:rightButton];
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/getParkingSpaces", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:@"1001" forKey:@"parkingId"];
    
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            [_aptParkData removeAllObjects];
            
            NSDictionary *responseDic = [NSDictionary dictionaryWithDictionary:responseObject[@"responseData"]];
            [self dealParkData:@"2001" withParkName:@"前坪预约车位" withDataDic:responseDic];
            [self dealParkData:@"2002" withParkName:@"南坪预约车位" withDataDic:responseDic];
            [self dealParkData:@"2003" withParkName:@"地下预约车位" withDataDic:responseDic];
            
            [_aptTableView reloadData];
        }
        
    }failure:^(NSError *error) {
        if(_aptParkData.count <= 0){
            [self showNoDataImage];
        }else {
            [self showHint:KRequestFailMsg];
        }
    }];
}

#pragma mark 无网络重新加载
- (void)reloadTableData {
    [self _loadData];
}

- (void)dealParkData:(NSString *)parkSpaceId withParkName:(NSString *)parkName withDataDic:(NSDictionary *)responseDic {
    if([responseDic.allKeys containsObject:parkSpaceId]){
        ParkAreaModel *parkAreaModel = [[ParkAreaModel alloc] init];
        parkAreaModel.areaId = parkSpaceId;
        NSArray *parks = responseDic[parkSpaceId][@"items"];
        NSMutableArray *parkSpaces = @[].mutableCopy;
        [parks enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ParkSpaceModel *parkSpaceModel = [[ParkSpaceModel alloc] initWithDataDic:obj];
            [parkSpaces addObject:parkSpaceModel];
        }];
        parkAreaModel.parkSpaces = parkSpaces;
        
        parkAreaModel.areaName = parkName;
        
        parkAreaModel.isDisplay = NO;
        
        [_aptParkData addObject:parkAreaModel];
    }
}

#pragma mark UITableView 协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _aptParkData.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ParkAreaModel *parkAreaModel = _aptParkData[section];
    return parkAreaModel.parkSpaces.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ParkAreaModel *parkAreaModel = _aptParkData[section];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 50)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 130, 50)];
    label.text = parkAreaModel.areaName;
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:17];
    label.textAlignment = NSTextAlignmentLeft;
    [headerView addSubview:label];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = section + 2000;
    button.frame = CGRectMake(KScreenWidth - 30, 15, 20, 20);
    [button setBackgroundImage:[UIImage imageNamed:@"park_cancel_apt_normal"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"park_cancel_apt_select"] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(selGroupAction:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:button];
    
    // 选中一组
    button.selected = parkAreaModel.isDisplay;
    
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BatchLockCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BatchLockCell" forIndexPath:indexPath];
    
    ParkAreaModel *areaModel = _aptParkData[indexPath.section];
    cell.parkSpaceModel = areaModel.parkSpaces[indexPath.row];
    
    return cell;
}

#pragma mark 批量选中某组
- (void)selGroupAction:(UIButton *)selBt {
    ParkAreaModel *areaModel = _aptParkData[selBt.tag - 2000];
    areaModel.isDisplay = !areaModel.isDisplay;
    
    [areaModel.parkSpaces enumerateObjectsUsingBlock:^(ParkSpaceModel *parkSpaceModel, NSUInteger idx, BOOL * _Nonnull stop) {
        parkSpaceModel.isSelect = areaModel.isDisplay;
    }];
    
    [_aptTableView reloadData];
}

#pragma mark 批量开放
- (void)batchOpenAction {
    NSString *spaces = [self achieveSelSpaces];
    if(spaces == nil || spaces.length <= 0){
        [self showHint:@"请先选择车位"];
        return;
    }
    
    // batchAllow
    [self operationSpace:@"batchAllow" withRemark:@""];
}

#pragma mark 批量禁止
- (void)batchProhibitAction {
    NSString *spaces = [self achieveSelSpaces];
    if(spaces == nil || spaces.length <= 0){
        [self showHint:@"请先选择车位"];
        return;
    }
    
    _aptCancelView.hidden = NO;
    [_aptCancelView showWindow:@""];
}

- (void)confirmComplete:(NSString *)orderId withRemark:(NSString *)remark {
    // batchForbid
    [self operationSpace:@"batchForbid" withRemark:remark];
}

- (void)operationSpace:(NSString *)opreation withRemark:(NSString *)remark {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/batchOperate", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    NSString *spaces = [self achieveSelSpaces];
    [paramDic setObject:spaces forKey:@"parkingSpaces"];
    [paramDic setObject:opreation forKey:@"batchOperate"];
    if(remark !=nil && remark.length > 0){
        [paramDic setObject:remark forKey:@"remark"];
    }
    
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            // 全部取消选中
            [_aptParkData enumerateObjectsUsingBlock:^(ParkAreaModel *parkAreaModel, NSUInteger idx, BOOL * _Nonnull stop) {
                parkAreaModel.isDisplay = NO;
                [parkAreaModel.parkSpaces enumerateObjectsUsingBlock:^(ParkSpaceModel *parkSpaceModel, NSUInteger idx, BOOL * _Nonnull stop) {
                    parkSpaceModel.isSelect = NO;
                }];
            }];
            [_aptTableView reloadData];
            
            // 记录日志
            NSString *OperateName;
            if([opreation isEqualToString:@"batchAllow"]){
                OperateName = [NSString stringWithFormat:@"车位批量开放预约"];
            }else {
                OperateName = [NSString stringWithFormat:@"车位批量禁止预约"];
            }
            [self logRecordTagId:spaces withOperateName:OperateName withUrl:@"/parking/batchOperate"];
            
            // 发送操作成功通知, 刷新预约管理车位数据
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BatchOprationSuccess" object:nil];
        }
        NSString *message = responseObject[@"message"];
        if(message != nil && ![message isKindOfClass:[NSNull class]]) {
            [self showHint:message];
        }
        
    }failure:^(NSError *error) {
        [self showHint:KRequestFailMsg];
    }];
}

- (NSString *)achieveSelSpaces {
    NSMutableString *parkingSpaces = @"".mutableCopy;
    [_aptParkData enumerateObjectsUsingBlock:^(ParkAreaModel *areaModel, NSUInteger idx, BOOL * _Nonnull stop) {
        [areaModel.parkSpaces enumerateObjectsUsingBlock:^(ParkSpaceModel *parkSpaceModel, NSUInteger idx, BOOL * _Nonnull stop) {
            if(parkSpaceModel.isSelect){
                [parkingSpaces appendFormat:@"%@,", parkSpaceModel.parkingSpaceId];
            }
        }];
    }];
    
    if(parkingSpaces.length > 1){
        [parkingSpaces deleteCharactersInRange:NSMakeRange(parkingSpaces.length - 1, 1)];
    }
    
    return parkingSpaces;
}

#pragma mark 记录日志
- (void)logRecordTagId:(NSString *)tagId withOperateName:(NSString *)operateName withUrl:(NSString *)operateUrl {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:[NSString stringWithFormat:@"%@", operateName] forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:[NSString stringWithFormat:@"%@", operateName] forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:operateUrl forKey:@"operateUrl"];//操作url
    //    [logDic setObject:@"" forKey:@"operateLocation"];//操作地点
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:tagId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"车位管理" forKey:@"operateDeviceName"];//操作设备名  模块
    //    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

@end
