//
//  MeetRoomStateModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/6/29.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "MeetRoomStateModel.h"

@implementation MeetRoomStateModel

- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        NSNumber *state_id = data[@"id"];
        if(state_id != nil && ![state_id isKindOfClass:[NSNull class]]){
            self.state_id = [NSString stringWithFormat:@"%@", state_id];
        }
    }
    return self;
}

@end
