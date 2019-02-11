//
//  CountCakeView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/16.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "CountCakeView.h"
#import "AAChartView.h"

#import "CountMaxMinView.h"

@interface CountCakeView()<UIScrollViewDelegate>
{
    UIView *_topView;
    
    UIScrollView *_countBgScrollView;
    
    CountMaxMinView *_elcCountMaxMinView;
    CountMaxMinView *_waterCountMaxMinView;
}
@property (nonatomic, strong) AAChartModel *elcCakeChartModel; // 饼状图
@property (nonatomic, strong) AAChartView  *elcCakeChartView;  // 饼状图

@property (nonatomic, strong) AAChartModel *waterCakeChartModel; // 饼状图
@property (nonatomic, strong) AAChartView  *waterCakeChartView;  // 饼状图

@end

@implementation CountCakeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        [self _initView];
    }
    return self;
}

- (void)_initView {
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 50)];
    _topView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    [self addSubview:_topView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 45, KScreenWidth/2, 5)];
    lineView.tag = 401;
    lineView.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    [_topView addSubview:lineView];
    
    UILabel *electricLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 17, KScreenWidth/2, 17)];
    electricLabel.font = [UIFont systemFontOfSize:17];
    electricLabel.textAlignment = NSTextAlignmentCenter;
    electricLabel.text = @"电耗";
    [_topView addSubview:electricLabel];
    UITapGestureRecognizer *electricTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(electricAction)];
    electricLabel.userInteractionEnabled = YES;
    [electricLabel addGestureRecognizer:electricTap];
    
    UILabel *waterLabel = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth/2, 17, KScreenWidth/2, 17)];
    waterLabel.font = [UIFont systemFontOfSize:17];
    waterLabel.textAlignment = NSTextAlignmentCenter;
    waterLabel.text = @"水耗";
    [_topView addSubview:waterLabel];
    UITapGestureRecognizer *waterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(waterAction)];
    waterLabel.userInteractionEnabled = YES;
    [waterLabel addGestureRecognizer:waterTap];
    
    _countBgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, KScreenWidth, self.height - 50)];
    _countBgScrollView.contentSize = CGSizeMake(KScreenWidth * 2, 0);
    _countBgScrollView.delegate = self;
    _countBgScrollView.bounces = NO;
    _countBgScrollView.pagingEnabled = YES;
    _countBgScrollView.showsVerticalScrollIndicator = NO;
    _countBgScrollView.showsHorizontalScrollIndicator = NO;
    _countBgScrollView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_countBgScrollView];
    
    // 饼状图
    [self _createELcCharView];
    [self _createWaterCahrView];
    
    // 最大最新能耗
    [self _createMaxMinView];
    
}

- (void)_createELcCharView {
    // 耗电饼状图
    self.elcCakeChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, 270)];
    self.elcCakeChartView.contentHeight = 250;
    self.elcCakeChartView.isClearBackgroundColor = YES;
    self.elcCakeChartView.backgroundColor = [UIColor whiteColor];
    [_countBgScrollView addSubview:self.elcCakeChartView];
    
    self.elcCakeChartModel = AAObject(AAChartModel)
    .chartTypeSet(AAChartTypePie)
    .colorsThemeSet(@[])
    .titleSet(@"")
    .subtitleSet(@"")
    .dataLabelEnabledSet(true)//是否直接显示扇形图数据
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#ffffff")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#ffffff")    // y轴坐标值颜色
    .seriesSet(
               @[
                 AAObject(AASeriesElement)
                 .nameSet(@"电耗")
                 .innerSizeSet(@"0%")//内部圆环半径大小占比
                 .dataSet(@[
                            ]),
                 ]
               )
    ;
    
    _elcCakeChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.elcCakeChartModel.symbol = AAChartSymbolTypeCircle;
    
    [self.elcCakeChartView aa_drawChartWithChartModel:_elcCakeChartModel];
    
}
- (void)_createWaterCahrView {
    // 耗水饼状图
    self.waterCakeChartView = [[AAChartView alloc]initWithFrame:CGRectMake(KScreenWidth, 0, KScreenWidth, 270)];
    self.waterCakeChartView.contentHeight = 250;
    self.waterCakeChartView.isClearBackgroundColor = YES;
    self.waterCakeChartView.backgroundColor = [UIColor whiteColor];
    [_countBgScrollView addSubview:self.waterCakeChartView];
    
    self.waterCakeChartModel = AAObject(AAChartModel)
    .chartTypeSet(AAChartTypePie)
    .colorsThemeSet(@[])
    .titleSet(@"")
    .subtitleSet(@"")
    .dataLabelEnabledSet(true)//是否直接显示扇形图数据
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#ffffff")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#ffffff")    // y轴坐标值颜色
    .seriesSet(
               @[
                 AAObject(AASeriesElement)
                 .nameSet(@"水耗")
                 .innerSizeSet(@"0%")//内部圆环半径大小占比
                 .dataSet(@[
                            ]),
                 ]
               )
    ;
    
    _waterCakeChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.waterCakeChartModel.symbol = AAChartSymbolTypeCircle;
    
    [self.waterCakeChartView aa_drawChartWithChartModel:_waterCakeChartModel];
}

#pragma mark 最高最低能耗视图
- (void)_createMaxMinView {
    UIView *elcLine = [[UIView alloc] initWithFrame:CGRectMake(0, _elcCakeChartView.bottom, KScreenWidth*2, 0.5)];
    elcLine.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    [_countBgScrollView addSubview:elcLine];
    
    _elcCountMaxMinView = [[CountMaxMinView alloc] initWithFrame:CGRectMake(0, elcLine.bottom, KScreenWidth, 230)];
    _elcCountMaxMinView.maxPartName = @"-";
    _elcCountMaxMinView.maxNum = @"0 kwh";
    _elcCountMaxMinView.minPartName = @"-";
    _elcCountMaxMinView.minNum = @"- kwh";
    [_countBgScrollView addSubview:_elcCountMaxMinView];
    
    _waterCountMaxMinView = [[CountMaxMinView alloc] initWithFrame:CGRectMake(KScreenWidth, elcLine.bottom, KScreenWidth, 230)];
    _waterCountMaxMinView.maxPartName = @"-";
    _waterCountMaxMinView.maxNum = @"0 吨";
    _waterCountMaxMinView.minPartName = @"-";
    _waterCountMaxMinView.minNum = @"0 吨";
    [_countBgScrollView addSubview:_waterCountMaxMinView];
}

#pragma mark UIScrollView 协议
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    UIView *lineView = [_topView viewWithTag:401];
    CGRect lineFrame = lineView.frame;
    lineFrame = CGRectMake(scrollView.contentOffset.x/2, lineFrame.origin.y, lineFrame.size.width, lineFrame.size.height);
    lineView.frame = lineFrame;
}
// 点击电耗 滑动scrollview
- (void)electricAction {
    [_countBgScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}
// 点击水耗 滑动scrollview
- (void)waterAction {
    [_countBgScrollView setContentOffset:CGPointMake(KScreenWidth, 0) animated:YES];
}


- (void)setEleCakeData:(NSArray *)eleCakeData {
    _eleCakeData = eleCakeData;
    
    [self refreshELeCake:eleCakeData];
    
    // 最大最小能耗
    NSMutableArray *nutEleCakeData = eleCakeData.mutableCopy;
    
    NSString *maxNameStr;
    NSNumber *maxPawerValue;
    
    NSString *minNameStr;
    NSNumber *minPawerValue;
    
    for (int i=0; i<nutEleCakeData.count; i++) {
        for (int j=i; j<eleCakeData.count; j++) {
            NSArray *iCakeAry = nutEleCakeData[i];
            NSArray *jCakeAry = nutEleCakeData[j];
            
            NSNumber *iValue = iCakeAry.lastObject;
            NSNumber *jValue = jCakeAry.lastObject;
            
            if(iValue.floatValue > jValue.floatValue){
                [nutEleCakeData exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
        }
    }
    
    NSArray *minAry = nutEleCakeData.firstObject;
    NSArray *maxAry = nutEleCakeData.lastObject;
    
    minNameStr = minAry.firstObject;
    minPawerValue = minAry.lastObject;
    
    maxNameStr = maxAry.firstObject;
    maxPawerValue = maxAry.lastObject;
    
    _elcCountMaxMinView.minPartName = minNameStr;
    _elcCountMaxMinView.minNum = [NSString stringWithFormat:@"%@ kwh", minPawerValue];
    
    _elcCountMaxMinView.maxPartName = maxNameStr;
    _elcCountMaxMinView.maxNum = [NSString stringWithFormat:@"%@ kwh", maxPawerValue];
}

- (void)setWaterCakeData:(NSArray *)waterCakeData {
    _waterCakeData = waterCakeData;
 
    [self refreshWaterCake:waterCakeData];
    
    // 最大最小能耗
    NSMutableArray *nutEleCakeData = waterCakeData.mutableCopy;
    
    NSString *maxNameStr;
    NSNumber *maxPawerValue;
    
    NSString *minNameStr;
    NSNumber *minPawerValue;
    
    for (int i=0; i<nutEleCakeData.count; i++) {
        for (int j=i; j<waterCakeData.count; j++) {
            NSArray *iCakeAry = nutEleCakeData[i];
            NSArray *jCakeAry = nutEleCakeData[j];
            
            NSNumber *iValue = iCakeAry.lastObject;
            NSNumber *jValue = jCakeAry.lastObject;
            
            if(iValue.floatValue > jValue.floatValue){
                [nutEleCakeData exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
        }
    }
    
    NSArray *minAry = nutEleCakeData.firstObject;
    NSArray *maxAry = nutEleCakeData.lastObject;
    
    minNameStr = minAry.firstObject;
    minPawerValue = minAry.lastObject;
    
    maxNameStr = maxAry.firstObject;
    maxPawerValue = maxAry.lastObject;
    
    _waterCountMaxMinView.minPartName = minNameStr;
    _waterCountMaxMinView.minNum = [NSString stringWithFormat:@"%@ 吨", minPawerValue];
    
    _waterCountMaxMinView.maxPartName = maxNameStr;
    _waterCountMaxMinView.maxNum = [NSString stringWithFormat:@"%@ 吨", maxPawerValue];
}

#pragma mark 刷新耗电饼状图
- (void)refreshELeCake:(NSArray *)arr
{
    
    self.elcCakeChartModel = AAObject(AAChartModel)
    .chartTypeSet(AAChartTypePie)
    .colorsThemeSet(@[@"#edc443",@"#ea9731",@"#ed3732",@"#4db6f9",@"#63d540", @"#842B00", @"    #707038", @"#7373B9", @"#D2A2CC", @"#5B00AE"])
    .titleSet(@"")
    .subtitleSet(@"")
    .dataLabelEnabledSet(true)//是否直接显示扇形图数据
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#ffffff")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#ffffff")    // y轴坐标值颜色
    .seriesSet(
               @[
                 AAObject(AASeriesElement)
                 .nameSet(@"电耗")
                 .innerSizeSet(@"0%")//内部圆环半径大小占比
                 .dataSet(arr),
                 ]
               )
    ;
    
    _elcCakeChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.elcCakeChartModel.symbol = AAChartSymbolTypeCircle;
    
    [self.elcCakeChartView aa_refreshChartWithChartModel:self.elcCakeChartModel];
}

#pragma mark 刷新耗水饼状图
- (void)refreshWaterCake:(NSArray *)arr
{
    
    self.waterCakeChartModel = AAObject(AAChartModel)
    .chartTypeSet(AAChartTypePie)
    .colorsThemeSet(@[@"#edc443",@"#ea9731",@"#ed3732",@"#4db6f9",@"#63d540", @"#842B00", @"    #707038", @"#7373B9", @"#D2A2CC", @"#5B00AE"])
    .titleSet(@"")
    .subtitleSet(@"")
    .dataLabelEnabledSet(true)//是否直接显示扇形图数据
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#ffffff")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#ffffff")    // y轴坐标值颜色
    .seriesSet(
               @[
                 AAObject(AASeriesElement)
                 .nameSet(@"水耗")
                 .innerSizeSet(@"0%")//内部圆环半径大小占比
                 .dataSet(arr),
                 ]
               )
    ;
    
    _waterCakeChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.waterCakeChartModel.symbol = AAChartSymbolTypeCircle;
    
    [self.waterCakeChartView aa_refreshChartWithChartModel:self.waterCakeChartModel];
}

@end
