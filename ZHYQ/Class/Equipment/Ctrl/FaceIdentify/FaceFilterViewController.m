//
//  FaceFilterViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/3/28.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "FaceFilterViewController.h"
#import "WSDatePickerView.h"

#import "YQSlider.h"

@interface FaceFilterViewController ()
{
    __weak IBOutlet UILabel *_startTimeLabel;
    // 添加日历选择
    __weak IBOutlet UIButton *_startTimeBt;
    
    __weak IBOutlet UILabel *_endTimeLabel;
    __weak IBOutlet UIButton *_endTimeBt;
    
    __weak IBOutlet YQSlider *_similarSilder;
    
}
@end

@implementation FaceFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
    
    [self setUpBottomButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(faceFilter:) name:@"FaceFilterParam" object:nil];
}

- (void)_initView {
    UITapGestureRecognizer *endEditTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditAction)];
    [self.view addGestureRecognizer:endEditTap];
    
    UITapGestureRecognizer *startTimeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startTimeAction:)];
    _startTimeLabel.userInteractionEnabled = YES;
    [_startTimeLabel addGestureRecognizer:startTimeTap];
    
    UITapGestureRecognizer *endTimeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endTimeAction:)];
    _endTimeLabel.userInteractionEnabled = YES;
    [_endTimeLabel addGestureRecognizer:endTimeTap];
    
    NSDateFormatter *nowDateFormat = [[NSDateFormatter alloc] init];
    [nowDateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [nowDateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *timeStr = [nowDateFormat stringFromDate:[NSDate date]];
    _startTimeLabel.text = timeStr;
    _endTimeLabel.text = timeStr;

//    UIImage *stetchLeftTrack= [UIImage imageNamed:@"scene_edit_height_reduce"];
//    UIImage *stetchRightTrack = [UIImage imageNamed:@"scene_edit_height_add"];
    //滑块图片
    UIImage *thumbImage = [UIImage imageNamed:@"Slider"];
    _similarSilder.backgroundColor = [UIColor clearColor];
    _similarSilder.minimumTrackTintColor = [UIColor colorWithHexString:@"0068B8"];
    _similarSilder.unitStr = @"%";
    _similarSilder.value=0.9;
    _similarSilder.minimumValue=0.01;
    _similarSilder.maximumValue=1.0;
//    _similarSilder.minimumValueImage = stetchLeftTrack;
//    _similarSilder.maximumValueImage = stetchRightTrack;
    _similarSilder.minimumTrackImageName = @"_light_full_bg";
    //滑动拖动后的事件
    [_similarSilder addTarget:self action:@selector(sliderDragUp:) forControlEvents:UIControlEventTouchUpInside];
    [_similarSilder setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [_similarSilder setThumbImage:thumbImage forState:UIControlStateNormal];
}

- (void)faceFilter:(NSNotification *)notification {
    NSDictionary *param = notification.userInfo;
    NSString *beginTime = param[@"startTime"];
    NSString *endTime = param[@"endTime"];
    NSNumber *sliderValue = param[@"threshold"];
    
    NSDateFormatter *nowDateFormat = [[NSDateFormatter alloc] init];
    [nowDateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [nowDateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *startDate = [nowDateFormat dateFromString:beginTime];
    NSDate *endDate = [nowDateFormat dateFromString:endTime];
    
    NSDateFormatter *filterDateFormat = [[NSDateFormatter alloc] init];
    [filterDateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [filterDateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *startDateFilter = [filterDateFormat dateFromString:beginTime];
    NSDate *endDateFilter = [filterDateFormat dateFromString:endTime];
    
    NSDateFormatter *showDateFormat = [[NSDateFormatter alloc] init];
    [showDateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [showDateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSString *beginTimeFormat;
    NSString *endTimeFormat;
    
    if(startDate != nil && endDate != nil){
        beginTimeFormat = [showDateFormat stringFromDate:startDate];
        endTimeFormat = [showDateFormat stringFromDate:endDate];
    }else if(startDateFilter != nil && endDateFilter != nil) {
        beginTimeFormat = [showDateFormat stringFromDate:startDateFilter];
        endTimeFormat = [showDateFormat stringFromDate:endDateFilter];
    }
    
    _startTimeLabel.text = beginTimeFormat;
    _endTimeLabel.text = endTimeFormat;
    
    _similarSilder.value = sliderValue.floatValue/100;
}

#pragma mark 滑动手指松开
- (void)sliderDragUp:(YQSlider *)yqSlider {
    
}

- (void)endEditAction {
    [self.view endEditing:YES];
}

- (IBAction)startTimeAction:(id)sender {
    [self.view endEditing:YES];
    WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDayHourMinute scrollToDate:[NSDate date] CompleteBlock:^(NSDate *selectDate) {
        NSString *date = [selectDate stringWithFormat:@"yyyy-MM-dd HH:mm"];
        _startTimeLabel.text = date;
        
    }];
    datepicker.dateLabelColor = [UIColor colorWithHexString:@"1B82D1"];//年-月-日-时-分 颜色
    datepicker.datePickerColor = [UIColor blackColor];//滚轮日期颜色
    datepicker.doneButtonColor = [UIColor colorWithHexString:@"1B82D1"];//确定按钮的颜色
    datepicker.yearLabelColor = [UIColor clearColor];//大号年份字体颜色
    datepicker.maxLimitDate = [NSDate date];
    [datepicker show];
}
- (IBAction)endTimeAction:(id)sender {
    [self.view endEditing:YES];
    WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDayHourMinute scrollToDate:[NSDate date] CompleteBlock:^(NSDate *selectDate) {
        NSString *date = [selectDate stringWithFormat:@"yyyy-MM-dd HH:mm"];
        _endTimeLabel.text = date;
        
    }];
    datepicker.dateLabelColor = [UIColor colorWithHexString:@"1B82D1"];//年-月-日-时-分 颜色
    datepicker.datePickerColor = [UIColor blackColor];//滚轮日期颜色
    datepicker.doneButtonColor = [UIColor colorWithHexString:@"1B82D1"];//确定按钮的颜色
    datepicker.yearLabelColor = [UIColor clearColor];//大号年份字体颜色
    datepicker.maxLimitDate = [NSDate date];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FaceSimilarResSet" object:nil userInfo:nil];
    }else if (button.tag == 1){
        //确定点击
        NSDateFormatter *showFormat = [[NSDateFormatter alloc] init];
        [showFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [showFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSDate *showStartDate = [showFormat dateFromString:_startTimeLabel.text];
        NSDate *showEndDate = [showFormat dateFromString:_endTimeLabel.text];
        
        // 结束时间不能小于开始时间
        NSComparisonResult result = [showStartDate compare:showEndDate];
        if (result == NSOrderedDescending) {
            //end比start小
            [self showHint:@"结束时间不能小于开始时间"];
            return;
        }
        
        NSDateFormatter *inputFormat = [[NSDateFormatter alloc] init];
        [inputFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [inputFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *inputStartStr = [inputFormat stringFromDate:showStartDate];
        NSString *inputEndStr = [inputFormat stringFromDate:showEndDate];
        
        // 发送筛选通知
        NSMutableDictionary *filterDic = @{}.mutableCopy;
        [filterDic setObject:inputStartStr forKey:@"startTime"];
        [filterDic setObject:inputEndStr forKey:@"endTime"];
        // 添加相似度
        [filterDic setObject:[NSNumber numberWithFloat:_similarSilder.value * 100] forKey:@"threshold"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FaceSimilarFilter" object:nil userInfo:filterDic];
    }
    
    !_sureClickBlock ? : _sureClickBlock(@[]);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FaceFilterParam" object:nil];
}

@end
