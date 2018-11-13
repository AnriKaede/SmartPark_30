//
//  ClockTimeCell.m
//  ZHYQ
//
//  Created by coder on 2018/10/23.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "ClockTimeCell.h"
#import "WSDatePickerView.h"

@interface ClockTimeCell ()
{
    __weak IBOutlet UIImageView *listrightView;
    __weak IBOutlet UILabel *clockTimeLab;
    __weak IBOutlet UIView *clockView;
}

@end

@implementation ClockTimeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    listrightView.userInteractionEnabled = YES;
    clockTimeLab.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseClockTimeAction)];
    [clockView addGestureRecognizer:tap];
}

-(void)chooseClockTimeAction
{
    __weak typeof(self) weakSelf = self;
    WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDayHourMinute scrollToDate:[NSDate date] CompleteBlock:^(NSDate *selectDate) {
        NSString *date = [selectDate stringWithFormat:@"yyyy-MM-dd HH:mm"];
        clockTimeLab.text = date;
        if (weakSelf.delegate != nil&&[weakSelf.delegate respondsToSelector:@selector(clockTimeWithTimeStr:)]) {
            [weakSelf.delegate clockTimeWithTimeStr:date];
        }
    }];
    datepicker.dateLabelColor = [UIColor colorWithHexString:@"1B82D1"];//年-月-日-时-分 颜色
    datepicker.datePickerColor = [UIColor blackColor];//滚轮日期颜色
    datepicker.doneButtonColor = [UIColor colorWithHexString:@"1B82D1"];//确定按钮的颜色
    datepicker.yearLabelColor = [UIColor clearColor];//大号年份字体颜色
    datepicker.maxLimitDate = [NSDate date];
    [datepicker show];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
