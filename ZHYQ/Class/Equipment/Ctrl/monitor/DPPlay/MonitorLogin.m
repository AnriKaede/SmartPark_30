//
//  MonitorLogin.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/18.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "MonitorLogin.h"
#import "DHDataCenter.h"
#import "DHLoginManager.h"
#import "DHHudPrecess.h"
#import "WeikitErrorCode.h"

@implementation MonitorLogin

+ (void)loginWithAddress:(NSString *)address withPort:(NSString *)port withName:(NSString *)name withPsw:(NSString *)psw withResule:(LoginResult)loginResult{
    
    dispatch_queue_t queue2 = dispatch_queue_create("Queue2", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue2, ^{
        [[DHDataCenter sharedInstance] setHost:address port:port.intValue];
        NSError *error = nil;
        DSSUserInfo *userInfo = [[DHLoginManager sharedInstance] loginWithUserName:name Password:psw error:&error];
        if (error) {
//            MSG("", @"Login failed", "");
            switch (error.code) {
                case YYS_BEC_USER_PASSWORD_ERROR:
                    NSLog(@"username or password error");
                    break;
                case YYS_BEC_USER_SESSION_EXIST:
                    NSLog(@"user logined");
                    break;
                case YYS_BEC_USER_NOT_EXSIT:
                    NSLog(@"user not exsit");
                    break;
                case YYS_BEC_USER_LOGIN_TIMEOUT:
                    NSLog(@"login timeout");
                    break;
                case YYS_BEC_COMMON_NETWORK_ERROR:
                    NSLog(@"network error");
                    break;
                default:
                    break;
            }
            
            loginResult(NO);
            return;
        }
        //call after login
        [[DHDeviceManager sharedInstance] afterLoginInExcute:userInfo];
        [[DHDeviceManager sharedInstance] loadDeviceTree:&error];
        
        loginResult(YES);
    });
    
    #warning 大华SDK旧版本
    /*
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
     */
}

+ (void)logoutServer {
    NSError *error = nil;
    [[DHLoginManager sharedInstance] logout:&error];
    
    #warning 大华SDK旧版本
    /*
    int nRet = [[LoginManager sharedInstance]logoutServer];
    if ( DPSDK_RET_SUCCESS == nRet)
    {
        NSLog(@"因数据加载超时或者失败退出平台登陆");
    }
     */
}
+ (void)loginErrorMsg:(int)nError
{
    switch (nError)
    {
        case 1000424:
//            MSG(@"", _L(@"login_error_pwd"), @"");
            break;
            
        case 1000423:
        case 1000531:
//            MSG(@"", _L(@"login_error_account"), @"");
            break;
            
        case 10005421:
//            MSG(@"", _L(@"login_error_registered"), @"");
            break;
            
        case 1000426:
//            MSG(@"", _L(@"login_error_locked"), @"");
            break;
            
        default:
//            MSG(@"", _L(@"login_error_connect"), @"");
            break;
    }
}

+ (void)selectNodeWithChanneId:(NSString *)channeId {
    NSMutableDictionary *treeNodeDic = [DHDeviceManager sharedInstance].treeNodeDic;
    if([treeNodeDic containsObjectForKey:channeId]){
        NSLog(@"%@", treeNodeDic[channeId]);
        TreeNode *node = (TreeNode *)treeNodeDic[channeId];
        [DHDataCenter sharedInstance].selectNode = node;
    }else {
        NSLog(@"%@", @"未找到此设备");
    }
}

@end
