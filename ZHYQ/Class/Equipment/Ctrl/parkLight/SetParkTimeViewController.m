//
//  SetParkTimeViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/27.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "SetParkTimeViewController.h"

#import "WSDatePickerView.h"
#import "SelWeekView.h"
#import "Utils.h"

@interface SetParkTimeViewController ()<SelCompleteDelegate>
{
    __weak IBOutlet UITextField *_nameTF;
    
    __weak IBOutlet UILabel *_typeNameLabel;
    
    __weak IBOutlet UILabel *_recurDateLabel;
    __weak IBOutlet UILabel *_startTimeLabel;
    __weak IBOutlet UILabel *_endTimeLabel;
    
    BOOL _isEveryDay;    // 是否是每天
    
    NSString *_startTime;
    NSString *_endTime;
    
    // 选择星期视图
    SelWeekView *_selWeekView;
    
    NSArray *_selWeekDays;
}
@end

@implementation SetParkTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isEveryDay = YES;     // 默认每天
    
    [self _initView];
}
    
- (void)_initView {
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
    
    self.title = @"定时照明";
    
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#EFEFEF"];
    
    _selWeekView = [[SelWeekView alloc] init];
    _selWeekView.selComDelegate = self;
    
    // 是否是修改
    if(_isUpdate){
        _nameTF.text = _parkNightTaskModel.TASKNAME;
        
        if([_parkNightTaskModel.JOBTYPE isEqualToString:@"1"]){
            _isEveryDay = YES;
            _typeNameLabel.text = @"每天";
        }else {
            _isEveryDay = NO;
            _typeNameLabel.text = @"每周";
            _recurDateLabel.text = [self weekWithDays:_parkNightTaskModel.JOBDURATION];
            _recurDateLabel.textColor = [UIColor blackColor];
        }
        
        _selWeekDays = [self weekSelDaysWithstr:_parkNightTaskModel.JOBDURATION];
        
        _startTimeLabel.text = _parkNightTaskModel.BEGIN_TIME;
        _startTimeLabel.textColor = [UIColor blackColor];
        _startTime = _parkNightTaskModel.BEGIN_TIME;
        
        _endTimeLabel.text = _parkNightTaskModel.END_TIME;
        _endTimeLabel.textColor = [UIColor blackColor];
        _endTime = _parkNightTaskModel.END_TIME;
    }
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveAction {
    [self.view endEditing:YES];
    
    // 保存
    if(_nameTF.text == nil || _nameTF.text.length <= 0){
        [self showHint:@"请输入任务名称"];
        return;
    }
    
    NSString *jobDuration;  // 每周的日期
    
    if(!_isEveryDay){
        // 每周
        // 未选择
        if(_selWeekDays == nil || _selWeekDays.count <= 0){
            [self showHint:@"请选择重复日期"];
            return;
        }else {
            // 选择都是关
            __block BOOL isSelDay;  // 是否有选中日期
            [_selWeekDays enumerateObjectsUsingBlock:^(NSNumber *dayIndex, NSUInteger idx, BOOL * _Nonnull stop) {
                if(dayIndex.integerValue == 1){
                    isSelDay = YES;
                    *stop = YES;
                }
            }];
            
            if(!isSelDay){
                [self showHint:@"请选择重复日期"];
                return;
            }else {
                NSMutableString *dayStr = @"".mutableCopy;
                [_selWeekDays enumerateObjectsUsingBlock:^(NSNumber *selIndex, NSUInteger idx, BOOL * _Nonnull stop) {
                    [dayStr appendFormat:@"%@", selIndex];
                }];
                
                // 将周日放在第一位
//                NSString *fristChart = [dayStr substringWithRange:NSMakeRange(0, dayStr.length - 1)];
//                NSString *lastChart = [dayStr substringWithRange:NSMakeRange(dayStr.length - 1, 1)];
//                jobDuration = [NSString stringWithFormat:@"%@%@", lastChart, fristChart];
                
                jobDuration = dayStr;
            }
        }
        
    }else {
        jobDuration = @"1111111";
    }
    
    if(_startTime == nil || _startTime.length <= 0){
        [self showHint:@"请选择开始时间"];
        return;
    }
    
    if(_endTime == nil || _endTime.length <= 0){
        [self showHint:@"请选择结束时间"];
        return;
    }
    
    BOOL isVer = [self verDate:_startTime withEndTime:_endTime];
    if(!isVer){
        [self showHint:@"结束时间不能小于开始时间"];
        return;
    }
    
    NSString *urlStr;
    NSMutableDictionary *paramDic =@{}.mutableCopy;
    // 修改还是新增
    if(_isUpdate){
        [paramDic setObject:_parkNightTaskModel.TASKID forKey:@"taskId"];
        urlStr = [NSString stringWithFormat:@"%@/task/update", Main_Url];
    }else {
        urlStr = [NSString stringWithFormat:@"%@/task/insert", Main_Url];
    }
    
    switch (_timeTaskType) {
        case ParkLightTask:
            [paramDic setObject:@"parking" forKey:@"deviceType"];
            break;
        
        case LEDTask:
            [paramDic setObject:@"ledScreen" forKey:@"deviceType"];
            [paramDic setObject:_tagId forKey:@"tagid"];
            break;
            
        default:
            break;
    }
    
    [paramDic setObject:_nameTF.text forKey:@"taskName"];
    if(_isEveryDay){
        [paramDic setObject:@"1" forKey:@"jobType"];
    }else {
        [paramDic setObject:@"2" forKey:@"jobType"];
    }
    [paramDic setObject:jobDuration forKey:@"jobDuration"];
    [paramDic setObject:_startTime forKey:@"beginTime"];
    [paramDic setObject:_endTime forKey:@"endTime"];
    [paramDic setObject:@"ON" forKey:@"jobAction"];
    if(_isUpdate){
        [paramDic setObject:_parkNightTaskModel.ISVALID forKey:@"isValid"];
    }else {
        [paramDic setObject:@"1" forKey:@"isValid"];
    }
    
    NSString *paramStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param =@{@"param" : paramStr};
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self showHudInView:self.view hint:nil];
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        if([responseObject[@"code"] isEqualToString:@"1"]){
            if(_addDelegate){
                [_addDelegate addTaskComplete];
            }
            // 成功
            if(_isUpdate){
                // 记录修改日志
                [self logRecordUpdateTaskID:[NSString stringWithFormat:@"%@", _parkNightTaskModel.TASKID] withTaskName:_parkNightTaskModel.TASKNAME];
            }else {
                // 记录新增日志
                NSString *taskID = [NSString stringWithFormat:@"%@", responseObject[@"responseData"][@"taskId"]];
                [self logRecordAddTaskID:taskID withTaskName:_nameTF.text];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
            [self showHint:responseObject[@"message"]];
        }
        
    } failure:^(NSError *error) {
        [self hideHud];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }];
    
}

- (BOOL)verDate:(NSString *)startTime withEndTime:(NSString *)endTime {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [format setDateFormat:@"HH:mm"];
    NSDate *startDate = [format dateFromString:startTime];
    NSDate *endDate = [format dateFromString:endTime];
    
    // 结束时间不能小于开始时间
    NSComparisonResult result = [startDate compare:endDate];
    if (result == NSOrderedDescending) {
        //end比start小
        return NO;
    }else {
        return YES;
    }
}

#pragma mark UITableView 协议
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            {
                switch (indexPath.row) {
                    case 0:
                        return 150;
                        break;
                        
                    case 1:
                        return 60;
                        break;
                        
                    default:
                        return 0;
                        break;
                }
            }
            break;
            
        case 1:
            {
                if(indexPath.row == 1 && _isEveryDay){
                    return 0;
                }else {
                    return 60;
                }
            }
            break;
            
        default:
            return 0;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    
    if(indexPath.section == 1){
        switch (indexPath.row) {
            case 0:
                {
                    if(_isEveryDay){
                        _typeNameLabel.text = @"每周";
                        _isEveryDay = NO;
                    }else {
                        _typeNameLabel.text = @"每天";
                        _isEveryDay = YES;
                    }
                    [tableView reloadRowsAtIndexPaths:@[] withRowAnimation:UITableViewRowAnimationFade];
                    break;
                }
            case 1:
            {
                // 设置重复时间
                _selWeekView.hidden = NO;
                break;
            }
            case 2:
            {
                // 设置开始时间
                WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowHourMinute scrollToDate:[NSDate date] CompleteBlock:^(NSDate *selectDate) {
                    NSString *date = [selectDate stringWithFormat:@"HH:mm"];
                    _startTimeLabel.text = date;
                    _startTimeLabel.textColor = [UIColor blackColor];
                    _startTime = date;
                }];
                datepicker.dateLabelColor = [UIColor colorWithHexString:@"1B82D1"];//年-月-日-时-分 颜色
                datepicker.datePickerColor = [UIColor blackColor];//滚轮日期颜色
                datepicker.doneButtonColor = [UIColor colorWithHexString:@"1B82D1"];//确定按钮的颜色
                datepicker.yearLabelColor = [UIColor clearColor];//大号年份字体颜色
                [datepicker show];
                break;
            }
            case 3:
            {
                // 设置结束时间
                WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowHourMinute scrollToDate:[NSDate date] CompleteBlock:^(NSDate *selectDate) {
                    NSString *date = [selectDate stringWithFormat:@"HH:mm"];
                    _endTimeLabel.text = date;
                    _endTimeLabel.textColor = [UIColor blackColor];
                    _endTime = date;
                }];
                datepicker.dateLabelColor = [UIColor colorWithHexString:@"1B82D1"];//年-月-日-时-分 颜色
                datepicker.datePickerColor = [UIColor blackColor];//滚轮日期颜色
                datepicker.doneButtonColor = [UIColor colorWithHexString:@"1B82D1"];//确定按钮的颜色
                datepicker.yearLabelColor = [UIColor clearColor];//大号年份字体颜色
                [datepicker show];
                break;
            }
                
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 选择每周日期协议
- (void)selWeekDay:(NSArray *)days {
    _selWeekDays = days;
    
    NSMutableString *selDayStr = @"".mutableCopy;
    [days enumerateObjectsUsingBlock:^(NSNumber *dayIndex, NSUInteger idx, BOOL * _Nonnull stop) {
        switch (idx) {
            case 0:
                if(dayIndex.integerValue == 1){
                    [selDayStr appendString:@" 一"];
                }
                break;
                
            case 1:
                if(dayIndex.integerValue == 1){
                    [selDayStr appendString:@" 二"];
                }
                break;
                
            case 2:
                if(dayIndex.integerValue == 1){
                    [selDayStr appendString:@" 三"];
                }
                break;
                
            case 3:
                if(dayIndex.integerValue == 1){
                    [selDayStr appendString:@" 四"];
                }
                break;
                
            case 4:
                if(dayIndex.integerValue == 1){
                    [selDayStr appendString:@" 五"];
                }
                break;
                
            case 5:
                if(dayIndex.integerValue == 1){
                    [selDayStr appendString:@" 六"];
                }
                break;
                
            case 6:
                if(dayIndex.integerValue == 1){
                    [selDayStr appendString:@" 日"];
                }
                break;
                
            default:
                break;
        }
    }];
    
    if(selDayStr != nil && selDayStr.length > 0){
        // 选择日期不为空
        selDayStr = [NSString stringWithFormat:@"星期%@", selDayStr].mutableCopy;
        _recurDateLabel.text = selDayStr;
        _recurDateLabel.textColor = [UIColor blackColor];
    }else {
        _recurDateLabel.text = @"请选择重复日期";
        _recurDateLabel.textColor = [UIColor colorWithHexString:@"#A3A3A3"];
    }
    
}

#pragma mark 字符串分割
- (NSString *)weekWithDays:(NSString *)dayStr {
    if(dayStr == nil || [dayStr isKindOfClass:[NSNull class]]){
        return @"星期 ";
    }
    
    NSMutableString *weekStr = @"".mutableCopy;
    NSArray *weekDayStr = @[@" 一", @" 二", @" 三", @" 四", @" 五", @" 六", @" 日"];
    for (int i=0; i<dayStr.length; i++) {
        NSString *chartStr = [dayStr substringWithRange:NSMakeRange(i, 1)];
        if(chartStr.integerValue == 1){
            if(i < weekDayStr.count){
                [weekStr appendString:weekDayStr[i]];
            }
        }
    }
    
    weekStr = [NSString stringWithFormat:@"星期%@", weekStr].mutableCopy;
    
    return weekStr;
}

- (NSArray *)weekSelDaysWithstr:(NSString *)dayStr {
    if(dayStr == nil || [dayStr isKindOfClass:[NSNull class]]){
        return @[];
    }
    
    NSMutableArray *days = @[].mutableCopy;
    for (int i=0; i<dayStr.length; i++) {
        NSString *chartStr = [dayStr substringWithRange:NSMakeRange(i, 1)];
        [days addObject:[NSNumber numberWithInt:chartStr.intValue]];
    }
    
//    NSNumber *fristObj = days.firstObject;
//    [days removeObjectAtIndex:0];
//    [days insertObject:fristObj atIndex:days.count - 1];
    
    return days;
}

#pragma mark 新增定时任务日志
- (void)logRecordAddTaskID:(NSString *)taskId withTaskName:(NSString *)taskName {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:[NSString stringWithFormat:@"新增定时任务\"%@\"", taskName] forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:[NSString stringWithFormat:@"新增定时任务\"%@\"", taskName] forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"task/insert" forKey:@"operateUrl"];//操作url
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:taskId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"车库照明" forKey:@"operateDeviceName"];//操作设备名  模块
//    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

#pragma mark 修改定时任务日志
- (void)logRecordUpdateTaskID:(NSString *)taskId withTaskName:(NSString *)taskName {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:[NSString stringWithFormat:@"修改定时任务\"%@\"", taskName] forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:[NSString stringWithFormat:@"修改定时任务\"%@\"", taskName] forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"task/delete" forKey:@"operateUrl"];//操作url
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:taskId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"车库照明" forKey:@"operateDeviceName"];//操作设备名  模块
    //    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

@end
