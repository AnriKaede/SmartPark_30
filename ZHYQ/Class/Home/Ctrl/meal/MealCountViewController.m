//
//  MealCountViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/2/1.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "MealCountViewController.h"
#import "MealCountCell.h"
#import "AAChartView.h"
#import "VisCountNumModel.h"
#import "MealDayModel.h"

@interface MealCountViewController ()<UITableViewDataSource, UITableViewDelegate, VisDateFilterDelegate>
{
    UITableView *_countTableView;
    MealCountCell *_mealCountCell;
    
    NSMutableArray *_xRollerData;
    NSMutableArray *_numData;
    NSMutableArray *_costData;
}
@end

@implementation MealCountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _xRollerData = @[].mutableCopy;
    _numData = @[].mutableCopy;
    _costData = @[].mutableCopy;
    
    [self _initView];
    
    [self _loadData];
}

- (void)_loadData {
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *statDate = [dateFormat stringFromDate:nowDate];
    
    NSDateFormatter *monthFormat = [[NSDateFormatter alloc] init];
    [monthFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [monthFormat setDateFormat:@"yyyy-MM"];
    NSString *statMonth = [monthFormat stringFromDate:nowDate];
    
    [self _loadDayCount:statMonth];
    
    [self _loadTimeCountData:statDate];
}

- (void)_initView {
    _countTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64 - kTabBarHeight) style:UITableViewStyleGrouped];
    _countTableView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    _countTableView.contentInset = UIEdgeInsetsMake(0, 0, 5, 0);
    _countTableView.dataSource = self;
    _countTableView.delegate = self;
    [self.view addSubview:_countTableView];
    
    [_countTableView registerNib:[UINib nibWithNibName:@"MealCountCell" bundle:nil] forCellReuseIdentifier:@"MealCountCell"];
}

#pragma mark 按天统计 单位天
- (void)_loadDayCount:(NSString *)statMonth {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parkCard/dayFlowStat",Main_Url];
    
    NSMutableDictionary *searchParam = @{}.mutableCopy;
    [searchParam setObject:statMonth forKey:@"statMonth"];
    
    NSString *jsonStr = [Utils convertToJsonData:searchParam];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            [_xRollerData removeAllObjects];
            [_numData removeAllObjects];
            [_costData removeAllObjects];
            NSArray *dayStat = responseObject[@"responseData"][@"dayStat"];
            [dayStat enumerateObjectsUsingBlock:^(NSDictionary *dayInfo, NSUInteger idx, BOOL * _Nonnull stop) {
                [_xRollerData addObject:[self getNDay:dayStat.count - idx - 1]];
                if([dayInfo[@"count"] isKindOfClass:[NSString class]]){
                    NSString *avgNum = dayInfo[@"count"];
                    [_numData addObject:[NSNumber numberWithString:avgNum]];
                }else {
                    NSNumber *avgNum = dayInfo[@"count"];
                    [_numData addObject:avgNum];
                }
                if([dayInfo[@"money"] isKindOfClass:[NSString class]]){
                    [_costData addObject:[NSNumber numberWithString:dayInfo[@"money"]]];
                }else {
                    [_costData addObject:dayInfo[@"money"]];
                }
            }];
            
            // 更新cell，给cell赋值数据
            _mealCountCell.xRollerData = _xRollerData;
            _mealCountCell.numData = _numData;
            _mealCountCell.costData = _costData;
        }
        
        
    } failure:^(NSError *error) {
        [self showHint:KRequestFailMsg];
    }];
}

#pragma mark 当日统计
- (void)_loadTimeCountData:(NSString *)statDate {
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/parkCard/dayStat",Main_Url];
    
    NSMutableDictionary *searchParam = @{}.mutableCopy;
    [searchParam setObject:statDate forKey:@"statDate"];
    
    NSString *jsonStr = [Utils convertToJsonData:searchParam];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            // 天统计
            MealDayModel *model = [[MealDayModel alloc] initWithDataDic:responseObject[@"responseData"]];
            _mealCountCell.mealDayModel = model;
        }
        
    } failure:^(NSError *error) {
    }];
}

#pragma mark UITableView 协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 590;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    _mealCountCell = [tableView dequeueReusableCellWithIdentifier:@"MealCountCell" forIndexPath:indexPath];
    _mealCountCell.selectionStyle = UITableViewCellSelectionStyleNone;
    _mealCountCell.filterDelegate = self;
    //        cell.countData = _countTableView;
    return _mealCountCell;
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
    [date_formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *the_date_str = [date_formatter stringFromDate:theDate];
    
    return the_date_str;
}

#pragma mark 筛选和点击某列协议
- (void)filterDelegate:(FilterDateStyle)filterDateStyle {
    /*
    switch (filterDateStyle) {
        case FilterDay:
            // 日
            _linkRatio = DayLinkRatio;
            //            [self loadDayData];
            break;
            
        case FilterWeek:
            // 周
            _linkRatio = WeekLinkRatio;
            //            [self loadWeekData];
            break;
            
        case FilterMonth:
            // 月
            _linkRatio = MonthLinkRatio;
            //            [self loadMonthData];
            break;
            
    }
     */
}
- (void)didSelectChartLineIndex:(NSInteger)selIndex {
    
    [self _loadTimeCountData:_xRollerData[selIndex]];
    
    /*
    if(_xRollerData.count > selIndex){
        switch (_linkRatio) {
            case DayLinkRatio:
                [self _loadTimeCountData:_xRollerData[selIndex]];
                break;
                
            case WeekLinkRatio:
                [self _loadTimeCountData:_xRollerData[selIndex]];
                break;
                
            case MonthLinkRatio:
                [self _loadTimeCountData:_xRollerData[selIndex]];
                break;
                
        }
    }
     */
}

@end
