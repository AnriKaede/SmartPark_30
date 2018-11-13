//
//  EnvInfoModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/8.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "EnvInfoModel.h"

@implementation EnvInfoModel

- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        NSDictionary *attributes = data[@"attributes"];
        if(attributes != nil && ![attributes isKindOfClass:[NSNull class]]){
            EnvAttributesModel *model = [[EnvAttributesModel alloc] initWithDataDic:attributes];
            self.envAttributesModel = model;
        }
        
        NSString *smallWhite = data[@"smallWhite"];
        if(smallWhite != nil && ![smallWhite isKindOfClass:[NSNull class]]){
            smallWhite = [smallWhite stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            self.smallWhite = smallWhite;
        }
        
        NSString *smallBlue = data[@"smallBlue"];
        if(smallBlue != nil && ![smallBlue isKindOfClass:[NSNull class]]){
            smallBlue = [smallBlue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            self.smallBlue = smallBlue;
        }
        
        NSString *bigColor = data[@"bigColor"];
        if(bigColor != nil && ![bigColor isKindOfClass:[NSNull class]]){
            bigColor = [bigColor stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            self.bigColor = bigColor;
        }
        
    }
    return self;
}

@end
