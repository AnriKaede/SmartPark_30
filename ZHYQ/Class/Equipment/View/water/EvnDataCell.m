//
//  EvnDataCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/3/6.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "EvnDataCell.h"

@implementation EvnDataCell
{
    __weak IBOutlet UIImageView *_typeImgView;
    
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UILabel *_valueLabel;
    __weak IBOutlet UILabel *_timeLabel;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setEvnDataModel:(EvnDataModel *)evnDataModel {
    _evnDataModel = evnDataModel;
    
    if(evnDataModel.sensor_type_id.integerValue == 182){
        // 雨量
        _typeImgView.image = [UIImage imageNamed:@"evn_rainfall_icon"];
        _valueLabel.text = [NSString stringWithFormat:@"%@mm", evnDataModel.value];
    }else if(evnDataModel.sensor_type_id.integerValue == 161){
        // 土壤温度
        _typeImgView.image = [UIImage imageNamed:@"evn_temperature_icon"];
        _valueLabel.text = [NSString stringWithFormat:@"%@℃", evnDataModel.value];
    }else if(evnDataModel.sensor_type_id.integerValue == 162){
        // 土壤水分
        _typeImgView.image = [UIImage imageNamed:@"evn_water_icon"];
        _valueLabel.text = [NSString stringWithFormat:@"%@%%", evnDataModel.value];
    }
    
    _nameLabel.text = evnDataModel.device_name;
    
    if(evnDataModel.datetime != nil && ![evnDataModel.datetime isKindOfClass:[NSNull class]]){
        _timeLabel.text = [self dateFormatterForString:evnDataModel.datetime];
    }
}

- (NSString *)dateFormatterForString:(NSString *)dateTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *timeDate = [dateFormatter dateFromString:dateTime];
    
    NSDateFormatter *inpoutFormatter = [[NSDateFormatter alloc] init];
    [inpoutFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *timeString = [inpoutFormatter stringFromDate:timeDate];
    
    return timeString;
}

@end
