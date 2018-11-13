//
//  WarnCountCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/20.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "WarnCountCell.h"
#import "AAChartView.h"

@interface WarnCountCell()
{
    __weak IBOutlet UIView *_headPostView;
    
}
@property (nonatomic, strong) AAChartModel *postChartModel;
@property (nonatomic, strong) AAChartView  *postChartView;
@end

@implementation WarnCountCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // 头部柱状图
    [self _createPostView];
    
}

- (void)_createPostView {
    // 头部日期背景
    UIView *filterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 40)];
    filterView.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    [_headPostView addSubview:filterView];
    
    UILabel *elcLabel = [[UILabel alloc] init];
    elcLabel.frame = CGRectMake(10,13,35,17);
    elcLabel.text = @"设备";
    elcLabel.textColor = [UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:1];
    [filterView addSubview:elcLabel];
    
    UIView *elcView = [[UIView alloc] init];
    elcView.frame = CGRectMake(elcLabel.right + 7,18,25,7.5);
    elcView.backgroundColor = [UIColor colorWithHexString:@"#FFC921"];
    [filterView addSubview:elcView];
    
    UILabel *waterLabel = [[UILabel alloc] init];
    waterLabel.frame = CGRectMake(elcView.right + 18,13,35,17);
    waterLabel.text = @"安防";
    waterLabel.textColor = [UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:1];
    [filterView addSubview:waterLabel];
    
    UIView *waterView = [[UIView alloc] init];
    waterView.frame = CGRectMake(waterLabel.right + 7,18,25,7.5);
    waterView.backgroundColor = [UIColor colorWithHexString:@"#00FF3C"];
    [filterView addSubview:waterView];
    
    NSArray *btTitles = @[@"日", @"周", @"月"];
    [btTitles enumerateObjectsUsingBlock:^(NSString *btTitle, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *dateBt = [UIButton buttonWithType:UIButtonTypeCustom];
        dateBt.frame = CGRectMake(KScreenWidth - 130 + idx*40, 10, 40, 25);
        [dateBt setTitle:btTitle forState:UIControlStateNormal];
        dateBt.tag = 100 + idx;
        dateBt.layer.borderColor = [UIColor colorWithHexString:@"#D1E6F6"].CGColor;
        dateBt.layer.borderWidth = 1;
        if(idx == 0){
            dateBt.backgroundColor = [UIColor colorWithHexString:@"#D1E6F6"];
            [dateBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else {
            dateBt.backgroundColor = [UIColor clearColor];
            [dateBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        [dateBt addTarget:self action:@selector(dateFilterAction:) forControlEvents:UIControlEventTouchUpInside];
        [filterView addSubview:dateBt];
    }];
    
    self.postChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 40, KScreenWidth, 275)];
    self.postChartView.contentHeight = 255;
    self.postChartView.isClearBackgroundColor = YES;
    self.postChartView.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    self.postChartView.clipsToBounds = YES;
    [_headPostView addSubview:self.postChartView];
    
    self.postChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeColumn)
    .titleSet(@"")
    .subtitleSet(@"")
    .categoriesSet(@[@"0",@"3",@"6",@"9", @"12",@"15",@"18",@"21",@"24"])
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#ffffff")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#ffffff")    // y轴坐标值颜色
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .typeSet(AAChartTypeColumn)
                 .nameSet(@"会员")
                 .dataSet(@[@45,@88,@49,@43,@65,@56,@47,@28,@49]),
                 
                 AAObject(AASeriesElement)
                 .typeSet(AAChartTypeColumn)
                 .nameSet(@"临停")
                 .dataSet(@[@65,@58,@42,@43,@65,@56,@77,@45,@49]),
                 ]
               )
    ;
    
    self.postChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.postChartModel.symbol = AAChartSymbolTypeCircle;
    self.postChartModel.colorsTheme = @[@"#FFC921", @"#00FF3C", @"#ffffff"];
    [self.postChartView aa_drawChartWithChartModel:_postChartModel];
    
    [_headPostView addSubview:_postChartView];
}

#pragma mark 柱状图按日期筛选
- (void)dateFilterAction:(UIButton *)dateBt {
    [self changeBtState:dateBt];
    
    switch (dateBt.tag - 100) {
        case 0:
            // 日
            break;
        case 1:
            // 周
            break;
        case 2:
            // 月
            break;
            
    }
}
- (void)changeBtState:(UIButton *)dateBt {
    for (int i=0; i<3; i++) {
        UIButton *button = [_headPostView viewWithTag:100 + i];
        if(button == dateBt){
            button.backgroundColor = [UIColor colorWithHexString:@"#D1E6F6"];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else {
            button.backgroundColor = [UIColor clearColor];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
