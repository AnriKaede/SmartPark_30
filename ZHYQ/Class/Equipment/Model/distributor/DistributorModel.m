//
//  DistributorModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/8/16.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "DistributorModel.h"

@implementation DistributorModel

- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        NSMutableArray *tagArrays = @[].mutableCopy;
        NSArray *tagArray = data[@"tagArray"];
        [tagArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MeetRoomStateModel *stateModel = [[MeetRoomStateModel alloc] initWithDataDic:obj];
            [tagArrays addObject:stateModel];
        }];
        
        self.tagArray = tagArrays;
    }
    return self;
}

@end
