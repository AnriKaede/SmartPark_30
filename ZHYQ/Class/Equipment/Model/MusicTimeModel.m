//
//  MusicTimeModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/12.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "MusicTimeModel.h"

@implementation MusicTimeModel

- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        NSNumber *taskId = data[@"id"];
        if(taskId != nil && ![taskId isKindOfClass:[NSNull class]]){
            self.musicTimeId = taskId;
        }
    }
    return self;
}

@end
