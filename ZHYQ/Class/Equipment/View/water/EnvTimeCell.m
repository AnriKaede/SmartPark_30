//
//  EnvTimeCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/3/1.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "EnvTimeCell.h"

@implementation EnvTimeCell
{
    __weak IBOutlet UILabel *_dateLabel;
    __weak IBOutlet UILabel *_timeLabel;
    
    __weak IBOutlet UIView *_bgView;
    __weak IBOutlet UILabel *_msgLabel;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _bgView.layer.cornerRadius = 8;
}

- (void)setEvnDelModel:(EvnDelModel *)evnDelModel {
    _evnDelModel = evnDelModel;
    
    if(evnDelModel.datetime != nil && ![evnDelModel.datetime isKindOfClass:[NSNull class]]){
        _dateLabel.text = [self dateFormatterForString:evnDelModel.datetime];
        _timeLabel.text = [self timeFormatterForString:evnDelModel.datetime];
    }
    
}

- (void)setEvnDataModel:(EvnDataModel *)evnDataModel {
    _evnDataModel = evnDataModel;
    
    if(evnDataModel.sensor_type_id.integerValue == 182){
        // 雨量
        _msgLabel.text = [NSString stringWithFormat:@"%@ %@mm",evnDataModel.device_name , _evnDelModel.value];
    }else if(evnDataModel.sensor_type_id.integerValue == 161){
        // 土壤温度
        _msgLabel.text = [NSString stringWithFormat:@"%@ %@℃",evnDataModel.device_name , _evnDelModel.value];
    }else if(evnDataModel.sensor_type_id.integerValue == 162){
        // 土壤水分
        _msgLabel.text = [NSString stringWithFormat:@"%@ %@%%",evnDataModel.device_name , _evnDelModel.value];
    }
}

- (NSString *)dateFormatterForString:(NSString *)dateTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *timeDate = [dateFormatter dateFromString:dateTime];
    
    NSDateFormatter *inpoutFormatter = [[NSDateFormatter alloc] init];
    [inpoutFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *timeString = [inpoutFormatter stringFromDate:timeDate];
    
    return timeString;
}

- (NSString *)timeFormatterForString:(NSString *)dateTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *timeDate = [dateFormatter dateFromString:dateTime];
    
    NSDateFormatter *inpoutFormatter = [[NSDateFormatter alloc] init];
    [inpoutFormatter setDateFormat:@"HH:mm:ss"];
    NSString *timeString = [inpoutFormatter stringFromDate:timeDate];
    
    return timeString;
}

@end
