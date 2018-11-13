//
//  MonitorLogin.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/18.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MonitorLogin : NSObject

+ (BOOL)loginWithAddress:(NSString *)address withPort:(NSString *)port withName:(NSString *)name withPsw:(NSString *)psw;

+ (void)logoutServer;

@end
