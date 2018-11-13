//
//  ParkFlowCountModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface ParkFlowCountModel : BaseModel

/*
{
    "reportId":null,
    "agentId":null,
    "parkId":"8a04a41f56bc33a20156bc3726df0004",
    "reportGateId":null,
    "reportTollNo":null,
    "reportOccurDate":"20171208",
    "reportOccurHour":null,
    "tmpSmallCount":1474,
    "tmpMiddleCount":0,
    "tmpBigCount":0,
    "tmpTotalCount":1474,
    "mouthSmallCount":0,
    "mouthMiddleCount":0,
    "mouthBigCount":0,
    "mouthTotalCount":0,
    "balanceSmallCount":0,
    "balanceMiddleCount":0,
    "balanceBigCount":0,
    "balanceTotalCount":0,
    "selfSmallCount":0,
    "selfMiddleCount":0,
    "selfBigCount":0,
    "selfTotalCount":0,
    "exceptionCount":0,
    "totalSmallCount":1474,
    "totalMiddleCount":0,
    "totalBigCount":0,
    "totalTotalCount":1474,
    "tollName":null,
    "joinParkName":null,
    "reportOccurDateStart":null,
    "reportOccurDateEnd":null
}
 */

@property (nonatomic, copy) NSString *reportId;
@property (nonatomic, strong) NSNumber *totalTotalCount;
@property (nonatomic, strong) NSNumber *mouthTotalCount;
@property (nonatomic, strong) NSNumber *tmpTotalCount;

@end
