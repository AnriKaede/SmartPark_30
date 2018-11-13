//
//  FlowTraceModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface FlowTraceModel : BaseModel

/*
{
    "reportId":null,
    "reportAgentId":null,
    "reportParkId":"8a04a41f56bc33a20156bc3726df0004",
    "reportGateId":null,
    "reportOccurDate":"20171208",
    "reportOccurHour":null,
    "smallTime":157033,
    "middleTime":0,
    "bigTime":2126,
    "totalTime":159159
}
 */

@property (nonatomic, strong) NSNumber *totalTime;

@end
