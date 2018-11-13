//
//  PlaybackManager.m
//  DemoDPSDK
//
//  Created by jiang_bin on 14-4-24.
//  Copyright (c) 2014年 jiang_bin. All rights reserved.
//

#import "PlaybackManager.h"
#import "PlayerManager.h"

static PlaybackManager* g_shareInstance = nil;
static long iPlaybackPort = -1;

@implementation PlaybackManager
{
    NSMutableArray *_fileRanges;
}

+ (PlaybackManager *) sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_shareInstance = [[self alloc] init];
    });
    return g_shareInstance;
}

int32_t DPSDK_CALLTYPE playbackCallback(int32_t nPDLLHandle,
                                        int32_t nSeq,
                                        int32_t nMediaType,
                                        const char* szNodeId,
                                        int32_t nParamVal,
                                        char* szData,
                                        int32_t nDataLen,
                                        void* pUserParam )
{
    int ret = PLAY_InputData(iPlaybackPort, (unsigned char*)szData, nDataLen);
    while(ret == 0)
    {
        usleep(2*1000);
        ret = PLAY_InputData(iPlaybackPort, (unsigned char*)szData, nDataLen);
    }

    return ret;
}

- (void)initPlaybackManager
{
    
}

- (void)dealloc
{
    if (isInited_)
    {
        SAFE_DELETE_ARRAY(fileInfo_.pSingleRecord);
    }
}

- (int)queryRecordByStart:(NSDate *)startDate withEnd:(NSDate *)endDate
{
    self.isFileExisted = NO;
    beginTime_ = [startDate timeIntervalSince1970];
    endTime_   = [endDate timeIntervalSince1970];
    int recordNum = 0;
    Query_Record_Info_t recordInfo = { sizeof(Query_Record_Info_t)};
    recordInfo.nRecordType = [PlaybackManager sharedInstance].recordTypeValue;
    recordInfo.nRight = DPSDK_CORE_NOT_CHECK_RIGHT;
    recordInfo.nSource = [PlaybackManager sharedInstance].recordResourceValue;
    strcpy(recordInfo.szCameraId, [[DHDataCenter sharedInstance].channelID UTF8String]);
    recordInfo.uBeginTime = beginTime_;
    recordInfo.uEndTime = endTime_;
    
    int nRet = DPSDK_QueryRecord([DHDataCenter sharedInstance]->nDPHandle_,
                                 &recordInfo,
                                 &recordNum,
                                 [DHDataCenter sharedInstance].nTimeout);
    
    if (nRet == DPSDK_RET_SUCCESS && recordNum)
    {
        fileInfo_.nCount = 100;
        fileInfo_.nBegin = 0;
        strcpy(fileInfo_.szCameraId, [[DHDataCenter sharedInstance].channelID UTF8String]);
        if (fileInfo_.pSingleRecord == NULL)
        {
            fileInfo_.pSingleRecord = new Single_Record_Info_t[fileInfo_.nCount];
            memset(fileInfo_.pSingleRecord, 0, 100*sizeof(Single_Record_Info_t));
            
        }
        
        nRet = DPSDK_GetRecordInfo([DHDataCenter sharedInstance]->nDPHandle_, &fileInfo_);
        
        _fileRanges = @[].mutableCopy;
        for (int i = 0; i < fileInfo_.nRetCount; i++)
        {
            NSLog(@"Fileindex:%d,start:%llu,end:%llu",
                  fileInfo_.pSingleRecord[i].nFileIndex,
                  fileInfo_.pSingleRecord[i].uBeginTime,
                  fileInfo_.pSingleRecord[i].uEndTime);
            
            NSDate *beginDate = [NSDate dateWithTimeIntervalSince1970:fileInfo_.pSingleRecord[i].uBeginTime];
            NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:fileInfo_.pSingleRecord[i].uEndTime];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//            NSTimeZone* localzone = [NSTimeZone localTimeZone];
//            NSTimeZone* GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
//            [formatter setTimeZone:GTMzone];
            [formatter setDateFormat:@"HH:mm"];
            
            NSString *timeRange = [NSString stringWithFormat:@"%@-%@", [formatter stringFromDate:beginDate], [formatter stringFromDate:endDate]];
            
            NSDictionary *fileInfoDic = @{@"timeRange":timeRange,
                                              @"timeIndex":[NSNumber numberWithInteger:fileInfo_.pSingleRecord[i].nFileIndex]
                                              };
            [_fileRanges addObject:fileInfoDic];
        }
        
        if (fileInfo_.nRetCount)
        {
            self.isFileExisted = YES;
        }
    }
    return nRet;
}
- (NSArray *)queryFileList {
    return _fileRanges;
}

- (int)playBackByTimeOnWindow:(void *)hWnd
{
    fileIndex_ = 0;
    Get_RecordStream_Time_Info_t timeInfo = { sizeof(Get_RecordStream_Time_Info_t)};
    strcpy(timeInfo.szCameraId, [[DHDataCenter sharedInstance].channelID UTF8String]);
    timeInfo.nRight = DPSDK_CORE_NOT_CHECK_RIGHT;
    timeInfo.nMode = DPSDK_CORE_PB_MODE_NORMAL;
    timeInfo.nSource = [PlaybackManager sharedInstance].recordResourceValue;
    timeInfo.uBeginTime = beginTime_;
    timeInfo.uEndTime = endTime_;
    
    int nRet = DPSDK_GetRecordStreamByTime([DHDataCenter sharedInstance]->nDPHandle_,
                                           &nPlaySeq_,
                                           &timeInfo,
                                           playbackCallback,
                                           nil,
                                           15*1000);
    NSLog(@"PlaybackManager::Open error:%d", nRet);
    
    if (0 == nRet)
    {
        //调用playsdk进行播放
        iPlaybackPort = [[PlayerManager sharedInstance]getFreePort];
        [[PlayerManager sharedInstance]startRecordPlay:iPlaybackPort window:hWnd];
    }
    return nRet;
}

- (int)playBackByFile:(int)index onWindow:(void *)hWnd
{
    //文件索引不正确
    if (index < 0 || index > fileInfo_.nRetCount - 1 || index > fileInfo_.nCount - 1)
    {
        return -1;
    }
    
    fileIndex_ = index;
    
    Get_RecordStream_File_Info_t fileInfo = { sizeof(Get_RecordStream_File_Info_t)};
    strcpy(fileInfo.szCameraId, [[DHDataCenter sharedInstance].channelID UTF8String]);
    fileInfo.nRight = DPSDK_CORE_NOT_CHECK_RIGHT;
    fileInfo.nMode = DPSDK_CORE_PB_MODE_NORMAL;
    fileInfo.nFileIndex = fileInfo_.pSingleRecord[index].nFileIndex;
    fileInfo.uBeginTime = fileInfo_.pSingleRecord[index].uBeginTime;
    fileInfo.uEndTime = fileInfo_.pSingleRecord[index].uEndTime;
    
    int nRet = DPSDK_GetRecordStreamByFile([DHDataCenter sharedInstance]->nDPHandle_,
                                           &nPlaySeq_,
                                           &fileInfo,
                                           playbackCallback,
                                           nil,
                                           15*1000);
    NSLog(@"PlaybackManager::Open error:%d", nRet);
    
    if (0 == nRet)
    {
        //调用playsdk进行播放
        iPlaybackPort = [[PlayerManager sharedInstance]getFreePort];
        [[PlayerManager sharedInstance]startRecordPlay:iPlaybackPort window:hWnd];
    }
    return nRet;
}

- (int)stopPlayback
{
    int nRet = DPSDK_CloseRecordStreamBySeq([DHDataCenter sharedInstance]->nDPHandle_,
                                            nPlaySeq_,
                                            [DHDataCenter sharedInstance].nTimeout);
    if (0 == nRet)
    {
        [[PlayerManager sharedInstance] stopRecordPlay:iPlaybackPort];
    }
    
    return nRet;
}


- (BOOL)openVoice{
    BOOL nret = [[PlayerManager sharedInstance]openVoice:iPlaybackPort];
    return nret;
}

- (BOOL)closeVoice{
    BOOL nret = [[PlayerManager sharedInstance] closeVoice:iPlaybackPort];
    return nret;
}


- (int)pausePlayback:(BOOL)paused
{
    int nRet = 0;
    if (paused) //暂停
    {
        nRet = DPSDK_PauseRecordStreamBySeq([DHDataCenter sharedInstance]->nDPHandle_,
                                            nPlaySeq_,
                                            [DHDataCenter sharedInstance].nTimeout);
    }
    else    //恢复
    {
        nRet = DPSDK_ResumeRecordStreamBySeq([DHDataCenter sharedInstance]->nDPHandle_,
                                             nPlaySeq_,
                                             [DHDataCenter sharedInstance].nTimeout);

    }
    if (0 == nRet)
    {
        PLAY_Pause(iPlaybackPort, paused);
    }
    return nRet;
}

- (void)setPlaybackSpeed:(dpsdk_playback_speed_e) speed{
    _playbackSpeed = speed;
   int ret = DPSDK_SetRecordStreamSpeed([DHDataCenter sharedInstance]->nDPHandle_, nPlaySeq_, speed, [DHDataCenter sharedInstance].nTimeout) ;
    [[PlayerManager sharedInstance] setPlaySpeed:speed/8.0 withPort:iPlaybackPort];
    NSLog(@"%d",ret);
}


- (int)playedTime
{
    char *pBuf = new char[64];
    memset(pBuf, 0, 64);
    int nLen = 0;
    PLAY_QueryInfo(iPlaybackPort, PLAY_CMD_GetTime, pBuf, 64, &nLen);
    
    NSDate *current = [self convertNSDateFromNetTime:pBuf];
    NSDate *begin = [NSDate dateWithTimeIntervalSince1970:fileInfo_.pSingleRecord[fileIndex_].uBeginTime];
    NSTimeInterval playedTime = [current timeIntervalSinceDate:begin];
    SAFE_DELETE_ARRAY(pBuf)
    return (int)playedTime;
}

- (NSTimeInterval)timeIntervalOfFile:(NSInteger)fileIndex
{
    if (fileIndex > fileInfo_.nRetCount - 1 || fileIndex < 0)
    {
        return 0;
    }
    
    NSTimeInterval timeInterval = fileInfo_.pSingleRecord[fileIndex_].uEndTime -
                                  fileInfo_.pSingleRecord[fileIndex_].uBeginTime;
    return timeInterval;
}

/**
 *  文件开始时间
 *  @param index 文件序号
 *  @return 开始时间
 */
- (NSDate *)beginTimeOfFile:(int)index
{
    if (index > fileInfo_.nRetCount - 1 || index < 0)
    {
        return nil;
    }
    return [NSDate dateWithTimeIntervalSince1970:fileInfo_.pSingleRecord[fileIndex_].uBeginTime];
}

/**
 *  文件结束时间
 *  @param index 文件序号
 *  @return 结束时间
 */
- (NSDate *)endTimeOfFile:(int)index
{
    if (index > fileInfo_.nRetCount - 1 || index < 0)
    {
        return nil;
    }
    return [NSDate dateWithTimeIntervalSince1970:fileInfo_.pSingleRecord[fileIndex_].uEndTime];
}

- (NSString *)formatFromInt:(int)number
{
    if (number < 10 && number >= 0)
    {
        return [NSString stringWithFormat:@"0%d",number];
    }
    else
    {
        return [NSString stringWithFormat:@"%d",number];
    }
}

- (NSDate *)convertNSDateFromNetTime:(char *)pBuf
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    NSLocale *enLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
    [format setLocale:enLocale];
    [format setDateFormat:@"yyyy-MM-dd HH-mm-ss"];
    
    NSString *stringTime = [NSString stringWithFormat:@"%d-%d-%d %d-%d-%d",
                            *((int*)pBuf),
                            *((int*)(pBuf+4)),
                            *((int*)(pBuf+4*2)),
                            *((int*)(pBuf+4*3)),
                            *((int*)(pBuf+4*4)),
                            *((int*)(pBuf+4*5))];
    NSDate *date = [format dateFromString:stringTime];
    return date;
}


- (int)seekByTime:(float)time{
    int nRet = DPSDK_CloseRecordStreamBySeq([DHDataCenter sharedInstance]->nDPHandle_,
                                            nPlaySeq_,
                                            [DHDataCenter sharedInstance].nTimeout);
    if (0 == nRet)
    {
        [[PlayerManager sharedInstance] resetBuffer:iPlaybackPort];
        if (_isPlayBackByFile) {
            Get_RecordStream_File_Info_t fileInfo = { sizeof(Get_RecordStream_File_Info_t)};
            strcpy(fileInfo.szCameraId, [[DHDataCenter sharedInstance].channelID UTF8String]);
            fileInfo.nRight = DPSDK_CORE_NOT_CHECK_RIGHT;
            fileInfo.nMode = DPSDK_CORE_PB_MODE_NORMAL;
            fileInfo.nFileIndex = fileInfo_.pSingleRecord[fileIndex_].nFileIndex;
            fileInfo.uBeginTime = fileInfo_.pSingleRecord[fileIndex_].uBeginTime + time;
            fileInfo.uEndTime = fileInfo_.pSingleRecord[fileIndex_].uEndTime;
            
            nRet = DPSDK_GetRecordStreamByFile([DHDataCenter sharedInstance]->nDPHandle_,
                                               &nPlaySeq_,
                                               &fileInfo,
                                               playbackCallback,
                                               nil,
                                               15*1000);;
        }
        else{
            Get_RecordStream_Time_Info_t timeInfo = { sizeof(Get_RecordStream_Time_Info_t)};
            strcpy(timeInfo.szCameraId, [[DHDataCenter sharedInstance].channelID UTF8String]);
            timeInfo.nRight = DPSDK_CORE_NOT_CHECK_RIGHT;
            timeInfo.nMode = DPSDK_CORE_PB_MODE_NORMAL;
            timeInfo.nSource = _recordResourceValue;
            timeInfo.uBeginTime = beginTime_ + time;
            timeInfo.uEndTime = endTime_;
            
            nRet = DPSDK_GetRecordStreamByTime([DHDataCenter sharedInstance]->nDPHandle_,
                                               &nPlaySeq_,
                                               &timeInfo,
                                               playbackCallback,
                                               nil,
                                               15*1000);
            
        }
    }
    
    
    return nRet;

}

@end
