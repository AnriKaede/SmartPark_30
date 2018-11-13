//
//  VisitorViserModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/20.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "VisitorViserModel.h"

@implementation VisitorViserModel
- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        NSString *idNum = data[@"idNum"];
        if(idNum != nil && ![idNum isKindOfClass:[NSNull class]]){
            self.idNum = idNum;
        }else {
            self.idNum = @"";
        }
        
        NSString *name = data[@"name"];
        if(name != nil && ![name isKindOfClass:[NSNull class]]){
            self.name = name;
        }else {
            self.name = @"";
        }
        
        NSString *sex = data[@"sex"];
        if(sex != nil && ![sex isKindOfClass:[NSNull class]]){
            self.sex = sex;
        }else {
            self.sex = @"";
        }
        
        NSString *phone = data[@"phone"];
        if(phone != nil && ![phone isKindOfClass:[NSNull class]]){
            self.phone = phone;
        }else {
            self.phone = @"";
        }
        
    }
    return self;
}
@end
