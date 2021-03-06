//
//  LogFilterView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/8/30.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "LogFilterView.h"
#import "WSDatePickerView.h"

@implementation LogFilterView
{
    UIView *_bgView;
    UILabel *beginTimeLabel;
    UILabel *endTimeLabel;
    
    NSString *_operateMan;
    NSString *_operateKey;
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
    
    UILabel *operateLabel = [[UILabel alloc] init];
    operateLabel.frame = CGRectMake(18, 40, 60, 17);
    operateLabel.text = @"操作人";
    operateLabel.textColor = [UIColor blackColor];
    [_bgView addSubview:operateLabel];
    
    UITextField *manTF = [[UITextField alloc] initWithFrame:CGRectMake(operateLabel.right + 20, operateLabel.top - 14, KScreenWidth - operateLabel.right - 60, 45)];
    manTF.tag = 3000;
    manTF.borderStyle = UITextBorderStyleRoundedRect;
    manTF.placeholder = @"请输入操作人姓名";
    manTF.font = [UIFont systemFontOfSize:15];
    [_bgView addSubview:manTF];
    
    UILabel *operateKeyLabel = [[UILabel alloc] init];
    operateKeyLabel.frame = CGRectMake(operateLabel.left, operateLabel.bottom + 40, 60, 17);
    operateKeyLabel.text = @"关键字";
    operateKeyLabel.textColor = [UIColor blackColor];
    [_bgView addSubview:operateKeyLabel];
    
    UITextField *keyTF = [[UITextField alloc] initWithFrame:CGRectMake(operateKeyLabel.right + 20, operateKeyLabel.top - 14, manTF.width, 45)];
    keyTF.tag = 3001;
    keyTF.borderStyle = UITextBorderStyleRoundedRect;
    keyTF.placeholder = @"请输入筛选关键字";
    keyTF.font = [UIFont systemFontOfSize:15];
    [_bgView addSubview:keyTF];
    
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, keyTF.bottom + 15, KScreenWidth, 1)];
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
//    beginTimeLabel.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
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
//    endTimeLabel.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
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
        UITextField *manTF = [_bgView viewWithTag:3000];
        UITextField *keyTF = [_bgView viewWithTag:3001];
        
        _operateMan = manTF.text;
        _operateKey = keyTF.text;
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
    
    UITextField *manTF = [_bgView viewWithTag:3000];
    UITextField *keyTF = [_bgView viewWithTag:3001];
    
    manTF.text = @"";
    keyTF.text = @"";
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
    self.hidden = YES;
    if([self isChangeFilter]){
        [self filterDataAction];
    }
}
- (void)filterDataAction {
    [self endEditing:YES];
    // 发送确定完成通知
    
    NSString *inputStartStr;
    NSString *inputEndStr;
    
    //确定点击
    if(_timeFilter){
        // 带时间筛选
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
        [inputFormat setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        inputStartStr = [inputFormat stringFromDate:showStartDate];
        inputEndStr = [inputFormat stringFromDate:[self getNDay:1 withDate:showEndDate]];   // 选中结束时间的后一天，查询选中的整天
    }else {
        inputStartStr = @"";
        inputEndStr = @"";
    }
    
    
    UITextField *manTF = [_bgView viewWithTag:3000];
    UITextField *keyTF = [_bgView viewWithTag:3001];
    
    // 筛选
    if(_filterTimeDelegate && [_filterTimeDelegate respondsToSelector:@selector(filterWithStart:withEndTime:withOperateMan:withOperateKey:)]){
        [_filterTimeDelegate filterWithStart:inputStartStr withEndTime:inputEndStr withOperateMan:manTF.text withOperateKey:keyTF.text];
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
    UITextField *manTF = [_bgView viewWithTag:3000];
    UITextField *keyTF = [_bgView viewWithTag:3001];
    
    if(![_operateMan isEqualToString:manTF.text]){
        return YES;
    }
    if(![_operateKey isEqualToString:keyTF.text]){
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
