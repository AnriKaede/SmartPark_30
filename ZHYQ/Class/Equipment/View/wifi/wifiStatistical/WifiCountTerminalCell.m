//
//  WifiCountTerminalCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/10/26.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WifiCountTerminalCell.h"
#import "AAChartView.h"
#import "WifiCountTypeModel.h"

@interface WifiCountTerminalCell()
@property (nonatomic, strong) AAChartModel *cakeChartModel;
@property (nonatomic, strong) AAChartView  *cakeChartView;
@end

@implementation WifiCountTerminalCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self _createCakeView];
}

#pragma mark 扇形图
- (void)_createCakeView {
    self.cakeChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, 200)];
    self.cakeChartView.isClearBackgroundColor = YES;
    self.cakeChartView.backgroundColor = [UIColor whiteColor];
    
    [self.contentView addSubview:self.cakeChartView];
    
    self.cakeChartModel = AAObject(AAChartModel)
    .chartTypeSet(AAChartTypePie)
    .colorsThemeSet(@[@"#edc443",@"#ea9731",@"#ed3732",@"#4db6f9",@"#63d540"])
    .titleSet(@"")
    .subtitleSet(@"")
    .dataLabelEnabledSet(NO)//是否直接显示扇形图数据
    .yAxisTitleSet(@"")
    .legendEnabledSet(YES)
    .xAxisVisibleSet(NO)
    .yAxisVisibleSet(NO)
    .seriesSet(
               @[
                 AAObject(AASeriesElement)
                 .nameSet(@"数量")
                 .innerSizeSet(@"0%")//内部圆环半径大小占比
                 .dataSet(@[@[@"苹果端" , @10],
                            @[@"安卓端" , @18],
                            @[@"笔记本" , @12],
                            @[@"其他设备" , @30]
                            ]),
                 ]
               )
    ;
    
    _cakeChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.cakeChartModel.symbol = AAChartSymbolTypeCircle;
    
    [self.cakeChartView aa_drawChartWithChartModel:_cakeChartModel];
    
}

- (void)setTypeData:(NSArray *)typeData {
    _typeData = typeData;
    
    NSMutableArray *countAry = @[].mutableCopy;
    [typeData enumerateObjectsUsingBlock:^(WifiCountTypeModel *typeModel, NSUInteger idx, BOOL * _Nonnull stop) {
        [countAry addObject:@[typeModel.clientType, [NSNumber numberWithString:typeModel.userCount]]];
    }];
    [self refreshCake:countAry];
}

- (void)refreshCake:(NSArray *)cakeData {
    self.cakeChartModel = AAObject(AAChartModel)
    .chartTypeSet(AAChartTypePie)
    .colorsThemeSet(@[@"#edc443",@"#ea9731",@"#ed3732",@"#4db6f9",@"#63d540"])
    .titleSet(@"")
    .subtitleSet(@"")
    .dataLabelEnabledSet(NO)//是否直接显示扇形图数据
    .yAxisTitleSet(@"")
    .legendEnabledSet(YES)
    .xAxisVisibleSet(NO)
    .yAxisVisibleSet(NO)
    .seriesSet(
               @[
                 AAObject(AASeriesElement)
                 .nameSet(@"数量")
                 .innerSizeSet(@"0%")//内部圆环半径大小占比
                 .dataSet(cakeData),
                 ]
               )
    ;

    _cakeChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.cakeChartModel.symbol = AAChartSymbolTypeCircle;

    [self.cakeChartView aa_refreshChartWithChartModel:self.cakeChartModel];
    
}

@end
