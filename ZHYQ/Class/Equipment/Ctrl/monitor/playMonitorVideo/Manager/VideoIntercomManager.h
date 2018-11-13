//
//  VideoIntercomManager.h
//  DemoDPSDK
//
//  Created by chen_zhongbo on 16/4/27.
//  Copyright © 2016年 jiang_bin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHDataCenter.h"
#import "DHVideoWnd.h"
#import "VtCallInfo.h"
@interface VideoIntercomManager : NSObject
{
@public
    InviteVtCallParam_t* m_invteInfo;/*被动接受邀请时保存的信息*/
    int32_t   nRealSeq_;  /**< 码流请求序号 */
    VtCallInfo* _m_VtCallInfo;  /*保存当前会话信息*/
}
+ (VideoIntercomManager *) sharedInstance;

-(int32_t) setRingCallback;
-(int32_t) setVtCallInviteCallback;
-(int32_t) setGeneralJsonTransportCallback;
- (int)openIntercomPlay;
//主动挂断
-(void) OnStopCallTalk;
//设置播放窗口句柄
-(void)setPlayWnd:(void *)hWnd;
@property (nonatomic, strong) NSString *strVtoName; /*设备名称*/
@property (nonatomic, strong) NSString *strCallNum; /*呼叫号码*/
@property (nonatomic, strong) NSString *strDevID;   /*通道ID*/

//被动接听对讲
- (int) startIntercomVideoCall;
//开门
-(int) OpenDoor;

//拒接通话处理
-(void) OnHangupTalk;
@end
