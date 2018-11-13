//
//  WifiInfoCountModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/6.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "WifiInfoCountModel.h"

@implementation WifiInfoCountModel

- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        
        NSArray *clientType = data[@"clientType"];
        NSMutableArray *types = @[].mutableCopy;
        [clientType enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            WifiCountTypeModel *model = [[WifiCountTypeModel alloc] initWithDataDic:obj];
            [types addObject:model];
        }];
        self.clientType = types;
        
        NSArray *onlineTime = data[@"onlineTime"];
        NSMutableArray *times = @[].mutableCopy;
        [onlineTime enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            WifiCountTimeModel *model = [[WifiCountTimeModel alloc] initWithDataDic:obj];
            [times addObject:model];
        }];
        self.onlineTime = times;
        
        NSArray *sendAndRec = data[@"sendAndRec"];
        NSMutableArray *speeds = @[].mutableCopy;
        [sendAndRec enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            WifiCountSpeedModel *model = [[WifiCountSpeedModel alloc] initWithDataDic:obj];
            [speeds addObject:model];
        }];
        self.sendAndRec = speeds;
        
        NSArray *signalStrength = data[@"signalStrength"];
        NSMutableArray *strongs = @[].mutableCopy;
        [signalStrength enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            WifiCountStrongModel *model = [[WifiCountStrongModel alloc] initWithDataDic:obj];
            [strongs addObject:model];
        }];
        self.signalStrength = strongs;
        
        NSArray *newUser = data[@"newUser"];
        NSMutableArray *users = @[].mutableCopy;
        [newUser enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            WifiNewUserModel *model = [[WifiNewUserModel alloc] initWithDataDic:obj];
            [users addObject:model];
        }];
        self.addNewUser = users;
        
        NSDictionary *apNum = data[@"APNum"];
        APNumModel *apNumModel = [[APNumModel alloc] initWithDataDic:apNum];
        self.APNum = apNumModel;
    }
    return self;
}

@end
