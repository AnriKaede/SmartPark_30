//
//  NewCoverModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/25.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "NewCoverModel.h"

@implementation NewCoverModel

- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        NSDictionary *platItem = data[@"platItem"];
        if(platItem != nil && ![platItem isKindOfClass:[NSNull class]]){
            NewCoverInfoModel *coverInfoModel = [[NewCoverInfoModel alloc] initWithDataDic:platItem];
            self.platItem = coverInfoModel;
        }
    }
    return self;
}

@end
