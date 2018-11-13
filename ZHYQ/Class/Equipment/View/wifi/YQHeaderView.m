//
//  YQHeaderView.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/6.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "YQHeaderView.h"

@implementation YQHeaderView

-(UILabel *)leftNumLab
{
    if (_leftNumLab == nil) {
        _leftNumLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 21, KScreenWidth/3, 22)];
        _leftNumLab.text = @"-";
        _leftNumLab.font = [UIFont systemFontOfSize:27];
        _leftNumLab.textColor = [UIColor whiteColor];
        _leftNumLab.textAlignment = NSTextAlignmentCenter;
    }
    return _leftNumLab;
}

-(UILabel *)leftLab
{
    if (_leftLab == nil) {
        _leftLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_leftNumLab.frame)+10, KScreenWidth/3, 12)];
        _leftLab.text = @"开启";
        _leftLab.font = [UIFont systemFontOfSize:14];
        _leftLab.textColor = [UIColor colorWithHexString:@"ACFF2A"];
        _leftLab.textAlignment = NSTextAlignmentCenter;
    }
    return _leftLab;
}

-(UILabel *)centerNumLab
{
    if (_centerNumLab == nil) {
        _centerNumLab = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth/3, 21, KScreenWidth/3, 22)];
        _centerNumLab.text = @"-";
        _centerNumLab.font = [UIFont systemFontOfSize:27];
        _centerNumLab.textColor = [UIColor whiteColor];
        _centerNumLab.textAlignment = NSTextAlignmentCenter;
    }
    return _centerNumLab;
}

-(UILabel *)centerLab
{
    if (_centerLab == nil) {
        _centerLab = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth/3, CGRectGetMaxY(_centerNumLab.frame)+10, KScreenWidth/3, 12)];
        _centerLab.text = @"关闭";
        _centerLab.font = [UIFont systemFontOfSize:14];
        _centerLab.textColor = [UIColor colorWithHexString:@"92FFCD"];
        _centerLab.textAlignment = NSTextAlignmentCenter;
    }
    return _centerLab;
}

-(UILabel *)rightNumLab
{
    if (_rightNumLab == nil) {
        _rightNumLab = [[UILabel alloc] initWithFrame:CGRectMake((KScreenWidth/3)*2, 21, KScreenWidth/3, 22)];
        _rightNumLab.text = @"-";
        _rightNumLab.font = [UIFont systemFontOfSize:27];
        _rightNumLab.textColor = [UIColor whiteColor];
        _rightNumLab.textAlignment = NSTextAlignmentCenter;
    }
    return _rightNumLab;
}

-(UILabel *)rightLab
{
    if (_rightLab == nil) {
        _rightLab = [[UILabel alloc] initWithFrame:CGRectMake((KScreenWidth/3)*2, CGRectGetMaxY(_rightNumLab.frame)+10, KScreenWidth/3, 12)];
        _rightLab.text = @"故障";
        _rightLab.font = [UIFont systemFontOfSize:14];
        _rightLab.textColor = [UIColor colorWithHexString:@"FFB400"];
        _rightLab.textAlignment = NSTextAlignmentCenter;
    }
    return _rightLab;
}

-(UIImageView *)hLineView1
{
    if (_hLineView1 == nil) {
        _hLineView1 = [[UIImageView alloc] init];
        _hLineView1.image = [UIImage imageNamed:@"weather_sep"];
        _hLineView1.frame = CGRectMake(KScreenWidth/3, 25, 0.5, 32);
    }
    return _hLineView1;
}

-(UIImageView *)hLineView2
{
    if (_hLineView2 == nil) {
        _hLineView2 = [[UIImageView alloc] init];
        _hLineView2.image = [UIImage imageNamed:@"weather_sep"];
        _hLineView2.frame = CGRectMake(KScreenWidth/3 * 2, 25, 0.5, 32);
    }
    return _hLineView2;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initView];
        
        self.backgroundColor = [UIColor colorWithHexString:@"1B82D1"];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        [self _initView];
        
        self.backgroundColor = [UIColor colorWithHexString:@"1B82D1"];
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
    
    [self addSubview:self.hLineView1];
    [self addSubview:self.hLineView2];
}


@end
