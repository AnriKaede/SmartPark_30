//
//  ParkFilterViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/29.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "ParkFilterViewController.h"
#import "WSDatePickerView.h"

@interface ParkFilterViewController ()
{
    __weak IBOutlet UILabel *_beginLabel;
    
    __weak IBOutlet UILabel *_endLabel;
    
}
@end

@implementation ParkFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
}

- (void)_initView {
    UITapGestureRecognizer *startTimeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beginAction:)];
    _beginLabel.userInteractionEnabled = YES;
    [_beginLabel addGestureRecognizer:startTimeTap];
    
    UITapGestureRecognizer *endTimeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endAction:)];
    _endLabel.userInteractionEnabled = YES;
    [_endLabel addGestureRecognizer:endTimeTap];
    
    NSDateFormatter *nowDateFormat = [[NSDateFormatter alloc] init];
    [nowDateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [nowDateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *startTimeStr = [nowDateFormat stringFromDate:[self formatMonthDate]];   // 默认前一个月
    NSString *endTimeStr = [nowDateFormat stringFromDate:[NSDate date]];
    _beginLabel.text = startTimeStr;
    _endLabel.text = endTimeStr;
    
    [self setUpBottomButton];
}

- (IBAction)beginAction:(id)sender {
    WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDayHourMinute scrollToDate:[self formatMonthDate] CompleteBlock:^(NSDate *selectDate) {
        NSString *date = [selectDate stringWithFormat:@"yyyy-MM-dd HH:mm"];
        _beginLabel.text = date;
        
    }];
    datepicker.dateLabelColor = [UIColor colorWithHexString:@"1B82D1"];//年-月-日-时-分 颜色
    datepicker.datePickerColor = [UIColor blackColor];//滚轮日期颜色
    datepicker.doneButtonColor = [UIColor colorWithHexString:@"1B82D1"];//确定按钮的颜色
    datepicker.yearLabelColor = [UIColor clearColor];//大号年份字体颜色
    [datepicker show];
}

- (IBAction)endAction:(id)sender {
    WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDayHourMinute scrollToDate:[NSDate date] CompleteBlock:^(NSDate *selectDate) {
        NSString *date = [selectDate stringWithFormat:@"yyyy-MM-dd HH:mm"];
        _endLabel.text = date;
        
    }];
    datepicker.dateLabelColor = [UIColor colorWithHexString:@"1B82D1"];//年-月-日-时-分 颜色
    datepicker.datePickerColor = [UIColor blackColor];//滚轮日期颜色
    datepicker.doneButtonColor = [UIColor colorWithHexString:@"1B82D1"];//确定按钮的颜色
    datepicker.yearLabelColor = [UIColor clearColor];//大号年份字体颜色
    [datepicker show];
}

#pragma mark - 底部重置确定按钮
- (void)setUpBottomButton
{
    CGFloat buttonW = KScreenWidth*0.8/2;
    CGFloat buttonH = 50;
    CGFloat buttonY = KScreenHeight - buttonH;
    NSArray *titles = @[@"重置",@"确定"];
    for (NSInteger i = 0; i < titles.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        button.tag = i;
        [button setTitleColor:(i == 0) ? [UIColor whiteColor] : [UIColor colorWithHexString:@"CCFF00"] forState:UIControlStateNormal];
        CGFloat buttonX = i*buttonW;
        button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        button.titleLabel.font = PFR16Font;
        button.backgroundColor = (i == 0) ? [UIColor colorWithPatternImage:[UIImage imageNamed:@"reset_btn_bg"]] : [UIColor colorWithHexString:@"1B82D1"];
        [button addTarget:self action:@selector(bottomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:button];
    }
}

#pragma mark - 点击事件
- (void)bottomButtonClick:(UIButton *)button
{
    if (button.tag == 0) {//重置点击
        
        // 重置
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ParkRecordResSet" object:nil userInfo:nil];
    }else if (button.tag == 1){
        //确定点击
        NSDateFormatter *showFormat = [[NSDateFormatter alloc] init];
        [showFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [showFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSDate *showStartDate = [showFormat dateFromString:_beginLabel.text];
        NSDate *showEndDate = [showFormat dateFromString:_endLabel.text];
        
        // 结束时间不能小于开始时间
        NSComparisonResult result = [showStartDate compare:showEndDate];
        if (result == NSOrderedDescending) {
            //end比start小
            [self showHint:@"结束时间不能小于开始时间"];
            return;
        }
        
        NSDateFormatter *inputFormat = [[NSDateFormatter alloc] init];
        [inputFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [inputFormat setDateFormat:@"yyyyMMddHHmm"];
        NSString *inputStartStr = [inputFormat stringFromDate:showStartDate];
        NSString *inputEndStr = [inputFormat stringFromDate:showEndDate];
        
        // 发送筛选通知
        NSMutableDictionary *filterDic = @{}.mutableCopy;
        [filterDic setObject:inputStartStr forKey:@"startDate"];
        [filterDic setObject:inputEndStr forKey:@"endDate"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ParkRecordFilter" object:nil userInfo:filterDic];
    }
    
    !_sureClickBlock ? : _sureClickBlock(@[]);
}

#pragma mark 返回前n天 时间  单位天
- (NSDate *)getNDay:(NSInteger)n{
    NSDate*nowDate = [NSDate date];
    NSDate* theDate;
    
    if(n!=0){
        NSTimeInterval  oneDay = 24*60*60*1;  //1天的长度
        theDate = [nowDate initWithTimeIntervalSinceNow: -oneDay*n ];//initWithTimeIntervalSinceNow是从现在往前后推的秒数
        
    }else{
        theDate = nowDate;
    }
    
    return theDate;
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


@end
