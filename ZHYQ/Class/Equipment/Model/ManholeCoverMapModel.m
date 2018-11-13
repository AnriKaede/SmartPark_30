//
//  ManholeCoverMapModel.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/13.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ManholeCoverMapModel.h"

@implementation ManholeCoverMapModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {

    if([key isEqualToString:@"long"]) {
        _long_1 = value;
    }
    if ([key isEqualToString:@"id"]) {
        _id_1 = value;
    }
    if ([key isEqualToString:@"manhole_cover"]) {
        NSDictionary *dic = (NSDictionary *)value;
        self.holeModel = [[ManholeCoverModel alloc] initWithDataDic:dic];
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
