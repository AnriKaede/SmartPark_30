//
//  TalkManager.m
//  DemoDPSDK
//
//  Created by dahua on 15-4-2.
//  Copyright (c) 2015年 jiang_bin. All rights reserved.
//

#import "TalkManager.h"
#import "DHDataCenter.h"
#import "DHHudPrecess.h"
#import "PlayerManager.h"
#import "g711.h"

typedef void (*pAudioCallFunction) (unsigned char* pDataBuffer, DWORD DataLength, long user);

static TalkManager* g_shareInstance = nil;

@implementation TalkManager
{
    long iTalkPort;
    int32_t iTalkSeq;
    Get_TalkStream_Info_t talkInfo;
    
    unsigned char audioCBData[1024]; /**< 对讲发送的数据 */
}

+ (TalkManager *) sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_shareInstance = [[self alloc] init];
    });
    return g_shareInstance;
}

int32_t talkMediaCallback( IN int32_t nPDLLHandle,
                       IN int32_t nSeq,
                       IN int32_t nMediaType,
                       IN const char* szNodeId,
                       IN int32_t nParamVal,
                       IN char* szData,
                       IN int32_t nDataLen,
                       IN void* pUserParam )
{
    return [[TalkManager sharedInstance]onTalkMediaCallback:nPDLLHandle sequence:nSeq meidaType:nMediaType nodeId:szNodeId paramVal:nParamVal data:szData dataLen:nDataLen userParam:pUserParam];
}

int32_t talkParamCallback(IN int32_t nPDLLHandle,
                                IN int32_t nTalkType,
                                IN int32_t nAudioType,
                                IN int32_t nAudioBit,
                                IN int32_t nSampleRate,
                                IN int32_t nTransMode,
                                IN void* pUserParam)
{
    return [[TalkManager sharedInstance]onTalkParamCallback:nPDLLHandle talkType:nTalkType audioType:nAudioType audioBit:nAudioBit sampleRate:nSampleRate transMode:nTransMode];
}

- (int32_t)onTalkMediaCallback:(int32_t)nPDLLHandle sequence:(int32_t)nSeq meidaType:(int32_t)nMediaType
                    nodeId:(const char *)szNodeId paramVal:(int32_t)nParamVal data:(char*)szData
                   dataLen:(int32_t)nDataLen userParam:(void*)pUserParam
{
    return PLAY_InputData(iTalkPort, (unsigned char *)szData, nDataLen);
}

- (int)onTalkParamCallback:(int32_t)nPDLLHandle talkType:(int32_t)nTalkType
                 audioType:(int32_t)nAudioType audioBit:(int32_t)nAudioBit
                sampleRate:(int32_t)nSampleRate transMode:(int32_t)nTransMode
{
    talkInfo.nAudioType = (dpsdk_audio_type_e)nAudioType;
    talkInfo.nBitsType = (dpsdk_talk_bits_e)nAudioBit;
    talkInfo.nSampleType = (Talk_Sample_Rate_e)nSampleRate;
    talkInfo.nTalkType = (dpsdk_talk_type_e)nTalkType;
    talkInfo.nTransType = (dpsdk_trans_type_e)nTransMode;
    return DPSDK_RET_SUCCESS;
}

- (void)onAudioCallFunction:(unsigned char*)pDataBuffer
                    dataLen:(unsigned long)DataLength
                   userData:(void*)pUserData
{
    //dpsdk
    if(nil != fSdkAudioCallback)
    {
        long userParam = (long)pAudioUserParam;
        int nLen = 0;
        memset(audioCBData, 0, sizeof(audioCBData));
        
        //G711处理
//        if (g711a_Encode(pDataBuffer, audioCBData + 8, DataLength, &nLen) != 1)
//        {
//            return;
//        }
        
#ifdef TEST_AUDIOSAMPLE
        //写入G711压缩后的采样文件
        writeTalkSampleToFile(@"OriginSample.g711",pDataBuffer, dwDataLength);
#endif
        
        //大华码流格式帧头

//                //大华码流格式帧头
//                audioCBData[0]=0x00;
//                audioCBData[1]=0x00;
//                audioCBData[2]=0x01;
//                audioCBData[3]=0xF0;
//                
//                audioCBData[4]=0x0E; //G711A
//                audioCBData[5]=0x02;
//                audioCBData[6]=(nLen&0xff);
//                audioCBData[7]=(nLen>>8);
//                nLen += 8;
        //大华码流格式帧头
        audioCBData[0]=0x00;
        audioCBData[1]=0x00;
        audioCBData[2]=0x01;
        audioCBData[3]=0xF0;
        
        audioCBData[4]=0x0C; 
        audioCBData[5]=0x02;
        audioCBData[6]=(DataLength&0xff);
        audioCBData[7]=(DataLength>>8);
        memcpy(audioCBData+8,pDataBuffer,DataLength);
        DataLength += 8;
        
        pAudioCallFunction pAudioCall = (pAudioCallFunction)fSdkAudioCallback;
        pAudioCall(audioCBData, DataLength, userParam);
    }
}

- (int)startTalk
{
    [self stopTalk];
    DPSDK_SetDPSDKTalkParamCallback([DHDataCenter sharedInstance]->nDPHandle_, talkParamCallback, (__bridge void*)self);
    memset(&talkInfo, 0, sizeof(talkInfo));
     NSString * deviceID1 = [[DHDataCenter sharedInstance].channelID substringToIndex:[[DHDataCenter sharedInstance].channelID rangeOfString:@"$"].location];
    talkInfo.nAudioType = Talk_Coding_Default;
    talkInfo.nBitsType = Talk_Audio_Bits_16;
    talkInfo.nSampleType = Talk_Audio_Sam_8K;
    talkInfo.nTalkType = Talk_Type_Device;
    talkInfo.nTransType = DPSDK_CORE_TRANSTYPE_TCP;
    strcpy(talkInfo.szCameraId, [deviceID1 UTF8String]);
    int iRet = DPSDK_GetTalkStream([DHDataCenter sharedInstance]->nDPHandle_,
                                   &iTalkSeq, &talkInfo,
                                   talkMediaCallback,
                                   (__bridge void*)self,
                                   DPSDK_CORE_DEFAULT_TIMEOUT);
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    while (iRet != DPSDK_RET_SUCCESS) {
        sleep(0.2);
        NSDate * dateNow = [NSDate date];
        NSTimeInterval t = [dateNow timeIntervalSinceDate:date];
        if (t > 10) {
            NSLog(@"Retry talking failed!");
            return -1;
        }
        iRet = DPSDK_GetTalkStream([DHDataCenter sharedInstance]->nDPHandle_,
                                   &iTalkSeq, &talkInfo,
                                   talkMediaCallback,
                                   (__bridge void*)self,
                                   DPSDK_CORE_DEFAULT_TIMEOUT);
    }
    if (iRet == DPSDK_RET_SUCCESS) {
        iTalkPort = [[PlayerManager sharedInstance]getFreePort];
      
        if ([[PlayerManager sharedInstance]startTalk:iTalkPort bVtoTalk:(NO)]) {
            MSG(@"", @"打开对讲成功", @"");
        }
//        iRet = DPSDK_GetSdkAudioCallbackInfo([DHDataCenter sharedInstance]->nDPHandle_,
//                                      &fSdkAudioCallback, &pAudioUserParam);
    }

    return iRet;
}

-(void)getAudioSendCallback:(BOOL)bVto
{
    int i = -1;
    if (bVto == YES) {
        
        i = DPSDK_GetAudioSendFunCallBack([DHDataCenter sharedInstance]->nDPHandle_,
                                          &fSdkAudioCallback,
                                          &pAudioUserParam);
    }
    else
    {
        i = DPSDK_GetSdkAudioCallbackInfo([DHDataCenter sharedInstance]->nDPHandle_,
                                          &fSdkAudioCallback,
                                          &pAudioUserParam);
    }
    
    NSLog(@"%d",i);
}
- (int)stopTalk
{
    int iRet = DPSDK_CloseTalkStreamBySeq([DHDataCenter sharedInstance]->nDPHandle_,
                                          iTalkSeq,
                                          DPSDK_CORE_DEFAULT_TIMEOUT);
    if (iRet == DPSDK_RET_SUCCESS) {
        [[PlayerManager sharedInstance]stopTalk:iTalkPort];
        iTalkPort = -1;
    }
    return iRet;
}

/** 写入音频测试文件 */
void writeTalkSampleToFile(NSString *fileName, unsigned char *pData, int dataLen)
{
    //Path for sampled audio
    NSString *documentsDirectory = [DHPubfun documentFolder];
    NSString *path = [NSString stringWithFormat:@"%@/SampleTest",documentsDirectory];;
    NSFileManager *fileManage = [NSFileManager defaultManager];
    NSError *pError;
    [fileManage createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&pError];
    //File path:
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",path,fileName];
    FILE *p = fopen([filePath UTF8String], "ab+");
    if (p)
    {
        fwrite(pData, 1, dataLen, p);
        fclose(p);
    }
}

@end
