//
//  VisitorCountViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/17.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "VisitorCountViewController.h"
#import "VisCountCell.h"
#import "AAChartView.h"
#import "VisCountNumModel.h"

@interface VisitorCountViewController ()<UITableViewDataSource, UITableViewDelegate, VisDateFilterDelegate>
{
    UITableView *_countTableView;
    VisCountCell *_visCountCell;
    
    NSMutableArray *_xRollerData;
    NSMutableArray *_snapData;
    NSMutableArray *_postData;
    
    
    NSString *_totalNum;
    NSString *_manNum;
    NSString *_fermanNum;
    
    NSString *_dodPersent;
    NSString *_avgDuration;
    
    LinkRatio _linkRatio;
}
@property (nonatomic, strong) AAChartModel *cakeChartModel;
@property (nonatomic, strong) AAChartView  *cakeChartView;
@property (nonatomic, strong) AAChartModel *mixChartModel;
@property (nonatomic, strong) AAChartView  *mixChartView;
@end

@implementation VisitorCountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _xRollerData = @[].mutableCopy;
    _snapData = @[].mutableCopy;
    _postData = @[].mutableCopy;
    
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
    // 创建饼状图
    [self _createCakeView];
    // 创建折线图
    [self _createMixView];
    
    _countTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64 - kTabBarHeight) style:UITableViewStyleGrouped];
    _countTableView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    _countTableView.contentInset = UIEdgeInsetsMake(0, 0, 5, 0);
    _countTableView.dataSource = self;
    _countTableView.delegate = self;
    [self.view addSubview:_countTableView];
    
    [_countTableView registerNib:[UINib nibWithNibName:@"VisCountCell" bundle:nil] forCellReuseIdentifier:@"VisCountCell"];
}

#pragma mark 按天统计 单位天
- (void)_loadDayCount:(NSString *)statMonth {
    NSString *urlStr = [NSString stringWithFormat:@"%@/visitor/dayFlowStat",Main_Url];
    
    NSMutableDictionary *searchParam = @{}.mutableCopy;
    [searchParam setObject:statMonth forKey:@"statMonth"];
    
    NSString *jsonStr = [Utils convertToJsonData:searchParam];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            [_xRollerData removeAllObjects];
            [_snapData removeAllObjects];
            [_postData removeAllObjects];
            NSArray *dayStat = responseObject[@"responseData"][@"dayStat"];
            [dayStat enumerateObjectsUsingBlock:^(NSDictionary *dayInfo, NSUInteger idx, BOOL * _Nonnull stop) {
                [_xRollerData addObject:[self getNDay:dayStat.count - idx - 1]];
                if([dayInfo[@"avgDuration"] isKindOfClass:[NSString class]]){
                    NSString *avgNum = dayInfo[@"avgDuration"];
                    avgNum = [NSString stringWithFormat:@"%.1f", avgNum.floatValue/3600];
                    [_snapData addObject:[NSNumber numberWithString:avgNum]];
                }else {
                    NSNumber *avgNum = dayInfo[@"avgDuration"];
                    NSString *avgDuration = [NSString stringWithFormat:@"%.1f", avgNum.floatValue/3600];
                    [_snapData addObject:[NSNumber numberWithString:avgDuration]];
                }
                if([dayInfo[@"count"] isKindOfClass:[NSString class]]){
                    [_postData addObject:[NSNumber numberWithString:dayInfo[@"count"]]];
                }else {
                    [_postData addObject:dayInfo[@"count"]];
                }
            }];
        }
        
        [_countTableView reloadData];
        
    } failure:^(NSError *error) {
    }];
}

#pragma mark 访客总数 男女比例
- (void)_loadTimeCountData:(NSString *)statDate {
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/visitor/dayStat",Main_Url];
    
    NSMutableDictionary *searchParam = @{}.mutableCopy;
    [searchParam setObject:statDate forKey:@"statDate"];
    
    NSString *jsonStr = [Utils convertToJsonData:searchParam];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            
            if(responseObject[@"responseData"] != nil && ![responseObject[@"responseData"] isKindOfClass:[NSNull class]]){
                VisCountNumModel *model = [[VisCountNumModel alloc] initWithDataDic:responseObject[@"responseData"]];
                
                _visCountCell.visCountNumModel = model;
                
                _linkRatio = DayLinkRatio;
                _visCountCell.linkRatio = _linkRatio;
            }
        }
        
    } failure:^(NSError *error) {
    }];
}

#pragma mark 饼状图
- (void)_createCakeView {
    self.cakeChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, 220)];
    self.cakeChartView.contentHeight = 200;
    self.cakeChartView.isClearBackgroundColor = YES;
    self.cakeChartView.backgroundColor = [UIColor whiteColor];
    
    self.cakeChartModel = AAObject(AAChartModel)
    .chartTypeSet(AAChartTypePie)
    .colorsThemeSet(@[@"#edc443",@"#ea9731",@"#ed3732",@"#4db6f9",@"#63d540"])
    .titleSet(@"")
    .subtitleSet(@"")
    .dataLabelEnabledSet(true)//是否直接显示扇形图数据
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#ffffff")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#ffffff")    // y轴坐标值颜色
    .seriesSet(
               @[
                 AAObject(AASeriesElement)
                 .nameSet(@"访问事由")
                 .innerSizeSet(@"0%")//内部圆环半径大小占比
                 .dataSet(@[
                            @[@"园区广场" , @10],
                            @[@"园区广场" , @18],
                            @[@"园区广场" , @12],
                            @[@"办公楼宇" , @30],
                            @[@"园区广场" , @30],
                            ]),
                 ]
               )
    ;
    
    _cakeChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.cakeChartModel.symbol = AAChartSymbolTypeCircle;
    
    [self.cakeChartView aa_drawChartWithChartModel:_cakeChartModel];
}
#pragma mark 折线图柱状混合图
- (void)_createMixView {
    self.mixChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, 275)];
    self.mixChartView.contentHeight = 255;
    self.mixChartView.isClearBackgroundColor = YES;
    self.mixChartView.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    
    self.mixChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeLine)
    .titleSet(@"")
    .subtitleSet(@"")
    .categoriesSet(@[@"三力",@"创发",@"设计院",@"阳光保险", @"通服"])
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#ffffff")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#ffffff")    // y轴坐标值颜色
    .seriesSet(@[
                AAObject(AASeriesElement)
                .typeSet(AAChartTypeColumn)
                .nameSet(@"停车次数")
                .dataSet(@[@45,@88,@49,@43,@65]),
                
                AAObject(AASeriesElement)
                .typeSet(AAChartTypeLine)
                .nameSet(@"平均访问时长")
                .dataSet(@[@45,@88,@49,@43,@65]),
               
               ]);
    
    self.mixChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.mixChartModel.symbol = AAChartSymbolTypeCircle;
    self.mixChartModel.colorsTheme = @[@"#edc443", @"#FF4359"];
    
    [self.mixChartView aa_drawChartWithChartModel:_mixChartModel];
}

#pragma mark UITableView 协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 3;
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        return 590;
    }else if (indexPath.section == 1) {
        return 220;
    }else {
        return 275;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return 0;
    }else {
        return 40;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return [UIView new];
    }else {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 40)];
        UILabel *headLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 11, 200, 17)];
        if(section == 1){
            headLabel.text = @"访问事由";
        }else if (section == 2){
            headLabel.text = @"访问公司情况";
        }
        [headView addSubview:headLabel];
        return headView;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        _visCountCell = [tableView dequeueReusableCellWithIdentifier:@"VisCountCell" forIndexPath:indexPath];
        _visCountCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _visCountCell.xRollerData = _xRollerData;
        _visCountCell.snapData = _snapData;
        _visCountCell.postData = _postData;
        _visCountCell.filterDelegate = self;
        
//        cell.countData = _countTableView;
        return _visCountCell;
    }else if(indexPath.section == 1){
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VisCakeCell"];
        [cell addSubview:_cakeChartView];
        return cell;
    }else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VisCakeCell"];
        [cell addSubview:_mixChartView];
        return cell;
    }
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
//    [date_formatter setDateFormat:@"MM-dd"];
    NSString *the_date_str = [date_formatter stringFromDate:theDate];
    
    return the_date_str;
}

#pragma mark 筛选和点击某列协议
- (void)filterDelegate:(FilterDateStyle)filterDateStyle {
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
}
- (void)didSelectChartLineIndex:(NSInteger)selIndex {
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
}

@end
