//
//  ConsumptionCircleView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/15.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ConsumptionElectric = 0,
    ConsumptionWater = 1
}ConsumptionType;

@interface ConsumptionCircleView : UIView

- (instancetype)initWithFrame:(CGRect)frame withConsumptionType:(ConsumptionType)consumptionType;

@property (nonatomic,copy) NSString *countValue;
@property (nonatomic,copy) NSString *countCost;

@end
