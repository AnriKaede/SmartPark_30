//
//  ParkDateCountModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/8.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface ParkDateCountModel : BaseModel

/*
{
    "reportId": null,
    "reportAgentId": null,
    "reportParkId": "8a04a41f56bc33a20156bc3726df0004",
    "reportGateId": null,
    "reportOccurDate": "20171208",
    "reportOccurHour": "00",
    "smallTime": 5,
    "middleTime": 0,
    "bigTime": 0,
    "totalTime": 5
}
 */
 
@property (nonatomic,copy) NSString *reportId;
@property (nonatomic,copy) NSString *reportAgentId;
@property (nonatomic,copy) NSString *reportParkId;
@property (nonatomic,copy) NSString *reportGateId;
@property (nonatomic,copy) NSString *reportOccurDate;
@property (nonatomic,copy) NSString *reportOccurHour;
@property (nonatomic,strong) NSNumber *smallTime;
@property (nonatomic,strong) NSNumber *middleTime;
@property (nonatomic,strong) NSNumber *bigTime;
@property (nonatomic,strong) NSNumber *totalTime;

@end
