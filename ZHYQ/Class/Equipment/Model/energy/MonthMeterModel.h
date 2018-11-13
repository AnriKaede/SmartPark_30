//
//  MonthMeterModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/27.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface MonthMeterModel : BaseModel

/*
{
    "deviceName": "西侧门监控室水表",
    "endIoValue": 623,
    "energyCost": 153,
    "startIoValue": 470,
    "statMonth": "2018-01",
    "tagid": "84017153"
}
*/

@property (nonatomic,copy) NSString *deviceName;
@property (nonatomic,strong) NSNumber *endIoValue;
@property (nonatomic,strong) NSNumber *energyCost;
@property (nonatomic,copy) NSString *startIoValue;
@property (nonatomic,copy) NSString *statMonth;
@property (nonatomic,copy) NSString *tagid;

@end
