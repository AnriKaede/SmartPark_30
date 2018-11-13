//
//  AirCompanyModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/7/27.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "AirCompanyModel.h"
#import "AirLayerModel.h"

@implementation AirCompanyModel

- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        NSArray *layers = data[@"layers"];
        NSMutableArray *airLayers = @[].mutableCopy;
        [layers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            AirLayerModel *layerModel = [[AirLayerModel alloc] initWithDataDic:obj];
            [airLayers addObject:layerModel];
        }];
        self.layers = airLayers;
    }
    return self;
}

@end
