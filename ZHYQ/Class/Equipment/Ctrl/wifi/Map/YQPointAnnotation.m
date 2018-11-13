//
//  YQPointAnnotation.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "YQPointAnnotation.h"

@implementation YQPointAnnotation

- (void)setStatus:(NSString *)status {
    if([status isKindOfClass:[NSNumber class]]){
        _status = [NSString stringWithFormat:@"%ld", status.integerValue];
    }else {
        _status = status;
    }
}

@end
