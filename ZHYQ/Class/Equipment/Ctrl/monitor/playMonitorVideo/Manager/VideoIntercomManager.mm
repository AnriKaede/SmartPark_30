//
//  VideoIntercomManager.m
//  DemoDPSDK
//
//  Created by chen_zhongbo on 16/4/27.
//  Copyright © 2016年 jiang_bin. All rights reserved.
//

#import "VideoIntercomManager.h"
#import "DHDataCenter.h"
#import "PlayerManager.h"
#import "TalkManager.h"
#import "SBJson.h"

static VideoIntercomManager* g_shareInstance = nil;
static void *hPlayWnd = nil;  //窗口句柄
static long iVideoplayPort = -1;
static long iTalkPort = -1;
static BOOL bFirstStream = true;
@interface VideoIntercomManager()

@end

@implementation VideoIntercomManager
int m_nRingCId;
int m_nRingDId;
int m_nRingTid;

+ (VideoIntercomManager *) sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_shareInstance = [[self alloc] init];
    });
    return g_shareInstance;
}

int32_t  videoIntercomeCallback( IN int32_t nPDLLHandle,
                       IN int32_t nSeq,
                       IN int32_t nMediaType,
                       IN const char* szNodeId,
                       IN int32_t nParamVal,
                       IN char* szData,
                       IN int32_t nDataLen,
                       IN void* pUserParam )
{
    if(bFirstStream == true)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OnFirstStreamComing" object:nil];
    }
    
    PLAY_InputData(iVideoplayPort, (unsigned char *)szData, nDataLen);
    return 0;
}
/*开门*/
-(int) OpenDoor
{
   DeviceTreeNode* node = [[VideoIntercomManager sharedInstance] GetDevNodeByCallNum:[VideoIntercomManager sharedInstance]->_strCallNum];
    NSString* doorChnlID =  [NSString stringWithFormat:@"%@$7$0$0",node.cameraID];
    
    SetDoorCmd_Request_t request;
    
    const char* tempStr = [doorChnlID cStringUsingEncoding:NSUTF8StringEncoding];
    strcpy(request.szCameraId, tempStr);
    request.cmd = CORE_DOOR_CMD_OPEN;
    request.start = 0;
    request.end = 0;
    
    int32_t ret = DPSDK_SetDoorCmd([DHDataCenter sharedInstance]->nDPHandle_,
                                               &request,
                                               10000);
    return ret;
}

typedef enum{
    INTERCOM_STARTCALL_RESULT = 0,
    INTERCOM_STOPCALL_RESULT,
    INTERCOM_INVITECALL_RESULT,
    INTERCOM_CEASEDCALL_RESULT,
    INTERCOM_DEMANDCALL_RESULT,
    INTERCOM_CALLSTREAM_TIMEOUT,
    INTERCOM_INVITECALL_NOTIFY,
    INTERCOM_GRANTEDCALL_NOTIFY,
    INTERCOM_CEASEDCALL_NOTIFY,
    INTERCOM_INTERRUPTCALL_NOTIFY,
    INTERCOM_BYECALL_NOTIFY,
    INTERCOM_RINGCALL_NOTIFY,
    INTERCOM_BUSYCALL_NOTIFY,
    INTERCOM_INFOPUBLISH_RESULT,
    INTERCOM_EXPRESSNOTICE_RESULT,
    INTERCOM_CANCELCALL_NOTIFY,
    INTERCOM_STOPPUBLISH_RESULT,
    INTERCOM_MESSAGEPUBLISH_PROGRESS,
    INTERCOM_JSONMESSAGE_NOTIFY,
    
}VideoIntercomNoticeType;

int ringInfoCallBack(int32_t nPDLLHandle, RingInfo_t* param, void* pUserParam)
{
    
    return 0;
}


int32_t videoIntercomeMediaDataCallback(int32_t nPDLLHandle,
                          int32_t nSeq,
                          int32_t nMediaType,
                          const char* szNodeId,
                          int32_t nParamVal,
                          char* szData,
                          int32_t nDataLen,
                          void* pUserParam )
{
    PLAY_InputData(iTalkPort, (unsigned char *)szData, nDataLen);
    return 0;
}


//主动挂断处理
-(void) OnStopCallTalk
{
    //通话记录写入本地文件
    if (m_invteInfo) {
        
        [self stopIntercomVideoCall:false];
    }
}
//接听对讲处理
- (int) startIntercomVideoCall
{
    if (!m_invteInfo) {
        return -1;
    }
    if (_m_VtCallInfo) {
        _m_VtCallInfo = nil;
    }
    /*关闭响铃*/
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sgnStopRing" object:nil];
    
    //视频会话videoSessionId,音频会话nSessionId
    uint32_t videoSessionId;
    uint32_t audioSessionId;

    DPSDK_SetLog([DHDataCenter sharedInstance]->nDPHandle_, DPSDK_LOG_LEVEL_DEBUG, nil, 1, 1);
    
    int ret = DPSDK_InviteVtCall([DHDataCenter sharedInstance]->nDPHandle_, &audioSessionId, &videoSessionId, m_invteInfo, m_invteInfo->nCallType, videoIntercomeMediaDataCallback, nil, 10000);
    if(ret != 0){
        return -1;
    }
    _m_VtCallInfo = new VtCallInfo;
    _m_VtCallInfo->audioSessionId = audioSessionId;
    _m_VtCallInfo->videoSessionId = videoSessionId;
    _m_VtCallInfo->nCallType = m_invteInfo->nCallType;
    _m_VtCallInfo->strUserId = [NSString stringWithFormat:@"%s",m_invteInfo->szUserId];
    _m_VtCallInfo->nCallStatus = CALL_STATUS_RECVING;
    _m_VtCallInfo->nAudioType = m_invteInfo->audioType;
    _m_VtCallInfo->nBitsPerSample = m_invteInfo->audioBit;
    _m_VtCallInfo->nSamplesPerSec = m_invteInfo->sampleRate;
    //获取当前时间
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDate * dateNow = [NSDate date];
    NSTimeInterval t = [dateNow timeIntervalSinceDate:date];
    _m_VtCallInfo->nCallingStartTime = t;
    _m_VtCallInfo->bCaller = false;
    
    //视频打开
    DeviceTreeNode *devNode =  [[VideoIntercomManager sharedInstance] GetDevNodeByCallNum:[VideoIntercomManager sharedInstance]->_strCallNum];
    if(devNode != nil)
    {
        if(!devNode.Nodelist || devNode.Nodelist== 0){
            return -1;
        }
        //待播放节点
        DeviceTreeNode *encNode = devNode.Nodelist[0];
        [DHDataCenter sharedInstance].channelID = encNode.cameraID;
        _strDevID = devNode.cameraID;
        //打开对讲
        iTalkPort = [[PlayerManager sharedInstance] getFreePort];
        if(![[PlayerManager sharedInstance] startTalk:iTalkPort bVtoTalk:YES]){
            return -1;
        }
        _m_VtCallInfo->nCallAPort = iTalkPort;
        return 0;
    }
    return -1;
}

//结束通话
-(void) stopIntercomVideoCall:(bool) bStopByBusy
{
    //会话Id
    int ret;
    if (!_m_VtCallInfo || _m_VtCallInfo->nCallStatus == CALL_STATUS_PREPARED) {
        //处理通话还未建立时，接收方拒绝接听电话
        if ( !m_invteInfo) {
            return;
        }
        DPSDK_SetLog([DHDataCenter sharedInstance]->nDPHandle_, DPSDK_LOG_LEVEL_DEBUG, nil, 1, 1);
        
        ret = DPSDK_SendRejectVtCall([DHDataCenter sharedInstance]->nDPHandle_,
                                                         m_invteInfo->szUserId,
                                                         m_invteInfo->callId,
                                                         m_invteInfo->dlgId,
                                                         m_invteInfo->tid,
                                                         10000);
    }
    else if(_m_VtCallInfo->nCallStatus == CALL_STATUS_REQTOSCS)
    {
        if (!bStopByBusy) {
            const char* strUserID = [_m_VtCallInfo->strUserId cStringUsingEncoding:NSUTF8StringEncoding];
            ret = DPSDK_SendCancelVtCall([DHDataCenter sharedInstance]->nDPHandle_, strUserID, _m_VtCallInfo->audioSessionId, _m_VtCallInfo->videoSessionId, m_nRingCId, m_nRingDId, 10000);
        }else {
            ret = DPSDK_SendCancelVtCall([DHDataCenter sharedInstance]->nDPHandle_, "", _m_VtCallInfo->audioSessionId, _m_VtCallInfo->videoSessionId, m_nRingCId, m_nRingDId, 10000);
        }
    }else {
        const char* strUserID = [_m_VtCallInfo->strUserId cStringUsingEncoding:NSUTF8StringEncoding];
        ret = DPSDK_StopVtCall([DHDataCenter sharedInstance]->nDPHandle_, strUserID, _m_VtCallInfo->audioSessionId, _m_VtCallInfo->videoSessionId, m_nRingCId, m_nRingDId, 1000);
        
        
 //       ret = DPSDK_ByeVtCall([DHDataCenter sharedInstance]->nDPHandle_, strUserID, _m_VtCallInfo->audioSessionId, _m_VtCallInfo->videoSessionId, nsTid.intValue, 10000);
    }
    
    if (_m_VtCallInfo != NULL) {
        [[PlayerManager sharedInstance] stopTalk:iTalkPort];
        int nRet = DPSDK_CloseRealStreamBySeq([DHDataCenter sharedInstance]->nDPHandle_,
                                              nRealSeq_,
                                              5000);
        [[PlayerManager sharedInstance] stopRealPlay:iVideoplayPort];
    }
    _m_VtCallInfo = NULL;
    m_invteInfo = NULL;
    _strVtoName = @"";
    _strDevID = @"";
}

//拒接通话处理
-(void) OnHangupTalk
{
    //通话记录写入本地文件
    if (m_invteInfo) {
        [self stopIntercomVideoCall:false];
    }
}
static NSNumber *nsCallId;
static NSNumber *nsDlgId;
static NSNumber *nsTid;
int inviteVtCallParamCallBack(int32_t nPDLLHandle, InviteVtCallParam_t* param, void* pUserParam)
{
//    NSNumber *nsCallType = [NSNumber numberWithInt:param->nCallType];
//    NSString *nsUserId = [NSString stringWithUTF8String:param->szUserId];
//    NSString *nsRtpServIp = [NSString stringWithUTF8String:param->rtpServIP];
//    NSNumber *nsRtpAPort = [NSNumber numberWithInt:param->rtpAPort];
//    NSNumber *nsRtpVPort = [NSNumber numberWithInt:param->rtpVPort];
//    NSNumber *nsAudioType = [NSNumber numberWithInt:param->audioType];
//    NSNumber *nsAudioBit = [NSNumber numberWithInt:param->audioBit];
//    NSNumber *nsSampleRate = [NSNumber numberWithInt:param->sampleRate];
     nsCallId= [NSNumber numberWithInt:param->callId];
    nsDlgId = [NSNumber numberWithInt:param->dlgId];
    nsTid = [NSNumber numberWithInt:param->tid];
    if ([VideoIntercomManager sharedInstance]->m_invteInfo != nil) {
        delete [VideoIntercomManager sharedInstance]->m_invteInfo;
        [VideoIntercomManager sharedInstance]->m_invteInfo = nil;
    }
    
  //  InviteVtCallParam_t* temp = new InviteVtCallParam_t(*param);
    [VideoIntercomManager sharedInstance]->m_invteInfo = new InviteVtCallParam_t(*param);
    [VideoIntercomManager sharedInstance]->_strCallNum = [NSString stringWithUTF8String:param->szUserId];
    
    DeviceTreeNode *devNode =  [[VideoIntercomManager sharedInstance] GetDevNodeByCallNum:[VideoIntercomManager sharedInstance]->_strCallNum];
	
    if(devNode != nil)
    {
        if(!devNode.Nodelist || devNode.Nodelist.count <= 0)
        {
            return 0;
        }
        //待播放节点
        DeviceTreeNode *encNode = devNode.Nodelist[0];
        
        [DHDataCenter sharedInstance].incomingTalkChnlID = encNode.cameraID;
        
        NSDictionary *dicInfo = [NSDictionary dictionaryWithObjectsAndKeys:devNode,@"DevNode", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sgnStartRing" object:nil userInfo:dicInfo];
    }
    /*
    GroupLogical::IGroupManager *m_pGroupMgr = CDCMManager::GetGroupManager();
    GroupLogical::Device_Info_t devInfo;
    bool bRet = GetDevInfoByCallNum([nsUserId cStringUsingEncoding:NSUTF8StringEncoding], devInfo);
    if (bRet) {
        if (devInfo.enumType > GroupLogical::DEV_TYPE_VIDEO_TALK_BEGIN && devInfo.enumType < GroupLogical::DEV_TYPE_VIDEO_TALK_END) {
            GroupLogical::EncChannelInfo_t chnInfo;
            int nSize = sizeof(GroupLogical::EncChannelInfo_t);
            bool cRet = m_pGroupMgr->GetChannelInfoByNo(devInfo.codeDevice.c_str(), GroupLogical::DEV_UNIT_ENC, 0, (void*)&chnInfo,nSize);
            GroupLogical::DoorCtrlChannelInfo_t doorInfo;
            int nDSize = sizeof(GroupLogical::DoorCtrlChannelInfo_t);
            bool dDRet = m_pGroupMgr->GetChannelInfoByNo(devInfo.codeDevice.c_str(), GroupLogical::DEV_UNIT_DOORCTRL, 0, (void*)&doorInfo,nDSize);
            NSString *strDoorId;
            if (dDRet) {
                strDoorId = [NSString stringWithUTF8String:doorInfo.codeChannel.c_str()];
            }
            if (cRet) {
                [MonitorManager sharedInstance].strLastChnlId = [QDataCenter sharedDataCenter].playChnlID;
                [MonitorManager sharedInstance].lastPlayState = [PlayerManager sharedInstance].isPlaying;
                [QDataCenter sharedDataCenter].playChnlID = [NSString stringWithUTF8String:chnInfo.codeChannel.c_str()];
                _strVtoName = [NSString stringWithCString:devInfo.strName.c_str() encoding:NSUTF8StringEncoding];
                NSDictionary *dicInfo = [NSDictionary dictionaryWithObjectsAndKeys:_strVtoName,@"DevName",strDoorId,@"ChnlId", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"sgnStartRing" object:nil userInfo:dicInfo];
            }
        }
    }
    */

    return 0;
}


int generalJsonTransportCallback(IN int32_t nPDLLHandle, IN const char* szJson, void* pUserParam)
{
    NSLog(@"generalJsonTransportCallback");
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSError *error = nil;
    id jsonObjects = [jsonParser objectWithString:[NSString stringWithUTF8String: szJson ] error:&error];
    if ([jsonObjects isKindOfClass:[NSDictionary class]])     // treat as a dictionary, or reassign to a dictionary ivar
    {
        if ([jsonObjects[@"method"] isEqualToString:@"Scs.NotifyBye"])
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"Scs.NotifyBye" object:nil];
//            [[VideoIntercomManager sharedInstance]OnHangupTalk];
  //          [(__bridge <#type#>)expression) OnHangupTalk];
        }
    }
    else if ([jsonObjects isKindOfClass:[NSArray class]])     // treat as an array or reassign to an array ivar.
    {
        
    }

    return 0;
}

-(int32_t) setRingCallback
{
    return DPSDK_SetRingCallback([DHDataCenter sharedInstance]->nDPHandle_,
                                                           ringInfoCallBack,
                                                           nil);
}


-(int32_t) setVtCallInviteCallback
{
    return DPSDK_SetVtCallInviteCallback([DHDataCenter sharedInstance]->nDPHandle_,
                                        inviteVtCallParamCallBack,
                                        nil);
}


-(int32_t)setGeneralJsonTransportCallback
{
    return DPSDK_SetGeneralJsonTransportCallback([DHDataCenter sharedInstance]->nDPHandle_, generalJsonTransportCallback,nil);
}


#pragma mark - Local Method
//视频处理 start
-(void)setPlayWnd:(void *)hWnd
{
    hPlayWnd = hWnd;
}

//打开视频
- (int)openIntercomPlay
{
    Get_RealStream_Info_t streamInfo = {0};
    strcpy(streamInfo.szCameraId, [[DHDataCenter sharedInstance].incomingTalkChnlID UTF8String]);
    streamInfo.nRight = DPSDK_CORE_NOT_CHECK_RIGHT;
    streamInfo.nStreamType = DPSDK_CORE_STREAMTYPE_SUB;
    streamInfo.nMediaType  = DPSDK_CORE_MEDIATYPE_ALL;
    streamInfo.nTransType  = DPSDK_CORE_TRANSTYPE_TCP;
    
    int nRet = DPSDK_GetRealStream([DHDataCenter sharedInstance]->nDPHandle_,
                                   &nRealSeq_,
                                   &streamInfo,
                                   videoIntercomeCallback,
                                   nil,
                                   5000);
    if (0 == nRet)
    {
        //调用playsdk进行实时播放
        iVideoplayPort = [[PlayerManager sharedInstance]getFreePort];
        [[PlayerManager sharedInstance]startRealPlay:iVideoplayPort window:hPlayWnd];
        // PLAY_PlaySound(kRealplayPort);
    }
    return nRet;
}

-(DeviceTreeNode*) GetDevNodeByCallNum:(NSString*)strUserId
{
    
    for(int i=0; i<[DHDataCenter sharedInstance].arrVTNodes.count;i++ )
    {
        DeviceTreeNode* treeNode = [DHDataCenter sharedInstance].arrVTNodes[i];
        if([treeNode.strCallNum isEqualToString:strUserId])
        {
            return treeNode;
        }

    }
    return [DHDataCenter sharedInstance].arrVTNodes[0];
}
@end
