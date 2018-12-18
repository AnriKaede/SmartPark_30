//
//  MsgView.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/14.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "MsgView.h"

@interface MsgView()
{
    
}

@end

@implementation MsgView

-(UILabel *)leftLab
{
    if (_leftLab == nil) {
        _leftLab = [[UILabel alloc] init];
        _leftLab.font = [UIFont systemFontOfSize:12];
        _leftLab.textColor = [UIColor colorWithHexString:@"ACFF2A"];
        _leftLab.textAlignment = NSTextAlignmentLeft;
        _leftLab.text = @"开启";
    }
    return _leftLab;
}

-(UILabel *)leftNumLab
{
    if (_leftNumLab == nil) {
        _leftNumLab = [[UILabel alloc] init];
        _leftNumLab.text = @"-";
        _leftNumLab.textAlignment = NSTextAlignmentRight;
        _leftNumLab.textColor = [UIColor whiteColor];
        _leftNumLab.font = [UIFont systemFontOfSize:25];
    }
    return _leftNumLab;
}

-(UILabel *)centerLab
{
    if (_centerLab == nil) {
        _centerLab = [[UILabel alloc] init];
        _centerLab.font = [UIFont systemFontOfSize:12];
        _centerLab.textColor = [UIColor colorWithHexString:@"92FFCD"];
        _centerLab.textAlignment = NSTextAlignmentLeft;
        _centerLab.text = @"关闭";

    }
    return _centerLab;
}

-(UILabel *)centerNumLab
{
    if (_centerNumLab == nil) {
        _centerNumLab = [[UILabel alloc] init];
        _centerNumLab.text = @"-";
        _centerNumLab.textAlignment = NSTextAlignmentRight;
        _centerNumLab.textColor = [UIColor whiteColor];
        _centerNumLab.font = [UIFont systemFontOfSize:25];
    }
    return _centerNumLab;
}

-(UILabel *)rightLab
{
    if (_rightLab == nil) {
        _rightLab = [[UILabel alloc] init];
        _rightLab.font = [UIFont systemFontOfSize:12];
        _rightLab.textColor = [UIColor colorWithHexString:@"FFB400"];
        _rightLab.textAlignment = NSTextAlignmentLeft;
        _rightLab.text = @"故障";
    }
    return _rightLab;
}

-(UILabel *)rightNumLab
{
    if (_rightNumLab == nil) {
        _rightNumLab = [[UILabel alloc] init];
        _rightNumLab.text = @"-";
        _rightNumLab.textAlignment = NSTextAlignmentRight;
        _rightNumLab.textColor = [UIColor whiteColor];
        _rightNumLab.font = [UIFont systemFontOfSize:25];

    }
    return _rightNumLab;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self _initView];
    }
    return self;
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
    // 添加渐变色
    [NavGradient viewAddGradient:self];
    
    [self addSubview:self.leftLab];
    [self addSubview:self.leftNumLab];
    
    [self addSubview:self.centerLab];
    [self addSubview:self.centerNumLab];
    
    [self addSubview:self.rightLab];
    [self addSubview:self.rightNumLab];
    
    NSString *leftStr = @"开启";
    CGSize size2 = [leftStr boundingRectWithSize:CGSizeMake(KScreenWidth/6, self.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil].size;
    
    _leftNumLab.frame = CGRectMake(0, 0, KScreenWidth/6, self.height);
    _leftLab.frame = CGRectMake(CGRectGetMaxX(_leftNumLab.frame)+5, 22, KScreenWidth/6-5, size2.height);
    
    _centerNumLab.frame = CGRectMake(KScreenWidth/6 * 2, 0, KScreenWidth/6, self.height);
    _centerLab.frame = CGRectMake(CGRectGetMaxX(_centerNumLab.frame)+5, 22, KScreenWidth/6-5, size2.height);
    
    _rightNumLab.frame = CGRectMake(CGRectGetMaxX(_centerLab.frame), 0, KScreenWidth/6, self.height);
    _rightLab.frame = CGRectMake(CGRectGetMaxX(_rightNumLab.frame)+5, 22, KScreenWidth/6-5, size2.height);
}

-(void)setNum:(NSInteger)num
{
    _num = num;
    
    NSString *leftStr = @"开启";
    CGSize size2 = [leftStr boundingRectWithSize:CGSizeMake(KScreenWidth/6, self.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil].size;
    
    if (num == 2) {
        _rightLab.hidden = YES;
        _rightNumLab.hidden = YES;
        
        _leftNumLab.frame = CGRectMake(0, 0, KScreenWidth/4, self.height);
        _leftLab.frame = CGRectMake(CGRectGetMaxX(_leftNumLab.frame)+5, 22, KScreenWidth/4-5, size2.height);
        
        _centerNumLab.frame = CGRectMake(KScreenWidth/4 * 2, 0, KScreenWidth/4, self.height);
        _centerLab.frame = CGRectMake(CGRectGetMaxX(_centerNumLab.frame)+5, 22, KScreenWidth/4-5, size2.height);
    }
    
}

@end
