//
//  InTimeConsumptionViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/15.
//  Copyright © 2017年 焦平. All rights reserved.
//

// 实时能耗

#import "InTimeConsumptionViewController.h"
#import "AAChartView.h"
#import "ConsumptionCircleView.h"
#import "ConsumPartCell.h"

#import "EnergyInTimeModel.h"

#import "EnergyElectricUseModel.h"
#import "EnergyWaterUseModel.h"

#define PageLineWidth (KScreenWidth - 95)/7

@interface InTimeConsumptionViewController ()<AAChartViewDidFinishLoadDelegate, UIScrollViewDelegate>
{
    NSMutableArray *_todayData; // 折线图数据
    
    NSMutableArray *_useElectricData; // 公司用电数据
    NSMutableArray *_useWaterData; // 各水表用水数据
    
    UIScrollView *_bgScrollView;
    
    UIScrollView *_chartScrollView;
    
    UIView *_summaryView;
    ConsumptionCircleView *_electricCircleView;
    ConsumptionCircleView *_waterCircleView;
    
    UIView *_partBgView;
    UIScrollView *_partScrollView;
}

@property (nonatomic, strong) AAChartModel *aaChartModel;
@property (nonatomic, strong) AAChartView  *aaChartView;
@end

@implementation InTimeConsumptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _todayData = @[].mutableCopy;
    _useElectricData = @[].mutableCopy;
    _useWaterData = @[].mutableCopy;
    
    [self _initView];
    
    [self _loadTimeCountData];
}

- (void)_initView {
    
    _bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight - 49)];
    // 添加渐变色
    [NavGradient viewAddGradient:_bgScrollView];
    _bgScrollView.contentSize = CGSizeMake(0, 750);
    _bgScrollView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    [self.view addSubview:_bgScrollView];
    
    [self _createSnapView];
    
    [self _createSummaryView];
    
    [self _createParkView];
}

#pragma mark 创建折线图
- (void)_createSnapView {
    _chartScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 275)];
    _chartScrollView.bounces = NO;
    [_bgScrollView addSubview:_chartScrollView];
    
    self.aaChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, 275)];
    self.aaChartView.delegate = self;
    self.aaChartView.contentHeight = 255
    ;
    self.aaChartView.isClearBackgroundColor = YES;
    self.aaChartView.backgroundColor = [UIColor clearColor];
    [_chartScrollView addSubview:self.aaChartView];
    
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
    
    self.aaChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeLine)
    .titleSet(@"")
    .subtitleSet(@"")
    .categoriesSet(@[])
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
                 .yAxisSet(@1)
                 .dataSet(@[]),
                 ]
               )
    ;
    
    _aaChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.aaChartModel.symbol = AAChartSymbolTypeCircle;
    self.aaChartModel.colorsTheme = @[@"#FFC921",@"#00FF3C"];
    
    
    [self.aaChartView aa_drawChartWithChartModel:_aaChartModel];//aa_refreshChartWithChartModel
    
}
#pragma mark -- AAChartView delegate
-(void)AAChartViewDidFinishLoad {
    
}
#pragma mark 今日能耗统计视图
- (void)_createSummaryView {
    _summaryView = [[UIView alloc] initWithFrame:CGRectMake(0, _aaChartView.bottom, KScreenWidth, 176)];
    _summaryView.backgroundColor = [UIColor whiteColor];
    [_bgScrollView addSubview:_summaryView];
    
    _electricCircleView = [[ConsumptionCircleView alloc] initWithFrame:CGRectMake((KScreenWidth/2 - 150)/2, 13, 150, 150) withConsumptionType:ConsumptionElectric];
    _electricCircleView.backgroundColor = [UIColor colorWithHexString:@"#F7BB00"];
    [_summaryView addSubview:_electricCircleView];
    
    _waterCircleView = [[ConsumptionCircleView alloc] initWithFrame:CGRectMake(KScreenWidth/2 +  (KScreenWidth/2 - 150)/2, 13, 150, 150) withConsumptionType:ConsumptionWater];
    _waterCircleView.backgroundColor = [UIColor colorWithHexString:@"#11C03A"];
    [_summaryView addSubview:_waterCircleView];
    
}

#pragma mark 区域能耗视图
- (void)_createParkView {
    _partBgView = [[UIView alloc] initWithFrame:CGRectMake(0, _summaryView.bottom, KScreenWidth, 290)];
    _partBgView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    [_bgScrollView addSubview:_partBgView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 45, KScreenWidth/2, 5)];
    lineView.tag = 301;
    lineView.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    [_partBgView addSubview:lineView];
    
    UILabel *electricLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 17, KScreenWidth/2, 17)];
    electricLabel.font = [UIFont systemFontOfSize:17];
    electricLabel.textAlignment = NSTextAlignmentCenter;
    electricLabel.text = @"电耗";
    [_partBgView addSubview:electricLabel];
    UITapGestureRecognizer *electricTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(electricAction)];
    electricLabel.userInteractionEnabled = YES;
    [electricLabel addGestureRecognizer:electricTap];
    
    UILabel *waterLabel = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth/2, 17, KScreenWidth/2, 17)];
    waterLabel.font = [UIFont systemFontOfSize:17];
    waterLabel.textAlignment = NSTextAlignmentCenter;
    waterLabel.text = @"水耗";
    [_partBgView addSubview:waterLabel];
    UITapGestureRecognizer *waterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(waterAction)];
    waterLabel.userInteractionEnabled = YES;
    [waterLabel addGestureRecognizer:waterTap];
    
    _partScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, KScreenWidth, _partBgView.height - 50)];
    _partScrollView.contentSize = CGSizeMake(KScreenWidth * 2, 0);
    _partScrollView.delegate = self;
    _partScrollView.bounces = NO;
    _partScrollView.pagingEnabled = YES;
    _partScrollView.showsVerticalScrollIndicator = NO;
    _partScrollView.showsHorizontalScrollIndicator = NO;
    _partScrollView.backgroundColor = [UIColor whiteColor];
    [_partBgView addSubview:_partScrollView];
    
}
#pragma mark UIScrollView 协议
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    UIView *lineView = [_partBgView viewWithTag:301];
    CGRect lineFrame = lineView.frame;
    lineFrame = CGRectMake(scrollView.contentOffset.x/2, lineFrame.origin.y, lineFrame.size.width, lineFrame.size.height);
    lineView.frame = lineFrame;
}
// 点击电耗 滑动scrollview
- (void)electricAction {
    [_partScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}
// 点击水耗 滑动scrollview
- (void)waterAction {
    [_partScrollView setContentOffset:CGPointMake(KScreenWidth, 0) animated:YES];
}

#pragma mark 加载数据
- (void)_loadTimeCountData {
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *statDate = [dateFormat stringFromDate:nowDate];
    
    // 当天按小时统计
    NSString *urlStr = [NSString stringWithFormat:@"%@/energy/hourFlowStat",Main_Url];
    
    NSMutableDictionary *searchParam = @{}.mutableCopy;
    [searchParam setObject:statDate forKey:@"statDate"];
    
    NSString *jsonStr = [Utils convertToJsonData:searchParam];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            [_todayData removeAllObjects];
            NSArray *hourStat = responseObject[@"responseData"][@"hourStat"];
            if(hourStat != nil && ![hourStat isKindOfClass:[NSNull class]]){
                [hourStat enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    EnergyInTimeModel *model = [[EnergyInTimeModel alloc] initWithDataDic:obj];
                    [_todayData addObject:model];
                }];
                
                [self refreshSnap];
            }
        }
        
    } failure:^(NSError *error) {
        [self showHint:KRequestFailMsg];
    }];
    
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
            _electricCircleView.countValue = [NSString stringWithFormat:@"%@", electicityCost];
            
            // 今日水耗统计
            NSNumber *waterCost = responseObject[@"responseData"][@"waterCost"];
            _waterCircleView.countValue = [NSString stringWithFormat:@"%@", waterCost];
            
            // 计算成本
            [self caultCost:electicityCost withWaterNum:waterCost];
            
            // 耗电分公司
            __block CGFloat eleBottom;
            [_useElectricData removeAllObjects];
            NSArray *electricityList = responseObject[@"responseData"][@"electricityList"];
            [electricityList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                EnergyElectricUseModel *model = [[EnergyElectricUseModel alloc] initWithDataDic:obj];
                
                ConsumPartCell *cell = [[NSBundle mainBundle] loadNibNamed:@"ConsumPartCell" owner:self options:nil].lastObject;
                cell.electricUseModel = model;
                cell.frame = CGRectMake(0, idx*60, KScreenWidth, 60);
                [_partScrollView addSubview:cell];
                
                [_useElectricData addObject:model];
                
                if(idx == electricityList.count - 1){
                    eleBottom = cell.bottom;
                }
            }];
            
            // 耗水分水表
            __block CGFloat waterBottom;
            [_useWaterData removeAllObjects];
            NSArray *waterList = responseObject[@"responseData"][@"waterList"];
            [waterList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                EnergyWaterUseModel *model = [[EnergyWaterUseModel alloc] initWithDataDic:obj];
                
                ConsumPartCell *cell = [[NSBundle mainBundle] loadNibNamed:@"ConsumPartCell" owner:self options:nil].lastObject;
                cell.waterUseModel = model;
                cell.frame = CGRectMake(KScreenWidth, idx*60, KScreenWidth, 60);
                [_partScrollView addSubview:cell];
                
                [_useWaterData addObject:model];
                
                if(idx == electricityList.count - 1){
                    waterBottom = cell.bottom;
                }
            }];
            
            // 判断能耗分区数量 改变背景大小
            CGRect bgFrame = _partBgView.frame;
            CGFloat maxHeight;
            if(eleBottom > waterBottom){
                maxHeight = eleBottom;
            }else {
                maxHeight = waterBottom;
            }
            _partBgView.frame = CGRectMake(bgFrame.origin.x, bgFrame.origin.y, bgFrame.size.width, maxHeight);
            
            _partScrollView.frame = CGRectMake(0, 50, KScreenWidth, _partBgView.height - 50);
            
            _bgScrollView.contentSize = CGSizeMake(0, _partBgView.bottom);
        }
        
    } failure:^(NSError *error) {
    }];
}

#pragma mark 刷新折线图
- (void)refreshSnap {
    
    NSMutableArray *waterCountAry = @[].mutableCopy;
    NSMutableArray *electricCountAry = @[].mutableCopy;
    NSMutableArray *timeArr = @[].mutableCopy;
    [_todayData enumerateObjectsUsingBlock:^(EnergyInTimeModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        [timeArr addObject:model.hour];
        [waterCountAry addObject:model.waterCost];
        [electricCountAry addObject:model.elecCost];
    }];
    
    if(timeArr.count > 7){
        // 大于7列 滑动
        CGFloat snapChartWidth = 95 + PageLineWidth*timeArr.count;
        _chartScrollView.contentSize = CGSizeMake(snapChartWidth, 0);
        [_chartScrollView setContentOffset:CGPointMake(_chartScrollView.contentSize.width - KScreenWidth, 0) animated:YES];
        
        [self.aaChartView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.aaChartView removeFromSuperview];
        self.aaChartView = nil;
        
        self.aaChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, snapChartWidth, 275)];
        self.aaChartView.contentHeight = 255;
        self.aaChartView.isClearBackgroundColor = YES;
        self.aaChartView.backgroundColor = [UIColor clearColor];
        [_chartScrollView addSubview:self.aaChartView];
        
    }
    
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
    
    self.aaChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeLine)
    .titleSet(@"")
    .subtitleSet(@"")
    .categoriesSet(timeArr)
    .additionalOptionsSet((id)yAxisDic)
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#ffffff")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#ffffff")    // y轴坐标值颜色
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .nameSet(@"电耗")
                 .yAxisSet(@0)
                 .dataSet(electricCountAry),
                 
                 AAObject(AASeriesElement)
                 .nameSet(@"水耗")
                 .yAxisSet(@1)
                 .dataSet(waterCountAry),
                 ]
               )
    ;
    
    self.aaChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.aaChartModel.symbol = AAChartSymbolTypeCircle;
    self.aaChartModel.colorsTheme = @[@"#FFC921", @"#00FF3C"];
    [self.aaChartView aa_drawChartWithChartModel:self.aaChartModel];
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
                _electricCircleView.countCost = [NSString stringWithFormat:@"%.1f", (elePric.floatValue/100) * electricNum.floatValue];
                
                // 今日水耗统计
                _waterCircleView.countCost = [NSString stringWithFormat:@"%.1f", (waterPrice.floatValue/100) * waterNum.floatValue];
            }
        }
        
    } failure:^(NSError *error) {
        
    }];
}

@end
