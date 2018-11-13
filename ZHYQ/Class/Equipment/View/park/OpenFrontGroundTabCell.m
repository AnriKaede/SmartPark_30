//
//  OpenFrontGroundTabCell.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/27.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "OpenFrontGroundTabCell.h"

@implementation OpenFrontGroundTabCell
{
    __weak IBOutlet UILabel *_timeLabel;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setParkLockModel:(ParkLockModel *)parkLockModel {
    _parkLockModel = parkLockModel;
    
    if(parkLockModel.lockOccutime != nil && ![parkLockModel.lockOccutime isKindOfClass:[NSNull class]]){
        NSString *string = parkLockModel.lockOccutime;
        NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
        [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [inputFormatter setDateFormat:@"yyyyMMddHHmmss"];
        NSDate *inputDate = [inputFormatter dateFromString:string];
        NSDateFormatter *outputFormatter= [[NSDateFormatter alloc] init];
        [outputFormatter setLocale:[NSLocale currentLocale]];
        [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *str= [outputFormatter stringFromDate:inputDate];
        
        _timeLabel.text = [NSString stringWithFormat:@"%@",str];
    }
}

@end
