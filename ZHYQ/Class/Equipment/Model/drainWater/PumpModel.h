//
//  PumpModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/8/16.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PumpModel : BaseModel

/*
{
    "fault": "0",
    "inPressure": "0.410000",
    "mode": "1",
    "outPressure": "0.650000",
    "overAlarm": "0",
    "pressureAlarm": "0"
}
 */

@property (nonatomic,copy) NSString *fault;
@property (nonatomic,copy) NSString *inPressure;
@property (nonatomic,copy) NSString *mode;
@property (nonatomic,copy) NSString *outPressure;
@property (nonatomic,copy) NSString *overAlarm;
@property (nonatomic,copy) NSString *pressureAlarm;

@end

NS_ASSUME_NONNULL_END
