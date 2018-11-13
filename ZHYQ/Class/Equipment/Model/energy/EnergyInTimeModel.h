//
//  EnergyInTimeModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/28.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface EnergyInTimeModel : BaseModel

/*
{
    "elecCost": 190,
    "elecCurrentValue": 114154,
    "elecPreValue": 113964,
    "hour": "0",
    "waterCost": 0,
    "waterCurrentValue": 959,
    "waterPreValue": 959
}
 */

@property (nonatomic,strong) NSNumber *elecCost;
@property (nonatomic,strong) NSNumber *elecCurrentValue;
@property (nonatomic,strong) NSNumber *elecPreValue;
@property (nonatomic,copy) NSString *hour;
@property (nonatomic,strong) NSNumber *waterCost;
@property (nonatomic,strong) NSNumber *waterCurrentValue;
@property (nonatomic,strong) NSNumber *waterPreValue;


@end
