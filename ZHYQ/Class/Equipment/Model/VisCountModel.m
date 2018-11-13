//
//  VisCountModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/22.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "VisCountModel.h"

@implementation VisCountModel

- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        NSArray *visItems = data[@"items"];
        if(visItems != nil && ![visItems isKindOfClass:[NSNull class]]){
            NSMutableArray *items = @[].mutableCopy;
            [visItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                VisCountItemModel *model = [[VisCountItemModel alloc] initWithDataDic:obj];
                [items addObject:model];
            }];
            self.items = items;
        }else {
            self.items = @[];
        }
        
    }
    return self;
}

@end
