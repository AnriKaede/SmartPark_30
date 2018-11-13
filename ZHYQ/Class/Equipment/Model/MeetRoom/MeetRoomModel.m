//
//  MeetRoomModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/23.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "MeetRoomModel.h"

@implementation MeetRoomModel

- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        NSArray *airList = data[@"airList"];
        NSMutableArray *airListAry = @[].mutableCopy;
        if(airList != nil && ![airList isKindOfClass:[NSNull class]]){
            [airList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                MeetRoomDeviceModel *model = [[MeetRoomDeviceModel alloc] initWithDataDic:obj];
                [airListAry addObject:model];
            }];
        }
        self.airList = airListAry;
    }
    return self;
}

@end
