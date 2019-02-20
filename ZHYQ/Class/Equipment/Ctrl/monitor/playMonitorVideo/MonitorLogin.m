//
//  MonitorLogin.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/18.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "MonitorLogin.h"
#import "LoginManager.h"
#import "GroupManager.h"
#import "DHHudPrecess.h"

@implementation MonitorLogin

+ (void)loginWithAddress:(NSString *)address withPort:(NSString *)port withName:(NSString *)name withPsw:(NSString *)psw withResule:(LoginResult)loginResult{
    //页面加载时,向平台请求业务数据回调
    int ret = [[GroupManager sharedInstance]attachIssueCallback];
    if ( DPSDK_RET_SUCCESS != ret)
    {
        printf("SetDPSDKIssueCallback fail");
    }
    
    Login_Info_t logInfo =  {0};
    
    logInfo.nPort = [port intValue];
    strcpy(logInfo.szIp, [address UTF8String]);
    strcpy(logInfo.szUsername, [name UTF8String]);
    strcpy(logInfo.szPassword, [psw UTF8String]);
    logInfo.nProtocol = DPSDK_PROTOCOL_VERSION_II;
    logInfo.iType = 2;
    
    dispatch_queue_t queue2 = dispatch_queue_create("Queue2", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue2, ^{
        int nRet = [[LoginManager sharedInstance]loginServer:logInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ( DPSDK_RET_SUCCESS == nRet) {
                //加载组织设备信息
                int ret = [[GroupManager sharedInstance]loadGroupInfo];
                if (ret != DPSDK_RET_SUCCESS) {
                    MSG(@"", @"加载组织设备信息失败", @"确定");
                    [self logoutServer];
//                    return NO;
                    loginResult(NO);
                }
                //一直到数据加载完成
                NSDate * date = [NSDate dateWithTimeIntervalSinceNow:0];
                while (TRUE) {
                    Sleep(0.2);//
                    NSDate * dateNow = [NSDate date];
                    NSTimeInterval t = [dateNow timeIntervalSinceDate:date];
                    
                    //超时时间30s
                    if ( t > 30) {
                        MSG(@"", @"数据加载超时", @"");
//                        return NO;
                        loginResult(NO);
                    }
                    if ([[GroupManager sharedInstance]isLoadComplete]) {
                        break;
                    }
                }
//                return YES;
                loginResult(YES);
            }else {
//                return NO;
                loginResult(NO);
            }
        });
    });
}

+ (void)logoutServer
{
    int nRet = [[LoginManager sharedInstance]logoutServer];
    if ( DPSDK_RET_SUCCESS == nRet)
    {
        NSLog(@"因数据加载超时或者失败退出平台登陆");
    }
}
+ (void)loginErrorMsg:(int)nError
{
    switch (nError)
    {
        case 1000424:
            MSG(@"", _L(@"login_error_pwd"), @"");
            break;
            
        case 1000423:
        case 1000531:
            MSG(@"", _L(@"login_error_account"), @"");
            break;
            
        case 10005421:
            MSG(@"", _L(@"login_error_registered"), @"");
            break;
            
        case 1000426:
            MSG(@"", _L(@"login_error_locked"), @"");
            break;
            
        default:
            MSG(@"", _L(@"login_error_connect"), @"");
            break;
    }
}

@end
