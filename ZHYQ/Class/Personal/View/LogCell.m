//
//  LogCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/13.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "LogCell.h"

@implementation LogCell
{
    __weak IBOutlet UILabel *_timeLabel;
    __weak IBOutlet UILabel *_userLabel;
    
    __weak IBOutlet UILabel *_operateLabel;
    __weak IBOutlet UILabel *_phoneModelLabel;
    __weak IBOutlet UILabel *_deviceCodeLabel;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setOperateLogModel:(OperateLogModel *)operateLogModel {
    _operateLogModel = operateLogModel;
    
    _timeLabel.text = [self timeStrWithScince:operateLogModel.operateTime];
    
    _userLabel.text = [NSString stringWithFormat:@"操作人: %@", operateLogModel.userName];
    
    _operateLabel.text = [NSString stringWithFormat:@"%@", operateLogModel.operateName];
    
    _phoneModelLabel.text = [NSString stringWithFormat:@"%@", operateLogModel.deviceName];
    
    _deviceCodeLabel.text = [NSString stringWithFormat:@"%@", operateLogModel.deviceId];
}

- (NSString *)timeStrWithScince:(NSNumber *)scince {
    NSTimeInterval timeInt = scince.integerValue/1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInt];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *dateStr = [formatter stringFromDate:date];
    
    return dateStr;
}

@end
