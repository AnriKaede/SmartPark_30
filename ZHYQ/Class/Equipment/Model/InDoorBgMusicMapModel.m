//
//  InDoorBgMusicMapModel.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/16.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "InDoorBgMusicMapModel.h"

@implementation InDoorBgMusicMapModel

- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        id MUSIC_STATUS = data[@"MUSIC_STATUS"];
        self.MUSIC_STATUS = [NSString stringWithFormat:@"%@", MUSIC_STATUS];
    }
    return self;
}

@end
