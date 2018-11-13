//
//  TimeConvert.m
//  DemoDPSDK
//
//  Created by jiang_bin on 14-4-24.
//  Copyright (c) 2014年 jiang_bin. All rights reserved.
//

#import "TimeConvert.h"

@implementation TimeConvert

+ (NSString *)stringBeginWithHourFromDate:(NSDate *)date
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    NSLocale *enLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
    [format setLocale:enLocale];
    [format setDateFormat:@"HH:mm:ss"];
    NSString *dateString = [format stringFromDate:date];
    return dateString;
}

@end
