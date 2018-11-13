//
//  OpenDoorAreaheaderView.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/20.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "OpenDoorAreaheaderView.h"

@interface OpenDoorAreaheaderView()

@end

@implementation OpenDoorAreaheaderView

-(UILabel *)titleLab
{
    if (_titleLab == nil) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont boldSystemFontOfSize:17];
        _titleLab.textAlignment = NSTextAlignmentLeft;
        _titleLab.backgroundColor = [UIColor clearColor];
        _titleLab.textColor = [UIColor blackColor];
    }
    return _titleLab;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initView];
    }
    return self;
}

-(void)_initView
{
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, 9, 5, 20)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    lineView.layer.cornerRadius = 2;
    lineView.clipsToBounds = YES;
    [self addSubview:lineView];
    
    [self addSubview:self.titleLab];
    _titleLab.frame = CGRectMake(lineView.right + 10, 0, 200, self.height);
    
    self.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
}

@end
