//
//  EnvDetLineViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/2/28.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "EnvDetLineViewController.h"
#import "AAChartView.h"
#import "EvnDelModel.h"

#define PageLineWidth (KScreenWidth - 60)/7

@interface EnvDetLineViewController ()
{
    UIScrollView *_chartScrollView;
    NSMutableArray *_dataArr;
}

@property (nonatomic, strong) AAChartModel *snapChartModel;
@property (nonatomic, strong) AAChartView  *snapChartView;

@end

@implementation EnvDetLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
    
    [self _loadData];
}

- (void)_initView {
    [self _createSnapView];
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/irrigation/sensor/info",Main_Url];
    
    NSMutableDictionary *searchParam = @{}.mutableCopy;
    [searchParam setObject:[NSNumber numberWithInteger:24] forKey:@"pagesize"];
    [searchParam setObject:[NSNumber numberWithInteger:1] forKey:@"pagenum"];
    [searchParam setObject:_evnDataModel.device_id forKey:@"device_id"];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:searchParam progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSArray *items = responseObject[@"responseData"];
            
            NSMutableArray *evnData = @[].mutableCopy;
            
            [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                EvnDelModel *model = [[EvnDelModel alloc] initWithDataDic:obj];
                [evnData addObject:model];
            }];
            
            // 排序
            NSArray *mtbAry = [self sortData:evnData];
            [self refreshSnap:mtbAry];
        }
        
    } failure:^(NSError *error) {
        [self showHint:KRequestFailMsg];
    }];
}

#pragma mark 折线图
- (void)_createSnapView {
    // 创建折线背景scrollView
    _chartScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64 - 60)];
    _chartScrollView.bounces = NO;
    //    _chartScrollView.contentSize = CGSizeMake(self.view.frame.size.width*2, 0);
    [self.view addSubview:_chartScrollView];
    
    self.snapChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, _chartScrollView.height)];
    self.snapChartView.contentHeight = _chartScrollView.height - 20;
    self.snapChartView.isClearBackgroundColor = YES;
    self.snapChartView.backgroundColor = [UIColor whiteColor];
    [_chartScrollView addSubview:self.snapChartView];
    
    self.snapChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeLine)
    .titleSet(@"")
    .subtitleSet(@"")
    .categoriesSet(@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23"])
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#737373")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#737373")    // y轴坐标值颜色
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .nameSet(_evnDataModel.device_name)
                 .dataSet(@[@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0]),
                 ]
               )
    ;
    
    self.snapChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.snapChartModel.symbol = AAChartSymbolTypeCircle;
    self.snapChartModel.colorsTheme = @[@"#1B82D1"];
    
    [self.snapChartView aa_drawChartWithChartModel:_snapChartModel];
}

- (void)refreshSnap:(NSArray *)evnData {
    
    NSMutableArray *countAry = @[].mutableCopy;
    NSMutableArray *timeArr = @[].mutableCopy;
    [evnData enumerateObjectsUsingBlock:^(EvnDelModel *evnDelModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [timeArr addObject:[self timeFormatWithStr:evnDelModel.datetime]];
        [countAry addObject:[NSNumber numberWithString:evnDelModel.value]];
        
    }];
    
    /*
    if(timeArr.count > 7){
        // 大于7列 滑动
        CGFloat snapChartWidth = 60 + PageLineWidth*timeArr.count;
        _chartScrollView.contentSize = CGSizeMake(snapChartWidth, 0);
        [_chartScrollView setContentOffset:CGPointMake(_chartScrollView.contentSize.width - KScreenWidth, 0) animated:YES];
        
        self.snapChartView = nil;
        [_snapChartView removeFromSuperview];
        
        self.snapChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, snapChartWidth, 275)];
        self.snapChartView.contentHeight = 260;
        self.snapChartView.isClearBackgroundColor = YES;
        self.snapChartView.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
        [_chartScrollView addSubview:self.snapChartView];
        
    }
     */
    
    self.snapChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeLine)
    .titleSet(@"")
    .subtitleSet(@"")
    .categoriesSet(timeArr)
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#737373")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#737373")    // y轴坐标值颜色
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .nameSet(_evnDataModel.device_name)
                 .dataSet(countAry),
                 ]
               )
    ;
    
    self.snapChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.snapChartModel.symbol = AAChartSymbolTypeCircle;
    self.snapChartModel.colorsTheme = @[@"#1B82D1"];
    
    [self.snapChartView aa_drawChartWithChartModel:self.snapChartModel];
     
}

- (NSString *)timeFormatWithStr:(NSString *)timeStr {
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *date = [timeFormat dateFromString:timeStr];
    
    NSDateFormatter *inputFormat = [[NSDateFormatter alloc] init];
    [inputFormat setDateFormat:@"HH:mm"];
    NSString *inputStr = [inputFormat stringFromDate:date];
    
    return inputStr;
}

- (NSArray *)sortData:(NSArray *)data {
    NSMutableArray *mtbData = @[].mutableCopy;
    
    [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [mtbData insertObject:obj atIndex:0];
    }];
    
    return mtbData;
}

@end
