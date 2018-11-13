//
//  AlarmManager.h
//  DemoDPSDK
//
//  Created by mac on 15/4/27.
//  Copyright (c) 2015年 jiang_bin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHDataCenter.h"

@interface AlarmManager : NSObject

+ (AlarmManager *) sharedInstance;
@property (strong,nonatomic) NSMutableArray*   alarmArray;
-(int32_t) enableAlarm:(Alarm_Enable_Info_t*) pSourceInfo;
-(int32_t) disableAlarm;
-(int32_t) setAlarmCallback:(fDPSDKAlarmCallback)fun;
@property (assign,nonatomic) dpsdk_alarm_type_e   alarmTypeValue;



@end
