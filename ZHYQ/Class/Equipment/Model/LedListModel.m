//
//  LedListModel.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/2/2.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "LedListModel.h"

@implementation LedListModel

- (instancetype)initWithDataDic:(NSDictionary *)data {
    self = [super initWithDataDic:data];
    if(self){
        NSString *mainstatus = data[@"mainstatus"];
        if(mainstatus != nil && [mainstatus isKindOfClass:[NSNull class]] && mainstatus.length > 0){
            self.mainstatus = mainstatus;
        }else {
            NSString *status = data[@"status"];
            if(status != nil && [status isKindOfClass:[NSNull class]] && status.length > 0){
                self.mainstatus = [NSString stringWithFormat:@"%@", data[@"status"]];
            }
        }
    }
    return self;
}

- (void)setStatus:(NSString *)status {
    _status = status;
    if(_mainstatus == nil){
        _mainstatus = status;
    }
}

@end
