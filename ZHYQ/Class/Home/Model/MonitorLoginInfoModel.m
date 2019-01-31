//
//  MonitorLoginInfoModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/17.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "MonitorLoginInfoModel.h"
#import "AESUtil.h"

@implementation MonitorLoginInfoModel

- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){

        NSString *dssAddr = data[@"dssAddr"];
        NSString *dssAdmin = data[@"dssAdmin"];
        NSString *dssPasswd = data[@"dssPasswd"];
        NSString *dssPort = data[@"dssPort"];
        
        NSString *decAddr = [AESUtil decryptAES:dssAddr key:AESKey];
        NSString *decAdmin = [AESUtil decryptAES:dssAdmin key:AESKey];
        NSString *decPasswd = [AESUtil decryptAES:dssPasswd key:AESKey];
        NSString *decPort = dssPort;
        
        self.dssAddr = decAddr;
        self.dssAdmin = decAdmin;
        self.dssPasswd = decPasswd;
        self.dssPort = decPort;
    }
    return self;
}

@end
