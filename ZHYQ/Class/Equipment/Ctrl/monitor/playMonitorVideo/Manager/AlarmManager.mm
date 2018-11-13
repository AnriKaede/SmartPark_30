//
//  AlarmManager.m
//  DemoDPSDK
//
//  Created by mac on 15/4/27.
//  Copyright (c) 2015年 jiang_bin. All rights reserved.
//

#import "AlarmManager.h"

@implementation AlarmManager

static AlarmManager* g_shareInstance = nil;
+ (AlarmManager *) sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_shareInstance = [[self alloc] init];
    });
    return g_shareInstance;
}

- (id)init
{
    self = [super init];
    _alarmArray = [[NSMutableArray alloc]init];
    return self;
}


-(int32_t) setAlarmCallback:(fDPSDKAlarmCallback)fun
{
    return DPSDK_SetDPSDKAlarmCallback([DHDataCenter sharedInstance]->nDPHandle_, fun, nil);
}

-(int32_t) enableAlarm:(Alarm_Enable_Info_t*) pSourceInfo
{
    return DPSDK_EnableAlarm([DHDataCenter sharedInstance]->nDPHandle_, pSourceInfo, [DHDataCenter sharedInstance].nTimeout);
}

-(int) disableAlarm
{
    return DPSDK_DisableAlarm([DHDataCenter sharedInstance]->nDPHandle_,
                              [DHDataCenter sharedInstance].nTimeout);
}




@end
