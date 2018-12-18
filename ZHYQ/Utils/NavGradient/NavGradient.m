//
//  NavGradient.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/18.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "NavGradient.h"

@implementation NavGradient

#define NRoundOneWidth KScreenWidth*1.5 // 第一个椭圆宽度
#define NRoundTowWidth KScreenWidth // 第二个椭圆宽度

#define NRoundOneHeight 340 // 第一个椭圆高度
#define NRoundTowHeight 280 // 第二个椭圆高度

#define NOneViewTop (-200) // 第一个椭圆向上偏移量
#define NTowViewTop (-150) // 第二个椭圆向上偏移量

#pragma mark 导航栏渐变视图
+ (UIImage *)navBgColorImg {
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, kTopHeight)];
    
    [self gradientView:navView withIsNav:YES];
    
    UIImage *image = [self convertViewToImage:navView];
    
    return image;
}
+ (UIImage*)convertViewToImage:(UIView*)view {
    CGSize s = view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(s,YES, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark 导航栏下方渐变视图
+ (void)viewAddGradient:(UIView *)view {
    [self gradientView:view withIsNav:NO];
}

#pragma mark 搜索渐变视图
+ (UIImage *)searchAddGradient:(UIView *)view {
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.width, view.height)];
    [self gradientView:navView withIsNav:NO];
    UIImage *image = [self convertViewToImage:navView];
    return image;
}

+ (void)gradientView:(UIView *)view withIsNav:(BOOL)isNav {
    [self addGradient:view withIsNav:isNav];
    [self addRoundLayerOne:view withIsNav:isNav];
    [self addRoundLayerTow:view withIsNav:isNav];
}
+ (void)addGradient:(UIView *)view withIsNav:(BOOL)isNav {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    if(isNav){
        gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithHexString:@"#1949b2"].CGColor,(id)[UIColor colorWithHexString:@"#1a4bb3"].CGColor,nil];
    }else {
        
       gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithHexString:@"#1949b2"].CGColor,(id)[UIColor colorWithHexString:@"#285ab9"].CGColor,nil];
    }
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(1, 1);
    gradient.locations = @[@0.0, @0.5];
    [view.layer insertSublayer:gradient atIndex:0];
//    [view.layer addSublayer:gradient];
}
+ (void)addRoundLayerOne:(UIView *)view withIsNav:(BOOL)isNav {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, view.width, view.height);
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithHexString:@"#285ab9"].CGColor,(id)[UIColor colorWithHexString:@"#4287cd"].CGColor, nil];
    gradient.locations = @[@0.5, @1.0];    // 颜色的起点位置，递增，并且数量跟颜色数量相等
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(1, 0);
    
    UIBezierPath *path;
    if(isNav){
        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(KScreenWidth/5, NOneViewTop+kTopHeight, NRoundOneWidth, NRoundOneHeight)];
    }else {
        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(KScreenWidth/5, NOneViewTop, NRoundOneWidth, NRoundOneHeight)];
    }
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = path.CGPath;
    gradient.mask = maskLayer;
    [view.layer insertSublayer:gradient atIndex:1];
//    [view.layer addSublayer:gradient];
}
+ (void)addRoundLayerTow:(UIView *)view withIsNav:(BOOL)isNav {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, view.width, view.height);
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithHexString:@"#3b72c4"].CGColor,(id)[UIColor colorWithHexString:@"#4a8ecf"].CGColor, nil];
    gradient.locations = @[@0.0, @1.0];    // 颜色的起点位置，递增，并且数量跟颜色数量相等
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(1, 0);
    
    UIBezierPath *path;
    if(isNav){
        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(KScreenWidth*3/5, NTowViewTop+kTopHeight, NRoundTowWidth, NRoundTowHeight)];
    }else {
        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(KScreenWidth*3/5, NTowViewTop, NRoundTowWidth, NRoundTowHeight)];
    }
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = path.CGPath;
    gradient.mask = maskLayer;
    [view.layer insertSublayer:gradient atIndex:2];
//    [view.layer addSublayer:gradient];
}

@end
