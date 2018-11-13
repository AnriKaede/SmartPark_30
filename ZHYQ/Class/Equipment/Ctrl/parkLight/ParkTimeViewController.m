//
//  ParkTimeViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/27.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ParkTimeViewController.h"
#import "SetParkTimeViewController.h"
#import "ParkLightTaskCell.h"
#import "ParkNightTaskModel.h"
#import "NoDataView.h"

@interface ParkTimeViewController ()<UITableViewDelegate, UITableViewDataSource, addCompleteDelegate, TaskSwitchDelegate, CYLTableViewPlaceHolderDelegate>
{
    UITableView *_taskTableView;
    
    NSMutableArray *_taskData;
}
@end

@implementation ParkTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _taskData = @[].mutableCopy;
    
    [self _initView];
    
    [self _loadData];
    
    _taskTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self _loadData];
    }];
}

- (void)_initView {
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTask)];
    
    self.title = _navTitle;
    
    CGFloat tableHeight = KScreenHeight - 64;
    if(_timeTaskType == WaterTask){
        tableHeight = tableHeight - 60;
        
        UIButton *timeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        timeButton.frame = CGRectMake(0, KScreenHeight - 64 - 60, KScreenWidth, 60);
        timeButton.backgroundColor = CNavBgColor;
        [timeButton setTitle:@"+ 添加定时任务" forState:UIControlStateNormal];
        [timeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [timeButton addTarget:self action:@selector(addTask) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:timeButton];
    }
    
    _taskTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, tableHeight) style:UITableViewStylePlain];
    _taskTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _taskTableView.delegate = self;
    _taskTableView.dataSource = self;
    _taskTableView.tableFooterView = [UIView new];
    [self.view addSubview:_taskTableView];
    
    _taskTableView.backgroundColor = [UIColor colorWithHexString:@"#EFEFEF"];
    
    [_taskTableView registerNib:[UINib nibWithNibName:@"ParkLightTaskCell" bundle:nil] forCellReuseIdentifier:@"ParkLightTaskCell"];
}
- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 新增定时任务
- (void)addTask {
    SetParkTimeViewController *setParkVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"SetParkTimeViewController"];
    setParkVC.addDelegate = self;
    setParkVC.timeTaskType = _timeTaskType;
    setParkVC.tagId = _tagId;
    [self.navigationController pushViewController:setParkVC animated:YES];
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/task/get", Main_Url];
    NSMutableDictionary *param = @{}.mutableCopy;
    switch (_timeTaskType) {
        case ParkLightTask:
            [param setObject:@"parking" forKey:@"deviceType"];
            break;
            
        case LEDTask:
            [param setObject:@"ledScreen" forKey:@"deviceType"];
            [param setObject:_tagId forKey:@"tagid"];
            break;
            
        case WaterTask:
#warning 浇灌定时任务
            // 浇灌定时任务
            break;
            
        default:
            break;
    }
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        [_taskTableView.mj_header endRefreshing];
        if([responseObject[@"code"] isEqualToString:@"1"]){
            [_taskData removeAllObjects];
            NSArray *responseData = responseObject[@"responseData"];
            [responseData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ParkNightTaskModel *model = [[ParkNightTaskModel alloc] initWithDataDic:obj];
                [_taskData addObject:model];
            }];
            [_taskTableView cyl_reloadData];
        }else {
            if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
                [self showHint:responseObject[@"message"]];
            }
        }
    } failure:^(NSError *error) {
        [_taskTableView.mj_header endRefreshing];
        if(_taskData.count <= 0){
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


#pragma mark UITableView 协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _taskData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 95;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ParkLightTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ParkLightTaskCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.parkTaskModel = _taskData[indexPath.row];
    cell.taskSwitchDelegate = self;
    return cell;
}
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除"handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        ParkNightTaskModel *model = _taskData[indexPath.row];
        // 定时任务删除
        [self deleteTask:model.TASKID withIndexPath:indexPath withTaskName:model.TASKNAME];
    }];
    
    // 将设置好的按钮放到数组中返回
    return @[deleteRowAction];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SetParkTimeViewController *setParkVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"SetParkTimeViewController"];
    setParkVC.addDelegate = self;
    ParkNightTaskModel *model = _taskData[indexPath.row];
    setParkVC.isUpdate = YES;
    setParkVC.parkNightTaskModel = model;
    setParkVC.timeTaskType = _timeTaskType;
    setParkVC.tagId = _tagId;
    [self.navigationController pushViewController:setParkVC animated:YES];
}

#pragma mark 新增 修改完成协议
- (void)addTaskComplete {
    [self _loadData];
}

#pragma mark 删除任务
- (void)deleteTask:(NSNumber *)taskId withIndexPath:(NSIndexPath *)indexPath withTaskName:(NSString *)taskName {
    NSString *urlStr = [NSString stringWithFormat:@"%@/task/delete", Main_Url];
    NSString *type = @"";
    switch (_timeTaskType) {
        case ParkLightTask:
            type = @"parking";
            break;
            
        case LEDTask:
            type = @"ledScreen";
            break;
            
        default:
            break;
    }
    
    NSDictionary *param = @{@"deviceType":type,
                            @"taskId":taskId
                            };
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [_taskTableView.mj_header endRefreshing];
        if([responseObject[@"code"] isEqualToString:@"1"]){
            [_taskData removeObjectAtIndex:indexPath.row];
            [_taskTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            // 记录日志
            [self logRecordAddTaskID:[NSString stringWithFormat:@"%@", taskId] withTaskName:taskName];
        }else {
            if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
                [self showHint:responseObject[@"message"]];
            }
        }
    } failure:^(NSError *error) {
    }];
}

#pragma marl 开关任务协议
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
        [_taskTableView.mj_header endRefreshing];
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
        
        NSInteger index = [_taskData indexOfObject:model];
        [_taskTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    } failure:^(NSError *error) {
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 删除定时任务日志
- (void)logRecordAddTaskID:(NSString *)taskId withTaskName:(NSString *)taskName {
    NSString *styleStr = @"";
    if(_timeTaskType == ParkLightTask){
        styleStr = @"车库照明";
    }else if(_timeTaskType == LEDTask) {
        styleStr = @"LED屏";
    }else if(_timeTaskType == WaterTask) {
        styleStr = @"浇灌";
    }
    
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:[NSString stringWithFormat:@"删除定时任务\"%@\"", taskName] forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:[NSString stringWithFormat:@"删除定时任务\"%@\"", taskName] forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"task/delete" forKey:@"operateUrl"];//操作url
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:taskId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:styleStr forKey:@"operateDeviceName"];//操作设备名  模块
    //    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

#pragma mark 开关定时任务日志
- (void)logRecordOperateTaskID:(NSString *)taskId withTaskName:(NSString *)taskName isOpen:(BOOL)isOpen {
    
    NSString *operateStr;
    if(isOpen){
        operateStr = [NSString stringWithFormat:@"开启定时任务\"%@\"", taskName];
    }else {
        operateStr = [NSString stringWithFormat:@"关闭定时任务\"%@\"", taskName];
    }
    
    NSString *styleStr = @"";
    if(_timeTaskType == ParkLightTask){
        styleStr = @"车库照明";
    }else if(_timeTaskType == LEDTask) {
        styleStr = @"LED屏";
    }else if(_timeTaskType == WaterTask) {
        styleStr = @"浇灌";
    }
    
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:operateStr forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:operateStr forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"task/delete" forKey:@"operateUrl"];//操作url
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:taskId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:styleStr forKey:@"operateDeviceName"];//操作设备名  模块
    //    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

@end
