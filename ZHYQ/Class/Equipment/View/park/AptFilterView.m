//
//  AptFilterView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/6/15.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "AptFilterView.h"
#import "WSDatePickerView.h"

#import "InputKeyBoardView.h"
#import "NumInputView.h"
#import "UITextField+Position.h"

@implementation AptFilterView
{
    UITextField *_carNoTF;
    
    UILabel *beginTimeLabel;
    UILabel *endTimeLabel;
    
    InputKeyBoardView *_keyBoardView;
    NumInputView *_numInputView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _initView];
        
        [self _initKeyBoradInput];
    }
    return self;
}

- (void)_initView {
    self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
    
    UILabel *carNoLabel = [[UILabel alloc] init];
    carNoLabel.frame = CGRectMake(18, 21, 70, 17);
    carNoLabel.text = @"车牌号：";
    carNoLabel.textColor = [UIColor blackColor];
    [self addSubview:carNoLabel];
    
    _carNoTF = [[UITextField alloc] initWithFrame:CGRectMake(carNoLabel.right + 10, carNoLabel.top - 9, 200, 40)];
    _carNoTF.borderStyle = UITextBorderStyleNone;
    _carNoTF.placeholder = @"请输入车牌号";
    [self addSubview:_carNoTF];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, carNoLabel.bottom + 19, KScreenWidth, 1)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#E2E2E2"];
    [self addSubview:lineView];
    
    UILabel *beginLabel = [[UILabel alloc] init];
    beginLabel.frame = CGRectMake(18, lineView.bottom + 20, 70, 17);
    beginLabel.text = @"开始时间";
    beginLabel.textColor = [UIColor blackColor];
    [self addSubview:beginLabel];
    
    UILabel *endLabel = [[UILabel alloc] init];
    endLabel.frame = CGRectMake(beginLabel.right + 133, beginLabel.top, 70, 17);
    endLabel.text = @"结束时间";
    endLabel.textColor = [UIColor blackColor];
    [self addSubview:endLabel];
    
    // 格式化时间
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *beginTime = [dateFormat stringFromDate:[self formatMonthDate]];
    NSString *endTime = [dateFormat stringFromDate:[NSDate date]];
    
    // 开始时间
    beginTimeLabel = [[UILabel alloc] init];
    beginTimeLabel.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    beginTimeLabel.frame = CGRectMake(18, beginLabel.bottom + 20, 115, 30);
    beginTimeLabel.text = beginTime;
    beginTimeLabel.font = [UIFont systemFontOfSize:17];
    beginTimeLabel.textAlignment = NSTextAlignmentCenter;
    beginTimeLabel.textColor = [UIColor whiteColor];
    [self addSubview:beginTimeLabel];
    
    UITapGestureRecognizer *beginTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beginTimeAction)];
    beginTimeLabel.userInteractionEnabled = YES;
    [beginTimeLabel addGestureRecognizer:beginTap];
    
    UIButton *beginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    beginButton.frame = CGRectMake(beginTimeLabel.right + 11, beginTimeLabel.top + 4, 20, 20);
    [beginButton setBackgroundImage:[UIImage imageNamed:@"calendar_icon"] forState:UIControlStateNormal];
    [beginButton addTarget:self action:@selector(beginTimeAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:beginButton];
    
    // 结束时间
    endTimeLabel = [[UILabel alloc] init];
    endTimeLabel.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    endTimeLabel.frame = CGRectMake(endLabel.left, endLabel.bottom + 20, 115, 30);
    endTimeLabel.text = endTime;
    endTimeLabel.font = [UIFont systemFontOfSize:17];
    endTimeLabel.textAlignment = NSTextAlignmentCenter;
    endTimeLabel.textColor = [UIColor whiteColor];
    [self addSubview:endTimeLabel];
    
    UITapGestureRecognizer *endTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endTimeAction)];
    endTimeLabel.userInteractionEnabled = YES;
    [endTimeLabel addGestureRecognizer:endTap];
    
    UIButton *endButton = [UIButton buttonWithType:UIButtonTypeCustom];
    endButton.frame = CGRectMake(endTimeLabel.right + 11, endTimeLabel.top + 4, 20, 20);
    [endButton setBackgroundImage:[UIImage imageNamed:@"calendar_icon"] forState:UIControlStateNormal];
    [endButton addTarget:self action:@selector(endTimeAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:endButton];
    
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, endTimeLabel.bottom + 18, KScreenWidth, 1)];
    bottomLineView.backgroundColor = [UIColor colorWithHexString:@"#E2E2E2"];
    [self addSubview:bottomLineView];
    
    // 下方按钮
    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    resetButton.frame = CGRectMake(0, bottomLineView.bottom + 9, KScreenWidth/2, 60);
    resetButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [resetButton setTitle:@"重置" forState:UIControlStateNormal];
    [resetButton setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
    [resetButton setBackgroundImage:[UIImage imageNamed:@"apt_filter_bt_bg"] forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(resetAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:resetButton];
    
    UIButton *certainButton = [UIButton buttonWithType:UIButtonTypeCustom];
    certainButton.frame = CGRectMake(KScreenWidth/2, bottomLineView.bottom + 9, KScreenWidth/2, 60);
    certainButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [certainButton setTitle:@"确定" forState:UIControlStateNormal];
    [certainButton setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
    [certainButton setBackgroundImage:[UIImage imageNamed:@"apt_filter_bt_bg"] forState:UIControlStateNormal];
    [certainButton addTarget:self action:@selector(certainAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:certainButton];
    
    // 背景view
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, certainButton.bottom + 8)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self insertSubview:bgView atIndex:0];
}

#pragma mark 初始化车牌键盘
- (void)_initKeyBoradInput {
    // 设置自定义键盘
    int verticalCount = 5;
    CGFloat kheight = KScreenWidth/10 + 8;
    _keyBoardView = [[InputKeyBoardView alloc] initWithFrame:CGRectMake(0, KScreenHeight - kheight * verticalCount, KScreenWidth, kheight * verticalCount) withClickKeyBoard:^(NSString *character) {
        
        NSString *textStr = [_carNoTF.text stringByAppendingString:character];
        if(textStr.length <= 8){
            [self judgementKeyBorad:textStr];
            [_carNoTF positionAddCharacter:character];
        }
        
        
    } withDelete:^{
        if(_carNoTF.text.length > 0){
            [_carNoTF positionDelete];
            [self judgementKeyBorad:_carNoTF.text];
        }
    } withConfirm:^{
        [self endEditing:YES];
    } withCut:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            _carNoTF.inputView = _numInputView;
            [_carNoTF reloadInputViews];
        });
    }];
    [_keyBoardView setNeedsDisplay];
    _carNoTF.inputView = _keyBoardView;
    
    _numInputView = [[NumInputView alloc] initWithFrame:CGRectMake(0, KScreenHeight - kheight * verticalCount, KScreenWidth, kheight * verticalCount) withClickKeyBoard:^(NSString *character) {
        
        NSString *textStr = [_carNoTF.text stringByAppendingString:character];
        if(textStr.length <= 8){
            [self judgementKeyBorad:textStr];
            [_carNoTF positionAddCharacter:character];
            //            if(textStr.length == 7){
            //                [self searchClicked];
            //            }
        }
        
    } withDelete:^{
        // 依次删除
        if(_carNoTF.text.length > 0){
            [_carNoTF positionDelete];
            [self judgementKeyBorad:_carNoTF.text];
        }
    } withConfirm:^{
        [self endEditing:YES];
    }withCut:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            _carNoTF.inputView = _keyBoardView;
            [_carNoTF reloadInputViews];
        });
    }];
    [_numInputView setNeedsDisplay];
    
}
- (void)judgementKeyBorad:(NSString *)textStr {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(textStr.length > 0){
            _carNoTF.inputView = _numInputView;
            [_carNoTF reloadInputViews];
        }else{
            _carNoTF.inputView = _keyBoardView;
            [_carNoTF reloadInputViews];
        }
    });
}

#pragma mark 开始时间选择
- (void)beginTimeAction {
    [self endEditing:YES];
    WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDay scrollToDate:[self formatMonthDate] CompleteBlock:^(NSDate *selectDate) {
        NSString *date = [selectDate stringWithFormat:@"yyyy-MM-dd"];
        beginTimeLabel.text = date;
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
    _carNoTF.text = nil;
    // 发送重置通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AppointMentParkResSet" object:nil userInfo:nil];
}

#pragma mark 确定
- (void)certainAction {
    [self endEditing:YES];
    // 发送确定完成通知
    //确定点击
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
    NSString *inputStartStr = [inputFormat stringFromDate:showStartDate];
    NSString *inputEndStr = [inputFormat stringFromDate:[self getNDay:1 withDate:showEndDate]];   // 选中结束时间的后一天，查询选中的整天
    
    // 发送筛选通知
    NSMutableDictionary *filterDic = @{}.mutableCopy;
    if(_carNoTF.text){
        [filterDic setObject:_carNoTF.text forKey:@"carNo"];
    }
    [filterDic setObject:inputStartStr forKey:@"startDate"];
    [filterDic setObject:inputEndStr forKey:@"endDate"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AppointMentParkFilter" object:nil userInfo:filterDic];
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


@end
