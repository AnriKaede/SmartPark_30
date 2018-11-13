//
//  ParkCountNumCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/20.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ParkCountNumCell.h"
#import "AAChartView.h"
#import "ParkDateCountModel.h"
#import "HourFlowCountModel.h"

#define PageLineWidth (KScreenWidth - 65)/7
#define PostLeftWidth 65

@interface ParkCountNumCell()<UIGestureRecognizerDelegate>
{
    __weak IBOutlet UIView *_topPostView;
    
    __weak IBOutlet UILabel *_parkCountLabel;
    __weak IBOutlet UILabel *_vipLabel;
    __weak IBOutlet UILabel *_averageTimeLabel;
    __weak IBOutlet UILabel *_dayProLabel;
    __weak IBOutlet UILabel *_proTitleLabel;
    __weak IBOutlet UILabel *_tempCountLabel;
    
    UIScrollView *_chartScrollView;
    NSInteger _postNum;
}

@property (nonatomic, strong) AAChartModel *mixChartModel;
@property (nonatomic, strong) AAChartView  *mixChartView;

@end

@implementation ParkCountNumCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
//        [self _initView];
    }
    return self;
}

- (void)_initView {
    // 头部日期背景
    UIView *filterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 80)];
    filterView.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    [_topPostView addSubview:filterView];
    
    UILabel *elcLabel = [[UILabel alloc] init];
    elcLabel.frame = CGRectMake(10,13,35,17);
    elcLabel.text = @"会员";
    elcLabel.textColor = [UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:1];
    [filterView addSubview:elcLabel];
    
    UIView *elcView = [[UIView alloc] init];
    elcView.frame = CGRectMake(elcLabel.right + 7,18,25,7.5);
    elcView.backgroundColor = [UIColor colorWithHexString:@"#FFC921"];
    [filterView addSubview:elcView];
    
    UILabel *waterLabel = [[UILabel alloc] init];
    waterLabel.frame = CGRectMake(elcView.right + 18,13,35,17);
    waterLabel.text = @"临停";
    waterLabel.textColor = [UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:1];
    [filterView addSubview:waterLabel];
    
    UIView *waterView = [[UIView alloc] init];
    waterView.frame = CGRectMake(waterLabel.right + 7,18,25,7.5);
    waterView.backgroundColor = [UIColor colorWithHexString:@"#00FF3C"];
    [filterView addSubview:waterView];
    
    UILabel *parkSnapLabel = [[UILabel alloc] init];
    parkSnapLabel.frame = CGRectMake(elcLabel.left,elcLabel.bottom + 12,70,17);
    parkSnapLabel.text = @"停车时长";
    parkSnapLabel.textColor = [UIColor whiteColor];
    [filterView addSubview:parkSnapLabel];
    
    UIView *parkSnapLineView = [[UIView alloc] init];
    parkSnapLineView.frame = CGRectMake(parkSnapLabel.right + 9,elcLabel.bottom + 20,21,1);
    parkSnapLineView.backgroundColor = [UIColor whiteColor];
    [filterView addSubview:parkSnapLineView];
    
    UIView *parkSnapPointView = [[UIView alloc] init];
    parkSnapPointView.frame = CGRectMake(parkSnapLineView.left + 6,elcLabel.bottom + 16,8,8);
    parkSnapPointView.backgroundColor = [UIColor whiteColor];
    parkSnapPointView.layer.cornerRadius = 4;
    [filterView addSubview:parkSnapPointView];
    
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
    
    // 混合图背景scrollView
    _chartScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 80, KScreenWidth, 275)];
    _chartScrollView.bounces = NO;
    //    _chartScrollView.contentSize = CGSizeMake(self.view.frame.size.width*2, 0);
    [_topPostView addSubview:_chartScrollView];
    
    self.mixChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, 275)];
    self.mixChartView.contentHeight = 255;
    self.mixChartView.isClearBackgroundColor = YES;
    self.mixChartView.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    self.mixChartView.clipsToBounds = YES;
    
    self.mixChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.mixChartModel.symbol = AAChartSymbolTypeCircle;
    self.mixChartModel.colorsTheme = @[@"#FFC921", @"#00FF3C", @"#ffffff"];
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
    
    if(_filterDelegate == nil || ![_filterDelegate respondsToSelector:@selector(filterDelegate:)]){
        return;
    }
    
    switch (dateBt.tag - 100) {
        case 0:
            // 日
            [_filterDelegate filterDelegate:FilterDay];
            break;
        case 1:
            // 周
            [_filterDelegate filterDelegate:FilterWeek];
            break;
        case 2:
            // 月
            [_filterDelegate filterDelegate:FilterMonth];
            break;
            
    }
}
- (void)changeBtState:(UIButton *)dateBt {
    for (int i=0; i<3; i++) {
        UIButton *button = [_topPostView viewWithTag:100 + i];
        if(button == dateBt){
            button.backgroundColor = [UIColor colorWithHexString:@"#D1E6F6"];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else {
            button.backgroundColor = [UIColor clearColor];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
}

- (void)setSnapData:(NSArray *)snapData {
    _snapData = snapData;
    
    if(_carNumData != nil){
        [self refreshChart];
    }
}

- (void)setCarNumData:(NSArray *)carNumData {
    _carNumData = carNumData;
    
    if(_snapData != nil){
        [self refreshChart];
    }
}

- (void)refreshChart {
    NSMutableArray *timeArr = @[].mutableCopy;
    NSMutableArray *snapAry = @[].mutableCopy;
    NSMutableArray *vipCarnumAry = @[].mutableCopy;
    NSMutableArray *tempCarnumAry = @[].mutableCopy;
    [_snapData enumerateObjectsUsingBlock:^(ParkDateCountModel *parkDateCountModel, NSUInteger idx, BOOL * _Nonnull stop) {
        // x轴坐标，不为空取 snapData reportOccurHour
        NSInteger xRollerIndex = _xRollerData.count - _snapData.count;
        if(_xRollerData != nil && _xRollerData.count > (idx + xRollerIndex)){
            NSString *xRoller = _xRollerData[idx + xRollerIndex];
            [timeArr addObject:xRoller];
        }else {
            if(parkDateCountModel.reportOccurHour != nil && ![parkDateCountModel.reportOccurHour isKindOfClass:[NSNull class]]){
                [timeArr addObject:parkDateCountModel.reportOccurHour];
            }else {
                [timeArr addObject:[NSNumber numberWithUnsignedInteger:idx]];
            }
        }
        
        [snapAry addObject:[NSNumber numberWithInteger:parkDateCountModel.totalTime.floatValue/60]];
        if(_carNumData.count > idx){
            HourFlowCountModel *carnumModel = _carNumData[idx];
            [vipCarnumAry addObject:carnumModel.mouthTotalCount];
            [tempCarnumAry addObject:carnumModel.tmpTotalCount];
        }
    }];
    
    _postNum = timeArr.count;
    
    if(timeArr.count > 7){
        // 大于7列 滑动
        CGFloat snapChartWidth = PostLeftWidth + 20 + PageLineWidth*timeArr.count;
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
    .categoriesSet(timeArr)
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#ffffff")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#ffffff")    // y轴坐标值颜色
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .typeSet(AAChartTypeColumn)
                 .nameSet(@"会员")
                 .dataSet(vipCarnumAry),
                 
                 AAObject(AASeriesElement)
                 .typeSet(AAChartTypeColumn)
                 .nameSet(@"临停")
                 .dataSet(tempCarnumAry),
                 
                 AAObject(AASeriesElement)
                 .typeSet(AAChartTypeLine)
                 .nameSet(@"停车时长(小时)")
                 .dataSet(snapAry),
                 ]
               )
    ;
    
    self.mixChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.mixChartModel.symbol = AAChartSymbolTypeCircle;
    self.mixChartModel.colorsTheme = @[@"#FFC921", @"#00FF3C", @"#ffffff"];
//    [self.mixChartView aa_refreshChartWithChartModel:_mixChartModel];
    [self.mixChartView aa_drawChartWithChartModel:_mixChartModel];
}

#pragma mark 下方 天 数据统计
- (void)setDayCountModel:(ParkDayCountModel *)dayCountModel {
    _dayCountModel = dayCountModel;
    
    if(dayCountModel.flowCountModel.totalTotalCount != nil && ![dayCountModel.flowCountModel.totalTotalCount isKindOfClass:[NSNull class]]){
        _parkCountLabel.text = [NSString stringWithFormat:@"%@ 次", dayCountModel.flowCountModel.totalTotalCount];
    }
    
    if(dayCountModel.flowCountModel.mouthTotalCount != nil && ![dayCountModel.flowCountModel.mouthTotalCount isKindOfClass:[NSNull class]]){
        _vipLabel.text = [NSString stringWithFormat:@"%@ 辆", dayCountModel.flowCountModel.mouthTotalCount];
    }
    
    if(dayCountModel.flowTraceModel.totalTime != nil && ![dayCountModel.flowTraceModel.totalTime isKindOfClass:[NSNull class]] && dayCountModel.flowCountModel.totalTotalCount != nil && ![dayCountModel.flowCountModel.totalTotalCount isKindOfClass:[NSNull class]]){
        CGFloat avgTime = dayCountModel.flowTraceModel.totalTime.floatValue/dayCountModel.flowCountModel.totalTotalCount.floatValue;
        
        NSString *hour = [NSString stringWithFormat:@"%d", (int)(avgTime/60)];
        if(hour.length < 2){
            hour = [NSString stringWithFormat:@"0%@", hour];
        }
        NSString *minter = [NSString stringWithFormat:@"%d", (int)avgTime%60];
        if(minter.length < 2){
            minter = [NSString stringWithFormat:@"0%@", minter];
        }
        
        _averageTimeLabel.text = [NSString stringWithFormat:@"%@:%@:00", hour, minter];
    }
    
    
    if(dayCountModel.dodPersent != nil && ![dayCountModel.dodPersent isKindOfClass:[NSNull class]]){
        if(dayCountModel.dodPersent.integerValue > 0){
            _dayProLabel.text = [NSString stringWithFormat:@"↑%d%%", abs(dayCountModel.dodPersent.intValue)];
            _dayProLabel.textColor = [UIColor colorWithHexString:@"#ec535e"];
        }else {
            _dayProLabel.text = [NSString stringWithFormat:@"↓%d%%", abs(dayCountModel.dodPersent.intValue)];
            _dayProLabel.textColor = [UIColor colorWithHexString:@"#88d777"];
        }
    }
    
    if(dayCountModel.flowCountModel.tmpTotalCount != nil && ![dayCountModel.flowCountModel.tmpTotalCount isKindOfClass:[NSNull class]]){
        _tempCountLabel.text = [NSString stringWithFormat:@"%@", dayCountModel.flowCountModel.tmpTotalCount];
    }
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
    CGFloat postWidth = (xRallerWidth - PostLeftWidth)/_postNum;
    for (int i=0; i<_postNum; i++) {
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

- (void)setLinkRatio:(LinkRatio)linkRatio {
    _linkRatio = linkRatio;
    
    switch (linkRatio) {
        case DayLinkRatio:
            _proTitleLabel.text = @"日环比";
            break;
            
        case WeekLinkRatio:
            _proTitleLabel.text = @"周环比";
            break;
            
        case MonthLinkRatio:
            _proTitleLabel.text = @"月环比";
            break;
            
    }
}

@end
