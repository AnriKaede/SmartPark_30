//
//  VisitorFinishModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/20.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "VisitorFinishModel.h"

@implementation VisitorFinishModel

- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        NSDictionary *user = data[@"user"];
        if(user != nil && ![user isKindOfClass:[NSNull class]]){
            VisitorUserModel *userModel = [[VisitorUserModel alloc] initWithDataDic:user];
            self.userModel = userModel;
        }
        
        NSDictionary *visitor = data[@"visitor"];
        if(visitor != nil && ![visitor isKindOfClass:[NSNull class]]){
            VisitorViserModel *visitorModel = [[VisitorViserModel alloc] initWithDataDic:visitor];
            self.viserModel = visitorModel;
        }
        
        NSString *startTime = data[@"startTime"];
        if(startTime != nil && ![startTime isKindOfClass:[NSNull class]]){
            self.startTime = startTime;
        }else {
            self.startTime = @"";
        }
        
        NSString *logOffTime = data[@"logOffTime"];
        if(logOffTime != nil && ![logOffTime isKindOfClass:[NSNull class]]){
            self.logOffTime = logOffTime;
        }else {
            self.logOffTime = @"";
        }
        
        NSString *reasons = data[@"reasons"];
        if(reasons != nil && ![reasons isKindOfClass:[NSNull class]]){
            self.reasons = reasons;
        }else {
            self.reasons = @"";
        }
        
    }
    return self;
}

@end
