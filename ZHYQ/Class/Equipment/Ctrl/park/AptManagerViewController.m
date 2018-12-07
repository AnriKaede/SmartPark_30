//
//  AptManagerViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/6/19.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "AptManagerViewController.h"
#import "YQHeaderView.h"
#import "ParkSpaceModel.h"
#import "ParkAreaModel.h"
#import "ParkSpaceCell.h"

#import "AptCancelView.h"

@interface AptManagerViewController ()<UITableViewDelegate, UITableViewDataSource, SpaceOperateDelegate, WindowChooseDelegate>
{
    UITableView *_aptTableView;
    NSMutableArray *_aptParkData;
    NSMutableArray *_aptParkTempData;   // 记录上次状态临时数组
    
    AptCancelView *_aptCancelView;
    
    ParkSpaceModel *_parkSpaceModel;
}
@property (nonatomic,strong) YQHeaderView *headerView;
@end

@implementation AptManagerViewController

-(YQHeaderView *)headerView
{
    if (_headerView == nil) {
        _headerView = [[YQHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 85)];
        _headerView.backgroundColor = [UIColor colorWithHexString:@"1B82D1"];
    }
    return _headerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _aptParkData = @[].mutableCopy;
    _aptParkTempData = @[].mutableCopy;
    
    [self _initView];
    
    [self _loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadData) name:@"BatchOprationSuccess" object:nil];
}

- (void)_initView {
    [self.view addSubview:self.headerView];
    
    _headerView.leftLab.text = @"占用";
    _headerView.centerLab.text = @"空闲";
    _headerView.rightLab.text = @"预约中";
    
    _aptTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _headerView.bottom, KScreenWidth, KScreenHeight - 64 - _headerView.height) style:UITableViewStylePlain];
    _aptTableView.tableFooterView = [UIView new];
    _aptTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _aptTableView.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    _aptTableView.delegate = self;
    _aptTableView.dataSource = self;
    [self.view addSubview:_aptTableView];
    
    [_aptTableView registerNib:[UINib nibWithNibName:@"ParkSpaceCell" bundle:nil] forCellReuseIdentifier:@"ParkSpaceCell"];
    
    _aptTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self _loadData];
    }];
    
    // 确认取消弹窗
    _aptCancelView = [[AptCancelView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight)];
    _aptCancelView.chooseDelegate = self;
    [self.view addSubview:_aptCancelView];
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/getParkingSpaces", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:@"1001" forKey:@"parkingId"];
    
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [_aptTableView.mj_header endRefreshing];
        [self removeNoDataImage];
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            
            if(_aptParkData.count > 0){
                _aptParkTempData = _aptParkData.mutableCopy;
                [_aptParkData removeAllObjects];
            }
            
            _headerView.leftNumLab.text = [NSString stringWithFormat:@"%@", responseObject[@"responseData"][@"parkingNum"]];
            _headerView.centerNumLab.text = [NSString stringWithFormat:@"%@", responseObject[@"responseData"][@"avalibleNum"]];
            _headerView.rightNumLab.text = [NSString stringWithFormat:@"%@", responseObject[@"responseData"][@"reservationNum"]];
            
            // 前坪2001
            NSDictionary *responseDic = [NSDictionary dictionaryWithDictionary:responseObject[@"responseData"]];
            [self dealParkData:@"2001" withParkName:@"前坪" withDataDic:responseDic];
            [self dealParkData:@"2002" withParkName:@"南坪" withDataDic:responseDic];
            [self dealParkData:@"2003" withParkName:@"地下车库" withDataDic:responseDic];
         
            // 默认地下车库展开
            if(_aptParkData.count > 0){
                ParkAreaModel *parkAreaModel = _aptParkData.lastObject;
                parkAreaModel.isDisplay = YES;
            }
            [_aptTableView reloadData];
        }
        
    }failure:^(NSError *error) {
        [_aptTableView.mj_header endRefreshing];
        if(_aptParkData.count <= 0){
            [self showNoDataImage];
        }else {
            [self showHint:KRequestFailMsg];
        }
    }];
}

#pragma mark 无数据视图点击刷新
- (void)reloadTableData {
    [self _loadData];
}

- (void)dealParkData:(NSString *)parkSpaceId withParkName:(NSString *)parkName withDataDic:(NSDictionary *)responseDic {
    // 升降车位锁 带led屏
    NSMutableDictionary *spaceStatusDic = @{}.mutableCopy;
    if([parkSpaceId isEqualToString:@"2003"]){
        NSArray *spaceStatus = responseDic[parkSpaceId][@"spaceStatus"];
        [spaceStatus enumerateObjectsUsingBlock:^(NSDictionary *stateDic, NSUInteger idx, BOOL * _Nonnull stop) {
            if([stateDic.allKeys containsObject:@"ledStatus"] && [stateDic.allKeys containsObject:@"parkingSpaceId"]){
                [spaceStatusDic setObject:stateDic[@"ledStatus"] forKey:stateDic[@"parkingSpaceId"]];
            }
        }];
    }
    
    if([responseDic.allKeys containsObject:parkSpaceId]){
        ParkAreaModel *parkAreaModel = [[ParkAreaModel alloc] init];
        parkAreaModel.areaId = parkSpaceId;
        NSArray *parks = responseDic[parkSpaceId][@"items"];
        NSMutableArray *parkSpaces = @[].mutableCopy;
        [parks enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ParkSpaceModel *parkSpaceModel = [[ParkSpaceModel alloc] initWithDataDic:obj];
            if([spaceStatusDic.allKeys containsObject:parkSpaceModel.parkingSpaceId]){
                parkSpaceModel.ledStatus = spaceStatusDic[parkSpaceModel.parkingSpaceId];
            }
            [parkSpaces addObject:parkSpaceModel];
        }];
        parkAreaModel.parkSpaces = parkSpaces;
        
        parkAreaModel.areaName = parkName;
        
        parkAreaModel.isDisplay = NO;
        [_aptParkTempData enumerateObjectsUsingBlock:^(ParkAreaModel *areaModel, NSUInteger idx, BOOL * _Nonnull stop) {
            if([areaModel.areaId isEqualToString:parkSpaceId]){
                parkAreaModel.isDisplay = areaModel.isDisplay;
            }
        }];
        
        [_aptParkData addObject:parkAreaModel];
    }
}

#pragma mark UITableView 协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _aptParkData.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ParkAreaModel *parkAreaModel = _aptParkData[section];
    if(parkAreaModel.isDisplay){
        return parkAreaModel.parkSpaces.count;
    }else {
        return 0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ParkAreaModel *parkAreaModel = _aptParkData[section];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 50)];
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.tag = section + 1000;
    UITapGestureRecognizer *selTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selHeaderAction:)];
    [headerView addGestureRecognizer:selTap];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 130, 50)];
    label.text = parkAreaModel.areaName;
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:17];
    label.textAlignment = NSTextAlignmentLeft;
    [headerView addSubview:label];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(KScreenWidth - 40, 11, 21, 21)];
    imgView.tag = 2001;
    imgView.image = [UIImage imageNamed:@"park_sel_icon"];
    [headerView addSubview:imgView];
    
    if(!parkAreaModel.isDisplay){
        imgView.transform = CGAffineTransformRotate(imgView.transform, M_PI);
    }
    
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ParkSpaceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ParkSpaceCell" forIndexPath:indexPath];
    
    ParkAreaModel *areaModel = _aptParkData[indexPath.section];
    cell.areaId = areaModel.areaId;
    cell.parkSpaceModel = areaModel.parkSpaces[indexPath.row];
    cell.spaceOperateDelegate = self;
    
    return cell;
}

- (void)selHeaderAction:(UITapGestureRecognizer *)tap {
    ParkAreaModel *areaModel = _aptParkData[tap.view.tag - 1000];
    areaModel.isDisplay = !areaModel.isDisplay;
    
    [_aptTableView reloadData];
}

#pragma mark -- spaceOperateDelegate
#pragma mark 开车位锁
- (void)openLock:(ParkSpaceModel *)parkSpaceModel {
    [self oprateionLock:parkSpaceModel withOpration:@"on"];
}
#pragma mark 关车位锁
- (void)lockLock:(ParkSpaceModel *)parkSpaceModel {
    [self oprateionLock:parkSpaceModel withOpration:@"off"];
}
- (void)oprateionLock:(ParkSpaceModel *)parkSpaceModel withOpration:(NSString *)opration {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/forceOperateParkingLock", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:parkSpaceModel.parkingSpaceId forKey:@"parkingSpaceId"];
    [paramDic setObject:opration forKey:@"operateType"];
    
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            // 刷新tableView
            [self _loadData];
            // 记录日志
            NSString *OperateName;
            if([opration isEqualToString:@"on"]){
                OperateName = [NSString stringWithFormat:@"打开车位锁 %@", parkSpaceModel.parkingSpaceName];
            }else {
                OperateName = [NSString stringWithFormat:@"关闭车位锁 %@", parkSpaceModel.parkingSpaceName];
            }
            [self logRecordTagId:parkSpaceModel.parkingSpaceId withOperateName:OperateName withUrl:@"/parking/forceOperateParkingLock"];
        }
        NSString *message = responseObject[@"message"];
        if(message != nil && ![message isKindOfClass:[NSNull class]]) {
            [self showHint:message];
        }
    }failure:^(NSError *error) {
        
    }];
}

#pragma mark 取消预约
- (void)cancelApt:(ParkSpaceModel *)parkSpaceModel {
    [_aptCancelView showWindow:parkSpaceModel.parkingSpaceId];
    _parkSpaceModel = parkSpaceModel;
}
#pragma mark 取消预约弹窗确认协议
- (void)confirmComplete:(NSString *)orderId withRemark:(NSString *)remark {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/forceCancelOrder", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:orderId forKey:@"parkingSpaceId"];
    [paramDic setObject:remark forKey:@"remark"];
    
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            // 取消预约 车位变为空闲状态
            [self _loadData];
            // 记录日志
            NSString *OperateName = [NSString stringWithFormat:@"取消 %@ 预约 %@", _parkSpaceModel.carNo, _parkSpaceModel.parkingSpaceName];;
            [self logRecordTagId:_parkSpaceModel.parkingSpaceId withOperateName:OperateName withUrl:@"/parking/forceCancelOrder"];
        }
        NSString *message = responseObject[@"message"];
        if(message != nil && ![message isKindOfClass:[NSNull class]]) {
            [self showHint:message];
        }
    }failure:^(NSError *error) {
        
    }];
}

#pragma mark 禁止预约
- (void)prohibitApt:(ParkSpaceModel *)parkSpaceModel {
    [self oprateLock:@"off" withModel:parkSpaceModel];
}

#pragma mark 开放预约
- (void)openApt:(ParkSpaceModel *)parkSpaceModel {
    [self oprateLock:@"on" withModel:parkSpaceModel];
}
- (void)oprateLock:(NSString *)oprate withModel:(ParkSpaceModel *)parkSpaceModel {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/operateParking", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:parkSpaceModel.parkingSpaceId forKey:@"parkingSpaceId"];
    [paramDic setObject:parkSpaceModel.version forKey:@"version"];
    [paramDic setObject:oprate forKey:@"operateType"];
    
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            if([oprate isEqualToString:@"on"]){
                parkSpaceModel.parkingStatus = @"0";
            }else if ([oprate isEqualToString:@"off"]) {
                parkSpaceModel.parkingStatus = @"3";
            }
            // 刷新tableView  版本号version实时变化，需请求接口
            [self _loadData];
            // 记录日志
            NSString *OperateName;
            if([oprate isEqualToString:@"on"]){
                OperateName = [NSString stringWithFormat:@"开放预约 %@", parkSpaceModel.parkingSpaceName];
            }else {
                OperateName = [NSString stringWithFormat:@"禁止预约 %@", parkSpaceModel.parkingSpaceName];
            }
            [self logRecordTagId:parkSpaceModel.parkingSpaceId withOperateName:OperateName withUrl:@"/parking/operateParking"];
        }
        NSString *message = responseObject[@"message"];
        if(message != nil && ![message isKindOfClass:[NSNull class]]) {
           [self showHint:message];
        }
        
    }failure:^(NSError *error) {
        
    }];
}
// 开关车位LED灯
- (void)operateLedApt:(ParkSpaceModel *)parkSpaceModel {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/operateParkingLed", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:parkSpaceModel.parkingSpaceId forKey:@"parkingSpaceId"];
    NSString *logOperateName = @"";
    if(parkSpaceModel.ledStatus != nil && [parkSpaceModel.ledStatus isEqualToString:@"1"]){
        // 关灯
        [paramDic setObject:@"closeled" forKey:@"operateType"];
        logOperateName = [NSString stringWithFormat:@"关%@广告灯", parkSpaceModel.parkingSpaceName];
    }else {
        // 开灯
        [paramDic setObject:@"openled" forKey:@"operateType"];
        logOperateName = [NSString stringWithFormat:@"开%@广告灯", parkSpaceModel.parkingSpaceName];
    }
    
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            parkSpaceModel.ledStatus = (parkSpaceModel.ledStatus != nil && [parkSpaceModel.ledStatus isEqualToString:@"1"]) ? @"0" : @"1";
            [self refreshIndexPath:parkSpaceModel];
            // 记录日
            [self logRecordTagId:parkSpaceModel.parkingSpaceId withOperateName:logOperateName withUrl:@"/parking/operateParkingLed"];
        }
        NSString *message = responseObject[@"message"];
        if(message != nil && ![message isKindOfClass:[NSNull class]]) {
            [self showHint:message];
        }
    }failure:^(NSError *error) {
        
    }];
}

#pragma mark 根据model刷新
- (void)refreshIndexPath:(ParkSpaceModel *)parkSpaceModel {
    // 刷新tableView
    [_aptParkData enumerateObjectsUsingBlock:^(ParkAreaModel *areaModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if([areaModel.parkSpaces containsObject:parkSpaceModel]){
            NSInteger index = [areaModel.parkSpaces indexOfObject:parkSpaceModel];
            [_aptTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:idx]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }];
    
    __block int stopCount = 0;
    __block int freeCount = 0;
    __block int aptCount = 0;
    [_aptParkData enumerateObjectsUsingBlock:^(ParkAreaModel *parkAreaModel, NSUInteger idx, BOOL * _Nonnull stop) {
        [parkAreaModel.parkSpaces enumerateObjectsUsingBlock:^(ParkSpaceModel *spaceModel, NSUInteger idx, BOOL * _Nonnull stop) {
            // 车位状态 0空闲 1预占 2已占 3禁止预约 4异常 5 非预约占用
            if([spaceModel.parkingStatus isEqualToString:@"0"]){
                freeCount ++;
            }else if([spaceModel.parkingStatus isEqualToString:@"1"]){
                aptCount ++;
            }else if([spaceModel.parkingStatus isEqualToString:@"2"] && [spaceModel.parkingStatus isEqualToString:@"5"]){
                stopCount ++;
            }
        }];
    }];
    
    _headerView.leftNumLab.text = [NSString stringWithFormat:@"%d", stopCount];
    _headerView.centerNumLab.text = [NSString stringWithFormat:@"%d", freeCount];
    _headerView.rightNumLab.text = [NSString stringWithFormat:@"%d", aptCount];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BatchOprationSuccess" object:nil];
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
