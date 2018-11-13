//
//  WaterTimeViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/3/8.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WaterTimeViewController.h"
#import "WaterTimeCell.h"

#import "ParkNightTaskModel.h"
#import "WaterTaskEditTableViewController.h"

#import "NoDataView.h"

@interface WaterTimeViewController ()<UITableViewDelegate, UITableViewDataSource, TaskSwitchDelegate, addCompleteDelegate>
{
    NSMutableArray *_timeData;
    
    UITableView *_timeTableView;
}
@end

@implementation WaterTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _timeData = @[].mutableCopy;
    
    [self _initView];
    
    [self _loadData];
}

- (void)_initView {
    _timeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64) style:UITableViewStylePlain];
    _timeTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _timeTableView.tableFooterView = [UIView new];
    _timeTableView.dataSource = self;
    _timeTableView.delegate = self;
    [self.view addSubview:_timeTableView];
    
    [_timeTableView registerNib:[UINib nibWithNibName:@"WaterTimeCell" bundle:nil] forCellReuseIdentifier:@"WaterTimeCell"];
    
    _timeTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self _loadData];
    }];
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/task/get", Main_Url];
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:@"irrigation" forKey:@"deviceType"];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        [_timeTableView.mj_header endRefreshing];
        if([responseObject[@"code"] isEqualToString:@"1"]){
            [_timeData removeAllObjects];
            NSArray *responseData = responseObject[@"responseData"];
            [responseData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ParkNightTaskModel *model = [[ParkNightTaskModel alloc] initWithDataDic:obj];
                [_timeData addObject:model];
            }];
            [_timeTableView reloadData];
        }else {
            if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
                [self showHint:responseObject[@"message"]];
            }
        }
    } failure:^(NSError *error) {
        [_timeTableView.mj_header endRefreshing];
        
        if(_timeData.count <= 0){
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _timeData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 95;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WaterTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WaterTimeCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.taskModel = _timeData[indexPath.row];
    cell.taskSwitchDelegate = self;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ParkNightTaskModel *taskModel = _timeData[indexPath.row];
    WaterTaskEditTableViewController *editVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"WaterTaskEditTableViewController"];
    editVC.parkNightTaskModel = taskModel;
    editVC.addDelegate = self;
    [self.navigationController pushViewController:editVC animated:YES];
}

#pragma mark 任务开关协议
- (void)taskSwitch:(ParkNightTaskModel *)model withOn:(BOOL)on {
    NSString *onStr;
    if(on){
        onStr = @"1";
    }else {
        onStr = @"0";
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/task/update", Main_Url];
    NSDictionary *paramDic = @{@"taskId":model.TASKID,
                               @"isValid":onStr
                               };
    
    NSString *paramStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param =@{@"param" : paramStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [_timeTableView.mj_header endRefreshing];
        if([responseObject[@"code"] isEqualToString:@"1"]){
            if(on){
                model.ISVALID = @"1";
            }else {
                model.ISVALID = @"0";
            }
            
            // 记录日志
            [self logRecordOperateTaskID:[NSString stringWithFormat:@"%@", model.TASKID] withTaskName:model.TASKNAME isOpen:on];
        }else {
        }
        if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
            [self showHint:responseObject[@"message"]];
        }
        
        NSInteger index = [_timeData indexOfObject:model];
        [_timeTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    } failure:^(NSError *error) {
    }];
}


// 修改定时任务完成协议
- (void)addTaskComplete {
    [self _loadData];
}

#pragma mark 开关定时任务日志
- (void)logRecordOperateTaskID:(NSString *)taskId withTaskName:(NSString *)taskName isOpen:(BOOL)isOpen {
    
    NSString *operateStr;
    if(isOpen){
        operateStr = [NSString stringWithFormat:@"开启定时任务\"%@\"", taskName];
    }else {
        operateStr = [NSString stringWithFormat:@"关闭定时任务\"%@\"", taskName];
    }
    
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:operateStr forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:operateStr forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"task/delete" forKey:@"operateUrl"];//操作url
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:taskId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"智能浇灌" forKey:@"operateDeviceName"];//操作设备名  模块
    //    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

@end
