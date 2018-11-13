//
//  VisitorUserModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/20.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "VisitorUserModel.h"

@implementation VisitorUserModel
- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        NSString *nickname = data[@"nickname"];
        if(nickname != nil && ![nickname isKindOfClass:[NSNull class]]){
            self.nickname = nickname;
        }else {
            self.nickname = @"";
        }
        
    }
    return self;
}
@end
