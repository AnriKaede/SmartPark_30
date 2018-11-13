//
//  WifiCountTimeCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/10/26.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WifiCountTimeCell.h"
#import "AAChartView.h"
#import "WifiCountTimeModel.h"

#define PageLineWidth (KScreenWidth - 60)/7

@interface WifiCountTimeCell()
{
    UIScrollView *_chartScrollView;
}
@property (nonatomic, strong) AAChartModel *snapChartModel;
@property (nonatomic, strong) AAChartView  *snapChartView;
@end

@implementation WifiCountTimeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self _createSnapView];
}

#pragma mark 折线图
- (void)_createSnapView {
    // 创建折线背景scrollView
    _chartScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 218)];
    _chartScrollView.bounces = NO;
    [self.contentView insertSubview:_chartScrollView atIndex:0];
    
    self.snapChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, _chartScrollView.height)];
    self.snapChartView.contentHeight = _chartScrollView.height - 20;
    self.snapChartView.isClearBackgroundColor = YES;
    self.snapChartView.backgroundColor = [UIColor whiteColor];
    [_chartScrollView addSubview:self.snapChartView];
    
    self.snapChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeColumn)
    .titleSet(@"")
    .subtitleSet(@"")
    .categoriesSet(@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7"])
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#000000")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#000000")    // y轴坐标值颜色
    .legendEnabledSet(false)
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .nameSet(@"用户数")
                 .dataSet(@[@5,@6,@3,@10,@6,@8,@3,@6]),
                 ]
               )
    ;
    
    self.snapChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.snapChartModel.symbol = AAChartSymbolTypeCircle;
    self.snapChartModel.colorsTheme = @[@"#1B82D1"];
    
    [self.snapChartView aa_drawChartWithChartModel:_snapChartModel];
}

- (void)setTimeData:(NSArray *)timeData {
    _timeData = timeData;
    
    timeData = [self sortByX:timeData];
    
    NSMutableArray *countAry = @[].mutableCopy;
    NSMutableArray *timeArr = @[].mutableCopy;
    [timeData enumerateObjectsUsingBlock:^(WifiCountTimeModel *timeModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if(idx == timeData.count - 1){
            [timeArr addObject:[NSString stringWithFormat:@"> %@", [self timeFormat:timeModel.onlineTime]]];
        }else {
            WifiCountTimeModel *nextModel = timeData[idx+1];
            [timeArr addObject:[NSString stringWithFormat:@"%@~%@", [self timeFormat:timeModel.onlineTime], [self timeFormat:nextModel.onlineTime]]];
        }
        
        [countAry addObject:[NSNumber numberWithString:timeModel.userCount]];
    }];
    
    [self refreshPost:countAry withTime:timeArr];
}
- (NSArray *)sortByX:(NSArray *)data {
    NSMutableArray *sortData = data.mutableCopy;
    [sortData enumerateObjectsUsingBlock:^(WifiCountTimeModel *speedModel, NSUInteger idx, BOOL * _Nonnull stop) {
        for (NSInteger i=idx; i<data.count; i++) {
            WifiCountTimeModel *iSpeedModel = sortData[i];
            if(iSpeedModel.onlineTime.floatValue < speedModel.onlineTime.floatValue){
                [sortData exchangeObjectAtIndex:idx withObjectAtIndex:i];
                speedModel = iSpeedModel;
            }
        }
    }];
    return sortData;
}
- (NSString *)timeFormat:(NSString *)time {
    NSString *timeStr;
    if(time.floatValue >= 60){
        timeStr = [NSString stringWithFormat:@"%.0fh", time.floatValue/60];
    }else {
        timeStr = [NSString stringWithFormat:@"%@m", time];
    }
    return timeStr;
}

- (void)refreshPost:(NSArray *)countAry withTime:(NSArray *)timeArr {
    
    if(timeArr.count > 7){
        // 大于7列 滑动
        CGFloat snapChartWidth = 60 + PageLineWidth*timeArr.count;
        _chartScrollView.contentSize = CGSizeMake(snapChartWidth, 0);
        [_chartScrollView setContentOffset:CGPointMake(_chartScrollView.contentSize.width - KScreenWidth, 0) animated:YES];
        
        self.snapChartView = nil;
        [_snapChartView removeFromSuperview];
        
        self.snapChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, snapChartWidth, _chartScrollView.height)];
        self.snapChartView.contentHeight = _chartScrollView.height;
        self.snapChartView.isClearBackgroundColor = YES;
        self.snapChartView.backgroundColor = [UIColor whiteColor];
        [_chartScrollView addSubview:self.snapChartView];
        
    }
    
    self.snapChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeColumn)
    .titleSet(@"")
    .subtitleSet(@"")
    .categoriesSet(timeArr)
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#000000")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#000000")    // y轴坐标值颜色
    .yAxisAllowDecimalsSet(false)
    .legendEnabledSet(false)
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .nameSet(@"用户数")
                 .dataSet(countAry),
                 ]
               )
    ;
    
    self.snapChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.snapChartModel.symbol = AAChartSymbolTypeCircle;
    self.snapChartModel.colorsTheme = @[@"#1B82D1"];
    
    [self.snapChartView aa_drawChartWithChartModel:self.snapChartModel];
}

@end
