//
//  CarRoundView.m
//  TCBuildingSluice
//
//  Created by 魏唯隆 on 2018/8/20.
//  Copyright © 2018年 魏唯隆. All rights reserved.
//

#import "CarRoundView.h"

@implementation CarRoundView
{
    CAShapeLayer *maintainLayer;
    CAGradientLayer *gradientLayer;
    
    UIView *self;
    
    // 设备总警报数
    UILabel *valueLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        [self _initView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        [self _initView];
        
    }
    return self;
}

- (void)_initView {
//    [self addRangLayer];
    
    self.backgroundColor = [UIColor whiteColor];
    
    // 中心label
    valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 25, self.width - 24, 20)];
    valueLabel.text = @"";
    valueLabel.textColor = [UIColor colorWithHexString:@"#0093FC"];
    valueLabel.font = [UIFont systemFontOfSize:20];
    valueLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:valueLabel];
    
    UILabel *titleLlabel = [[UILabel alloc] initWithFrame:CGRectMake(14, valueLabel.bottom + 5, self.width - 28, 20)];
    titleLlabel.tag = 2001;
    titleLlabel.text = @"在线率";
    titleLlabel.textColor = [UIColor blackColor];
    titleLlabel.font = [UIFont systemFontOfSize:13];
    titleLlabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLlabel];
    
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [self addRangLayer];
}

- (void)addRangLayer {
    CGFloat strokeWidth = 10;
    CGFloat circleWidth = self.width - strokeWidth;
    
    UIBezierPath *circle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.width/2, self.height/2.0) radius:circleWidth/2 startAngle:1.5*M_PI endAngle:1.49999*M_PI clockwise:YES];
    
    [maintainLayer removeFromSuperlayer];
    maintainLayer = nil;
    maintainLayer = [CAShapeLayer layer];
    maintainLayer.frame = CGRectMake(0, 0, circleWidth, circleWidth);//设置Frame
    maintainLayer.fillColor = [UIColor clearColor].CGColor;//填充颜色=透明色
    maintainLayer.lineWidth = strokeWidth;//线条大小
    maintainLayer.strokeColor = [UIColor colorWithHexString:@"#A0D6FF"].CGColor;//线条颜色
    maintainLayer.strokeStart = 0.0f;//路径开始位置
    maintainLayer.strokeEnd = _maintainEndNum;//路径结束位置
    maintainLayer.path = circle.CGPath;//设置bgLayer的绘制路径为circle的路径
    [self.layer addSublayer:maintainLayer];//添加到屏幕上
    
    // 添加渐变色
    [gradientLayer removeFromSuperlayer];
    gradientLayer = nil;
    gradientLayer =  [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, self.width, self.width);
    [gradientLayer setColors:[NSArray arrayWithObjects:(id)[UIColor colorWithHexString:@"#F04CD3"].CGColor, (id)[UIColor colorWithHexString:@"#009CF3"].CGColor, nil]];
    gradientLayer.startPoint = CGPointMake(1, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    [self.layer addSublayer:gradientLayer];
    [gradientLayer setMask:maintainLayer];
}

- (void)setFreParkNum:(NSInteger)freParkNum {
    _freParkNum = freParkNum;
    valueLabel.text = [NSString stringWithFormat:@"%ld", freParkNum];
}

- (void)setMaintainEndNum:(CGFloat)maintainEndNum {
    _maintainEndNum = maintainEndNum;
    
    [self setNeedsDisplay];
}

- (void)setDataTitle:(NSString *)dataTitle {
    valueLabel.text = [NSString stringWithFormat:@"%@", dataTitle];
}
- (void)setSubTitle:(NSString *)subTitle {
    UILabel *titleLlabel = [self viewWithTag:2001];
    titleLlabel.text = [NSString stringWithFormat:@"%@", subTitle];
}

@end
