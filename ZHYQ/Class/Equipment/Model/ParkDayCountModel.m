//
//  ParkDayCountModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ParkDayCountModel.h"

@implementation ParkDayCountModel

- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        NSDictionary *currentFlowCount = data[@"currentFlowCount"];
        if(currentFlowCount != nil && ![currentFlowCount isKindOfClass:[NSNull class]]){
            self.flowCountModel = [[ParkFlowCountModel alloc] initWithDataDic:currentFlowCount];
        }
        
        NSDictionary *currentFlowTraceTime = data[@"currentFlowTraceTime"];
        if(currentFlowTraceTime != nil && ![currentFlowTraceTime isKindOfClass:[NSNull class]]){
            self.flowTraceModel = [[FlowTraceModel alloc] initWithDataDic:currentFlowTraceTime];
        }
    }
    return self;
}

@end
