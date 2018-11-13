//
//  YQSecondHeaderView.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "YQSecondHeaderView.h"

@implementation YQSecondHeaderView

-(UILabel *)openNumLab
{
    if (_openNumLab == nil) {
        _openNumLab = [[UILabel alloc] init];
        _openNumLab.text = @"-";
        _openNumLab.font = [UIFont systemFontOfSize:25];
        _openNumLab.textColor = [UIColor whiteColor];
        _openNumLab.textAlignment = NSTextAlignmentCenter;
        _openNumLab.frame = CGRectMake(0, 21, KScreenWidth/2, 19);
    }
    return _openNumLab;
}

-(UILabel *)openLab
{
    if (_openLab == nil) {
        _openLab = [[UILabel alloc] init];
        _openLab.text = @"开启";
        _openLab.font = [UIFont systemFontOfSize:12];
        _openLab.textColor = [UIColor colorWithHexString:@"ACFF2A"];
        _openLab.textAlignment = NSTextAlignmentCenter;
        _openLab.frame = CGRectMake(0, CGRectGetMaxY(_openNumLab.frame)+10, KScreenWidth/2, 12);
    }
    return _openLab;
}

-(UILabel *)brokenLab
{
    if (_brokenLab == nil) {
        _brokenLab = [[UILabel alloc] init];
        _brokenLab.text = @"故障";
        _brokenLab.font = [UIFont systemFontOfSize:12];
        _brokenLab.textColor = [UIColor colorWithHexString:@"FFB400"];
        _brokenLab.textAlignment = NSTextAlignmentCenter;
        _brokenLab.frame = CGRectMake(KScreenWidth/2, CGRectGetMaxY(_brokenNumLab.frame)+10, KScreenWidth/2, 12);
    }
    return _brokenLab;
}

-(UILabel *)brokenNumLab
{
    if (_brokenNumLab == nil) {
        _brokenNumLab = [[UILabel alloc] init];
        _brokenNumLab.text = @"-";
        _brokenNumLab.font = [UIFont systemFontOfSize:25];
        _brokenNumLab.textColor = [UIColor whiteColor];
        _brokenNumLab.textAlignment = NSTextAlignmentCenter;
        _brokenNumLab.frame = CGRectMake(KScreenWidth/2, 21, KScreenWidth/2, 19);
    }
    return _brokenNumLab;
}

-(UIImageView *)lineView
{
    if (_lineView == nil) {
        _lineView = [[UIImageView alloc] init];
        _lineView.image = [UIImage imageNamed:@"weather_sep"];
        _lineView.frame = CGRectMake(KScreenWidth/2-0.5, 24, 0.5, 32);
    }
    return _lineView;
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
    [self addSubview:self.openNumLab];
    [self addSubview:self.openLab];
    
    [self addSubview:self.brokenNumLab];
    [self addSubview:self.brokenLab];
    
    [self addSubview:self.lineView];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
