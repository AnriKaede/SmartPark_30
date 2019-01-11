//
//  OverAlarmModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/11.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OverAlarmModel : BaseModel

/*
{
    "alarmLevelCount": 170,
    "alarmLevelId": "1",
    "alarmLevelName": "可疑"
}
 */

@property (nonatomic,strong) NSNumber *alarmLevelCount;
@property (nonatomic,copy) NSString *alarmLevelId;
@property (nonatomic,copy) NSString *alarmLevelName;

@end

NS_ASSUME_NONNULL_END
