//
//  PlaybackManager.h
//  DemoDPSDK
//
//  Created by jiang_bin on 14-4-24.
//  Copyright (c) 2014年 jiang_bin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHDataCenter.h"

@interface PlaybackManager : NSObject
{
    int32_t         nPlaySeq_;      /**< 码流请求序号 */
    uint64_t        beginTime_;     /**< 播放开始时间 */
    uint64_t        endTime_;       /**< 播放结束时间 */
    Record_Info_t   fileInfo_;      /**< 查询的文件信息 */
    BOOL            isInited_;      /**< 是否已初始化 */
    int             fileIndex_;     /**< 当前播放的文件序号 */
}

+ (PlaybackManager *) sharedInstance;

@property (assign,nonatomic) BOOL   isFileExisted;
@property (assign,nonatomic) BOOL   isStartTime;
@property (assign,nonatomic) dpsdk_record_type_e   recordTypeValue;
@property (assign,nonatomic) dpsdk_recsource_type_e recordResourceValue;
@property (assign,nonatomic) dpsdk_playback_speed_e playbackSpeed;
@property (assign,nonatomic) BOOL isPlayBackByFile;

- (void)initPlaybackManager;

- (int)queryRecordByStart:(NSDate *)startDate withEnd:(NSDate *)endDate;

- (int)playBackByTimeOnWindow:(void *)hWnd;

- (int)playBackByFile:(int)index onWindow:(void *)hWnd;

- (int)stopPlayback;

- (int)pausePlayback:(BOOL)paused;

- (BOOL)openVoice;

- (BOOL)closeVoice;

- (int)playedTime;

- (NSTimeInterval)timeIntervalOfFile:(NSInteger)fileIndex;

/**
 *  文件开始时间
 *  @param index 文件序号
 *  @return 开始时间
 */
- (NSDate *)beginTimeOfFile:(int)index;

/**
 *  文件结束时间
 *  @param index 文件序号
 *  @return 结束时间
 */
- (NSDate *)endTimeOfFile:(int)index;

- (int)seekByTime:(float)time;

- (NSArray *)queryFileList;
@end
