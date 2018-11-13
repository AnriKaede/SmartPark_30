//
//  MealDayModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/2/3.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface MealDayModel : BaseModel
/*
{
    "cardCount": 720,
    "chargeCount": 1076,
    "costMoney": 12001.5,
    "dodPersent": -6.03,
    "preCardCount": 742,
    "preChargeCount": 1145,
    "preCostMoney": 18706.5,
    "statDate": "2018-02-01"
}
 */

@property (nonatomic,strong) NSNumber *cardCount;
@property (nonatomic,strong) NSNumber *chargeCount;
@property (nonatomic,strong) NSNumber *costMoney;
@property (nonatomic,strong) NSNumber *dodPersent;
@property (nonatomic,strong) NSNumber *preCardCount;
@property (nonatomic,strong) NSNumber *preChargeCount;
@property (nonatomic,strong) NSNumber *preCostMoney;
@property (nonatomic,copy) NSString *statDate;

@end
