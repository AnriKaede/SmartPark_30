//
//  LoginManager.m
//  DemoDPSDK
//
//  Created by jiang_bin on 14-4-16.
//  Copyright (c) 2014年 jiang_bin. All rights reserved.
//

#import "LoginManager.h"

static LoginManager* g_shareLoginManager = nil;

@implementation LoginManager

+ (LoginManager *) sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_shareLoginManager = [[self alloc] init];
    });
    return g_shareLoginManager;
}

/**
 *  登录服务器
 *  @param loginInfo 登录信息
 *  @return 返回错误码见dpsdk_retval_e
 */
- (int)loginServer:(Login_Info_t &)loginInfo
{
    return DPSDK_Login([DHDataCenter sharedInstance]->nDPHandle_,
                       &loginInfo,
                       [DHDataCenter sharedInstance].nTimeout);
}

/**
 *  登出服务器
 *  @return 返回错误码见dpsdk_retval_e
 */
- (int)logoutServer
{
    return DPSDK_Logout([DHDataCenter sharedInstance]->nDPHandle_,
                        [DHDataCenter sharedInstance].nTimeout);
}
@end
