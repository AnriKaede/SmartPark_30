//
//  MonthMeterCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/11.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "MonthMeterCell.h"

@implementation MonthMeterCell
{
    __weak IBOutlet UILabel *_dateLabel;
    
    __weak IBOutlet UILabel *_rangeLabel;
    __weak IBOutlet UILabel *_valueLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setMonthMeterModel:(MonthMeterModel *)monthMeterModel {
    _monthMeterModel = monthMeterModel;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormat setDateFormat:@"yyyy-MM"];
    
    NSDate *monthDate = [dateFormat dateFromString:monthMeterModel.statMonth];
    
    NSDateFormatter *newFormat = [[NSDateFormatter alloc] init];
    [newFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [newFormat setDateFormat:@"yyyy年MM月"];
    
    NSString *newStr = [newFormat stringFromDate:monthDate];
    _dateLabel.text = newStr;
    
    _rangeLabel.text = [NSString stringWithFormat:@"%@ - %@", monthMeterModel.startIoValue, monthMeterModel.endIoValue];
    
//    _valueLabel.text = [NSString stringWithFormat:@"%@", monthMeterModel.energyCost];
    _valueLabel.text = [NSString stringWithFormat:@"%.0f", monthMeterModel.endIoValue.floatValue - monthMeterModel.startIoValue.floatValue];
}

- (void)setIsWater:(BOOL)isWater {
    _isWater = isWater;
    
    if(isWater){
        _rangeLabel.text = [NSString stringWithFormat:@"%@吨 - %@吨", _monthMeterModel.startIoValue, _monthMeterModel.endIoValue];
        
//        _valueLabel.text = [NSString stringWithFormat:@"%@ 吨", _monthMeterModel.energyCost];
        _valueLabel.text = [NSString stringWithFormat:@"%.0f 吨", _monthMeterModel.endIoValue.floatValue - _monthMeterModel.startIoValue.floatValue];
    }else {
        _rangeLabel.text = [NSString stringWithFormat:@"%@kwh - %@kwh", _monthMeterModel.startIoValue, _monthMeterModel.endIoValue];
        
//        _valueLabel.text = [NSString stringWithFormat:@"%@ kwh", _monthMeterModel.energyCost];
        _valueLabel.text = [NSString stringWithFormat:@"%.0f kwh", _monthMeterModel.endIoValue.floatValue - _monthMeterModel.startIoValue.floatValue];
    }
}

@end
