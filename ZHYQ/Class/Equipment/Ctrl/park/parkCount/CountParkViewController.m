//
//  CountParkViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/20.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "CountParkViewController.h"
#import "ParkCountNumCell.h"

#import "ParkDateCountModel.h"
#import "HourFlowCountModel.h"

#import "ParkDayCountModel.h"

#import "ParkMonthTimeModel.h"

@interface CountParkViewController ()<UITableViewDataSource, UITableViewDelegate, DateFilterDelegate>
{
    __weak IBOutlet UITableView *_countTableView;
    
    NSMutableArray *_timeData;
    NSMutableArray *_carNumData;
    
    NSMutableArray *_xRollerData;
    
    ParkDayCountModel *_dayCountModel;
    
    ParkCountNumCell *_parkCountNumCell;
    
    // 环比类型
    LinkRatio _linkRatio;
}

@end

@implementation CountParkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _timeData = @[].mutableCopy;
    _carNumData = @[].mutableCopy;
    _xRollerData = @[].mutableCopy;
    
    _linkRatio = DayLinkRatio;  // 默认日环比
    
    [self _initView];
    
    // 加载天统计
    [self loadDayData];
}

- (void)_initView {
    _countTableView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    _countTableView.contentInset = UIEdgeInsetsMake(0, 0, 5, 0);
    _countTableView.dataSource = self;
    _countTableView.delegate = self;
    [_countTableView registerNib:[UINib nibWithNibName:@"ParkCountNumCell" bundle:nil] forCellReuseIdentifier:@"ParkCountNumCell"];
}


#pragma mark 时间范围内停车时长，单位----天。
- (void)_loadScopeDate:(NSString *)startDate withEndDate:(NSString *)endDate {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/analysis/loadDayFlowTime",ParkMain_Url];
    
    NSMutableDictionary *params = @{}.mutableCopy;
    [params setObject:startDate forKey:@"occurDateS"];
    [params setObject:endDate forKey:@"occurDateE"];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        
        [_timeData removeAllObjects];
        if([responseObject[@"success"] boolValue]){
            NSArray *arr = responseObject[@"data"];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ParkDateCountModel *parkModel = [[ParkDateCountModel alloc] initWithDataDic:obj];
                [_timeData addObject:parkModel];
            }];
            [self loadScopeCarNum:startDate withEndDate:endDate];
        }
    } failure:^(NSError *error) {
        [self showHint:KRequestFailMsg];
    }];
}
// 不需要直接调用，同步请求
- (void)loadScopeCarNum:(NSString *)startDate withEndDate:(NSString *)endDate {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/analysis/loadDayFlowCount",ParkMain_Url];
    
    NSMutableDictionary *params = @{}.mutableCopy;
    [params setObject:startDate forKey:@"occurDateS"];
    [params setObject:endDate forKey:@"occurDateE"];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        
        [_carNumData removeAllObjects];
        if([responseObject[@"success"] boolValue]){
            NSArray *arr = responseObject[@"data"];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                HourFlowCountModel *parkModel = [[HourFlowCountModel alloc] initWithDataDic:obj];
                [_carNumData addObject:parkModel];
            }];
            
            [_countTableView reloadData];
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark 当天停车时长，单位----小时。
- (void)_loadDayTime:(NSString *)todaty {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/analysis/loadHourFlowTime",ParkMain_Url];
    
    NSMutableDictionary *params = @{}.mutableCopy;
    [params setObject:todaty forKey:@"reportOccurDate"];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        
        [_timeData removeAllObjects];
        if([responseObject[@"success"] boolValue]){
            NSArray *arr = responseObject[@"data"];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ParkDateCountModel *parkModel = [[ParkDateCountModel alloc] initWithDataDic:obj];
                [_timeData addObject:parkModel];
            }];
            
            [self _loadDayCarNum:todaty];
        }
    } failure:^(NSError *error) {
        
    }];
}
// 不需要直接调用，同步请求
- (void)_loadDayCarNum:(NSString *)todaty {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/analysis/loadHourFlowCount",ParkMain_Url];
    
    NSMutableDictionary *params = @{}.mutableCopy;
    [params setObject:todaty forKey:@"reportOccurDate"];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        
        [_carNumData removeAllObjects];
        if([responseObject[@"success"] boolValue]){
            NSArray *arr = responseObject[@"data"];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                HourFlowCountModel *parkModel = [[HourFlowCountModel alloc] initWithDataDic:obj];
                [_carNumData addObject:parkModel];
            }];
            
            [_countTableView reloadData];
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark 根据选择图标 统计每月数据  单位----天/月
- (void)_loadDayCountData:(NSString *)todaty {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/analysis/analysisMain",ParkMain_Url];
    
    NSMutableDictionary *params = @{}.mutableCopy;
    [params setObject:todaty forKey:@"reportOccurDate"];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        if([responseObject[@"success"] boolValue]){
            _dayCountModel = [[ParkDayCountModel alloc] initWithDataDic:responseObject[@"data"]];
            _parkCountNumCell.dayCountModel = _dayCountModel;
            _parkCountNumCell.linkRatio = _linkRatio;
        }
        
    } failure:^(NSError *error) {
        
    }];
}


#pragma mark 传年当月停车时长，单位----月。
- (void)_loadMonthTime:(NSString *)year {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/analysis/mouth/loadMouthFlowTime?reportOccurYear=%@",ParkMain_Url, year];

    [[NetworkClient sharedInstance] POST:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        
        [_timeData removeAllObjects];
        if([responseObject[@"success"] boolValue]){
            NSArray *arr = responseObject[@"data"];
            [_xRollerData removeAllObjects];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ParkDateCountModel *parkModel = [[ParkDateCountModel alloc] initWithDataDic:obj];
                [_timeData addObject:parkModel];
                
                // 月 x轴坐标
                [_xRollerData addObject:[self dateStrFormatterWithStr:parkModel.reportOccurDate withFormatterStr:@"yyyyMM"]];
            }];
            
            [self _loadMonthCarNum:year];
        }
    } failure:^(NSError *error) {
        
    }];
}
// 不需要直接调用，同步请求
- (void)_loadMonthCarNum:(NSString *)year {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/analysis/mouth/loadMouthFlowCount?reportOccurYear=%@",ParkMain_Url, year];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        
        [_carNumData removeAllObjects];
        if([responseObject[@"success"] boolValue]){
            NSArray *arr = responseObject[@"data"];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                HourFlowCountModel *parkModel = [[HourFlowCountModel alloc] initWithDataDic:obj];
                [_carNumData addObject:parkModel];
            }];
            
            [_countTableView reloadData];
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark 根据选择图标 统计每月数据 单位---月
- (void)_loadMonthCountData:(NSString *)yearMonth { // 201712
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/analysis/mouth/analysisMain",ParkMain_Url];
    
    NSMutableDictionary *params = @{}.mutableCopy;
    [params setObject:yearMonth forKey:@"reportOccurMouth"];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        if([responseObject[@"success"] boolValue]){
            if(responseObject[@"data"] != nil && ![responseObject[@"data"] isKindOfClass:[NSNull class]]){
                _dayCountModel = [[ParkDayCountModel alloc] initWithDataDic:responseObject[@"data"]];
                _parkCountNumCell.dayCountModel = _dayCountModel;
                _parkCountNumCell.linkRatio = _linkRatio;
            }
        }
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark 传当天时间 按周统计，单位----周。
- (void)_loadWeekTime:(NSString *)todayStr {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/analysis/week/loadWeekFlowTime?reportOccurDate=%@",ParkMain_Url, todayStr];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        
        [_timeData removeAllObjects];
        if([responseObject[@"success"] boolValue]){
            [_xRollerData removeAllObjects];
            
            NSArray *arr = responseObject[@"data"];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ParkDateCountModel *parkModel = [[ParkDateCountModel alloc] initWithDataDic:obj];
                [_timeData addObject:parkModel];
                
                NSArray *times = [parkModel.reportOccurDate componentsSeparatedByString:@"-"];
                if(times.count >= 2){
                    // 转时间
                    NSString *weekStart = [self weekXRollteFormatterWithStr:times.firstObject withFormatterStr:@"yyyyMMdd"];
                    NSString *weekEnd = [self weekXRollteFormatterWithStr:times.lastObject withFormatterStr:@"yyyyMMdd"];
                    
                    NSString *xTimeStr = [NSString stringWithFormat:@"%@至%@", weekStart, weekEnd];
                    [_xRollerData addObject:xTimeStr];
                }
                
            }];
            
            for (int i=13; i>=0; i--) {
                
            }
            
            [self _loadWeekCarNum:todayStr];
        }
    } failure:^(NSError *error) {
        
    }];
}
// 不需要直接调用，同步请求
- (void)_loadWeekCarNum:(NSString *)todayStr {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/analysis/week/loadWeekFlowCount?reportOccurDate=%@",ParkMain_Url, todayStr];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        
        [_carNumData removeAllObjects];
        if([responseObject[@"success"] boolValue]){
            NSArray *arr = responseObject[@"data"];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                HourFlowCountModel *parkModel = [[HourFlowCountModel alloc] initWithDataDic:obj];
                [_carNumData addObject:parkModel];
            }];
            
            [_countTableView reloadData];
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark 根据选择图标 统计每周数据 单位---周
- (void)_loadWeekCountData:(NSString *)todayStr { // 20170924-20170930
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/analysis/week/analysisMain",ParkMain_Url];
    
    NSArray *dayArrys = [todayStr componentsSeparatedByString:@"-"];
    NSString *dayStr = @"";
    if(dayArrys != nil && dayArrys.count > 0){
        dayStr = dayArrys.firstObject;
    }
    
    NSMutableDictionary *params = @{}.mutableCopy;
    [params setObject:dayStr forKey:@"reportOccurDate"];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        if([responseObject[@"success"] boolValue]){
            if(responseObject[@"data"] != nil && ![responseObject[@"data"] isKindOfClass:[NSNull class]]){
                _dayCountModel = [[ParkDayCountModel alloc] initWithDataDic:responseObject[@"data"]];
                _parkCountNumCell.dayCountModel = _dayCountModel;
                _parkCountNumCell.linkRatio = _linkRatio;
            }
        }
        
    } failure:^(NSError *error) {
        
    }];
}


#pragma mark UITableView 协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 660;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    _parkCountNumCell = [tableView dequeueReusableCellWithIdentifier:@"ParkCountNumCell" forIndexPath:indexPath];
    _parkCountNumCell.selectionStyle = UITableViewCellSelectionStyleNone;
    _parkCountNumCell.xRollerData = _xRollerData;
    _parkCountNumCell.snapData = _timeData;
    _parkCountNumCell.carNumData = _carNumData;
//    _parkCountNumCell.dayCountModel = _dayCountModel;
    _parkCountNumCell.filterDelegate = self;
    return _parkCountNumCell;
}

#pragma mark 筛选和点击某列协议
- (void)filterDelegate:(FilterDateStyle)filterDateStyle {
    switch (filterDateStyle) {
        case FilterDay:
            // 日
            _linkRatio = DayLinkRatio;
            [self loadDayData];
            break;
            
        case FilterWeek:
            // 周
            _linkRatio = WeekLinkRatio;
            [self loadWeekData];
            break;
            
        case FilterMonth:
            // 月
            _linkRatio = MonthLinkRatio;
            [self loadMonthData];
            break;
            
    }
}
- (void)didSelectChartLineIndex:(NSInteger)selIndex {
    if(_timeData.count > selIndex){
        ParkDateCountModel *parkModel = _timeData[selIndex];
        if(parkModel.reportOccurDate != nil && ![parkModel.reportOccurDate isKindOfClass:[NSNull class]] && parkModel.reportOccurDate.length > 0){
            switch (_linkRatio) {
                case DayLinkRatio:
                    [self _loadDayCountData:parkModel.reportOccurDate];
                    break;
                    
                case WeekLinkRatio:
                    [self _loadWeekCountData:parkModel.reportOccurDate];
                    break;
                    
                case MonthLinkRatio:
                    [self _loadMonthCountData:parkModel.reportOccurDate];
                    break;
                    
            }
        }
    }
}

- (void)loadDayData {
    /*
    [_xRollerData removeAllObjects];
    
    NSDate *nowDate = [NSDate new];
    NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:@"yyyyMMdd"];
    NSString *todayString = [inputFormatter stringFromDate:nowDate];
    
    [self _loadDayTime:todayString];
    
#warning 加载当日下方数据
    [self _loadDayCountData:todayString];
    */
    
    NSString *weekDayStr = [self getNDay:29];   // 前29天加当天 一个月
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:@"yyyyMMdd"];
    NSString *todayString = [inputFormatter stringFromDate:nowDate];
    
    [_xRollerData removeAllObjects];
    for (int i=29; i>=0; i--) {
        NSString *befDayStr = [self getNDay:i];
        NSString *formatDayStr = [self weekStrFormatterWithStr:befDayStr withFormatterStr:@"yyyyMMdd"];
        [_xRollerData addObject:formatDayStr];
    }
    
    [self _loadScopeDate:weekDayStr withEndDate:todayString];
    
#pragma mark 加载当日下方数据
    [self _loadDayCountData:todayString];
}

- (void)loadWeekData {
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:@"yyyyMMdd"];
    NSString *todayString = [inputFormatter stringFromDate:nowDate];
    
//    [_xRollerData removeAllObjects];
//    for (int i=13; i>=0; i--) {
//        NSString *befDayStr = [self getNDay:i*7];
//        NSString *formatDayStr = [self weekStrFormatterWithStr:befDayStr withFormatterStr:@"yyyyMMdd"];
//        [_xRollerData addObject:formatDayStr];
//    }
    
    [self _loadWeekTime:todayString];
    
#pragma mark 加载本周下方数据
    [self _loadWeekCountData:todayString];
}

- (void)loadMonthData {
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:@"yyyy"];
    NSString *yearString = [inputFormatter stringFromDate:nowDate];
    
    [self _loadMonthTime:yearString];
    
#pragma mark 加载当月下方数据
    NSDateFormatter *loadFormatter= [[NSDateFormatter alloc] init];
    [loadFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [loadFormatter setDateFormat:@"yyyyMM"];
    NSString *dataString = [loadFormatter stringFromDate:nowDate];
    [self _loadMonthCountData:dataString];
}

#pragma mark 返回前n天 时间  单位天
- (NSString *)getNDay:(NSInteger)n{
    NSDate*nowDate = [NSDate date];
    NSDate* theDate;

    if(n!=0){
        NSTimeInterval  oneDay = 24*60*60*1;  //1天的长度
        theDate = [nowDate initWithTimeIntervalSinceNow: -oneDay*n ];//initWithTimeIntervalSinceNow是从现在往前后推的秒数
        
        }else{
            theDate = nowDate;
        }

    NSDateFormatter *date_formatter = [[NSDateFormatter alloc] init];
    [date_formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [date_formatter setDateFormat:@"yyyyMMdd"];
    NSString *the_date_str = [date_formatter stringFromDate:theDate];
    
    return the_date_str;
}
#pragma mark 返回前n月 时间  单位月
- (NSString *)getNMonth:(NSInteger)n{
    NSDate*nowDate = [NSDate date];
    NSDate* theDate;
    
    if(n!=0){
        NSTimeInterval  oneDay = 24*60*60*30;  //1月的长度
        theDate = [nowDate initWithTimeIntervalSinceNow: -oneDay*n ];//initWithTimeIntervalSinceNow是从现在往前后推的秒数
        
    }else{
        theDate = nowDate;
    }
    
    NSDateFormatter *date_formatter = [[NSDateFormatter alloc] init];
    [date_formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [date_formatter setDateFormat:@"yyyyMM"];
    NSString *the_date_str = [date_formatter stringFromDate:theDate];
    
    return the_date_str;
}

- (NSString *)dateStrFormatterWithStr:(NSString *)dateStr withFormatterStr:(NSString *)formatterStr {
    NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:formatterStr];
    NSDate *inDate = [inputFormatter dateFromString:dateStr];
    
    NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    NSString *inpoutStr = [dateFormatter stringFromDate:inDate];
    
    return inpoutStr;
}

- (NSString *)weekStrFormatterWithStr:(NSString *)dateStr withFormatterStr:(NSString *)formatterStr {
    NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:formatterStr];
    NSDate *inDate = [inputFormatter dateFromString:dateStr];
    
    NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *inpoutStr = [dateFormatter stringFromDate:inDate];
    
    return inpoutStr;
}

- (NSString *)weekXRollteFormatterWithStr:(NSString *)dateStr withFormatterStr:(NSString *)formatterStr {
    NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:formatterStr];
    NSDate *inDate = [inputFormatter dateFromString:dateStr];
    
    NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setDateFormat:@"MM-dd"];
    NSString *inpoutStr = [dateFormatter stringFromDate:inDate];
    
    return inpoutStr;
}

@end
