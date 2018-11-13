//
//  TimeConvert.h
//  DemoDPSDK
//
//  Created by jiang_bin on 14-4-24.
//  Copyright (c) 2014年 jiang_bin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeConvert : NSObject

/**
 *  得到时间的字符串形式 hh:MM:ss格式
 *  @param date 需要转化的时间
 *  @return hh:MM:ss格式的字符串
 */
+ (NSString *)stringBeginWithHourFromDate:(NSDate *)date;

@end
