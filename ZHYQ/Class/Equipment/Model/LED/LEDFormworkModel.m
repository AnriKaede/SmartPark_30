//
//  LEDFormworkModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/20.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "LEDFormworkModel.h"

@implementation LEDFormworkModel

- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        NSString *ledFormworkId = data[@"id"];
        if(ledFormworkId != nil && ![ledFormworkId isKindOfClass:[NSNull class]]){
            self.ledFormworkId = ledFormworkId;
        }else {
            self.ledFormworkId = @"";
        }
    }
    return self;
}

@end
