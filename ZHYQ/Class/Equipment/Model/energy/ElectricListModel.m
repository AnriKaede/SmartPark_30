//
//  ElectricListModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/28.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "ElectricListModel.h"
#import "ElectricInfoModel.h"

@implementation ElectricListModel

- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        NSArray *deviceList = data[@"deviceList"];
        if(deviceList != nil && ![deviceList isKindOfClass:[NSNull class]]){
            NSMutableArray *devAry = @[].mutableCopy;
            [deviceList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ElectricInfoModel *model = [[ElectricInfoModel alloc] initWithDataDic:obj];
                [devAry addObject:model];
            }];
            self.deviceList = devAry;
        }
        
    }
    return self;
}

@end
