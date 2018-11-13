//
//  WifiCountSpeedCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/10/26.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WifiCountSpeedCell.h"
#import "AAChartView.h"
#import "WifiCountSpeedModel.h"

#define PageLineWidth (KScreenWidth - 60)/7

@interface WifiCountSpeedCell()
{
    UIScrollView *_chartScrollView;
}
@property (nonatomic, strong) AAChartModel *snapChartModel;
@property (nonatomic, strong) AAChartView  *snapChartView;
@end

@implementation WifiCountSpeedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self _createSnapView];
}

#pragma mark 折线图
- (void)_createSnapView {
    // 创建折线背景scrollView
    _chartScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 211)];
    _chartScrollView.bounces = NO;
    [self.contentView insertSubview:_chartScrollView atIndex:0];
    
    self.snapChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, _chartScrollView.height + 15)];
    self.snapChartView.contentHeight = _chartScrollView.height - 20;
    self.snapChartView.isClearBackgroundColor = YES;
    self.snapChartView.backgroundColor = [UIColor whiteColor];
    [_chartScrollView addSubview:self.snapChartView];
    
    self.snapChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeColumn)
    .titleSet(@"")
    .subtitleSet(@"")
    .categoriesSet(@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7"])
    .invertedSet(true)
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#000000")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#000000")    // y轴坐标值颜色
    .dataLabelEnabledSet(YES) //是否直接显示数据
    .legendEnabledSet(true)
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .nameSet(@"接收速率")
                 .dataSet(@[@5,@6,@3,@10,@6,@8,@3,@6]),
                 
                 AAObject(AASeriesElement)
                 .nameSet(@"发送速率")
                 .dataSet(@[@3,@2,@9,@7,@3,@6,@3,@9]),
                 ]
               )
    ;
    
    self.snapChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.snapChartModel.symbol = AAChartSymbolTypeCircle;
    self.snapChartModel.colorsTheme = @[@"#1B82D1", @"#FFC13B"];
    
    [self.snapChartView aa_drawChartWithChartModel:_snapChartModel];
}

- (void)setSpeedData:(NSArray *)speedData {
    _speedData = speedData;
    
    speedData = [self sortByX:speedData];
    
    NSMutableArray *timeData = @[].mutableCopy;
    NSMutableArray *recvData = @[].mutableCopy;
    NSMutableArray *sendData = @[].mutableCopy;
    [speedData enumerateObjectsUsingBlock:^(WifiCountSpeedModel *speedModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if(idx == speedData.count - 1){
            [timeData addObject:[NSString stringWithFormat:@"> %@", [self speedValueStr:speedModel.recv.doubleValue]]];
        }else {
            WifiCountSpeedModel *nextModel = speedData[idx+1];
            [timeData addObject:[NSString stringWithFormat:@"%@~%@", [self speedValueStr:speedModel.recv.doubleValue], [self speedValueStr:nextModel.recv.doubleValue]]];
        }
        [recvData addObject:[NSNumber numberWithString:speedModel.userCount]];
        [sendData addObject:[NSNumber numberWithString:speedModel.send]];
    }];
    
    [self refreshSnapData:recvData withSend:sendData withTime:timeData];
}
- (NSArray *)sortByX:(NSArray *)data {
    NSMutableArray *sortData = data.mutableCopy;
    [sortData enumerateObjectsUsingBlock:^(WifiCountSpeedModel *speedModel, NSUInteger idx, BOOL * _Nonnull stop) {
        for (NSInteger i=idx; i<data.count; i++) {
            WifiCountSpeedModel *iSpeedModel = sortData[i];
            if(iSpeedModel.recv.floatValue < speedModel.recv.floatValue){
                [sortData exchangeObjectAtIndex:idx withObjectAtIndex:i];
                speedModel = iSpeedModel;
            }
        }
    }];
    return sortData;
}
- (NSString *)speedValueStr:(double)speed {
    NSString *speedStr;
    if(speed < 1024){
        // b
        speedStr = [NSString stringWithFormat:@"%.0fb", speed];
    }else if(speed > 1024 && speed < 1024*1024){
        // kb
        speedStr = [NSString stringWithFormat:@"%.0fk", speed/1024.00];
    }else {
        // M
        speedStr = [NSString stringWithFormat:@"%.0fm", speed/(1024.00*1024.00)];
    }
    return speedStr;
}

- (void)refreshSnapData:(NSArray *)recvData withSend:(NSArray *)sendData withTime:(NSArray *)timeArr {
    if(timeArr.count > 7){
        // 大于7列 滑动
        CGFloat snapChartWidth = 60 + PageLineWidth*timeArr.count;
        _chartScrollView.contentSize = CGSizeMake(snapChartWidth, 0);
        [_chartScrollView setContentOffset:CGPointMake(_chartScrollView.contentSize.width - KScreenWidth, 0) animated:YES];
        
        self.snapChartView = nil;
        [_snapChartView removeFromSuperview];
        
        self.snapChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, snapChartWidth, _chartScrollView.height + 15)];
        self.snapChartView.contentHeight = _chartScrollView.height - 20;
        self.snapChartView.isClearBackgroundColor = YES;
        self.snapChartView.backgroundColor = [UIColor whiteColor];
        [_chartScrollView addSubview:self.snapChartView];
        
    }
    
    self.snapChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeColumn)
    .titleSet(@"")
    .subtitleSet(@"")
    .categoriesSet(timeArr)
    .invertedSet(true)
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#000000")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#000000")    // y轴坐标值颜色
    .yAxisAllowDecimalsSet(false)
    .dataLabelEnabledSet(YES) //是否直接显示数据
    .legendEnabledSet(true)
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .nameSet(@"接收速率")
                 .dataSet(recvData),
                 
                 AAObject(AASeriesElement)
                 .nameSet(@"发送速率")
                 .dataSet(sendData),
                 ]
               )
    ;
    
    self.snapChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.snapChartModel.symbol = AAChartSymbolTypeCircle;
    self.snapChartModel.colorsTheme = @[@"#1B82D1", @"#FFC13B"];
    
    [self.snapChartView aa_drawChartWithChartModel:self.snapChartModel];
}

@end
