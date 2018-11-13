//
//  YQImageScrollView.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/10.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "YQImageScrollView.h"

@implementation YQImageScrollView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI{
    self.frame = CGRectMake(0, 0, KScreenWidth + 20, KScreenHeight - 64);
    self.pagingEnabled = YES;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = YES;
    self.backgroundColor = [UIColor blackColor];
}

@end
