//
//  VisCountCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/20.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "VisCountCell.h"
#import "AAChartView.h"

#define PageLineWidth (KScreenWidth - 60)/7

@interface VisCountCell ()
{
    __weak IBOutlet UIView *_topCountView;
    
    __weak IBOutlet UILabel *_allNumLabel;
    __weak IBOutlet UILabel *_manNumLabel;
    __weak IBOutlet UILabel *_femaleNumLabel;
    
    __weak IBOutlet UILabel *_rationLabel;
    __weak IBOutlet UILabel *_rationTitleLabel;
    
    __weak IBOutlet UILabel *_averageLabel;
    
    UIScrollView *_chartScrollView;
    
}
@property (nonatomic, strong) AAChartModel *mixChartModel;
@property (nonatomic, strong) AAChartView  *mixChartView;
@end

@implementation VisCountCell


- (void)_initView {
    // 添加渐变色
    [NavGradient viewAddGradient:_topCountView];
    
    // 头部日期背景
    UIView *filterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 80)];
    filterView.backgroundColor = [UIColor clearColor];
    [_topCountView addSubview:filterView];
    
    UILabel *elcLabel = [[UILabel alloc] init];
    elcLabel.frame = CGRectMake(10,13,78,17);
    elcLabel.text = @"访问人数";
    elcLabel.textColor = [UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:1];
    [filterView addSubview:elcLabel];
    
    UIView *elcView = [[UIView alloc] init];
    elcView.frame = CGRectMake(elcLabel.right + 7,18,25,7.5);
    elcView.backgroundColor = [UIColor colorWithHexString:@"#00FF3C"];
    [filterView addSubview:elcView];
    
    UILabel *parkSnapLabel = [[UILabel alloc] init];
    parkSnapLabel.frame = CGRectMake(elcLabel.left,elcLabel.bottom + 12,160,17);
    parkSnapLabel.text = @"平均访问时长(小时)";
    parkSnapLabel.textColor = [UIColor whiteColor];
    [filterView addSubview:parkSnapLabel];
    
    UIView *parkSnapLineView = [[UIView alloc] init];
    parkSnapLineView.frame = CGRectMake(parkSnapLabel.right + 9,elcLabel.bottom + 20,21,1);
    parkSnapLineView.backgroundColor = [UIColor colorWithHexString:@"#FFC921"];
    [filterView addSubview:parkSnapLineView];
    
    UIView *parkSnapPointView = [[UIView alloc] init];
    parkSnapPointView.frame = CGRectMake(parkSnapLineView.left + 6,elcLabel.bottom + 16,8,8);
    parkSnapPointView.backgroundColor = [UIColor colorWithHexString:@"#FFC921"];
    parkSnapPointView.layer.cornerRadius = 4;
    [filterView addSubview:parkSnapPointView];
    
//    NSArray *btTitles = @[@"日", @"周", @"月"];
    NSArray *btTitles = @[@"日"];
    [btTitles enumerateObjectsUsingBlock:^(NSString *btTitle, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *dateBt = [UIButton buttonWithType:UIButtonTypeCustom];
//        dateBt.frame = CGRectMake(KScreenWidth - 130 + idx*40, 10, 40, 25);
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
    _chartScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 75, KScreenWidth, 275)];
    _chartScrollView.bounces = NO;
    //    _chartScrollView.contentSize = CGSizeMake(self.view.frame.size.width*2, 0);
    [_topCountView addSubview:_chartScrollView];
    
    self.mixChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 75, KScreenWidth, 275)];
    self.mixChartView.contentHeight = 255;
    self.mixChartView.isClearBackgroundColor = YES;
    self.mixChartView.backgroundColor = [UIColor clearColor];
    self.mixChartView.clipsToBounds = YES;
    
    self.mixChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeLine)
    .titleSet(@"")
    .subtitleSet(@"")
    .categoriesSet(@[@"0",@"3",@"6",@"9", @"12",@"15",@"18",@"21",@"24"])
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#ffffff")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#ffffff")    // y轴坐标值颜色
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .typeSet(AAChartTypeColumn)
                 .nameSet(@"访问人数")
                 .dataSet(@[@45,@88,@49,@43,@65,@56,@47,@28,@49]),
                 
                 AAObject(AASeriesElement)
                 .typeSet(AAChartTypeLine)
                 .nameSet(@"平均访问时长")
                 .dataSet(@[@73,@88,@45,@46,@44,@74,@47,@35,@49]),
                 ]
               )
    ;
    
    self.mixChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.mixChartModel.symbol = AAChartSymbolTypeCircle;
    self.mixChartModel.colorsTheme = @[@"#00FF3C", @"#FFC921"];
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

#pragma mark 设置数据
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

- (void)setLinkRatio:(LinkRatio)linkRatio {
    _linkRatio = linkRatio;
    
    switch (linkRatio) {
        case DayLinkRatio:
            _rationTitleLabel.text = @"日环比";
            break;
            
        case WeekLinkRatio:
            _rationTitleLabel.text = @"周环比";
            break;
            
        case MonthLinkRatio:
            _rationTitleLabel.text = @"月环比";
            break;
            
        default:
            break;
    }
}

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
    NSMutableArray *formatXRollerData = @[].mutableCopy;
    [xRollerData enumerateObjectsUsingBlock:^(NSString *dateStr, NSUInteger idx, BOOL * _Nonnull stop) {
        // 格式化时间为yyyy-MM-dd
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [dateFormat dateFromString:dateStr];
        
        NSDateFormatter *newDateFormat = [[NSDateFormatter alloc] init];
        [newDateFormat setDateFormat:@"MM-dd"];
        NSString *newStatDate = [newDateFormat stringFromDate:date];
        
        [formatXRollerData addObject:newStatDate];
    }];
    
    _xRollerData = formatXRollerData;
    
    if(_postData != nil && _snapData != nil){
        [self refreshChart];
    }
}

- (void)setSnapData:(NSArray *)snapData {
    _snapData = snapData;
    
    if(_postData != nil && _xRollerData != nil){
        [self refreshChart];
    }
}

- (void)setPostData:(NSArray *)postData {
    _postData = postData;
    
    if(_xRollerData != nil && _snapData != nil){
        [self refreshChart];
    }
}

#pragma mark 刷新统计图表
- (void)refreshChart {
    
    if(_xRollerData.count > 7){
        // 大于7列 滑动
        CGFloat snapChartWidth = 60 + PageLineWidth*_xRollerData.count;
        _chartScrollView.contentSize = CGSizeMake(snapChartWidth, 0);
        [_chartScrollView setContentOffset:CGPointMake(_chartScrollView.contentSize.width - KScreenWidth, 0) animated:YES];
        
        [self.mixChartView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.mixChartView removeFromSuperview];
        self.mixChartView = nil;
        
        self.mixChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, snapChartWidth, 275)];
        self.mixChartView.contentHeight = 255;
        self.mixChartView.userInteractionEnabled = YES;
        self.mixChartView.isClearBackgroundColor = YES;
        self.mixChartView.backgroundColor = [UIColor clearColor];
        [_chartScrollView addSubview:self.mixChartView];
        
    }else {
        _chartScrollView.contentSize = CGSizeMake(0, 0);
        
        [self.mixChartView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.mixChartView removeFromSuperview];
        self.mixChartView = nil;
        
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
                 .nameSet(@"访问人数")
                 .dataSet(_postData),
                 
                 AAObject(AASeriesElement)
                 .typeSet(AAChartTypeLine)
                 .nameSet(@"平均访问时长")
                 .dataSet(_snapData),
                 ]
               )
    ;
    
    self.mixChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.mixChartModel.symbol = AAChartSymbolTypeCircle;
    self.mixChartModel.colorsTheme = @[@"#00FF3C", @"#FFC921"];
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
    CGFloat postWidth = (xRallerWidth - 60)/_xRollerData.count;
    for (int i=0; i<_xRollerData.count; i++) {
        if((gesturePoint.x + xOffset) >= (postWidth*i + 40) &&
           (gesturePoint.x + xOffset) <= (postWidth*(i+1) + 40)){
            //            NSLog(@"点击了第%d行柱", i+1);
            if(_filterDelegate && [_filterDelegate respondsToSelector:@selector(didSelectChartLineIndex:)]){
                [_filterDelegate didSelectChartLineIndex:i];
            }
            break;
        }
    }
}

@end
