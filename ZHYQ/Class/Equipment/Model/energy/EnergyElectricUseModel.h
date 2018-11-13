//
//  EnergyElectricUseModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/28.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface EnergyElectricUseModel : BaseModel

/*
{
    "companyId": "9",
    "companyName": "咨询",
    "costValue": 588,
    "preValue": 4870,
    "statValue": 5458
}
*/

@property (nonatomic,copy) NSString *companyId;
@property (nonatomic,copy) NSString *companyName;
@property (nonatomic,strong) NSNumber *costValue;
@property (nonatomic,strong) NSNumber *preValue;
@property (nonatomic,strong) NSNumber *statValue;


@end
