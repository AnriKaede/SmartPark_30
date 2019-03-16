//
//  HomeViewController+IMChatManager.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/3/16.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "HomeViewController+IMChatManager.h"
#import <Hyphenate/Hyphenate.h>
#import <UserNotifications/UserNotifications.h>
#import "EaseSDKHelper.h"

@interface HomeViewController()<EMChatManagerDelegate, EMCallManagerDelegate>
{
    BOOL gIsCalling;
}
@end

@implementation HomeViewController (IMChatManager)

- (void)dealloc {
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient].callManager removeDelegate:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNOTIFICATION_MAKE1V1CALL object:nil];
}

- (void)IMLogin {
    if(![EMClient sharedClient].isLoggedIn){
        NSString *loginName = [[NSUserDefaults standardUserDefaults] objectForKey:KLoginUserName];
        [[EMClient sharedClient] loginWithUsername:loginName password:[NSString stringWithFormat:@"%@%@", loginName, IMPasswordRule] completion:^(NSString *aUsername, EMError *aError) {
            if (!aError) {
                NSLog(@"登录成功");
            } else {
                NSLog(@"登录失败");
                //                [self showHint:KRequestFailMsg];
            }
        }];
    }
    
    // 代理环信协议(本地通知)
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].callManager addDelegate:self delegateQueue:nil];
    
    // 添加环信语音通话监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMake1v1Call:) name:KNOTIFICATION_MAKE1V1CALL object:nil];
}
#pragma mark 接收消息
- (void)messagesDidReceive:(NSArray *)aMessages {
    for (EMMessage *msg in aMessages) {
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
                    
                    EMMessageBody *body = msg.body;
                    content.body = [self bodyMsg:body];
                    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:msg.messageId content:content trigger:trigger];
                    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
                }
            }else {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.fireDate = [NSDate date]; //触发通知的时间
                notification.alertBody = [self bodyMsg:msg.body];
                notification.alertAction = @"Open";
                notification.timeZone = [NSTimeZone defaultTimeZone];
                notification.soundName = UILocalNotificationDefaultSoundName;
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            }
        }else {
            // 设置触发时间
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.fireDate = [NSDate date]; //触发通知的时间
            notification.alertBody = [self bodyMsg:msg.body];
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

#pragma mark - NSNotification点击拨打电话
- (void)handleMake1v1Call:(NSNotification*)notify {
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
    
    void (^completionBlock)(EMCallSession *, EMError *) = ^(EMCallSession *aCallSession, EMError *aError) {
        if (aError || aCallSession == nil) {
            gIsCalling = NO;
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"call.initFailed", @"Establish call failure") message:aError.errorDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
            [alertView show];
            
            return;
        } else {
            gIsCalling = NO;
            [[EMClient sharedClient].callManager endCall:aCallSession.callId reason:EMCallEndReasonNoResponse];
        }
    };
    
    gIsCalling = YES;
    
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    options.enableCustomizeVideoData = aIsCustomVideo;
    
    [[EMClient sharedClient].callManager startCall:aType remoteName:aUsername ext:@"" completion:^(EMCallSession *aCallSession, EMError *aError) {
        completionBlock(aCallSession, aError);
    }];
}

/*!
 *  \~chinese
 *  用户A拨打用户B，用户B会收到这个回调
 *
 *  @param aSession  会话实例
 *
 */
- (void)callDidReceive:(EMCallSession *)aSession {
    NSLog(@"接到通话 %@", aSession.localName);
}

/*!
 *  \~chinese
 *  通话通道建立完成，用户A和用户B都会收到这个回调
 *
 *  @param aSession  会话实例
 *
 */
- (void)callDidConnect:(EMCallSession *)aSession {
    NSLog(@"通话通道建立完成 %@", aSession.localName);
}

/*!
 *  \~chinese
 *  用户B同意用户A拨打的通话后，用户A会收到这个回调
 *
 *  @param aSession  会话实例
 */
- (void)callDidAccept:(EMCallSession *)aSession {
    NSLog(@"用户B同意用户A拨打的通话后，用户A会收到这个回调 %@", aSession.localName);
}

/*!
 *  \~chinese
 *  1. 用户A或用户B结束通话后，双方会收到该回调
 *  2. 通话出现错误，双方都会收到该回调
 *
 *  @param aSession  会话实例
 *  @param aReason   结束原因
 *  @param aError    错误
 */
- (void)callDidEnd:(EMCallSession *)aSession
            reason:(EMCallEndReason)aReason
             error:(EMError *)aError {
    NSLog(@"用户A或用户B结束通话后，双方会收到该回调 %@", aSession.localName);
}

@end
