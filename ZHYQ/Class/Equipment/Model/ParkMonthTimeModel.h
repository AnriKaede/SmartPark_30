//
//  ParkMonthModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/21.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface ParkMonthTimeModel : BaseModel

/*
{
    "reportId": null,
    "agentId": null,
    "parkId": "8a04a41f56bc33a20156bc3726df0004",
    "reportGateId": null,
    "reportTollNo": null,
    "reportOccurDate": "201712",
    "reportOccurHour": null,
    "tmpSmallCount": 18141,
    "tmpMiddleCount": 0,
    "tmpBigCount": 41,
    "tmpTotalCount": 18182,
    "mouthSmallCount": 11615,
    "mouthMiddleCount": 0,
    "mouthBigCount": 8,
    "mouthTotalCount": 11623,
    "balanceSmallCount": 0,
    "balanceMiddleCount": 0,
    "balanceBigCount": 0,
    "balanceTotalCount": 0,
    "selfSmallCount": 0,
    "selfMiddleCount": 0,
    "selfBigCount": 0,
    "selfTotalCount": 0,
    "exceptionCount": 0,
    "totalSmallCount": 29756,
    "totalMiddleCount": 0,
    "totalBigCount": 49,
    "totalTotalCount": 29805,
    "tollName": null,
    "joinParkName": null,
    "reportOccurDateStart": null,
    "reportOccurDateEnd": null
}
 */

@property (nonatomic,copy) NSString *reportOccurDate;
@property (nonatomic,strong) NSNumber *totalTotalCount;
@property (nonatomic,strong) NSNumber *mouthTotalCount;
@property (nonatomic,strong) NSNumber *tmpTotalCount;

@end
