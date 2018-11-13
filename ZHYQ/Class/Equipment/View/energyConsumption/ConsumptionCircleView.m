//
//  ConsumptionCircleView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/15.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ConsumptionCircleView.h"

@implementation ConsumptionCircleView
{
    ConsumptionType _consumptionType;
    
    UILabel *_numLabel;
    UILabel *_costNumLabel;
}

- (instancetype)initWithFrame:(CGRect)frame withConsumptionType:(ConsumptionType)consumptionType {
    self = [super initWithFrame:frame];
    if(self){
        _consumptionType = consumptionType;
        [self _initView];
    }
    return self;
}

- (void)_initView {
    self.layer.cornerRadius = self.width/2;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(0,18,self.width,17);
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:1];
    [self addSubview:titleLabel];

    _numLabel = [[UILabel alloc] init];
    _numLabel.frame = CGRectMake(2,titleLabel.bottom + 10,self.width - 4,22);
    _numLabel.text = @"0";
    _numLabel.textAlignment = NSTextAlignmentCenter;
    _numLabel.font = [UIFont systemFontOfSize:23];
    _numLabel.textColor = [UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:1];
    [self addSubview:_numLabel];
    
//    UILabel *numUnitLabel = [[UILabel alloc] init];
//    numUnitLabel.frame = CGRectMake(_numLabel.right + 10,titleLabel.bottom + 15,28,13);
//    numUnitLabel.font = [UIFont systemFontOfSize:15];
//    numUnitLabel.textColor = [UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:1];
//    [self addSubview:numUnitLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height/2 - 0.5, self.width, 1)];
    lineView.backgroundColor = [UIColor whiteColor];
    [self addSubview:lineView];
    
    _costNumLabel = [[UILabel alloc] init];
    _costNumLabel.frame = CGRectMake(_numLabel.left,_numLabel.bottom + 20,_numLabel.width,22);
    _costNumLabel.text = @"0 元";
    _costNumLabel.textAlignment = NSTextAlignmentCenter;
    _costNumLabel.font = [UIFont systemFontOfSize:23];
    _costNumLabel.textColor = [UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:1];
    [self addSubview:_costNumLabel];
    
//    UILabel *costNumUnitLabel = [[UILabel alloc] init];
//    costNumUnitLabel.frame = CGRectMake(numUnitLabel.left,_costNumLabel.top + 3,15,14);
//    costNumUnitLabel.text = @"元";
//    costNumUnitLabel.font = [UIFont systemFontOfSize:15];
//    costNumUnitLabel.textColor = [UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:1];
//    [self addSubview:costNumUnitLabel];
    
    UILabel *costLabel = [[UILabel alloc] init];
    costLabel.frame = CGRectMake(0,_costNumLabel.bottom + 10,self.width,16);
    costLabel.text = @"今日成本";
    costLabel.textAlignment = NSTextAlignmentCenter;
    costLabel.font = [UIFont systemFontOfSize:17];
    costLabel.textColor = [UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:1];
    [self addSubview:costLabel];
    
    switch (_consumptionType) {
        case ConsumptionElectric:
            titleLabel.text = @"今日耗电";
            break;
        case ConsumptionWater:
            titleLabel.text = @"今日耗水";
            break;
    }
}

- (void)setCountValue:(NSString *)countValue {
    _countValue = countValue;
    
    _numLabel.text = [NSString stringWithFormat:@"%@", countValue];
    
    switch (_consumptionType) {
        case ConsumptionElectric:
        {
            NSString *numStr = [NSString stringWithFormat:@"%@ kwh", _numLabel.text];
            NSMutableAttributedString *atttStr = [[NSMutableAttributedString alloc] initWithString:numStr];
            
            [atttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(numStr.length - 3, 3)];
            _numLabel.attributedText = atttStr;
            
            break;
        }
        case ConsumptionWater:
        {
            NSString *numStr = [NSString stringWithFormat:@"%@ 吨", _numLabel.text];
            NSMutableAttributedString *atttStr = [[NSMutableAttributedString alloc] initWithString:numStr];
            
            [atttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(numStr.length - 1, 1)];
            _numLabel.attributedText = atttStr;
            
            break;
        }
    }
}

- (void)setCountCost:(NSString *)countCost {
    _countCost = countCost;
    
    NSString *costStr = [NSString stringWithFormat:@"%@ 元", countCost];
    
    NSMutableAttributedString *atttStr = [[NSMutableAttributedString alloc] initWithString:costStr];
    
    [atttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(costStr.length - 1, 1)];
    _costNumLabel.attributedText = atttStr;
}

@end
