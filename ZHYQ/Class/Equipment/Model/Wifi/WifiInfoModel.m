//
//  WifiInfoModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/6.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "WifiInfoModel.h"

@implementation WifiInfoModel

- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        NSNumber *wifiId = data[@"id"];
        if(wifiId != nil && ![wifiId isKindOfClass:[NSNull class]]){
            self.wifiId = wifiId;
        }
    }
    return self;
}

@end
