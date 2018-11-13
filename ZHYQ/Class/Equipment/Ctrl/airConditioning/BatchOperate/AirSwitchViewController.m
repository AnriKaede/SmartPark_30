//
//  AirSwitchViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/7/13.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "AirSwitchViewController.h"
#import "AirSiwtchCell.h"
#import "FloorModel.h"

@interface AirSwitchViewController ()<UITableViewDelegate, UITableViewDataSource, AirSwitchDelegate>
{
    NSMutableArray *_switchData;
    
    UITableView *_switchTableView;
}
@end

@implementation AirSwitchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _switchData = @[].mutableCopy;
    
    [self _initView];
    
    [self _loadEntranceData];
}

- (void)_initView {
    _switchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64) style:UITableViewStylePlain];
    _switchTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _switchTableView.tableFooterView = [UIView new];
    _switchTableView.dataSource = self;
    _switchTableView.delegate = self;
    [self.view addSubview:_switchTableView];
    
    [_switchTableView registerNib:[UINib nibWithNibName:@"AirSiwtchCell" bundle:nil] forCellReuseIdentifier:@"AirSiwtchCell"];
    
//    _switchTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        [self _loadEntranceData];
//    }];
}

// 加载楼层空调数据
- (void)_loadEntranceData {
    [self showHudInView:self.view hint:@""];
    NSString *urlStr = [NSString stringWithFormat:@"%@/public/getChildBulidingList?bulidId=%@&menuId=%@",Main_Url, @"-11", _menuID];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        [self hideHud];
        [_switchData removeAllObjects];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSArray *dataArr = responseObject[@"responseData"];
            [dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FloorModel *model = [[FloorModel alloc] initWithDataDic:obj];
                [_switchData addObject:model];
            }];
        }
        [_switchTableView cyl_reloadData];
    } failure:^(NSError *error) {
        [self hideHud];
        if(_switchData.count <= 0){
            [self showNoDataImage];
        }else {
            [self showHint:KRequestFailMsg];
        }
    }];
}
// 无网络重载
- (void)reloadTableData {
    [self _loadEntranceData];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight)];
    return noDataView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _switchData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    88 + 计算高度
    return 80;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AirSiwtchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AirSiwtchCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.floorModel = _switchData[indexPath.row];
    cell.airSwitchDelegate = self;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}
#pragma mark cell设置开关协议
- (void)airSwitch:(FloorModel *)floorModel withOn:(BOOL)on {
    NSString *operateValue;
    if(on){
        operateValue = @"1";
    }else {
        operateValue = @"0";
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/airConditioner/batchOperate", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:@"layer" forKey:@"rangeType"];
    [paramDic setObject:[NSString stringWithFormat:@"'%@'", floorModel.LAYER_ID] forKey:@"rangeIds"];
    [paramDic setObject:operateValue forKey:@"operateValue"];
    
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            // 记录日志
            [self logRecordOperateTaskID:[NSString stringWithFormat:@"%@", floorModel.LAYER_ID] withTaskName:floorModel.LAYER_NAME isOpen:on];
            
        }
        NSString *message = responseObject[@"message"];
        if(message != nil && ![message isKindOfClass:[NSNull class]]) {
            [self showHint:message];
        }
        
    }failure:^(NSError *error) {
        [self showHint:KRequestFailMsg];
    }];
}

#pragma mark 一键开关日志
- (void)logRecordOperateTaskID:(NSString *)taskId withTaskName:(NSString *)taskName isOpen:(BOOL)isOpen {
    
    NSString *operateStr;
    if(isOpen){
        operateStr = [NSString stringWithFormat:@"一键开启空调\"%@\"", taskName];
    }else {
        operateStr = [NSString stringWithFormat:@"一键关闭空调\"%@\"", taskName];
    }
    
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:operateStr forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:operateStr forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"airConditioner/batchOperate" forKey:@"operateUrl"];//操作url
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:taskId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"空调" forKey:@"operateDeviceName"];//操作设备名  模块
    //    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

@end
