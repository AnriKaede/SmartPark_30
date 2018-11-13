//
//  VtCallInfo.h
//  DemoDPSDK
//
//  Created by chen_zhongbo on 16/4/29.
//  Copyright © 2016年 jiang_bin. All rights reserved.
//

#ifndef VtCallInfo_h
#define VtCallInfo_h

//存储可视对讲参数
class VtCallInfo
{
public:
    VtCallInfo()
    {
        strUserId = @"";
        audioSessionId = 0;
        videoSessionId = 0;
        nCallType = CALL_TYPE_VT_CALL;
        nCallingStartTime = 0;
        nCallStatus = CALL_STATUS_PREPARED;
        bCaller = true;
    }
    NSString    *strUserId;          //呼叫ID
    int         audioSessionId;     //音频会话ID
    int         videoSessionId;     //视频会话ID
    dpsdk_call_type_e    nCallType;  //呼叫类型：视频对讲
    uint64_t    nCallingStartTime;  //呼叫成功的时间
    long        nAudioType;         //音频类型
    long        nSamplesPerSec;     //采样频率
    long        nBitsPerSample;     //采样位数
    int         nCallAPort;         //Render音频端口
    int         nCallVPort;         //Rneder视频端口
    bool        bCaller;            //是否为呼叫方
    
    dpsdk_call_status_e  nCallStatus;    //当前呼叫状态
};


#endif /* VtCallInfo_h */
