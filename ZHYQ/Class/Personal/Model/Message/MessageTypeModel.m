//
//  MessageTypeModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/29.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "MessageTypeModel.h"

@implementation MessageTypeModel

- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        if([data.allKeys containsObject:@"latestMessage"]){
            NSDictionary *latestMessage = data[@"latestMessage"];
            if(latestMessage != nil && ![latestMessage isKindOfClass:[NSNull class]]){
                MessageModel *msgModel = [[MessageModel alloc] initWithDataDic:latestMessage];
                self.messageModel = msgModel;
            }
        }
    }
    return self;
}

@end
