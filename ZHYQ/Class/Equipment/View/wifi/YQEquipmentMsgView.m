//
//  YQEquipmentMsgView.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "YQEquipmentMsgView.h"

@implementation YQEquipmentMsgView

-(UILabel *)leftNumLab
{
    if (_leftNumLab == nil) {
        _leftNumLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 70*wScale, 50)];
        _leftNumLab.text = @"-";
        _leftNumLab.font = [UIFont systemFontOfSize:25];
        _leftNumLab.textColor = [UIColor whiteColor];
        _leftNumLab.textAlignment = NSTextAlignmentRight;
    }
    return _leftNumLab;
}

-(UILabel *)leftLab
{
    if (_leftLab == nil) {
        _leftLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_leftNumLab.frame), 5, KScreenWidth/3 - CGRectGetMaxX(_leftNumLab.frame), 50)];
        _leftLab.text = @"开启";
        _leftLab.font = [UIFont systemFontOfSize:12];
        _leftLab.textColor = [UIColor colorWithHexString:@"ACFF2A"];
        _leftLab.textAlignment = NSTextAlignmentCenter;
    }
    return _leftLab;
}

-(UILabel *)centerNumLab
{
    if (_centerNumLab == nil) {
        _centerNumLab = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth/3-20, 5, 80*wScale, 50)];
        _centerNumLab.text = @"-";
        _centerNumLab.font = [UIFont systemFontOfSize:25];
        _centerNumLab.textColor = [UIColor whiteColor];
        _centerNumLab.textAlignment = NSTextAlignmentRight;
    }
    return _centerNumLab;
}

-(UILabel *)centerLab
{
    if (_centerLab == nil) {
        _centerLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_centerNumLab.frame), 5, (KScreenWidth/3*2) - CGRectGetMaxX(_centerNumLab.frame), 50)];
        _centerLab.text = @"关闭";
        _centerLab.font = [UIFont systemFontOfSize:12];
        _centerLab.textColor = [UIColor colorWithHexString:@"92FFCD"];
        _centerLab.textAlignment = NSTextAlignmentCenter;
    }
    return _centerLab;
}

-(UILabel *)rightNumLab
{
    if (_rightNumLab == nil) {
        _rightNumLab = [[UILabel alloc] initWithFrame:CGRectMake((KScreenWidth/3)*2, 5, KScreenWidth/3 - 60, 50)];
        _rightNumLab.text = @"-";
        _rightNumLab.font = [UIFont systemFontOfSize:25];
        _rightNumLab.textColor = [UIColor whiteColor];
        _rightNumLab.textAlignment = NSTextAlignmentCenter;
    }
    return _rightNumLab;
}

-(UILabel *)rightLab
{
    if (_rightLab == nil) {
        _rightLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_rightNumLab.frame), 5, 60, 50)];
        _rightLab.text = @"故障";
        _rightLab.font = [UIFont systemFontOfSize:12];
        _rightLab.textColor = [UIColor whiteColor];
        _rightLab.textAlignment = NSTextAlignmentLeft;
    }
    return _rightLab;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self _initView];
    }
    return self;
}

-(void)_initView
{
    [self addSubview:self.leftNumLab];
    [self addSubview:self.leftLab];
    [self addSubview:self.centerNumLab];
    [self addSubview:self.centerLab];
    [self addSubview:self.rightNumLab];
    [self addSubview:self.rightLab];
    
}

@end
