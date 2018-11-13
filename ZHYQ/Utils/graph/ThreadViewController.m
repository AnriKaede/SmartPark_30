//
//  ThreadViewController.m
//  Graph_Demo
//
//  Created by weiweilong on 2017/10/31.
//  Copyright © 2017年 weiweilong. All rights reserved.
//

#import "ThreadViewController.h"
#import "AAChartKit.h"
#import "AAChartView.h"

@interface ThreadViewController ()<AAChartViewDidFinishLoadDelegate>
@property (nonatomic, strong) AAChartModel *aaChartModel;
@property (nonatomic, strong) AAChartView  *aaChartView;
@end

@implementation ThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configTheChartView:AAChartTypeLine];
}
- (void)configTheChartView:(AAChartType)chartType {
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height-220)];
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width*2, 0);
//    [self.view addSubview:scrollView];
    
    self.aaChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height-220)];
    self.aaChartView.delegate = self;
    self.aaChartView.contentHeight = self.view.frame.size.height-250;
    [self.view addSubview:self.aaChartView];
//    [scrollView addSubview:self.aaChartView];
    
//    self.aaChartView.mutable
    
    //    //设置 AAChartView 的背景色是否为透明(解开注释查看设置背景色透明后的效果)
    //    self.aaChartView.isClearBackgroundColor = YES;
    //    self.view.backgroundColor = [UIColor blueColor];
    
    self.aaChartModel= AAObject(AAChartModel)
    .chartTypeSet(chartType)
    .titleSet(@"")
    .subtitleSet(@"")
    .categoriesSet(@[@"0",@"3",@"6",@"9",@"12",@"15",@"18",@"21"])
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#ffffff")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#ffffff")    // y轴坐标值颜色
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .nameSet(@"水耗")
                 .dataSet(@[@11,@12,@19,@33,@56,@39,@13,@14]),
                 
                 AAObject(AASeriesElement)
                 .nameSet(@"电耗")
                 .dataSet(@[@21,@22,@28,@33,@40,@31,@27,@34]),
                 ]
               )
    
    /**
     *   标示线的设置
     *   标示线设置作为图表一项基础功能,用于对图表的基本数据水平均线进行标注
     *   虽然不太常被使用,但我们仍然提供了此功能的完整接口,以便于有特殊需求的用户使用
     *   解除以下代码注释,,运行程序,即可查看实际工程效果以酌情选择
     *
     **/
        .yAxisPlotLinesSet(@[AAObject(AAPlotLinesElement)
                         .colorSet(@"#F05353")//颜色值(16进制)
                         .dashStyleSet(@"Dash")//样式：Dash,Dot,Solid等,默认Solid
                         .widthSet(@(1)) //标示线粗细
                         .valueSet(@(30)) //所在位置
                         .zIndexSet(@(1)) //层叠,标示线在图表中显示的层叠级别，值越大，显示越向前
                         .labelSet(@{@"text":@"标示线1",@"x":@(0),@"style":@{@"color":@"#33bdfd"}})/*这里其实也可以像AAPlotLinesElement这样定义个对象来赋值（偷点懒直接用了字典，最会终转为js代码，可参考https://www.hcharts.cn/docs/basic-plotLines来写字典）*/
                         ]
                       )
        //Y轴最大值
        .yAxisMaxSet(@(80))
        //Y轴最小值
        .yAxisMinSet(@(1))
        //是否允许Y轴坐标值小数
        .yAxisAllowDecimalsSet(NO)
        //指定y轴坐标
        .yAxisTickPositionsSet(@[@(0),@(20),@(40),@(60),@(80)])
    
    ;
    
    if ([chartType isEqualToString:AAChartTypeLine]
        || [chartType isEqualToString:AAChartTypeSpline]) {
        _aaChartModel.symbol = AAChartSymbolTypeCircle;//设置折线连接点样式为:边缘白色
    } else if ([chartType isEqualToString:AAChartTypeArea]
               || [chartType isEqualToString:AAChartTypeAreaspline]) {
        _aaChartModel.symbol = AAChartSymbolTypeCircle;//设置折线连接点样式为:内部白色
    }
    
    [self.aaChartView aa_drawChartWithChartModel:_aaChartModel];
    
    //    [self.aaChartView aa_refreshChartWithChartModel:self.aaChartModel];
}
#pragma mark -- AAChartView delegate
-(void)AAChartViewDidFinishLoad {
    NSLog(@"😊😊😊图表视图已完成加载");
}

@end
