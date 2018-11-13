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

+ (BOOL)loginWithAddress:(NSString *)address withPort:(NSString *)port withName:(NSString *)name withPsw:(NSString *)psw {
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
    
    int nRet = [[LoginManager sharedInstance]loginServer:logInfo];
    
    //保存帐户信息
//    [DHDataCenter sharedInstance].serverIP   = @"113.240.243.212";
//    [DHDataCenter sharedInstance].serverPort = @"9000";
//    [DHDataCenter sharedInstance].userName   = @"admin";
//    [DHDataCenter sharedInstance].passCode   = @"admin1133";
//    [[DHDataCenter sharedInstance] saveAccount];
    
    if ( DPSDK_RET_SUCCESS == nRet)
    {
        //加载组织设备信息
        int ret = [[GroupManager sharedInstance]loadGroupInfo];
        if (ret != DPSDK_RET_SUCCESS)
        {
            MSG(@"", @"加载组织设备信息失败", @"确定");
            [self logoutServer];
            return NO;
        }
        
        //一直到数据加载完成
        NSDate * date = [NSDate dateWithTimeIntervalSinceNow:0];
        while (TRUE)
        {
            Sleep(0.2);//
            
            NSDate * dateNow = [NSDate date];
            NSTimeInterval t = [dateNow timeIntervalSinceDate:date];
            
            if ( t > 30) //超时时间30s
            {
                MSG(@"", @"数据加载超时", @"");
                return NO;
            }
            
            if ([[GroupManager sharedInstance]isLoadComplete])
            {
                break;
            }
        }
        
        return YES;
    }
    else
    {
//        [self loginErrorMsg:nRet];
        return NO;
    }
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
