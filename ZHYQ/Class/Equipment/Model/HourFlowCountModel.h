//
//  HourFlowCountModel.h
//  ZHYQ
//
//  Created by 焦平 on 2017/12/3.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface HourFlowCountModel : BaseModel
/*
 {
 agentId = "<null>";
 balanceBigCount = 0;
 balanceMiddleCount = 0;
 balanceSmallCount = 0;
 balanceTotalCount = 0;
 exceptionCount = 0;
 joinParkName = "<null>";
 mouthBigCount = 0;
 mouthMiddleCount = 0;
 mouthSmallCount = 5;
 mouthTotalCount = 5;
 parkId = 8a04a41f56bc33a20156bc3726df0004;
 reportGateId = "<null>";
 reportId = "<null>";
 reportOccurDate = 20171124;
 reportOccurDateEnd = "<null>";
 reportOccurDateStart = "<null>";
 reportOccurHour = 00;
 reportTollNo = "<null>";
 selfBigCount = 0;
 selfMiddleCount = 0;
 selfSmallCount = 0;
 selfTotalCount = 0;
 tmpBigCount = 0;
 tmpMiddleCount = 0;
 tmpSmallCount = 4;
 tmpTotalCount = 4;
 tollName = "<null>";
 totalBigCount = 0;
 totalMiddleCount = 0;
 totalSmallCount = 9;
 totalTotalCount = 9;
 }
 */

@property (nonatomic,strong) NSNumber *reportTollNo;
@property (nonatomic,copy) NSString *joinParkName;
@property (nonatomic,strong) NSNumber *mouthTotalCount;
@property (nonatomic,copy) NSString *reportOccurDateStart;
@property (nonatomic,strong) NSNumber *mouthMiddleCount;
@property (nonatomic,strong) NSNumber *balanceTotalCount;
@property (nonatomic,strong) NSNumber *totalTotalCount;
@property (nonatomic,copy) NSString *reportOccurHour;
@property (nonatomic,strong) NSNumber *tmpSmallCount;
@property (nonatomic,strong) NSNumber *balanceBigCount;
@property (nonatomic,strong) NSNumber *tmpTotalCount;
@property (nonatomic,strong) NSNumber *selfSmallCount;
@property (nonatomic,strong) NSNumber *selfBigCount;
@property (nonatomic,strong) NSNumber *exceptionCount;
@property (nonatomic,strong) NSNumber *totalBigCount;
@property (nonatomic,strong) NSNumber *tmpMiddleCount;
@property (nonatomic,copy) NSString *agentId;
@property (nonatomic,copy) NSString *reportGateId;
@property (nonatomic,strong) NSNumber *selfMiddleCount;
@property (nonatomic,strong) NSNumber *tmpBigCount;
@property (nonatomic,copy) NSString *tollName;
@property (nonatomic,copy) NSString *reportId;
@property (nonatomic,copy) NSString *reportOccurDateEnd;
@property (nonatomic,copy) NSString *reportOccurDate;
@property (nonatomic,strong) NSNumber *totalSmallCount;
@property (nonatomic,copy) NSString *parkId;
@property (nonatomic,strong) NSNumber *totalMiddleCount;
@property (nonatomic,strong) NSNumber *balanceSmallCount;
@property (nonatomic,strong) NSNumber *mouthBigCount;
@property (nonatomic,strong) NSNumber *balanceMiddleCount;
@property (nonatomic,strong) NSNumber *selfTotalCount;
@property (nonatomic,strong) NSNumber *mouthSmallCount;

@end
