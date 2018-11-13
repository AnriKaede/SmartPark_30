//
//  YQSlider.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/7.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "YQSlider.h"

@interface YQSlider ()

@property (nonatomic,strong) UILabel *signLab;
@property (nonatomic,strong) UILabel *leftLab;
@property (nonatomic,strong) UILabel *rightLab;

@end

@implementation YQSlider

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self config];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self config];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self config];
    }
    return self;
}

-(void)config
{
    _unitStr = @"%";
    
    [self setMinimumTrackImage:[UIImage imageNamed:@"_light_full_bg"] forState:UIControlStateNormal];//设置图片
    [self setMaximumTrackImage:[UIImage imageNamed:@"_light_zero_bg"] forState:UIControlStateNormal];//设置图片
    
    //滑块图片
    UIImage *thumbImage = [UIImage imageNamed:@"Slider"];
    
    [self setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [self setThumbImage:thumbImage forState:UIControlStateNormal];
    
    _signLab = [[UILabel alloc] init];
    _signLab.backgroundColor = [UIColor clearColor];
    _signLab.textAlignment = NSTextAlignmentCenter;
    _signLab.font = [UIFont systemFontOfSize:10];
    _signLab.textColor = [UIColor colorWithHexString:@"006AB9"];
    [self addSubview:_signLab];
    
    _leftLab = [[UILabel alloc] init];
    _leftLab.backgroundColor = [UIColor clearColor];
    _leftLab.textAlignment = NSTextAlignmentCenter;
    _leftLab.frame = CGRectMake(-15, 12, 40, 15);
    _leftLab.font = [UIFont systemFontOfSize:10];
    _leftLab.textColor = [UIColor colorWithHexString:@"006AB9"];
    [self addSubview:_leftLab];
    
    _rightLab = [[UILabel alloc] init];
    _rightLab.backgroundColor = [UIColor clearColor];
    _rightLab.textAlignment = NSTextAlignmentCenter;
    _rightLab.frame = CGRectMake(self.frame.size.width-30, 12, 40, 15);
    _rightLab.font = [UIFont systemFontOfSize:10];
    _rightLab.textColor = [UIColor colorWithHexString:@"006AB9"];
    [self addSubview:_rightLab];
    
    _minTrackBtn = [[UIButton alloc] initWithFrame:CGRectMake(-3, -5, self.height+10, self.height+10)];
    [_minTrackBtn addTarget:self action:@selector(_minTrackBtnAction) forControlEvents:UIControlEventTouchUpInside];
//    _minTrackBtn.backgroundColor = [UIColor orangeColor];
    [self addSubview:_minTrackBtn];
    
    _maxTrackBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-17, -5, self.height+10, self.height+10)];
    [_maxTrackBtn addTarget:self action:@selector(_maxTrackBtnAction) forControlEvents:UIControlEventTouchUpInside];
//    _maxTrackBtn.backgroundColor = [UIColor orangeColor];
    [self addSubview:_maxTrackBtn];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _minTrackBtn.frame = CGRectMake(-3, -5, self.height+10, self.height+10);
    _maxTrackBtn.frame = CGRectMake(self.frame.size.width-17, -5, self.height+10, self.height+10);
}

-(void)setLeftTitleStr:(NSString *)leftTitleStr
{
    _leftTitleStr = leftTitleStr;
    
    _leftLab.text = leftTitleStr;
}

-(void)setRightTitleStr:(NSString *)rightTitleStr
{
    _rightTitleStr = rightTitleStr;
    
    _rightLab.text = rightTitleStr;
}

-(void)setUnitStr:(NSString *)unitStr
{
    _unitStr = unitStr;
}

-(void)setValue:(float)value
{
    [self setValue:value animated:YES];
}

-(void)setValue:(float)value animated:(BOOL)animated
{
    
    CGFloat sliderWidth = self.frame.size.width-40-17;
    CGFloat sliderArea = value * sliderWidth * 1.0;
    if (sliderArea == 0) {
        _signLab.frame = CGRectMake(16, -20, 30, 15);
    }else{
        _signLab.frame = CGRectMake(16+sliderArea, -20, 30, 15);
    }
    
    if(_maxValue != nil){
        _signLab.text = [NSString stringWithFormat:@"%.f%@",value*_maxValue.floatValue,_unitStr];
    }else {
        _signLab.text = [NSString stringWithFormat:@"%.f%@",value*100,_unitStr];
    }
    
    [super setValue:value animated:animated];
}

- (void)setMinimumTrackImageName:(NSString *)minimumTrackImageName {
    _minimumTrackImageName = minimumTrackImageName;
    if(_minimumTrackImageName){
        [self setMinimumTrackImage:[UIImage imageNamed:_minimumTrackImageName] forState:UIControlStateNormal];//设置图片
    }else {
        [self setMinimumTrackImage:[UIImage imageNamed:@"_light_full_bg"] forState:UIControlStateNormal];//设置图片
    }
}

- (void)setMaximumTrackImageName:(NSString *)maximumTrackImageName {
    _maximumTrackImageName = maximumTrackImageName;
    if(_maximumTrackImageName){
        [self setMaximumTrackImage:[UIImage imageNamed:_maximumTrackImageName] forState:UIControlStateNormal];//设置图片
    }else {
        [self setMaximumTrackImage:[UIImage imageNamed:@"_light_zero_bg"] forState:UIControlStateNormal];//设置图片
    }
}

- (void)setMaxValue:(NSString *)maxValue {
    _maxValue = maxValue;
    
}

-(void)_minTrackBtnAction
{
    if (self.delegate != nil&&[self.delegate respondsToSelector:@selector(minimumTrackBtnAction:)]) {
        [self.delegate minimumTrackBtnAction:self];
    }
}

-(void)_maxTrackBtnAction
{
    if (self.delegate != nil&&[self.delegate respondsToSelector:@selector(maximumTrackBtnAction:)]) {
        [self.delegate maximumTrackBtnAction:self];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        CGPoint tempoint1 = [_minTrackBtn convertPoint:point fromView:self];
        if (CGRectContainsPoint(_minTrackBtn.bounds, tempoint1))
        {
            view = _minTrackBtn;
        }
        
        CGPoint tempoint2 = [_maxTrackBtn convertPoint:point fromView:self];
        if (CGRectContainsPoint(_maxTrackBtn.bounds, tempoint2))
        {
            view = _maxTrackBtn;
        }
    }
    return view;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

// 设置最大值
//- (CGRect)maximumValueImageRectForBounds:(CGRect)bounds
//{
//    return CGRectMake(0, 0, CGRectGetWidth(self.frame)/ 2, CGRectGetHeight(self.frame) / 2);
//}
//// 设置最小值
//- (CGRect)minimumValueImageRectForBounds:(CGRect)bounds
//{
//    return CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
//}

// 控制slider的宽和高，这个方法才是真正的改变slider滑道的高的
- (CGRect)trackRectForBounds:(CGRect)bounds
{
    return CGRectMake(20, 0, CGRectGetWidth(self.frame)-40, CGRectGetHeight(self.frame));
}
// 改变滑块的触摸范围
//- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
//{
//    return CGRectInset([super thumbRectForBounds:bounds trackRect:rect value:value], 10, 10);
//}

@end
