//
//  MealCountCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/2/1.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "MealCountCell.h"
#import "AAChartView.h"

#define PageLineWidth (KScreenWidth - 65)/7
#define PostLeftWidth 65

@interface MealCountCell()
@property (nonatomic, strong) AAChartModel *mixChartModel;
@property (nonatomic, strong) AAChartView  *mixChartView;
@end

@implementation MealCountCell
{
    __weak IBOutlet UIView *_topCountView;
    
    __weak IBOutlet UILabel *_preNumLabel;
    __weak IBOutlet UILabel *_costLabel;
    
    __weak IBOutlet UILabel *_dopostLabel;
    
    __weak IBOutlet UILabel *_dopostTitleLabel;
    
    
    UIScrollView *_chartScrollView;
}

- (void)_initView {
    // 头部日期背景
    UIView *filterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 80)];
    filterView.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    [_topCountView addSubview:filterView];
    
    UILabel *elcLabel = [[UILabel alloc] init];
    elcLabel.frame = CGRectMake(10,13,40,17);
    elcLabel.text = @"人数";
    elcLabel.textColor = [UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:1];
    [filterView addSubview:elcLabel];
    
    UIView *elcView = [[UIView alloc] init];
    elcView.frame = CGRectMake(elcLabel.right + 7,18,25,7.5);
    elcView.backgroundColor = [UIColor colorWithHexString:@"#FFC921"];
    [filterView addSubview:elcView];
    
    UILabel *parkSnapLabel = [[UILabel alloc] init];
    parkSnapLabel.frame = CGRectMake(elcView.right + 20,elcLabel.top,60,17);
    parkSnapLabel.text = @"消费额";
    parkSnapLabel.textColor = [UIColor whiteColor];
    [filterView addSubview:parkSnapLabel];
    
    UIView *parkSnapLineView = [[UIView alloc] init];
    parkSnapLineView.frame = CGRectMake(parkSnapLabel.right + 9,18,25,7.5);
    parkSnapLineView.backgroundColor = [UIColor colorWithHexString:@"#00FF3C"];
    [filterView addSubview:parkSnapLineView];
    
    NSArray *btTitles = @[@"日"];
    [btTitles enumerateObjectsUsingBlock:^(NSString *btTitle, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *dateBt = [UIButton buttonWithType:UIButtonTypeCustom];
        dateBt.frame = CGRectMake(KScreenWidth - 130 + 2*40, 10, 40, 25);
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
    
    // 混合图背景scrollView
    _chartScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 80, KScreenWidth, 275)];
    _chartScrollView.bounces = NO;
    //    _chartScrollView.contentSize = CGSizeMake(self.view.frame.size.width*2, 0);
    [_topCountView addSubview:_chartScrollView];
    
    self.mixChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 80, KScreenWidth, 275)];
    self.mixChartView.contentHeight = 255;
    self.mixChartView.isClearBackgroundColor = YES;
    self.mixChartView.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    self.mixChartView.clipsToBounds = YES;
    
    self.mixChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeLine)
    .titleSet(@"")
    .subtitleSet(@"")
    .categoriesSet(@[])
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#ffffff")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#ffffff")    // y轴坐标值颜色
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .typeSet(AAChartTypeColumn)
                 .nameSet(@"人数")
                 .dataSet(@[]),
                 
                 AAObject(AASeriesElement)
                 .typeSet(AAChartTypeColumn)
                 .nameSet(@"消费额")
                 .dataSet(@[]),
                 ]
               )
    ;
    
    self.mixChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.mixChartModel.symbol = AAChartSymbolTypeCircle;
    self.mixChartModel.colorsTheme = @[@"#FFC921", @"#00FF3C"];
    [self.mixChartView aa_drawChartWithChartModel:_mixChartModel];
    
    [_chartScrollView addSubview:_mixChartView];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self _initView];
    
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
        UIButton *button = [_topCountView viewWithTag:100 + i];
        if(button == dateBt){
            button.backgroundColor = [UIColor colorWithHexString:@"#D1E6F6"];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else {
            button.backgroundColor = [UIColor clearColor];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
}

#pragma mark 设置统计数据
/*
- (void)setVisCountNumModel:(VisCountNumModel *)visCountNumModel {
    _visCountNumModel = visCountNumModel;
    
    _allNumLabel.text = [NSString stringWithFormat:@"%@", visCountNumModel.total];
    
    _manNumLabel.text = [NSString stringWithFormat:@"%@", visCountNumModel.male];
    
    _femaleNumLabel.text = [NSString stringWithFormat:@"%@", visCountNumModel.female];
    
    NSString *dodPersent = [NSString stringWithFormat:@"%@", visCountNumModel.dodPersent];
    if(dodPersent.integerValue > 0){
        _rationLabel.text = [NSString stringWithFormat:@"↑%d%%", abs(dodPersent.intValue)];
        _rationLabel.textColor = [UIColor colorWithHexString:@"#ec535e"];
    }else {
        _rationLabel.text = [NSString stringWithFormat:@"↓%d%%", abs(dodPersent.intValue)];
        _rationLabel.textColor = [UIColor colorWithHexString:@"#88d777"];
    }
    
    NSString *avgDuration = [NSString stringWithFormat:@"%@", visCountNumModel.avgDuration];
    _averageLabel.text = [self traceTime:avgDuration];
    
}
*/

/*
- (void)setLinkRatio:(LinkRatio)linkRatio {
    _linkRatio = linkRatio;
    
    switch (linkRatio) {
        case DayLinkRatio:
            _dopostTitleLabel.text = @"就餐日环比";
            break;
            
        case WeekLinkRatio:
            _dopostTitleLabel.text = @"就餐周环比";
            break;
            
        case MonthLinkRatio:
            _dopostTitleLabel.text = @"就餐月环比";
            break;
            
        default:
            break;
    }
}
 */

- (NSString *)traceTime:(NSString *)traceTime {
    CGFloat avgTime = traceTime.floatValue;
    
    NSString *hour = [NSString stringWithFormat:@"%d", (int)(avgTime/3600)];
    if(hour.length < 2){
        hour = [NSString stringWithFormat:@"0%@", hour];
    }
    NSString *minter = [NSString stringWithFormat:@"%d", (int)avgTime%3600/60];
    if(minter.length < 2){
        minter = [NSString stringWithFormat:@"0%@", minter];
    }
    NSString *secord = [NSString stringWithFormat:@"%d", (int)avgTime%60];
    if(secord.length < 2){
        secord = [NSString stringWithFormat:@"0%@", secord];
    }
    
    NSString *avgTimeStr = [NSString stringWithFormat:@"%@:%@:%@", hour, minter, secord];
    return avgTimeStr;
}

- (void)setXRollerData:(NSArray *)xRollerData {
    _xRollerData = xRollerData;
    
    if(_numData != nil && _costData != nil){
        [self refreshChart];
    }
}

- (void)setNumData:(NSArray *)numData {
    _numData = numData;
    
    if(_costData != nil && _xRollerData != nil){
        [self refreshChart];
    }
}

- (void)setCostData:(NSArray *)costData {
    _costData = costData;
    
    if(_xRollerData != nil && _numData != nil){
        [self refreshChart];
    }
}

#pragma mark 刷新统计图表
- (void)refreshChart {
    
    if(_xRollerData.count > 7){
        // 大于7列 滑动
        CGFloat snapChartWidth = PostLeftWidth + 20 + PageLineWidth*_xRollerData.count;
        _chartScrollView.contentSize = CGSizeMake(snapChartWidth, 0);
        [_chartScrollView setContentOffset:CGPointMake(_chartScrollView.contentSize.width - KScreenWidth, 0) animated:YES];
        
        self.mixChartView = nil;
        [_mixChartView removeFromSuperview];
        
        self.mixChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, snapChartWidth, 275)];
        self.mixChartView.contentHeight = 255;
        self.mixChartView.userInteractionEnabled = YES;
        self.mixChartView.isClearBackgroundColor = YES;
        self.mixChartView.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
        [_chartScrollView addSubview:self.mixChartView];
        
    }else {
        _chartScrollView.contentSize = CGSizeMake(0, 0);
        
        self.mixChartView = nil;
        [_mixChartView removeFromSuperview];
        
        self.mixChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, 275)];
        self.mixChartView.contentHeight = 255;
        self.mixChartView.userInteractionEnabled = YES;
        self.mixChartView.isClearBackgroundColor = YES;
        self.mixChartView.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
        [_chartScrollView addSubview:self.mixChartView];
    }
    
    // 为chartView添加点击事件
    UITapGestureRecognizer *myTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.mixChartView addGestureRecognizer:myTap];
    myTap.delegate = self;
    myTap.cancelsTouchesInView = NO;
    
    self.mixChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeLine)
    .titleSet(@"")
    .subtitleSet(@"")
    .categoriesSet(_xRollerData)
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#ffffff")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#ffffff")    // y轴坐标值颜色
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .typeSet(AAChartTypeColumn)
                 .nameSet(@"人数")
                 .dataSet(_numData),
                 
                 AAObject(AASeriesElement)
                 .typeSet(AAChartTypeColumn)
                 .nameSet(@"消费额")
                 .dataSet(_costData),
                 ]
               )
    ;
    
    self.mixChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.mixChartModel.symbol = AAChartSymbolTypeCircle;
    self.mixChartModel.colorsTheme = @[@"#FFC921", @"#00FF3C"];
    [self.mixChartView aa_drawChartWithChartModel:_mixChartModel];
}

#pragma mark 点击一列的协议放方法
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
-(void)handleSingleTap:(UITapGestureRecognizer *)sender{
    CGPoint gesturePoint = [sender locationInView:self.contentView];
    
    CGFloat xRallerWidth;
    CGFloat xOffset;
    if(_chartScrollView.contentSize.width > KScreenWidth){
        xRallerWidth = _chartScrollView.contentSize.width;
        xOffset = _chartScrollView.contentOffset.x;
    }else {
        xRallerWidth = KScreenWidth;
        xOffset = 0;
    }
    
    // 点击区域
    CGFloat postWidth = (xRallerWidth - PostLeftWidth)/_xRollerData.count;
    for (int i=0; i<_xRollerData.count; i++) {
        if((gesturePoint.x + xOffset) >= (postWidth*i + PostLeftWidth) &&
           (gesturePoint.x + xOffset) <= (postWidth*(i+1) + PostLeftWidth)){
            //            NSLog(@"点击了第%d行柱", i+1);
            if(_filterDelegate && [_filterDelegate respondsToSelector:@selector(didSelectChartLineIndex:)]){
                [_filterDelegate didSelectChartLineIndex:i];
            }
            break;
        }
    }
}

#pragma mark 设置当天统计数据
- (void)setMealDayModel:(MealDayModel *)mealDayModel {
    _mealDayModel = mealDayModel;
    
    _preNumLabel.text = [NSString stringWithFormat:@"%@ 人", mealDayModel.chargeCount];
    
    _costLabel.text = [NSString stringWithFormat:@"%@ 元", mealDayModel.costMoney];
    
    NSString *dodPersent = [NSString stringWithFormat:@"%@", mealDayModel.dodPersent];
    if(dodPersent.integerValue > 0){
        _dopostLabel.text = [NSString stringWithFormat:@"↑%d%%", abs(dodPersent.intValue)];
        _dopostLabel.textColor = [UIColor colorWithHexString:@"#ec535e"];
    }else {
        _dopostLabel.text = [NSString stringWithFormat:@"↓%d%%", abs(dodPersent.intValue)];
        _dopostLabel.textColor = [UIColor colorWithHexString:@"#88d777"];
    }
}

@end
