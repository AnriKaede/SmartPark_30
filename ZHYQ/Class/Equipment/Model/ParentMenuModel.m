//
//  ParentMenuModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/23.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "ParentMenuModel.h"
#import "MenuModel.h"

@implementation ParentMenuModel

- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        NSArray *items = data[@"items"];
        if(items != nil && ![items isKindOfClass:[NSNull class]]){
            NSMutableArray *modelItems = @[].mutableCopy;
            [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                MenuModel *menuModel = [[MenuModel alloc] initWithDataDic:obj];
                [modelItems addObject:menuModel];
            }];
            self.items = modelItems;
        }else {
            self.items = @[];
        }
    }
    return self;
}

@end
