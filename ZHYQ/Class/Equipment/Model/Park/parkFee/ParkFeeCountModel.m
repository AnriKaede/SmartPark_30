//
//  ParkFeeCountModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/18.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "ParkFeeCountModel.h"

@implementation ParkFeeCountModel

- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        NSArray *items = data[@"items"];
        NSMutableArray *payItems = @[].mutableCopy;
        [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ParkFeePayModel *payModel = [[ParkFeePayModel alloc] initWithDataDic:obj];
            [payItems addObject:payModel];
        }];
        self.items = payItems;
    }
    return self;
}

@end
