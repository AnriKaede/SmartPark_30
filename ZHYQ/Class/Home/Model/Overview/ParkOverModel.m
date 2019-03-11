//
//  ParkOverModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/11.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "ParkOverModel.h"

@implementation ParkOverModel

- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        NSArray *online = data[@"online"][@"items"];
        NSMutableArray *onlines = @[].mutableCopy;
        [online enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            OverOnlineModel *model = [[OverOnlineModel alloc] initWithDataDic:obj];
            [onlines addObject:model];
        }];
        self.onlines = onlines;
        NSNumber *onlineTotalCount = data[@"online"][@"totalCount"];
        if(onlineTotalCount != nil && ![onlineTotalCount isKindOfClass:[NSNull class]]){
            self.onlineTotalCount = onlineTotalCount;
        }
        
        NSArray *alarm = data[@"alarm"][@"items"];
        NSMutableArray *alarms = @[].mutableCopy;
        [alarm enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            OverAlarmModel *model = [[OverAlarmModel alloc] initWithDataDic:obj];
            [alarms addObject:model];
        }];
        self.alarms = alarms;
        NSNumber *alarmTotalCount = data[@"alarm"][@"totalCount"];
        if(alarmTotalCount != nil && ![alarmTotalCount isKindOfClass:[NSNull class]]){
            self.alarmTotalCount = alarmTotalCount;
        }
        
        NSArray *used = data[@"used"][@"items"];
        NSMutableArray *useds = @[].mutableCopy;
        [used enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            OverDealModel *model = [[OverDealModel alloc] initWithDataDic:obj];
            [useds addObject:model];
        }];
        self.useds = useds;
        NSNumber *usedTotalCount = data[@"used"][@"totalCount"];
        if(usedTotalCount != nil && ![usedTotalCount isKindOfClass:[NSNull class]]){
            self.usedTotalCount = usedTotalCount;
        }
        
        NSArray *inspection = data[@"inspection"][@"items"];
        NSMutableArray *inspections = @[].mutableCopy;
        [inspection enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            OverCheckModel *model = [[OverCheckModel alloc] initWithDataDic:obj];
            [inspections addObject:model];
        }];
        self.inspections = inspections;
        NSNumber *inspectionTotalCount = data[@"inspection"][@"totalCount"];
        if(inspectionTotalCount != nil && ![inspectionTotalCount isKindOfClass:[NSNull class]]){
            self.inspectionTotalCount = inspectionTotalCount;
        }
    }
    return self;
}

@end
