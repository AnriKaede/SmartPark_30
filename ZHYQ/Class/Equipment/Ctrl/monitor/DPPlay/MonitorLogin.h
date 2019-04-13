//
//  MonitorLogin.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/18.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHDataCenter.h"
#import "DHLoginManager.h"
#import "DHHudPrecess.h"
#import "WeikitErrorCode.h"

typedef void (^LoginResult) (BOOL);
typedef void (^QueryNode) (TreeNode *node);

@interface MonitorLogin : NSObject

+ (void)loginWithAddress:(NSString *)address withPort:(NSString *)port withName:(NSString *)name withPsw:(NSString *)psw withResule:(LoginResult)loginResult;

+ (void)logoutServer;

+ (void)selectNodeWithChanneId:(NSString *)channeId withNode:(QueryNode)queryNode;

@end
