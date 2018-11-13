//
//  ManholeCoverModel.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/13.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ManholeCoverModel.h"

@implementation ManholeCoverModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        _id_2 = value;
    }
}

- (void)setValue:(id)value forKey:(NSString *)key {
    // ignore null value
    if ([value isKindOfClass:[NSNull class]]) {
        
        return;
    }
    
    [super setValue:value forKey:key];
}

-(id)initWithDataDic:(NSDictionary *)data
{
    if ([data isKindOfClass:[NSDictionary class]]) {
        
        if (self = [super init]) {
            
            [self setValuesForKeysWithDictionary:data];
        }
    }
    return self;
}

@end
