//
//  DistributorFloorModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/5.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "DistributorFloorModel.h"

@implementation DistributorFloorModel

- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        NSArray *deviceInfoList = data[@"deviceInfoList"];
        if(deviceInfoList != nil && ![deviceInfoList isKindOfClass:[NSNull class]] && deviceInfoList.count > 0){
            NSMutableArray *devices = @[].mutableCopy;
            [deviceInfoList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DistributorDeviceModel *deviceModel = [[DistributorDeviceModel alloc] initWithDataDic:obj];
                [devices addObject:deviceModel];
            }];
            self.deviceInfoList = devices;
        }
    }
    return self;
}

@end
