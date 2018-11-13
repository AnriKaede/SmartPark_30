//
//  FaceFilterView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/8/30.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "FaceFilterView.h"
#import "WSDatePickerView.h"
#import "YQSlider.h"

@implementation FaceFilterView
{
    UIView *_bgView;
    UILabel *beginTimeLabel;
    UILabel *endTimeLabel;
    
    YQSlider *_similarSilder;
    
    CGFloat _sliderValue;
    NSString *_startTime;
    NSString *_endTime;
    BOOL _timeFlag;
    
    BOOL _timeFilter;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _timeFilter = NO;
        [self _initView];
    }
    return self;
}

- (void)_initView {
    self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
    self.hidden = YES;
    UITapGestureRecognizer *hidTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAction)];
    [self addGestureRecognizer:hidTap];
    
    _bgView = [[UIView alloc] initWithFrame:CGRectZero];
    [self insertSubview:_bgView atIndex:0];
    
    UILabel *stateLabel = [[UILabel alloc] init];
    stateLabel.frame = CGRectMake(18, 40, 60, 17);
    stateLabel.text = @"相似度";
    stateLabel.textColor = [UIColor blackColor];
    [_bgView addSubview:stateLabel];
    
    UILabel *minLabel = [[UILabel alloc] init];
    minLabel.frame = CGRectMake(stateLabel.right + 20, stateLabel.top, 17, 17);
    minLabel.text = @"0";
    minLabel.textColor = [UIColor blackColor];
    [_bgView addSubview:minLabel];
    
    // 相似度滑块
    UIImage *thumbImage = [UIImage imageNamed:@"Slider"];
    _similarSilder = [[YQSlider alloc] initWithFrame:CGRectMake(minLabel.right + 8, stateLabel.top + 4, KScreenWidth - minLabel.right - 68, 10)];
    _similarSilder.backgroundColor = [UIColor clearColor];
    _similarSilder.minimumTrackTintColor = [UIColor colorWithHexString:@"0068B8"];
    _similarSilder.unitStr = @"%";
    _similarSilder.value=0.9;
    _similarSilder.minimumValue=0.01;
    _similarSilder.maximumValue=1.0;
    _similarSilder.minimumTrackImageName = @"_light_full_bg";
    //滑动拖动后的事件
    [_similarSilder addTarget:self action:@selector(sliderDragUp:) forControlEvents:UIControlEventTouchUpInside];
    [_similarSilder setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [_similarSilder setThumbImage:thumbImage forState:UIControlStateNormal];
    [_bgView addSubview:_similarSilder];
    
    UILabel *maxLabel = [[UILabel alloc] init];
    maxLabel.frame = CGRectMake(_similarSilder.right + 8, minLabel.top, 50, 17);
    maxLabel.text = @"100";
    maxLabel.textColor = [UIColor blackColor];
    [_bgView addSubview:maxLabel];
    
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, stateLabel.bottom + 15, KScreenWidth, 1)];
    topLineView.backgroundColor = [UIColor colorWithHexString:@"#E2E2E2"];
    [_bgView addSubview:topLineView];
    
    UILabel *beginLabel = [[UILabel alloc] init];
    beginLabel.frame = CGRectMake(18, topLineView.bottom + 15, 70, 17);
    beginLabel.text = @"开始时间";
    beginLabel.textColor = [UIColor blackColor];
    [_bgView addSubview:beginLabel];
    
    UILabel *endLabel = [[UILabel alloc] init];
    endLabel.frame = CGRectMake(beginLabel.right + 133, beginLabel.top, 70, 17);
    endLabel.text = @"结束时间";
    endLabel.textColor = [UIColor blackColor];
    [_bgView addSubview:endLabel];
    
    // 格式化时间
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *beginTime = [dateFormat stringFromDate:[self formatMonthDate]];
    NSString *endTime = [dateFormat stringFromDate:[NSDate date]];
    
    // 开始时间
    beginTimeLabel = [[UILabel alloc] init];
    beginTimeLabel.backgroundColor = [UIColor colorWithHexString:@"#dedcd9"];
    beginTimeLabel.frame = CGRectMake(18, beginLabel.bottom + 20, 115, 30);
    beginTimeLabel.text = beginTime;
    beginTimeLabel.font = [UIFont systemFontOfSize:17];
    beginTimeLabel.textAlignment = NSTextAlignmentCenter;
    beginTimeLabel.textColor = [UIColor whiteColor];
    [_bgView addSubview:beginTimeLabel];
    
    UITapGestureRecognizer *beginTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beginTimeAction)];
    beginTimeLabel.userInteractionEnabled = YES;
    [beginTimeLabel addGestureRecognizer:beginTap];
    
    UIButton *beginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    beginButton.frame = CGRectMake(beginTimeLabel.right + 11, beginTimeLabel.top + 4, 20, 20);
    [beginButton setBackgroundImage:[UIImage imageNamed:@"calendar_icon"] forState:UIControlStateNormal];
    [beginButton addTarget:self action:@selector(beginTimeAction) forControlEvents:UIControlEventTouchUpInside];
    [_bgView addSubview:beginButton];
    
    // 结束时间
    endTimeLabel = [[UILabel alloc] init];
    endTimeLabel.backgroundColor = [UIColor colorWithHexString:@"#dedcd9"];
    endTimeLabel.frame = CGRectMake(endLabel.left, endLabel.bottom + 20, 115, 30);
    endTimeLabel.text = endTime;
    endTimeLabel.font = [UIFont systemFontOfSize:17];
    endTimeLabel.textAlignment = NSTextAlignmentCenter;
    endTimeLabel.textColor = [UIColor whiteColor];
    [_bgView addSubview:endTimeLabel];
    
    UITapGestureRecognizer *endTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endTimeAction)];
    endTimeLabel.userInteractionEnabled = YES;
    [endTimeLabel addGestureRecognizer:endTap];
    
    UIButton *endButton = [UIButton buttonWithType:UIButtonTypeCustom];
    endButton.frame = CGRectMake(endTimeLabel.right + 11, endTimeLabel.top + 4, 20, 20);
    [endButton setBackgroundImage:[UIImage imageNamed:@"calendar_icon"] forState:UIControlStateNormal];
    [endButton addTarget:self action:@selector(endTimeAction) forControlEvents:UIControlEventTouchUpInside];
    [_bgView addSubview:endButton];
    
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, endTimeLabel.bottom + 18, KScreenWidth, 1)];
    bottomLineView.backgroundColor = [UIColor colorWithHexString:@"#E2E2E2"];
    [_bgView addSubview:bottomLineView];
    
    // 下方按钮
    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    resetButton.frame = CGRectMake(0, bottomLineView.bottom + 9, KScreenWidth/2, 60);
    resetButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [resetButton setTitle:@"重置" forState:UIControlStateNormal];
    [resetButton setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
    [resetButton setBackgroundImage:[UIImage imageNamed:@"apt_filter_bt_bg"] forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(resetAction) forControlEvents:UIControlEventTouchUpInside];
    [_bgView addSubview:resetButton];
    
    UIButton *certainButton = [UIButton buttonWithType:UIButtonTypeCustom];
    certainButton.frame = CGRectMake(KScreenWidth/2, bottomLineView.bottom + 9, KScreenWidth/2, 60);
    certainButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [certainButton setTitle:@"确定" forState:UIControlStateNormal];
    [certainButton setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
    [certainButton setBackgroundImage:[UIImage imageNamed:@"apt_filter_bt_bg"] forState:UIControlStateNormal];
    [certainButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    [_bgView addSubview:certainButton];
    
    // 背景view
    _bgView.frame = CGRectMake(0, 0, KScreenWidth, certainButton.bottom + 8);
    //    _bgView.hidden = YES;
    _bgView.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTap)];
    [_bgView addGestureRecognizer:tap];
}
- (void)bgTap {
    
}
#pragma mark 滑动手指松开
- (void)sliderDragUp:(YQSlider *)yqSlider {
    
}
- (void)closeAction {
    self.hidden = YES;
    if(_filterTimeDelegate && [_filterTimeDelegate respondsToSelector:@selector(closeFilter)]){
        [_filterTimeDelegate closeFilter];
    }
}
- (void)setHidden:(BOOL)hidden {
    
    if(hidden){
        _bgView.frame = CGRectMake(0, 0, KScreenWidth, _bgView.height);
        [UIView animateWithDuration:0.2 animations:^{
            _bgView.frame = CGRectMake(0, -_bgView.height, KScreenWidth, _bgView.height);
        }completion:^(BOOL finished) {
            [super setHidden:hidden];
        }];
        
        // 判断筛选是否变化，变化请求接口
        if([self isChangeFilter]){
            [self filterDataAction];
        }
    }else {
        [super setHidden:hidden];
        _bgView.frame = CGRectMake(0, -_bgView.height, KScreenWidth, _bgView.height);
        [UIView animateWithDuration:0.2 animations:^{
            _bgView.frame = CGRectMake(0, 0, KScreenWidth, _bgView.height);
        }];
        
        // 记录筛选前数据
        _sliderValue = _similarSilder.value;
        _startTime = beginTimeLabel.text;
        _endTime = endTimeLabel.text;
        _timeFlag = _timeFilter;
    }
}

#pragma mark 开始时间选择
- (void)beginTimeAction {
    [self endEditing:YES];
    WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDay scrollToDate:[self formatMonthDate] CompleteBlock:^(NSDate *selectDate) {
        NSString *date = [selectDate stringWithFormat:@"yyyy-MM-dd"];
        beginTimeLabel.text = date;
        
        beginTimeLabel.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
        endTimeLabel.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
        _timeFilter = YES;
    }];
    datepicker.dateLabelColor = [UIColor colorWithHexString:@"1B82D1"];//年-月-日-时-分 颜色
    datepicker.datePickerColor = [UIColor blackColor];//滚轮日期颜色
    datepicker.doneButtonColor = [UIColor colorWithHexString:@"1B82D1"];//确定按钮的颜色
    datepicker.yearLabelColor = [UIColor clearColor];//大号年份字体颜色
    [datepicker show];
}

#pragma mark 结束时间选择
- (void)endTimeAction {
    [self endEditing:YES];
    WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDay scrollToDate:[NSDate date] CompleteBlock:^(NSDate *selectDate) {
        NSString *date = [selectDate stringWithFormat:@"yyyy-MM-dd"];
        endTimeLabel.text = date;
        
        beginTimeLabel.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
        endTimeLabel.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
        _timeFilter = YES;
    }];
    datepicker.dateLabelColor = [UIColor colorWithHexString:@"1B82D1"];//年-月-日-时-分 颜色
    datepicker.datePickerColor = [UIColor blackColor];//滚轮日期颜色
    datepicker.doneButtonColor = [UIColor colorWithHexString:@"1B82D1"];//确定按钮的颜色
    datepicker.yearLabelColor = [UIColor clearColor];//大号年份字体颜色
    [datepicker show];
}

#pragma mark 重置
- (void)resetAction {
    [self endEditing:YES];
    
    // 格式化时间
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *beginTime = [dateFormat stringFromDate:[self formatMonthDate]];
    NSString *endTime = [dateFormat stringFromDate:[NSDate date]];
    
    _similarSilder.value = 0.9;
    beginTimeLabel.text = beginTime;
    endTimeLabel.text = endTime;
    
    beginTimeLabel.backgroundColor = [UIColor colorWithHexString:@"#dedcd9"];
    endTimeLabel.backgroundColor = [UIColor colorWithHexString:@"#dedcd9"];
    _timeFilter = NO;
    
    // 重置
    if(_filterTimeDelegate && [_filterTimeDelegate respondsToSelector:@selector(resetFilter)]){
        [_filterTimeDelegate resetFilter];
    }
}

#pragma mark 确定
- (void)certainAction {
//    if([self isChangeFilter]){
//        [self filterDataAction];
//    }
//    self.hidden = YES;
}
- (void)filterDataAction {
    [self endEditing:YES];
    //确定点击
    NSString *inputStartStr;
    NSString *inputEndStr;
    
    if(_timeFilter){
        NSDateFormatter *showFormat = [[NSDateFormatter alloc] init];
        [showFormat setTimeZone:[NSTimeZone localTimeZone]];
        [showFormat setDateFormat:@"yyyy-MM-dd"];
        NSDate *showStartDate = [showFormat dateFromString:beginTimeLabel.text];
        NSDate *showEndDate = [showFormat dateFromString:endTimeLabel.text];
        
        // 结束时间不能小于开始时间
        NSComparisonResult result = [showStartDate compare:showEndDate];
        if (result == NSOrderedDescending) {
            //end比start小
            [[self viewController] showHint:@"结束时间不能小于开始时间"];
            return;
        }
        
        NSDateFormatter *inputFormat = [[NSDateFormatter alloc] init];
        [inputFormat setTimeZone:[NSTimeZone localTimeZone]];
        [inputFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        inputStartStr = [inputFormat stringFromDate:showStartDate];
        inputEndStr = [inputFormat stringFromDate:[self getNDay:1 withDate:showEndDate]];   // 选中结束时间的后一天，查询选中的整天
    }else {
        inputStartStr = @"";
        inputEndStr = @"";
    }
    
    // 筛选
    if(_filterTimeDelegate && [_filterTimeDelegate respondsToSelector:@selector(filterWithStart:withEndTime:withSimValue:)]){
        [_filterTimeDelegate filterWithStart:inputStartStr withEndTime:inputEndStr withSimValue:[NSNumber numberWithFloat:_similarSilder.value * 100]];
    }
}

// 前一个月时间
- (NSDate *)formatMonthDate {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = nil;
    comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    [adcomps setYear:0];
    [adcomps setMonth:-1];
    [adcomps setDay:0];
    NSDate *newdate = [calendar dateByAddingComponents:adcomps toDate:[NSDate date] options:0];
    
    return newdate;
}

#pragma mark 返回前n天 时间  单位天
- (NSDate *)getNDay:(NSInteger)n withDate:(NSDate *)date{
    NSDate* theDate;
    
    if(n!=0){
        NSTimeInterval  oneDay = 24*60*60*1;  //1天的长度
        theDate = [NSDate dateWithTimeInterval:oneDay*n sinceDate:date];//initWithTimeIntervalSinceNow是从现在往前后推的秒数
        
    }else{
        theDate = date;
    }
    
    return theDate;
}

- (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate

{
    
    //设置源日期时区
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    
    //设置转换后的目标日期时区
    
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    
    //得到源日期与世界标准时间的偏移量
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    
    //目标日期与本地时区的偏移量
    
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    
    //得到时间偏移量的差值
    
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    //转为现在时间
    
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    
    return destinationDateNow;
}

// 值是否变化
- (BOOL)isChangeFilter {
    if(_similarSilder.value != _sliderValue){
        return YES;
    }
    if(![_startTime isEqualToString:beginTimeLabel.text]){
        return YES;
    }
    if(![_endTime isEqualToString:endTimeLabel.text]){
        return YES;
    }
    if(_timeFlag != _timeFilter){
        return YES;
    }
    return NO;
}

@end
