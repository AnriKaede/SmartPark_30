//
//  DemoCallManager.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 22/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import "DemoCallManager.h"

#if DEMO_CALL == 1

#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

#import "EaseSDKHelper.h"
#import "DemoConfManager.h"

#import "EMGlobalVariables.h"
#import "Call1v1AudioViewController.h"
#import "Call1v1VideoViewController.h"

#ifdef DEBUG
#import "EMCallRecorderPlugin.h"
#endif

#import <UserNotifications/UserNotifications.h>

static DemoCallManager *callManager = nil;

@interface DemoCallManager()<EMChatManagerDelegate, EMCallManagerDelegate, EMCallBuilderDelegate>

@property (strong, nonatomic) NSObject *callLock;
@property (strong, nonatomic) EMCallSession *currentCall;
@property (nonatomic, strong) EM1v1CallViewController *currentController;

@property (strong, nonatomic) NSTimer *timeoutTimer;

@property (nonatomic, strong) CTCallCenter *callCenter;

@end

#endif

@implementation DemoCallManager

#if DEMO_CALL == 1

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _initManager];
    }
    
    return self;
}

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        callManager = [[DemoCallManager alloc] init];
    });
    
    return callManager;
}

- (void)dealloc
{
    self.callCenter = nil;
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient].callManager removeDelegate:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNOTIFICATION_MAKE1V1CALL object:nil];
}

#pragma mark - private

- (void)_initManager
{
    _callLock = [[NSObject alloc] init];
    _currentCall = nil;
    _currentController = nil;
    
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].callManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].callManager setBuilderDelegate:self];
    
#ifdef DEBUG
    //录制相关功能初始化
    [EMCallRecorderPlugin initGlobalConfig];
#endif
    
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"calloptions.data"];
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
        options = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
    } else {
        options = [[EMClient sharedClient].callManager getCallOptions];
        options.isSendPushIfOffline = YES;
        options.videoResolution = EMCallVideoResolution640_480;
        options.isFixedVideoResolution = YES;
    }
    [[EMClient sharedClient].callManager setCallOptions:options];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMake1v1Call:) name:KNOTIFICATION_MAKE1V1CALL object:nil];
    
//    __weak typeof(self) weakSelf = self;
//    self.callCenter = [[CTCallCenter alloc] init];
//    self.callCenter.callEventHandler = ^(CTCall* call) {
////        if(call.callState == CTCallStateConnected) {
////            [weakSelf hangupCallWithReason:EMCallEndReasonBusy];
////        }
//
//        if(call.callState == CTCallStateConnected) {
//            [weakSelf.currentController muteCall];
//        } else if(call.callState == CTCallStateDisconnected) {
//            [weakSelf.currentController resumeCall];
//        }
//    };
}

#pragma mark - Call Timeout Before Answered

- (void)_timeoutBeforeCallAnswered
{
    [self endCallWithId:self.currentCall.callId reason:EMCallEndReasonNoResponse];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"call.autoHangup", @"No response and Hang up") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)_startCallTimeoutTimer
{
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:50 target:self selector:@selector(_timeoutBeforeCallAnswered) userInfo:nil repeats:NO];
}

- (void)_stopCallTimeoutTimer
{
    if (self.timeoutTimer == nil) {
        return;
    }
    
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
}

#pragma mark - EMCallManagerDelegate

- (void)callDidReceive:(EMCallSession *)aSession
{
    if (!aSession || [aSession.callId length] == 0) {
        return ;
    }
    
    if ([EaseSDKHelper shareHelper].isShowingimagePicker) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideImagePicker" object:nil];
    }
    
    if(gIsCalling || (self.currentCall && self.currentCall.status != EMCallSessionStatusDisconnected)){
        [[EMClient sharedClient].callManager endCall:aSession.callId reason:EMCallEndReasonBusy];
        return;
    }
    
    gIsCalling = YES;
    @synchronized (_callLock) {
        [self _startCallTimeoutTimer];
        
        self.currentCall = aSession;
        if (aSession.type == EMCallTypeVoice) {
            self.currentController = [[Call1v1AudioViewController alloc] initWithCallSession:self.currentCall];
        } else {
            self.currentController = [[Call1v1VideoViewController alloc] initWithCallSession:self.currentCall];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.currentController) {
                self.currentController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                [gMainController presentViewController:self.currentController animated:NO completion:nil];
            }
        });
    }
    
    [self callLocalPush:aSession];
}

- (void)callDidConnect:(EMCallSession *)aSession
{
    if ([aSession.callId isEqualToString:self.currentCall.callId]) {
        self.currentController.callStatus = EMCallSessionStatusConnected;
    }
}

- (void)callDidAccept:(EMCallSession *)aSession
{
    if ([aSession.callId isEqualToString:self.currentCall.callId]) {
        [self _stopCallTimeoutTimer];
        self.currentController.callStatus = EMCallSessionStatusAccepted;
    }
}

- (void)callDidEnd:(EMCallSession *)aSession
            reason:(EMCallEndReason)aReason
             error:(EMError *)aError
{
    if (![aSession.callId isEqualToString:self.currentCall.callId]) {
        return;
    }
    
    [self _endCallWithId:aSession.callId isNeedHangup:NO reason:aReason];
    if (aReason != EMCallEndReasonHangup) {
        if (aError) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:aError.errorDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
            [alertView show];
        } else {
            NSString *reasonStr = @"通话结束";
            switch (aReason) {
                case EMCallEndReasonNoResponse:
                    reasonStr = @"没有响应";
                    break;
                case EMCallEndReasonDecline:
                    reasonStr = @"对方拒绝接通通话";
                    break;
                case EMCallEndReasonBusy:
                    reasonStr = @"对方正在通话中";
                    break;
                case EMCallEndReasonFailed:
                    reasonStr = @"通话建立连接失败";
                    break;
                case EMCallEndReasonRemoteOffline:
                    reasonStr = @"对方不在线，无法接听通话";
                    break;
                default:
                    break;
            }
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:reasonStr delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

- (void)callStateDidChange:(EMCallSession *)aSession
                      type:(EMCallStreamingStatus)aStatus
{
    if ([aSession.callId isEqualToString:self.currentCall.callId]) {
        [self.currentController updateStreamingStatus:aStatus];
    }
}

- (void)callNetworkDidChange:(EMCallSession *)aSession
                      status:(EMCallNetworkStatus)aStatus
{
    if ([aSession.callId isEqualToString:self.currentCall.callId]) {
//        [self.currentController setNetwork:aStatus];
    }
}

#pragma mark - EMCallBuilderDelegate

- (void)callRemoteOffline:(NSString *)aRemoteName
{
    NSString *text = [[EMClient sharedClient].callManager getCallOptions].offlineMessageText;
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:text];
    NSString *fromStr = [EMClient sharedClient].currentUsername;
    EMMessage *message = [[EMMessage alloc] initWithConversationID:aRemoteName from:fromStr to:aRemoteName body:body ext:@{@"em_apns_ext":@{@"em_push_title":text}}];
    message.chatType = EMChatTypeChat;
    
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:nil];
}

#pragma mark - NSNotification

- (void)handleMake1v1Call:(NSNotification*)notify
{
    if (!notify.object) {
        return;
    }
    
    if (gIsCalling) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"有通话正在进行" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    EMCallType type = (EMCallType)[[notify.object objectForKey:@"type"] integerValue];
    if (type == EMCallTypeVideo) {
        [self _makeCallWithUsername:[notify.object valueForKey:@"chatter"] type:type isCustomVideoData:NO];
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//
//        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"title.conference.default", @"Default") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [self _makeCallWithUsername:[notify.object valueForKey:@"chatter"] type:type isCustomVideoData:NO];
//        }];
//        [alertController addAction:defaultAction];
//
//        UIAlertAction *customAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"title.conference.custom", @"Custom") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [self _makeCallWithUsername:[notify.object valueForKey:@"chatter"] type:type isCustomVideoData:YES];
//        }];
//        [alertController addAction:customAction];
//
//        [alertController addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"Cancel") style: UIAlertActionStyleCancel handler:nil]];
//
//        [self.mainController.navigationController presentViewController:alertController animated:YES completion:nil];
    } else {
        [self _makeCallWithUsername:[notify.object valueForKey:@"chatter"] type:type isCustomVideoData:NO];
    }
}

- (void)_makeCallWithUsername:(NSString *)aUsername
                         type:(EMCallType)aType
            isCustomVideoData:(BOOL)aIsCustomVideo
{
    if ([aUsername length] == 0) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    void (^completionBlock)(EMCallSession *, EMError *) = ^(EMCallSession *aCallSession, EMError *aError) {
        DemoCallManager *strongSelf = weakSelf;
        if (strongSelf) {
            if (aError || aCallSession == nil) {
                gIsCalling = NO;
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"call.initFailed", @"Establish call failure") message:aError.errorDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
                [alertView show];
                
                return;
            }
            
            @synchronized (self.callLock) {
                strongSelf.currentCall = aCallSession;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (aType == EMCallTypeVideo) {
                        strongSelf.currentController = [[Call1v1VideoViewController alloc] initWithCallSession:strongSelf.currentCall];
                    } else {
                        strongSelf.currentController = [[Call1v1AudioViewController alloc] initWithCallSession:strongSelf.currentCall];
                    }
                    
                    if (strongSelf.currentController) {
                        [gMainController presentViewController:strongSelf.currentController animated:NO completion:nil];
                    }
                });
            }
            
            [weakSelf _startCallTimeoutTimer];
        }
        else {
            gIsCalling = NO;
            [[EMClient sharedClient].callManager endCall:aCallSession.callId reason:EMCallEndReasonNoResponse];
        }
    };
    
    gIsCalling = YES;
    
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    options.enableCustomizeVideoData = aIsCustomVideo;
    
    [[EMClient sharedClient].callManager startCall:aType remoteName:aUsername ext:@"123" completion:^(EMCallSession *aCallSession, EMError *aError) {
        completionBlock(aCallSession, aError);
    }];
}

#pragma mark - public

- (void)saveCallOptions
{
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"calloptions.data"];
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    [NSKeyedArchiver archiveRootObject:options toFile:file];
}

- (void)answerCall:(NSString *)aCallId
{
    if (!self.currentCall || ![self.currentCall.callId isEqualToString:aCallId]) {
        return ;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = [[EMClient sharedClient].callManager answerIncomingCall:weakSelf.currentCall.callId];
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error.code == EMErrorNetworkUnavailable) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"network.disconnection", @"Network disconnection") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
                    [alertView show];
                }
                else{
                    [weakSelf endCallWithId:aCallId reason:EMCallEndReasonFailed];
                }
            });
        }
    });
}

- (void)_endCallWithId:(NSString *)aCallId
          isNeedHangup:(BOOL)aIsNeedHangup
                reason:(EMCallEndReason)aReason
{
    if (!self.currentCall || ![self.currentCall.callId isEqualToString:aCallId]) {
        if (aIsNeedHangup) {
            [[EMClient sharedClient].callManager endCall:aCallId reason:aReason];
        }
        return ;
    }
    
    gIsCalling = NO;
    [self _stopCallTimeoutTimer];
    
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    options.enableCustomizeVideoData = NO;
    
    if (aIsNeedHangup) {
        [[EMClient sharedClient].callManager endCall:aCallId reason:aReason];
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    @synchronized (_callLock) {
        self.currentCall = nil;
        
        //        self.currentController.isDismissing = YES;
        [self.currentController clearDataAndView];
        [self.currentController dismissViewControllerAnimated:NO completion:nil];
        self.currentController = nil;
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
        [audioSession setActive:YES error:nil];
    }
}

- (void)endCallWithId:(NSString *)aCallId
               reason:(EMCallEndReason)aReason
{
    [self _endCallWithId:aCallId isNeedHangup:YES reason:aReason];
}

#pragma mark 接收到语音/视频通话 发送本地通知
- (void)callLocalPush:(EMCallSession *)aSession {
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    // App在后台
    if (state == UIApplicationStateBackground) {
        //发送本地推送
        if (NSClassFromString(@"UNUserNotificationCenter")) { // ios 10
            if (@available(iOS 10.0, *)) {
                // 设置触发时间
                UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.01 repeats:NO];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.sound = [UNNotificationSound defaultSound];
                content.body = @"您有一个新来电...";
                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:aSession.callId content:content trigger:trigger];
                [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
            }
        }else {
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.fireDate = [NSDate date]; //触发通知的时间
            notification.alertBody = @"您有一个新来电...";
            notification.alertAction = @"Open";
            notification.timeZone = [NSTimeZone defaultTimeZone];
            notification.soundName = UILocalNotificationDefaultSoundName;
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
    }
}

- (NSString *)bodyMsg:(EMMessageBody *)body {
    NSString *bodyStr = @"您有一条新消息";
    if(body.type == EMMessageBodyTypeText){
        EMTextMessageBody *textMsg =  (EMTextMessageBody *)body;
        bodyStr = [NSString stringWithFormat:@"%@", textMsg.text];
    }else if (body.type == EMMessageBodyTypeImage) {
        bodyStr = @"[图片]";
    }else if (body.type == EMMessageBodyTypeVideo) {
        bodyStr = @"[视频]";
    }else if (body.type == EMMessageBodyTypeLocation) {
        bodyStr = @"[位置信息]";
    }else if (body.type == EMMessageBodyTypeVoice) {
        bodyStr = @"[语音]";
    }else if (body.type == EMMessageBodyTypeFile) {
        bodyStr = @"[文件]";
    }
    
    return bodyStr;
}

#endif

@end
