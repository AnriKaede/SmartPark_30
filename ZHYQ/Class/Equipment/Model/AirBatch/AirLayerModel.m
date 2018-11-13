//
//  AirLayerModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/7/27.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "AirLayerModel.h"
#import "AirRoomModel.h"

@implementation AirLayerModel

- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        NSArray *rooms = data[@"rooms"];
        NSMutableArray *airRooms = @[].mutableCopy;
        [rooms enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            AirRoomModel *roomModel = [[AirRoomModel alloc] initWithDataDic:obj];
            [airRooms addObject:roomModel];
        }];
        self.rooms = airRooms;
    }
    return self;
}

@end
