//
//  CountCostView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/16.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "CountCostView.h"

@implementation CountCostView
{
    UILabel *_elcCostNumLabel;
    UIImageView *_elcUpImgView;
    UILabel *_elcRatioLabel;
    
    UILabel *_waterCostNumLabel;
    UIImageView *_waterUpImgView;
    UILabel *_waterRatioLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        [self _initView];
    }
    return self;
}

- (void)_initView {
    self.backgroundColor = [UIColor whiteColor];
    
    UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(KScreenWidth/2 - 0.5, 0, 1, self.height)];
    lineImgView.image = [UIImage imageNamed:@"LED_seperateline_blue"];
    lineImgView.alpha = 0.8;
    [self addSubview:lineImgView];
    
    UIImageView *elcImgView = [[UIImageView alloc] init];
    elcImgView.frame = CGRectMake((KScreenWidth/2 - 30)/2,12.5,30,50);
    elcImgView.image = [UIImage imageNamed:@"elec"];
    [self addSubview:elcImgView];
    
    UIImageView *waterImgView = [[UIImageView alloc] init];
    waterImgView.frame = CGRectMake((KScreenWidth/2 - 30)/2 + KScreenWidth/2,12.5,30,50);
    waterImgView.image = [UIImage imageNamed:@"water"];
    [self addSubview:waterImgView];
    
    _elcCostNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, elcImgView.bottom + 18.5, KScreenWidth/2 - 2, 25)];
    _elcCostNumLabel.textAlignment = NSTextAlignmentCenter;
    _elcCostNumLabel.textColor = [UIColor colorWithHexString:@"#1B82D1"];
    _elcCostNumLabel.font = [UIFont systemFontOfSize:25];
    [self addSubview:_elcCostNumLabel];
    
    _waterCostNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth/2 + 1, elcImgView.bottom + 18.5, KScreenWidth/2 - 2, 25)];
    _waterCostNumLabel.textAlignment = NSTextAlignmentCenter;
    _waterCostNumLabel.textColor = [UIColor colorWithHexString:@"#1B82D1"];
    _waterCostNumLabel.font = [UIFont systemFontOfSize:25];
    [self addSubview:_waterCostNumLabel];
    
    UILabel *elcCostLabel = [[UILabel alloc] init];
    elcCostLabel.frame = CGRectMake((KScreenWidth/2 - 40)/2,_elcCostNumLabel.bottom + 10,40,17);
    elcCostLabel.textAlignment = NSTextAlignmentCenter;
    elcCostLabel.text = @"成本";
    elcCostLabel.textColor = [UIColor blackColor];
    [self addSubview:elcCostLabel];
    
    UILabel *waterCostLabel = [[UILabel alloc] init];
    waterCostLabel.frame = CGRectMake((KScreenWidth/2 - 40)/2 + KScreenWidth/2,_elcCostNumLabel.bottom + 10,40,17);
    waterCostLabel.textAlignment = NSTextAlignmentCenter;
    waterCostLabel.text = @"成本";
    waterCostLabel.textColor = [UIColor blackColor];
    [self addSubview:waterCostLabel];
    
    _elcRatioLabel = [[UILabel alloc] init];
    _elcRatioLabel.frame = CGRectMake((KScreenWidth/2 - 80)/2 + 13,elcCostLabel.bottom + 38,80,25);
    _elcRatioLabel.font = [UIFont systemFontOfSize:25];
    [self addSubview:_elcRatioLabel];
    
    _elcUpImgView = [[UIImageView alloc] initWithFrame:CGRectMake(_elcRatioLabel.left - 26, elcCostLabel.bottom + 32, 20, 31)];
    [self addSubview:_elcUpImgView];
    
    _waterRatioLabel = [[UILabel alloc] init];
    _waterRatioLabel.frame = CGRectMake((KScreenWidth/2 - 80)/2 + 13 + KScreenWidth/2,elcCostLabel.bottom + 38,80,25);
    _waterRatioLabel.font = [UIFont systemFontOfSize:25];
    [self addSubview:_waterRatioLabel];
    
    _waterUpImgView = [[UIImageView alloc] initWithFrame:CGRectMake(_waterRatioLabel.left - 26, elcCostLabel.bottom + 32, 20, 31)];
    [self addSubview:_waterUpImgView];
    
    UILabel *elcRation = [[UILabel alloc] init];
    elcRation.frame = CGRectMake((KScreenWidth/2 - 60)/2,_elcRatioLabel.bottom + 21,60,17);
    elcRation.textAlignment = NSTextAlignmentCenter;
    elcRation.text = @"日环比";
    elcRation.textColor = [UIColor blackColor];
    [self addSubview:elcRation];
    
    UILabel *waterRation = [[UILabel alloc] init];
    waterRation.frame = CGRectMake((KScreenWidth/2 - 60)/2 + KScreenWidth/2,_waterRatioLabel.bottom + 21,60,17);
    waterRation.textAlignment = NSTextAlignmentCenter;
    waterRation.text = @"日环比";
    waterRation.textColor = [UIColor blackColor];
    [self addSubview:waterRation];
}

#pragma mark 填充数据
- (void)setElcNum:(NSString *)elcNum {
    _elcNum = elcNum;
    _elcCostNumLabel.text = [NSString stringWithFormat:@"%@元", elcNum];
}
- (void)setIsElcUp:(BOOL)isElcUp {
    _isElcUp = isElcUp;
    if(isElcUp){
        _elcRatioLabel.textColor = [UIColor colorWithHexString:@"#FF4359"];
        _elcUpImgView.image = [UIImage imageNamed:@"count_up"];
    }else {
        _elcRatioLabel.textColor = [UIColor colorWithHexString:@"#189517"];
        _elcUpImgView.image = [UIImage imageNamed:@"count_down"];
    }
}

- (void)setWaterNum:(NSString *)waterNum {
    _waterNum = waterNum;
    _waterCostNumLabel.text = [NSString stringWithFormat:@"%@元", waterNum];
}
- (void)setIsWaterUp:(BOOL)isWaterUp {
    _isWaterUp = isWaterUp;
    if(isWaterUp){
        _waterRatioLabel.textColor = [UIColor colorWithHexString:@"#FF4359"];
        _waterUpImgView.image = [UIImage imageNamed:@"count_up"];
    }else {
        _waterRatioLabel.textColor = [UIColor colorWithHexString:@"#189517"];
        _waterUpImgView.image = [UIImage imageNamed:@"count_down"];
    }
}

- (void)setElcRatio:(NSString *)elcRatio {
    _elcRatio = elcRatio;
    _elcRatioLabel.text = [NSString stringWithFormat:@"%@%%", elcRatio];
    
    if(elcRatio.floatValue > 0){
        _elcRatioLabel.text = [NSString stringWithFormat:@"%d%%", abs(elcRatio.intValue)];
        _elcRatioLabel.textColor = [UIColor colorWithHexString:@"#ec535e"];
        _elcUpImgView.image = [UIImage imageNamed:@"count_up"];
    }else {
        _elcRatioLabel.text = [NSString stringWithFormat:@"%d%%", abs(elcRatio.intValue)];
        _elcRatioLabel.textColor = [UIColor colorWithHexString:@"#88d777"];
        _elcUpImgView.image = [UIImage imageNamed:@"count_down"];
    }
}
- (void)setWaterRatio:(NSString *)waterRatio {
    _waterRatio = waterRatio;
    _waterRatioLabel.text = [NSString stringWithFormat:@"%@%%", waterRatio];
    
    if(waterRatio > 0){
        _waterRatioLabel.text = [NSString stringWithFormat:@"%d%%", abs(waterRatio.intValue)];
        _waterRatioLabel.textColor = [UIColor colorWithHexString:@"#ec535e"];
        _waterUpImgView.image = [UIImage imageNamed:@"count_up"];
    }else {
        _waterRatioLabel.text = [NSString stringWithFormat:@"%d%%", abs(waterRatio.intValue)];
        _waterRatioLabel.textColor = [UIColor colorWithHexString:@"#88d777"];
        _waterUpImgView.image = [UIImage imageNamed:@"count_down"];
    }
}

@end
