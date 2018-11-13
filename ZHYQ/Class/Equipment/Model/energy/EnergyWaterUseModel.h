//
//  EnergyWaterUseModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/28.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface EnergyWaterUseModel : BaseModel

/*
{
    "costValue": 27,
    "deviceName": "西侧门监控室水表",
    "preValue": 596,
    "statValue": 623,
    "tagId": "84017153"
}
 */

@property (nonatomic,strong) NSNumber *costValue;
@property (nonatomic,copy) NSString *deviceName;
@property (nonatomic,strong) NSNumber *preValue;
@property (nonatomic,strong) NSNumber *statValue;
@property (nonatomic,copy) NSString *tagId;

@end
