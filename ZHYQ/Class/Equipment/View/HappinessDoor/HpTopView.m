//
//  HpTopView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/17.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "HpTopView.h"

@implementation HpTopView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        [self _initView];
    }
    return self;
}

- (void)_initView {
    [self createTopView];
    
    [self createScroolView];
}

- (void)createTopView {
    UIView *topBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 142*hScale)];
    [self addSubview:topBgView];
    
    // 添加渐变色
    [self addGradient:topBgView];
    
    CGFloat itemWidth = topBgView.height - 10;
    UIView *roundView = [[UIView alloc] initWithFrame:CGRectMake((KScreenWidth - itemWidth)/2, 5, itemWidth, itemWidth)];
    roundView.backgroundColor = [UIColor clearColor];
    roundView.layer.cornerRadius = itemWidth/2;
    roundView.layer.borderColor = [UIColor colorWithHexString:@"#A0D6FF"].CGColor;
    roundView.layer.borderWidth = 10;
    [topBgView addSubview:roundView];
    
    UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 40, itemWidth - 10, 25)];
    numLabel.text = @"00";
    numLabel.textColor = [UIColor whiteColor];
    numLabel.font = [UIFont systemFontOfSize:25];
    numLabel.textAlignment = NSTextAlignmentCenter;
    [roundView addSubview:numLabel];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, numLabel.bottom + 10, itemWidth - 20, 30)];
    label.text = @"人员进出总数\n（人）";
    label.textColor = [UIColor whiteColor];
    label.numberOfLines = 2;
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    [roundView addSubview:label];
}

- (void)createScroolView {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 142*hScale, KScreenWidth, self.height - 142*hScale)];
    scrollView.backgroundColor = [UIColor colorWithHexString:@"#EFEFEF"];
    CGFloat contentWidth = 568;
    if(KScreenWidth >= 568){
        contentWidth = KScreenWidth;
    }
    scrollView.contentSize = CGSizeMake(contentWidth, 0);
    [self addSubview:scrollView];
    
    CGFloat itemWidth = contentWidth/4.0;
    NSArray *msgData = @[@"员工进出总数(人)",@"访客进出总数(人)",@"车辆进出(辆)",@"远程开门(人)"];
    [msgData enumerateObjectsUsingBlock:^(NSString *msg, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect frame = CGRectMake(itemWidth*idx, 0, itemWidth, scrollView.height);
        UIView *itemView = [self createItemView:frame withMessage:msg withIndex:idx];
        [scrollView addSubview:itemView];
    }];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, scrollView.bottom - 1, KScreenWidth, 1)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#BFBFBF"];
    [self addSubview:lineView];
}
- (UIView *)createItemView:(CGRect)frame withMessage:(NSString *)msg withIndex:(NSInteger)index {
    UIView *itemView = [[UIView alloc] initWithFrame:frame];
    
    CGFloat itemWidth = frame.size.width;
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((itemWidth - 27)/2, 12, 27, 27)];
    imgView.image = [UIImage imageNamed:@"hp_person_icon"];
    [itemView addSubview:imgView];
    
    UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imgView.bottom + 11, itemWidth, 20)];
    numLabel.text = @"00";
    numLabel.tag = 2000+index;
    numLabel.textColor = [UIColor colorWithHexString:@"#3699FF"];
    numLabel.font = [UIFont systemFontOfSize:18];
    numLabel.textAlignment = NSTextAlignmentCenter;
    [itemView addSubview:numLabel];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, numLabel.bottom + 8, itemWidth, 15)];
    label.text = msg;
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:14];
    label.textAlignment = NSTextAlignmentCenter;
    [itemView addSubview:label];
    
    return itemView;
}

- (void)addGradient:(UIView *)view {
    view.backgroundColor = [UIColor colorWithHexString:@"#0D46B9"];
    [self addRoundLayerOne:view];
    [self addRoundLayerTow:view];
}
- (void)addRoundLayerOne:(UIView *)view {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, view.width, view.height);
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithHexString:@"#285ab9"].CGColor,(id)[UIColor colorWithHexString:@"#4287cd"].CGColor, nil];
    gradient.locations = @[@0.5, @1.0];    // 颜色的起点位置，递增，并且数量跟颜色数量相等
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(1, 0);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(KScreenWidth/5, -142, KScreenWidth*1.5, 280)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = path.CGPath;
    gradient.mask = maskLayer;
    [view.layer addSublayer:gradient];
}
- (void)addRoundLayerTow:(UIView *)view {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, view.width, view.height);
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithHexString:@"#3b72c4"].CGColor,(id)[UIColor colorWithHexString:@"#4a8ecf"].CGColor, nil];
    gradient.locations = @[@0.0, @1.0];    // 颜色的起点位置，递增，并且数量跟颜色数量相等
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(1, 0);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(KScreenWidth*3/5, -142, KScreenWidth, 260)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = path.CGPath;
    gradient.mask = maskLayer;
    [view.layer addSublayer:gradient];
}

@end
