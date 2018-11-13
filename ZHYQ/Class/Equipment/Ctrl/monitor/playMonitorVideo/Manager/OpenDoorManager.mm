//
//  OpenDoorManager.m
//  DemoDPSDK
//
//  Created by chen_zhongbo on 16/4/29.
//  Copyright © 2016年 jiang_bin. All rights reserved.
//

#import "OpenDoorManager.h"
#import "DHDataCenter.h"
#import "DHHudPrecess.h"
static OpenDoorManager* g_shareInstance = nil;
@implementation OpenDoorManager

+ (OpenDoorManager *) sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_shareInstance = [[self alloc] init];
    });
    return g_shareInstance;
}

void pecDoorStarusCallBack(int32_t nPDLLHandle, const char* szCamearId, dpsdk_door_status_e nStatus, int64_t nTime, void* pUserParam)
{
    if(nStatus == Door_Open)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            MSG(@"", @"已开门", @"");
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            MSG(@"", @" 未开门", @"");
        });
    }
}

-(int32_t) setPecDoorStatusCallback
{
    return DPSDK_SetPecDoorStatusCallback([DHDataCenter sharedInstance]->nDPHandle_, pecDoorStarusCallBack, nil);
}

@end
