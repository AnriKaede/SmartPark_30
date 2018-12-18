//
//  EnergyCountViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/15.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "EnergyCountViewController.h"
#import "AAChartView.h"

#import "CountCostView.h"
#import "CountCakeView.h"

#import "EnergyElectricUseModel.h"
#import "EnergyWaterUseModel.h"

#define PageLineWidth (KScreenWidth - 95)/7
// 双Y轴为95 单Y轴为60

typedef enum {
    DayLinkRatio = 0,
    WeekLinkRatio,
    MonthLinkRatio
}LinkRatio;

@interface EnergyCountViewController ()<AAChartViewDidFinishLoadDelegate, UIGestureRecognizerDelegate>
{
    NSMutableArray *_xRollerData; // x坐标数据
    NSMutableArray *_postEleData; // 耗电柱状图数据
    NSMutableArray *_postWaterData; // 耗水柱状图数据
    
    NSMutableArray *_cakeEleData; // 耗电饼状图数据
    NSMutableArray *_cakeWaterData; // 耗水饼状图数据
    
    UIScrollView *_bgScrollView;
    
    UIScrollView *_chartScrollView; // 图标背景
    
    CountCostView *_countCostView;
    
    CountCakeView *_countCakeView;
    
    LinkRatio _linkRatio;
}
@property (nonatomic, strong) AAChartModel *postChartModel; // 柱形图
@property (nonatomic, strong) AAChartView  *postChartView;  // 柱形图
@end

@implementation EnergyCountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _xRollerData = @[].mutableCopy;
    _postEleData = @[].mutableCopy;
    _postWaterData = @[].mutableCopy;
    
    _cakeEleData = @[].mutableCopy;
    _cakeWaterData = @[].mutableCopy;
    
    [self _initView];

    [self _loadData];
}

- (void)_initView {
    
    _bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight - 49)];
    // 添加渐变色
    [NavGradient viewAddGradient:_bgScrollView];
    _bgScrollView.contentSize = CGSizeMake(0, 1065);
//    _bgScrollView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    [self.view addSubview:_bgScrollView];
 
    [self _createPostView];
    
    [self _createCostView];
    
    [self _createCakeView];
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

#pragma mark 按天统计 单位天
- (void)_loadDayCount:(NSString *)statMonth {
    NSString *urlStr = [NSString stringWithFormat:@"%@/energy/dayFlowStat",Main_Url];
    
    NSMutableDictionary *searchParam = @{}.mutableCopy;
    [searchParam setObject:statMonth forKey:@"statMonth"];
    
    NSString *jsonStr = [Utils convertToJsonData:searchParam];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            [_xRollerData removeAllObjects];
            [_postEleData removeAllObjects];
            [_postWaterData removeAllObjects];
            NSArray *dayStat = responseObject[@"responseData"][@"dayStat"];
            [dayStat enumerateObjectsUsingBlock:^(NSDictionary *dayInfo, NSUInteger idx, BOOL * _Nonnull stop) {
                [_xRollerData addObject:[self getNDay:dayStat.count - idx - 1]];
                if([dayInfo[@"elecCost"] isKindOfClass:[NSString class]]){
                    NSString *avgNum = dayInfo[@"elecCost"];
                    [_postEleData addObject:[NSNumber numberWithString:avgNum]];
                }else {
                    NSNumber *avgNum = dayInfo[@"elecCost"];
                    [_postEleData addObject:avgNum];
                }
                
                if([dayInfo[@"waterCost"] isKindOfClass:[NSString class]]){
                    NSString *waterStr = dayInfo[@"waterCost"];
                    [_postWaterData addObject:[NSNumber numberWithInteger:waterStr.integerValue * 1]];
                }else {
                    NSNumber *waterNum = dayInfo[@"waterCost"];
                    [_postWaterData addObject:[NSNumber numberWithInteger:waterNum.integerValue * 1]];
                }
            }];
        }
        
        [self refreshChart];
        
    } failure:^(NSError *error) {
        [self showHint:KRequestFailMsg];
    }];
}

#pragma mark 当天能耗总数 统计
- (void)_loadTimeCountData:(NSString *)statDate {
    
    // 加载当日统计数据
    NSString *countStr = [NSString stringWithFormat:@"%@/energy/dayStat",Main_Url];
    
    NSMutableDictionary *countParam = @{}.mutableCopy;
    [countParam setObject:statDate forKey:@"statDate"];
    
    NSString *countJsonStr = [Utils convertToJsonData:countParam];
    NSDictionary *cParam = @{@"param":countJsonStr};
    [[NetworkClient sharedInstance] POST:countStr dict:cParam progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            
            // 今日电耗统计
            NSNumber *electicityCost = responseObject[@"responseData"][@"electicityCost"];
            // 电耗环比
            NSNumber *preELeNum = responseObject[@"responseData"][@"preElecticityTotal"];
            NSNumber *nowELeNum = responseObject[@"responseData"][@"electicityTotal"];
            _countCostView.elcRatio = [NSString stringWithFormat:@"%.2f", (nowELeNum.floatValue - preELeNum.floatValue)/preELeNum.floatValue * 100];
            
            // 今日水耗统计
            NSNumber *waterCost = responseObject[@"responseData"][@"waterCost"];
            // 水耗环比
            NSNumber *preWaterNum = responseObject[@"responseData"][@"preWaterTotal"];
            NSNumber *nowWaterNum = responseObject[@"responseData"][@"waterTotal"];
            _countCostView.waterRatio = [NSString stringWithFormat:@"%.2f", (nowWaterNum.floatValue - preWaterNum.floatValue)/preWaterNum.floatValue * 100];
            
            // 计算成本
            [self caultCost:electicityCost withWaterNum:waterCost];
            
            // 耗电分公司
            [_cakeEleData removeAllObjects];
            NSArray *electricityList = responseObject[@"responseData"][@"electricityList"];
            [electricityList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                EnergyElectricUseModel *model = [[EnergyElectricUseModel alloc] initWithDataDic:obj];
                // 处理数据为饼状图数据
                NSArray *cakeAry = @[model.companyName, model.costValue];
                [_cakeEleData addObject:cakeAry];
            }];
            _countCakeView.eleCakeData = _cakeEleData;
            
            // 耗水分水表
            [_cakeWaterData removeAllObjects];
            NSArray *waterList = responseObject[@"responseData"][@"waterList"];
            [waterList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                EnergyWaterUseModel *model = [[EnergyWaterUseModel alloc] initWithDataDic:obj];
                // 处理数据为饼状图数据
                NSArray *cakeAry = @[model.deviceName, model.costValue];
                [_cakeWaterData addObject:cakeAry];
            }];
            _countCakeView.waterCakeData = _cakeWaterData;
        }
        
    } failure:^(NSError *error) {
    }];
}

- (void)_createPostView {
    // 头部日期背景
    UIView *filterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 40)];
    filterView.backgroundColor = [UIColor clearColor];
    [_bgScrollView addSubview:filterView];
    
    UILabel *elcLabel = [[UILabel alloc] init];
    elcLabel.frame = CGRectMake(10,13,80,17);
    elcLabel.text = @"电耗(kwh)";
    elcLabel.textColor = [UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:1];
    [filterView addSubview:elcLabel];
    
    UIView *elcView = [[UIView alloc] init];
    elcView.frame = CGRectMake(elcLabel.right + 7,18,25,7.5);
    elcView.backgroundColor = [UIColor colorWithHexString:@"#FFC921"];
    [filterView addSubview:elcView];
    
    UILabel *waterLabel = [[UILabel alloc] init];
    waterLabel.frame = CGRectMake(elcView.right + 18,13,70,17);
    waterLabel.text = @"水耗(吨)";
    waterLabel.textColor = [UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:1];
    [filterView addSubview:waterLabel];
    
    UIView *waterView = [[UIView alloc] init];
    waterView.frame = CGRectMake(waterLabel.right + 7,18,25,7.5);
    waterView.backgroundColor = [UIColor colorWithHexString:@"#00FF3C"];
    [filterView addSubview:waterView];
    
//    NSArray *btTitles = @[@"日", @"周", @"月"];
    NSArray *btTitles = @[@"日"];
    [btTitles enumerateObjectsUsingBlock:^(NSString *btTitle, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *dateBt = [UIButton buttonWithType:UIButtonTypeCustom];
//        dateBt.frame = CGRectMake(KScreenWidth - 130 + idx*40, 10, 40, 25);
        dateBt.frame = CGRectMake(KScreenWidth - 130 + 2*40, 10, 40, 25);
        [dateBt setTitle:btTitle forState:UIControlStateNormal];
        dateBt.tag = 100 + idx;
        dateBt.layer.borderColor = [UIColor colorWithHexString:@"#D1E6F6"].CGColor;
        dateBt.layer.borderWidth = 1;
        if(idx == 0){
            dateBt.backgroundColor = [UIColor colorWithHexString:@"#D1E6F6"];
            [dateBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else {
            dateBt.backgroundColor = [UIColor clearColor];
            [dateBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        [dateBt addTarget:self action:@selector(dateFilterAction:) forControlEvents:UIControlEventTouchUpInside];
        [filterView addSubview:dateBt];
    }];
    
    NSArray *postData = @[];
    
    // 混合图背景scrollView
    _chartScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, KScreenWidth, 275)];
    _chartScrollView.bounces = NO;
    [_bgScrollView addSubview:_chartScrollView];
    
    self.postChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, 275)];
    self.postChartView.delegate = self;
    self.postChartView.contentWidth = KScreenWidth*(postData.count/10);
    self.postChartView.contentHeight = 260;
    self.postChartView.isClearBackgroundColor = YES;
    self.postChartView.backgroundColor = [UIColor clearColor];
    [_chartScrollView addSubview:self.postChartView];
    
    // 混合Y轴
    NSDictionary *yAxisDic = @{@"yAxis":@[
                                       @{ // Primary yAxis
                                           @"labels": @{@"format": @"{value} kwh",},
                                           @"title": @{@"text": @"电耗",},
                                           @"opposite": @true
                                           },
                                       @{ // Secondary yAxis
                                           @"gridLineWidth": @0,
                                           @"title": @{@"text": @"水耗",},
                                           @"labels": @{@"format": @"{value} t",}
                                           }
                                       ]};
    
    self.postChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeColumn)
    .titleSet(@"")
    .subtitleSet(@"")
    .categoriesSet(postData)
    .additionalOptionsSet((id)yAxisDic)
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#ffffff")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#ffffff")    // y轴坐标值颜色
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .nameSet(@"电耗")
                 .yAxisSet(@0)
                 .dataSet(@[]),
                 
                 AAObject(AASeriesElement)
                 .nameSet(@"水耗")
                 .yAxisSet(@0)
                 .dataSet(@[]),
                 ]
               )
    ;
    
    _postChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.postChartModel.symbol = AAChartSymbolTypeCircle;
    self.postChartModel.colorsTheme = @[@"#FFC921",@"#00FF3C"];
    
    
    [self.postChartView aa_drawChartWithChartModel:_postChartModel];//aa_refreshChartWithChartModel
    
}
#pragma mark -- AAChartView delegate
-(void)AAChartViewDidFinishLoad {
    NSLog(@"😊😊😊图表视图已完成加载");
}

#pragma mark 柱状图按日期筛选
- (void)dateFilterAction:(UIButton *)dateBt {
    [self changeBtState:dateBt];
    
    switch (dateBt.tag - 100) {
        case 0:
            // 日
            break;
        case 1:
            // 周
            break;
        case 2:
            // 月
            break;
            
    }
}
- (void)changeBtState:(UIButton *)dateBt {
    for (int i=0; i<3; i++) {
        UIButton *button = [_bgScrollView viewWithTag:100 + i];
        if(button == dateBt){
            button.backgroundColor = [UIColor colorWithHexString:@"#D1E6F6"];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else {
            button.backgroundColor = [UIColor clearColor];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
}

// ----------------------------------------------------------------------
#pragma mark 成本环比视图
- (void)_createCostView {
    _countCostView = [[CountCostView alloc] initWithFrame:CGRectMake(0, _postChartView.bottom - 20, KScreenWidth, 250)];
    _countCostView.elcNum = @"0";
    _countCostView.isElcUp = YES;
    _countCostView.elcRatio = @"0";
    
    _countCostView.waterNum = @"0";
    _countCostView.isWaterUp = NO;
    _countCostView.waterRatio = @"0";
    [_bgScrollView addSubview:_countCostView];
    
}

#pragma mark 饼状图
- (void)_createCakeView {
    _countCakeView = [[CountCakeView alloc] initWithFrame:CGRectMake(0, _countCostView.bottom, KScreenWidth, 530)];
    [_bgScrollView addSubview:_countCakeView];
}

#pragma mark 刷新统计图表
- (void)refreshChart {
    
    if(_xRollerData.count > 7){
        // 大于7列 滑动
        CGFloat snapChartWidth = 95 + PageLineWidth*_xRollerData.count;
        _chartScrollView.contentSize = CGSizeMake(snapChartWidth, 0);
        [_chartScrollView setContentOffset:CGPointMake(_chartScrollView.contentSize.width - KScreenWidth, 0) animated:YES];
        
        [self.postChartView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.postChartView removeFromSuperview];
        self.postChartView = nil;
        
        self.postChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, snapChartWidth, 275)];
        self.postChartView.contentHeight = 255;
        self.postChartView.userInteractionEnabled = YES;
        self.postChartView.isClearBackgroundColor = YES;
        self.postChartView.backgroundColor = [UIColor clearColor];
        [_chartScrollView addSubview:self.postChartView];
        
    }else {
        _chartScrollView.contentSize = CGSizeMake(0, 0);
        
        self.postChartView = nil;
        [_postChartView removeFromSuperview];
        
        self.postChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, 275)];
        self.postChartView.contentHeight = 255;
        self.postChartView.userInteractionEnabled = YES;
        self.postChartView.isClearBackgroundColor = YES;
        self.postChartView.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
        [_chartScrollView addSubview:self.postChartView];
    }
    
    // 为chartView添加点击事件
    UITapGestureRecognizer *myTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.postChartView addGestureRecognizer:myTap];
    myTap.delegate = self;
    myTap.cancelsTouchesInView = NO;
    
    // 混合Y轴
    NSDictionary *yAxisDic = @{@"yAxis":@[
                                       @{ // Primary yAxis
                                           @"labels": @{@"format": @"{value} kwh",},
                                           @"title": @{@"text": @"电耗",},
                                           @"opposite": @true
                                           },
                                       @{ // Secondary yAxis
                                           @"gridLineWidth": @0,
                                           @"title": @{@"text": @"水耗",},
                                           @"labels": @{@"format": @"{value} t",}
                                           }
                                       ]};
    
    self.postChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeColumn)
    .titleSet(@"")
    .subtitleSet(@"")
    .categoriesSet(_xRollerData)
    .additionalOptionsSet((id)yAxisDic)
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#ffffff")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#ffffff")    // y轴坐标值颜色
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .nameSet(@"电耗")
                 .yAxisSet(@0)
                 .dataSet(_postEleData),
                 
                 AAObject(AASeriesElement)
                 .nameSet(@"水耗")
                 .yAxisSet(@1)
                 .dataSet(_postWaterData),
                 ]
               )
    ;
    
    self.postChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.postChartModel.symbol = AAChartSymbolTypeCircle;
    self.postChartModel.colorsTheme = @[@"#FFC921", @"#00FF3C"];
    [self.postChartView aa_drawChartWithChartModel:_postChartModel];
}

#pragma mark 点击一列的协议放方法
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
-(void)handleSingleTap:(UITapGestureRecognizer *)sender{
    CGPoint gesturePoint = [sender locationInView:self.view];
    
    CGFloat xRallerWidth;
    CGFloat xOffset;
    if(_chartScrollView.contentSize.width > KScreenWidth){
        xRallerWidth = _chartScrollView.contentSize.width;
        xOffset = _chartScrollView.contentOffset.x;
    }else {
        xRallerWidth = KScreenWidth;
        xOffset = 0;
    }
    
    // 点击区域
    CGFloat postWidth = (xRallerWidth - 95 - 95)/_xRollerData.count;
    for (int i=0; i<_xRollerData.count; i++) {
        if((gesturePoint.x + xOffset) >= (postWidth*i + 95) &&
           (gesturePoint.x + xOffset) <= (postWidth*(i+1) + 95)){
            //            NSLog(@"点击了第%d行柱", i+1);
            [self didSelectChartLineIndex:i];
            break;
        }
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

#pragma mark 调用单价接口计算电、水成本
- (void)caultCost:(NSNumber *)electricNum withWaterNum:(NSNumber *)waterNum {
    NSString *urlStr = [NSString stringWithFormat:@"%@/public/getPublicConfig",Main_Url];
    
    NSMutableDictionary *pubParam = @{}.mutableCopy;
    [pubParam setObject:@"ENERGY" forKey:@"configCode"];
    NSString *jsonStr = [Utils convertToJsonData:pubParam];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        NSDictionary *data = responseObject;
        if ([data[@"code"] isEqualToString:@"1"]) {
            NSDictionary *responseData = responseObject[@"responseData"];
            if(responseData != nil && ![responseData isKindOfClass:[NSNull class]]){
                NSString *elePric = responseData[@"electricityPrice"];
                NSString *waterPrice = responseData[@"waterPrice"];
                
                // 今日电耗统计
                _countCostView.elcNum = [NSString stringWithFormat:@"%.1f", (elePric.floatValue/100) * electricNum.floatValue];
                
                // 今日水耗统计
                _countCostView.waterNum = [NSString stringWithFormat:@"%.1f", (waterPrice.floatValue/100) * waterNum.floatValue];
            }
        }
        
    } failure:^(NSError *error) {
        
    }];
}

@end
