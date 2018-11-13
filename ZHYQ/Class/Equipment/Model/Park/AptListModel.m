//
//  AptListModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/6/20.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "AptListModel.h"

@implementation AptListModel

- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        NSDictionary *order = data[@"order"];
        if(order != nil && ![order isKindOfClass:[NSNull class]]){
            AptOrderModel *orderModel = [[AptOrderModel alloc] initWithDataDic:order];
            self.orderModel = orderModel;
        }
        
        NSDictionary *parkingArea = data[@"parkingArea"];
        if(parkingArea != nil && ![parkingArea isKindOfClass:[NSNull class]]){
            AptParkingAreaModel *parkingAreaModel = [[AptParkingAreaModel alloc] initWithDataDic:parkingArea];
            self.parkingAreaModel = parkingAreaModel;
        }
        
        NSDictionary *parkingSpace = data[@"parkingSpace"];
        if(parkingSpace != nil && ![parkingSpace isKindOfClass:[NSNull class]]){
            AptParkingSpaceModel *parkingSpaceModel = [[AptParkingSpaceModel alloc] initWithDataDic:parkingSpace];
            self.parkingSpaceModel = parkingSpaceModel;
        }
    }
    return self;
}

@end
