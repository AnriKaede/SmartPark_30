//
//  LoginManager.h
//  DemoDPSDK
//
//  Created by jiang_bin on 14-4-16.
//  Copyright (c) 2014年 jiang_bin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHDataCenter.h"

@interface LoginManager : NSObject
{
    Login_Info_t    loginInfo_;
}

+ (LoginManager *) sharedInstance;

/**
 *  登录服务器
 *  @param loginInfo 登录信息
 *  @return 返回错误码见dpsdk_retval_e
 */
- (int)loginServer:(Login_Info_t ) loginInfo;

/**
 *  登出服务器
 *  @return 返回错误码见dpsdk_retval_e
 */
- (int)logoutServer;
@end
