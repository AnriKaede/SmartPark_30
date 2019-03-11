 //
//  WarnCakeView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/10.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WarnCakeView.h"

@implementation WarnCakeView
{
    UIView *bgRingView;
    
    CAShapeLayer *undealLayer;
    CAShapeLayer *distributeLayer;
    CAShapeLayer *maintainLayer;
    
    CGFloat _maintainEndNum;
    CGFloat _distributeBeginNum;
    CGFloat _distributeEndNum;
    CGFloat _undealBeginNum;
    
    // 设备总警报数
    UILabel *valueLabel;
    // 未处理数
    UILabel *undealFlagLabel;
    // 待派单数
    UILabel *distributeFlagLabel;
    // 维修中
    UILabel *maintainFlagLabel;
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        _maintainEndNum = 0;
        _distributeBeginNum = 0;
        _distributeEndNum = 0;
        _undealBeginNum = 1;
        [self _initView];
    }
    return self;
}

- (void)_initView {
    // 添加渐变色
    [NavGradient viewAddGradient:self];
    
    CGFloat circleWidth = 120;
    
    bgRingView = [[UIView alloc] initWithFrame:CGRectMake((KScreenWidth - circleWidth)/2, 50, circleWidth, circleWidth)];
    bgRingView.backgroundColor = [UIColor clearColor];
    bgRingView.layer.cornerRadius = circleWidth/2;
    [self addSubview:bgRingView];
    
    UIBezierPath *circle = [UIBezierPath bezierPathWithArcCenter:bgRingView.center radius:75 startAngle:1.5*M_PI endAngle:1.5001*M_PI clockwise:NO];
    
    CAShapeLayer *bgLayer = [CAShapeLayer layer];
    bgLayer.frame = CGRectMake(0, 0, bgRingView.width, bgRingView.height);//设置Frame
    bgLayer.fillColor = [UIColor clearColor].CGColor;//填充颜色=透明色
    bgLayer.lineWidth = 15.f;//线条大小
    bgLayer.strokeColor = [UIColor colorWithHexString:@"#A0D6FF"].CGColor;//线条颜色
    bgLayer.strokeStart = 0.f;//路径开始位置
    bgLayer.strokeEnd = 1.0f;//路径结束位置
    bgLayer.path = circle.CGPath;//设置bgLayer的绘制路径为circle的路径
    [self.layer addSublayer:bgLayer];//添加到屏幕上
    
    // 中心label
    UILabel *titleLlabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 25, circleWidth - 60, 20)];
    titleLlabel.text = @"故障";
    titleLlabel.textColor = [UIColor whiteColor];
    titleLlabel.font = [UIFont systemFontOfSize:17];
    titleLlabel.textAlignment = NSTextAlignmentCenter;
    [bgRingView addSubview:titleLlabel];
    
    valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, titleLlabel.bottom + 8, circleWidth - 30, 35)];
    valueLabel.text = @"0";
    valueLabel.textColor = [UIColor whiteColor];
    valueLabel.font = [UIFont systemFontOfSize:29];
    valueLabel.textAlignment = NSTextAlignmentCenter;
    [bgRingView addSubview:valueLabel];
    
    /*
    // 两边提示数量label
    equLabel = [[UILabel alloc] initWithFrame:CGRectMake(bgRingView.left - 147, bgRingView.center.y - 8, 100, 15)];
    equLabel.text = @"设备0";
    equLabel.textColor = [UIColor whiteColor];
    equLabel.font = [UIFont systemFontOfSize:14];
    equLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:equLabel];
    
    safeLabel = [[UILabel alloc] initWithFrame:CGRectMake(bgRingView.right + 55, bgRingView.top + 30, 100, 15)];
    safeLabel.text = @"安防0";
    safeLabel.textColor = [UIColor whiteColor];
    safeLabel.font = [UIFont systemFontOfSize:14];
    safeLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:safeLabel];
     */
    
    // 未处理标示label+view
    undealFlagLabel = [[UILabel alloc] initWithFrame:CGRectMake((KScreenWidth/3 - 70)/2, bgRingView.bottom + 50, 100, 17)];
    undealFlagLabel.text = @"未处理(0)";
    undealFlagLabel.textColor = [UIColor whiteColor];
    undealFlagLabel.font = [UIFont systemFontOfSize:17];
    undealFlagLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:undealFlagLabel];
    
    UIView *equFlagView = [[UIView alloc] initWithFrame:CGRectMake(undealFlagLabel.left - 16, undealFlagLabel.top + 4, 9, 9)];
    equFlagView.backgroundColor = [UIColor colorWithHexString:@"#FF95A1"];
    [self addSubview:equFlagView];
    
    // 待派单标示label+view
    distributeFlagLabel = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth/3 + (KScreenWidth/3 - 78)/2, undealFlagLabel.top, 100, 17)];
    distributeFlagLabel.text = @"待派单(0)";
    distributeFlagLabel.textColor = [UIColor whiteColor];
    distributeFlagLabel.font = [UIFont systemFontOfSize:17];
    distributeFlagLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:distributeFlagLabel];
    
    UIView *safeFlagView = [[UIView alloc] initWithFrame:CGRectMake(distributeFlagLabel.left - 16, distributeFlagLabel.top + 4, 9, 9)];
    safeFlagView.backgroundColor = [UIColor colorWithHexString:@"#DFE114"];
    [self addSubview:safeFlagView];
    
    // 维修中标示label+view
    maintainFlagLabel = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth*2/3 + (KScreenWidth/3 - 78)/2, undealFlagLabel.top, 120, 17)];
    maintainFlagLabel.text = @"处理中(0)";
    maintainFlagLabel.textColor = [UIColor whiteColor];
    maintainFlagLabel.font = [UIFont systemFontOfSize:17];
    maintainFlagLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:maintainFlagLabel];
    
    UIView *maintainFlagView = [[UIView alloc] initWithFrame:CGRectMake(maintainFlagLabel.left - 16, distributeFlagLabel.top + 4, 9, 9)];
    maintainFlagView.backgroundColor = [UIColor colorWithHexString:@"#6BDB6A"];
    [self addSubview:maintainFlagView];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [self addCircleLayer];
    
    /*
    // 设备警告数量连线
    UIBezierPath *equLinePath = [UIBezierPath bezierPath];
    equLinePath.lineWidth = 1;
    UIColor *equLineColor = [UIColor colorWithHexString:@"#6BDB6A"];//线条颜色
    [equLineColor set];
    
    [equLinePath moveToPoint:CGPointMake(bgRingView.left - 20, bgRingView.top + 35)];
    [equLinePath addLineToPoint:CGPointMake(bgRingView.left - 55, bgRingView.top + 35)];
    [equLinePath addLineToPoint:CGPointMake(bgRingView.left - 60, bgRingView.top + 47)];
    [equLinePath stroke];
    
    // 安防警告数量连线
    UIBezierPath *safeLinePath = [UIBezierPath bezierPath];
    safeLinePath.lineWidth = 1;
    UIColor *safeLineColor = [UIColor colorWithHexString:@"#FF95A1"];//线条颜色
    [safeLineColor set];
    
    [safeLinePath moveToPoint:CGPointMake(bgRingView.right + 25, bgRingView.top + 63)];
    [safeLinePath addLineToPoint:CGPointMake(bgRingView.right + 65, bgRingView.top + 63)];
    [safeLinePath addLineToPoint:CGPointMake(bgRingView.right + 70, bgRingView.top + 51)];
    [safeLinePath stroke];
     */
}

- (void)addCircleLayer {
    UIBezierPath *circle = [UIBezierPath bezierPathWithArcCenter:bgRingView.center radius:75 startAngle:1.5*M_PI endAngle:1.5001*M_PI clockwise:NO];
    [maintainLayer removeFromSuperlayer];
    maintainLayer = nil;
    maintainLayer = [CAShapeLayer layer];
    maintainLayer.frame = CGRectMake(0, 0, bgRingView.width, bgRingView.height);
    maintainLayer.fillColor = [UIColor clearColor].CGColor;
    maintainLayer.lineWidth = 15.f;
    maintainLayer.strokeColor = [UIColor colorWithHexString:@"#6BDB6A"].CGColor;
    maintainLayer.strokeStart = 0;
    maintainLayer.strokeEnd = _maintainEndNum;
    maintainLayer.path = circle.CGPath;
    [self.layer addSublayer:maintainLayer];
    
    [distributeLayer removeFromSuperlayer];
    distributeLayer = nil;
    distributeLayer = [CAShapeLayer layer];
    distributeLayer.frame = CGRectMake(0, 0, bgRingView.width, bgRingView.height);
    distributeLayer.fillColor = [UIColor clearColor].CGColor;
    distributeLayer.lineWidth = 15.f;
    distributeLayer.strokeColor = [UIColor colorWithHexString:@"#DFE114"].CGColor;
    distributeLayer.strokeStart = _distributeBeginNum;
    distributeLayer.strokeEnd = _distributeEndNum;
    distributeLayer.path = circle.CGPath;
    [self.layer addSublayer:distributeLayer];
    
    
    [undealLayer removeFromSuperlayer];
    undealLayer = nil;
    undealLayer = [CAShapeLayer layer];
    undealLayer.frame = CGRectMake(0, 0, bgRingView.width, bgRingView.height);
    undealLayer.fillColor = [UIColor clearColor].CGColor;
    undealLayer.lineWidth = 15.f;
    undealLayer.strokeColor = [UIColor colorWithHexString:@"#FF95A1"].CGColor;
    undealLayer.strokeStart = _undealBeginNum;
    undealLayer.strokeEnd = 1;
    undealLayer.path = circle.CGPath;
    [self.layer addSublayer:undealLayer];
    
    /*
     //设置渐变颜色
     CAGradientLayer *gradientLayer =  [CAGradientLayer layer];
     gradientLayer.frame = self.frame;
     [gradientLayer setColors:[NSArray arrayWithObjects:(id)[UIColor colorWithHexString:@"#2e73ea"].CGColor, (id)[UIColor colorWithHexString:@"#4f2e77"].CGColor, (id)[UIColor colorWithHexString:@"#f8ce5e"].CGColor, nil]];
     gradientLayer.startPoint = CGPointMake(0, 0);
     gradientLayer.endPoint = CGPointMake(1, 1);
     [self.layer addSublayer:gradientLayer];
     [gradientLayer setMask:bgLayer];
     */
}

- (void)warnEquipmentNum:(CGFloat)undealNum withSafeNum:(CGFloat)distributeNum withMaintainNum:(CGFloat)maintainNum {
    
    _maintainEndNum = maintainNum/(undealNum + distributeNum + maintainNum);
    _distributeBeginNum = _maintainEndNum;
    _distributeEndNum = _distributeBeginNum + distributeNum/(undealNum + distributeNum + maintainNum);
    _undealBeginNum = _distributeEndNum;
    [self setNeedsDisplay];
    
    NSString *valueNum = [NSString stringWithFormat:@"%.0f", undealNum + distributeNum + maintainNum];
    if(valueNum != nil && valueNum.integerValue > 9999){
        valueLabel.text = @"9999+";
    }else {
        valueLabel.text = valueNum;
    }
    NSString *undealValue = [NSString stringWithFormat:@"%.0f", undealNum];
    if(undealValue != nil && undealValue.integerValue > 99){
        undealFlagLabel.text = @"未处理(99+)";
    }else {
        undealFlagLabel.text = [NSString stringWithFormat:@"未处理(%.0f)", undealNum];
    }
    NSString *distributeValue = [NSString stringWithFormat:@"%.0f", distributeNum];
    if(distributeValue != nil && distributeValue.integerValue > 99){
        distributeFlagLabel.text = @"待派单(99+)";
    }else {
        distributeFlagLabel.text = [NSString stringWithFormat:@"待派单(%.0f)", distributeNum];
    }
    NSString *maintainValue = [NSString stringWithFormat:@"%.0f", maintainNum];
    if(maintainValue != nil && maintainValue.integerValue > 99){
        maintainFlagLabel.text = @"处理中(99+)";
    }else {
        maintainFlagLabel.text = [NSString stringWithFormat:@"处理中(%.0f)", maintainNum];
    }
//    equLabel.text = [NSString stringWithFormat:@"设备%.0f", equipmentNum];
//    safeLabel.text = [NSString stringWithFormat:@"安防%.0f", safeNum];
}

@end
