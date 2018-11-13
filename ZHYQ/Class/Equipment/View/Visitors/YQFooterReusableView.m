//
//  YQFooterReusableView.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/18.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "YQFooterReusableView.h"
#import "WSDatePickerView.h"

@interface YQFooterReusableView ()

@end

@implementation YQFooterReusableView

-(UILabel *)arriveTimeLab
{
    if (_arriveTimeLab == nil) {
        _arriveTimeLab = [[UILabel alloc] init];
        _arriveTimeLab.text = @"到访时间";
        _arriveTimeLab.font = PFR15Font;
        _arriveTimeLab.textAlignment = NSTextAlignmentLeft;
        _arriveTimeLab.textColor = [UIColor blackColor];
        _arriveTimeLab.backgroundColor = [UIColor clearColor];
    }
    return _arriveTimeLab;
}

-(UILabel *)arriveTimeDetailLab
{
    if (_arriveTimeDetailLab == nil) {
        _arriveTimeDetailLab = [[UILabel alloc] init];
        _arriveTimeDetailLab.text = @"-";
        _arriveTimeDetailLab.font = [UIFont systemFontOfSize:15];
        _arriveTimeDetailLab.textAlignment = NSTextAlignmentCenter;
        _arriveTimeDetailLab.textColor = [UIColor whiteColor];
        _arriveTimeDetailLab.backgroundColor = [UIColor colorWithHexString:@"1B82D1"];
        
        UITapGestureRecognizer *beginTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseArriveTimeBtnClick:)];
        _arriveTimeDetailLab.userInteractionEnabled = YES;
        [_arriveTimeDetailLab addGestureRecognizer:beginTap];
    }
    return _arriveTimeDetailLab;
}

-(UIButton *)chooseArriveTimeBtn
{
    if (_chooseArriveTimeBtn == nil) {
        _chooseArriveTimeBtn = [[UIButton alloc] init];
        [_chooseArriveTimeBtn addTarget:self action:@selector(chooseArriveTimeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_chooseArriveTimeBtn setImage:[UIImage imageNamed:@"calendar_icon"] forState:UIControlStateNormal];
    }
    return _chooseArriveTimeBtn;
}

-(UIButton *)arriveAmBtn
{
    if (_arriveAmBtn == nil) {
        _arriveAmBtn = [[UIButton alloc] init];
        _arriveAmBtn.hidden = YES;
        [_arriveAmBtn addTarget:self action:@selector(arriveAmBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_arriveAmBtn setTitle:@"上午" forState:UIControlStateNormal];
        _arriveAmBtn.titleLabel.font = PFR12Font;
        [_arriveAmBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_arriveAmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_arriveAmBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"F3F3F3"]] forState:UIControlStateNormal];
        [_arriveAmBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"1B82D1"]] forState:UIControlStateSelected];
        _arriveAmBtn.selected = YES;
    }
    return _arriveAmBtn;
}

-(UIButton *)arrivePmBtn
{
    if (_arrivePmBtn == nil) {
        _arrivePmBtn = [[UIButton alloc] init];
        _arrivePmBtn.hidden = YES;
        [_arrivePmBtn addTarget:self action:@selector(arrivePmBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_arrivePmBtn setTitle:@"下午" forState:UIControlStateNormal];
        [_arrivePmBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_arrivePmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_arrivePmBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"F3F3F3"]] forState:UIControlStateNormal];
        [_arrivePmBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"1B82D1"]] forState:UIControlStateSelected];
        _arrivePmBtn.titleLabel.font = PFR12Font;
        _arrivePmBtn.selected = NO;
    }
    return _arrivePmBtn;
}

-(UILabel *)leaveTimeLab
{
    if (_leaveTimeLab == nil) {
        _leaveTimeLab = [[UILabel alloc] init];
        _leaveTimeLab.text = @"离开时间";
        _leaveTimeLab.font = PFR15Font;
        _leaveTimeLab.textAlignment = NSTextAlignmentLeft;
        _leaveTimeLab.textColor = [UIColor blackColor];
        _leaveTimeLab.backgroundColor = [UIColor clearColor];
    }
    return _leaveTimeLab;
}

-(UILabel *)leaveTimeDetailLab
{
    if (_leaveTimeDetailLab == nil) {
        _leaveTimeDetailLab = [[UILabel alloc] init];
        _leaveTimeDetailLab.text = @"-";
        _leaveTimeDetailLab.font = [UIFont systemFontOfSize:15];
        _leaveTimeDetailLab.textAlignment = NSTextAlignmentCenter;
        _leaveTimeDetailLab.textColor = [UIColor whiteColor];
        _leaveTimeDetailLab.backgroundColor = [UIColor colorWithHexString:@"1B82D1"];
        
        UITapGestureRecognizer *leaveTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseLeaveTimeBtnClick:)];
        _leaveTimeDetailLab.userInteractionEnabled = YES;
        [_leaveTimeDetailLab addGestureRecognizer:leaveTap];
    }
    return _leaveTimeDetailLab;
}

-(UIButton *)chooseLeaveTimeBtn
{
    if (_chooseLeaveTimeBtn == nil) {
        _chooseLeaveTimeBtn = [[UIButton alloc] init];
        [_chooseLeaveTimeBtn addTarget:self action:@selector(chooseLeaveTimeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_chooseLeaveTimeBtn setImage:[UIImage imageNamed:@"calendar_icon"] forState:UIControlStateNormal];
    }
    return _chooseLeaveTimeBtn;
}

-(UIButton *)leaveAmBtn
{
    if (_leaveAmBtn == nil) {
        _leaveAmBtn = [[UIButton alloc] init];
        _leaveAmBtn.hidden = YES;
        [_leaveAmBtn addTarget:self action:@selector(leaveAmBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_leaveAmBtn setTitle:@"上午" forState:UIControlStateNormal];
        _leaveAmBtn.titleLabel.font = PFR12Font;
        [_leaveAmBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_leaveAmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_leaveAmBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"F3F3F3"]] forState:UIControlStateNormal];
        [_leaveAmBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"1B82D1"]] forState:UIControlStateSelected];
        _leaveAmBtn.selected = YES;
    }
    return _leaveAmBtn;
}

-(UIButton *)leavePmBtn
{
    if (_leavePmBtn == nil) {
        _leavePmBtn = [[UIButton alloc] init];
        _leavePmBtn.hidden = YES;
        [_leavePmBtn addTarget:self action:@selector(leavePmBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_leavePmBtn setTitle:@"下午" forState:UIControlStateNormal];
        [_leavePmBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_leavePmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_leavePmBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"F3F3F3"]] forState:UIControlStateNormal];
        [_leavePmBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"1B82D1"]] forState:UIControlStateSelected];
        _leavePmBtn.titleLabel.font = PFR12Font;
        _leavePmBtn.selected = NO;
    }
    return _leavePmBtn;
}


#pragma mark - Intial
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self _initView];
    }
    return self;
}

#pragma mark - Setter Getter Methods
-(void)_initView
{
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.arriveTimeLab];
    _arriveTimeLab.frame = CGRectMake(0, 20, 110, 30);
    
    [self addSubview:self.arriveTimeDetailLab];
    _arriveTimeDetailLab.frame = CGRectMake(0, CGRectGetMaxY(_arriveTimeLab.frame) + 15, 150, 25);
    
    [self addSubview:self.chooseArriveTimeBtn];
    _chooseArriveTimeBtn.frame = CGRectMake(CGRectGetMaxX(_arriveTimeDetailLab.frame) + 8, _arriveTimeDetailLab.y+2.5, 20, 20);
    
    [self addSubview:self.arriveAmBtn];
    _arriveAmBtn.frame = CGRectMake(CGRectGetMaxX(_chooseArriveTimeBtn.frame) + 8, _arriveTimeDetailLab.y, 50, 25);
    
    [self addSubview:self.arrivePmBtn];
    _arrivePmBtn.frame = CGRectMake(CGRectGetMaxX(_arriveAmBtn.frame) + 8, _arriveTimeDetailLab.y, 50, 25);
    
    
    
    [self addSubview:self.leaveTimeLab];
    _leaveTimeLab.frame = CGRectMake(0, CGRectGetMaxY(_arriveTimeDetailLab.frame) + 20, 110, 30);
    
    [self addSubview:self.leaveTimeDetailLab];
    _leaveTimeDetailLab.frame = CGRectMake(0, CGRectGetMaxY(_leaveTimeLab.frame) + 15, 150, 25);
    
    [self addSubview:self.chooseLeaveTimeBtn];
    _chooseLeaveTimeBtn.frame = CGRectMake(CGRectGetMaxX(_leaveTimeDetailLab.frame) + 8, _leaveTimeDetailLab.y+2.5, 20, 20);
    
    [self addSubview:self.leaveAmBtn];
    _leaveAmBtn.frame = CGRectMake(CGRectGetMaxX(_chooseLeaveTimeBtn.frame) + 8, _leaveTimeDetailLab.y, 50, 25);
    
    [self addSubview:self.leavePmBtn];
    _leavePmBtn.frame = CGRectMake(CGRectGetMaxX(_leaveAmBtn.frame) + 8, _leaveTimeDetailLab.y, 50, 25);
    
    // 设置默认时间
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *nowDateStr = [dateFormat stringFromDate:nowDate];
    
    NSDate *forMonthDate = [self formatMonthDate];
    NSString *forMonthDateStr = [dateFormat stringFromDate:forMonthDate];
    
    _arriveTimeDetailLab.text = forMonthDateStr;
    _leaveTimeDetailLab.text = nowDateStr;
}

#pragma mark chooseArriveTimeBtnClick
-(void)chooseArriveTimeBtnClick:(id)sender
{
    NSDateFormatter *minDateFormater = [[NSDateFormatter alloc] init];
    [minDateFormater setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *scrollToDate = [minDateFormater dateFromString:_arriveTimeDetailLab.text];
    
    WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDayHourMinute scrollToDate:scrollToDate CompleteBlock:^(NSDate *selectDate) {
        NSString *date = [selectDate stringWithFormat:@"yyyy-MM-dd HH:mm"];
        _arriveTimeDetailLab.text = date;
        
    }];
    datepicker.dateLabelColor = [UIColor colorWithHexString:@"1B82D1"];//年-月-日-时-分 颜色
    datepicker.datePickerColor = [UIColor blackColor];//滚轮日期颜色
    datepicker.doneButtonColor = [UIColor colorWithHexString:@"1B82D1"];//确定按钮的颜色
    datepicker.yearLabelColor = [UIColor clearColor];//大号年份字体颜色
    [datepicker show];
    
}

-(void)arriveAmBtnClick:(id)sender
{
    _arrivePmBtn.selected = NO;
    _arriveAmBtn.selected = YES;
}

-(void)arrivePmBtnClick:(id)sender
{
    _arriveAmBtn.selected = NO;
    _arrivePmBtn.selected = YES;
}

-(void)chooseLeaveTimeBtnClick:(id)sender
{
    NSDateFormatter *minDateFormater = [[NSDateFormatter alloc] init];
    [minDateFormater setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *scrollToDate = [minDateFormater dateFromString:_leaveTimeDetailLab.text];
    
    WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDayHourMinute scrollToDate:scrollToDate CompleteBlock:^(NSDate *selectDate) {
        NSString *date = [selectDate stringWithFormat:@"yyyy-MM-dd HH:mm"];
        _leaveTimeDetailLab.text = date;
        
    }];
    datepicker.dateLabelColor = [UIColor colorWithHexString:@"1B82D1"];//年-月-日-时-分 颜色
    datepicker.datePickerColor = [UIColor blackColor];//滚轮日期颜色
    datepicker.doneButtonColor = [UIColor colorWithHexString:@"1B82D1"];//确定按钮的颜色
    datepicker.yearLabelColor = [UIColor clearColor];//大号年份字体颜色
    [datepicker show];

}

-(void)leaveAmBtnClick:(id)sender
{
    _leavePmBtn.selected = NO;
    _leaveAmBtn.selected = YES;
}

-(void)leavePmBtnClick:(id)sender
{
    _leaveAmBtn.selected = NO;
    _leavePmBtn.selected = YES;
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
