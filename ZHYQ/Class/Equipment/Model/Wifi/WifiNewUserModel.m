//
//  WifiNewUserModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/7.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "WifiNewUserModel.h"

@implementation WifiNewUserModel

- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        NSString *newUser = data[@"newUser"];
        if(newUser != nil && ![newUser isKindOfClass:[NSNull class]]){
            self.addNewUser = newUser;
        }
    }
    return self;
}

@end
