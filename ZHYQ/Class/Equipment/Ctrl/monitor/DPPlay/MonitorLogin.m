//
//  MonitorLogin.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/18.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "MonitorLogin.h"

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
    
}

+ (void)logoutServer {
    NSError *error = nil;
    [[DHLoginManager sharedInstance] logout:&error];
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

+ (void)selectNodeWithChanneId:(NSString *)channeId withNode:(QueryNode)queryNode {
    NSMutableDictionary *treeNodeDic = [DHDeviceManager sharedInstance].treeNodeDic;
    if([treeNodeDic containsObjectForKey:channeId]){
        NSLog(@"%@", treeNodeDic[channeId]);
        TreeNode *node = (TreeNode *)treeNodeDic[channeId];
        [DHDataCenter sharedInstance].selectNode = node;
        queryNode(node);
    }else {
        NSLog(@"%@", @"未找到此设备");
    }
}

@end
