//
//  ParkFeeSnapCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/10/25.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "ParkFeeSnapCell.h"
#import "AAChartView.h"

@interface ParkFeeSnapCell()
{
    UIScrollView *_chartScrollView;
}
@property (nonatomic, strong) AAChartModel *snapChartModel;
@property (nonatomic, strong) AAChartView  *snapChartView;
@end

@implementation ParkFeeSnapCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        [self _crateSnapView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)_crateSnapView {
    _chartScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 214)];
    _chartScrollView.bounces = NO;
    //    _chartScrollView.contentSize = CGSizeMake(self.view.frame.size.width*2, 0);
    [self.contentView addSubview:_chartScrollView];

    self.snapChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, _chartScrollView.height)];
    self.snapChartView.contentHeight = _chartScrollView.height;
    self.snapChartView.isClearBackgroundColor = YES;
    self.snapChartView.backgroundColor = [UIColor whiteColor];
    [_chartScrollView addSubview:self.snapChartView];

    self.snapChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeLine)
    .titleSet(@"")
    .subtitleSet(@"")
    .categoriesSet(@[@"0",@"3",@"6",@"9", @"12",@"15",@"18",@"21",@"24"])
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#000000")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#000000")    // y轴坐标值颜色
    .legendEnabledSet(NO)
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .nameSet(@"收费统计")
                 .dataSet(@[@45,@88,@49,@43,@65,@56,@47,@28,@49]),
                 ]
               )
    ;

    self.snapChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.snapChartModel.symbol = AAChartSymbolTypeCircle;
    self.snapChartModel.colorsTheme = @[@"#1B82D1"];

    [self.snapChartView aa_drawChartWithChartModel:_snapChartModel];
}

@end
