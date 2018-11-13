//
//  WifiSpeedCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/10/26.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WifiSpeedCell.h"
#import "AAChartView.h"

@interface WifiSpeedCell()<AAChartViewDidFinishLoadDelegate>
@property (nonatomic, strong) AAChartModel *aaChartModel;
@property (nonatomic, strong) AAChartView  *aaChartView;
@end

@implementation WifiSpeedCell
{
    __weak IBOutlet UILabel *_speedUpLabel;
    __weak IBOutlet UILabel *_speedDownLabel;
    
    __weak IBOutlet UIView *_bgView;
    
    UIScrollView *_chartScrollView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self _createSnapView];
}

#pragma mark 创建折线图
- (void)_createSnapView {
    _chartScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth - 114, 175)];
    _chartScrollView.bounces = NO;
    [_bgView addSubview:_chartScrollView];
    
    self.aaChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth - 114, 175)];
    self.aaChartView.delegate = self;
    self.aaChartView.contentHeight = 175;
    self.aaChartView.isClearBackgroundColor = YES;
    self.aaChartView.backgroundColor = [UIColor whiteColor];
    [_chartScrollView addSubview:self.aaChartView];
    
    self.aaChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeLine)
    .titleSet(@"")
    .subtitleSet(@"")
    .categoriesSet(@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7"])
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#000000")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#000000")    // y轴坐标值颜色
    .legendEnabledSet(false)
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .nameSet(@"上行")
                 .dataSet(@[@3,@7,@3,@7,@3,@7,@3,@7]),
                 
                 AAObject(AASeriesElement)
                 .nameSet(@"下行")
                 .dataSet(@[@2,@9,@6,@9,@6,@9,@6,@9]),
                 ]
               )
    ;
    
    _aaChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.aaChartModel.symbol = AAChartSymbolTypeCircle;
    self.aaChartModel.colorsTheme = @[@"#1B82D1",@"#FFC13B"];
    
    
    [self.aaChartView aa_drawChartWithChartModel:_aaChartModel];//aa_refreshChartWithChartModel
    
}

- (void)AAChartViewDidFinishLoad {
    
}

@end
