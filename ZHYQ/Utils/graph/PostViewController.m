//
//  ViewController.m
//  Graph_Demo
//
//  Created by weiweilong on 2017/10/31.
//  Copyright © 2017年 weiweilong. All rights reserved.
//

#import "PostViewController.h"
#import "AAChartKit.h"
#import "AAChartView.h"

@interface PostViewController ()<AAChartViewDidFinishLoadDelegate>
@property (nonatomic, strong) AAChartModel *aaChartModel;
@property (nonatomic, strong) AAChartView  *aaChartView;
@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configTheChartView:AAChartTypeColumn];
}
- (void)configTheChartView:(AAChartType)chartType {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height-220)];
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width*2, 0);
    [self.view addSubview:scrollView];
    
    self.aaChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height-220)];
    self.aaChartView.delegate = self;
    self.aaChartView.contentHeight = self.view.frame.size.height-250;
    [self.view addSubview:self.aaChartView];
//    [scrollView addSubview:self.aaChartView];
    
    //    //设置 AAChartView 的背景色是否为透明(解开注释查看设置背景色透明后的效果)
    //    self.aaChartView.isClearBackgroundColor = YES;
    //    self.view.backgroundColor = [UIColor blueColor];
    
    self.aaChartModel= AAObject(AAChartModel)
    .chartTypeSet(chartType)
    .titleSet(@"")
    .subtitleSet(@"")
    .categoriesSet(@[@"10/25",@"10/26",@"10/27",@"10/28",@"10/29",@"10/30",@"10/31"])
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#ffffff")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#ffffff")    // y轴坐标值颜色
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .nameSet(@"水环比")
                 .dataSet(@[@16,@17,@18,@19,@33,@56,@39]),
                 
                 AAObject(AASeriesElement)
                 .nameSet(@"电环比")
                 .dataSet(@[@26,@37,@28,@49,@56,@31,@11]),
                 ]
               )
    /**
     *   标示线的设置
     *   标示线设置作为图表一项基础功能,用于对图表的基本数据水平均线进行标注
     *   虽然不太常被使用,但我们仍然提供了此功能的完整接口,以便于有特殊需求的用户使用
     *   解除以下代码注释,,运行程序,即可查看实际工程效果以酌情选择
     *
     **/
    //    .yPlotLinesSet(@[AAObject(AAPlotLinesElement)
    //                     .colorSet(@"#F05353")//颜色值(16进制)
    //                     .dashStyleSet(@"Dash")//样式：Dash,Dot,Solid等,默认Solid
    //                     .widthSet(@(1)) //标示线粗细
    //                     .valueSet(@(20)) //所在位置
    //                     .zIndexSet(@(1)) //层叠,标示线在图表中显示的层叠级别，值越大，显示越向前
    //                     .labelSet(@{@"text":@"标示线1",@"x":@(0),@"style":@{@"color":@"#33bdfd"}})/*这里其实也可以像AAPlotLinesElement这样定义个对象来赋值（偷点懒直接用了字典，最会终转为js代码，可参考https://www.hcharts.cn/docs/basic-plotLines来写字典）*/
    //                     ,AAObject(AAPlotLinesElement)
    //                     .colorSet(@"#33BDFD")
    //                     .dashStyleSet(@"Dash")
    //                     .widthSet(@(1))
    //                     .valueSet(@(40))
    //                     .labelSet(@{@"text":@"标示线2",@"x":@(0),@"style":@{@"color":@"#33bdfd"}})
    //                     ,AAObject(AAPlotLinesElement)
    //                     .colorSet(@"#ADFF2F")
    //                     .dashStyleSet(@"Dash")
    //                     .widthSet(@(1))
    //                     .valueSet(@(60))
    //                     .labelSet(@{@"text":@"标示线3",@"x":@(0),@"style":@{@"color":@"#33bdfd"}})
    //                     ]
    //                   )
    //    //Y轴最大值
    //    .yMaxSet(@(100))
    //    //Y轴最小值
    //    .yMinSet(@(1))
    //    //是否允许Y轴坐标值小数
    //    .yAllowDecimalsSet(NO)
    //    //指定y轴坐标
    //    .yTickPositionsSet(@[@(0),@(25),@(50),@(75),@(100)])
    ;
    
    if ([chartType isEqualToString:AAChartTypeLine]
        || [chartType isEqualToString:AAChartTypeSpline]) {
        _aaChartModel.symbol = AAChartSymbolTypeCircle;//设置折线连接点样式为:边缘白色
    } else if ([chartType isEqualToString:AAChartTypeArea]
               || [chartType isEqualToString:AAChartTypeAreaspline]) {
        _aaChartModel.symbol = AAChartSymbolTypeSquare;//设置折线连接点样式为:内部白色
    }
    
    //是否起用渐变色功能
    //    _aaChartModel.gradientColorEnable = YES;
    
    [self.aaChartView aa_drawChartWithChartModel:_aaChartModel];
    
//    [self.aaChartView aa_refreshChartWithChartModel:self.aaChartModel];
}
#pragma mark -- AAChartView delegate
-(void)AAChartViewDidFinishLoad {
    NSLog(@"😊😊😊图表视图已完成加载");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
