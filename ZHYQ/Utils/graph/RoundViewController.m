//
//  RoundViewController.m
//  Graph_Demo
//
//  Created by weiweilong on 2017/10/31.
//  Copyright © 2017年 weiweilong. All rights reserved.
//

#import "RoundViewController.h"
#import "AAChartKit.h"
#import "AAChartView.h"

@interface RoundViewController ()<AAChartViewDidFinishLoadDelegate>
@property (nonatomic, strong) AAChartModel *aaChartModel;
@property (nonatomic, strong) AAChartView  *aaChartView;
@end

@implementation RoundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configTheChartView:AAChartTypePie];
}
- (void)configTheChartView:(AAChartType)chartType {
    
    self.aaChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height-220)];
    self.aaChartView.delegate = self;
    self.aaChartView.contentHeight = self.view.frame.size.height-250;
    [self.view addSubview:self.aaChartView];
    
    self.aaChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypePie)
    .colorsThemeSet(@[@"#0c9674",@"#7dffc0",@"#d11b5f",@"#facd32",@"#ffffa0"])
    .titleSet(@"各区域耗电")
    .subtitleSet(@"虚拟数据")
    //        .dataLabelEnabledSet(true)//是否直接显示扇形图数据
    .yAxisTitleSet(@"摄氏度")
    .seriesSet(
               @[
                 AAObject(AASeriesElement)
                 .nameSet(@"耗电量")
                 .innerSizeSet(@"35%")
                 .dataSet(@[
                            @[@"停车场"  , @67],
                            @[@"园区广场" , @44],
                            @[@"办公楼宇", @83],
                            @[@"喷泉"    , @11],
                            @[@"路灯"  , @42],
                            ]),
                 ]
               )
    ;
    
    [self.aaChartView aa_drawChartWithChartModel:_aaChartModel];
    
    //    [self.aaChartView aa_refreshChartWithChartModel:self.aaChartModel];
}
#pragma mark -- AAChartView delegate
-(void)AAChartViewDidFinishLoad {
    NSLog(@"😊😊😊图表视图已完成加载");
}

@end
