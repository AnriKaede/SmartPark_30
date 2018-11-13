//
//  PreviewManager.h
//  DemoDPSDK
//
//  Created by jiang_bin on 14-4-21.
//  Copyright (c) 2014年 jiang_bin. All rights reserved.
//  测试demo,主要是实时预览及预览界面的相关配置功能

#import <Foundation/Foundation.h>
#import "DHDataCenter.h"
#import "PtzSinglePrepointInfo.h"

@interface PreviewManager : NSObject

+ (PreviewManager *) sharedInstance;

- (void)initData;
- (int)openRealPlay:(void *)hWnd;

- (int)pauseRealPlay:(BOOL)paused;

- (int)stopRealPlay;

- (bool)doSnap;

- (BOOL)beginRecord;

- (BOOL)stopRecord;

- (BOOL)openVoice;

- (BOOL)closeVoice;

- (int)ptzDirection:(dpsdk_ptz_direct_e)direction byStep:(int)step stop:(BOOL)stop;

- (int)ptzCamara:(dpsdk_camera_operation_e)operation byStep:(int)step stop:(BOOL)stop;

- (NSMutableArray*)ptzQueryPrePoint;
- (int)ptzPrePoint:(dpsdk_ptz_prepoint_cmd_e)operation prePoint:(PtzSinglePrepointInfo*)pointInfo;

@end
