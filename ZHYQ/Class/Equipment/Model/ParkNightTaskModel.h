//
//  ParkNightTaskModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/29.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface ParkNightTaskModel : BaseModel

/*
{
    "BEGIN_TIME": "06:00",
    "END_TIME": "18:00",
    "EXECUTETIME": null,
    "ISVALID": "0",
    "JOBACTION": "ON",
    "JOBDURATION": "1111110",
    "JOBENDTIME": null,
    "JOBSTARTTIME": null,
    "JOBTYPE": "1",
    "NEXTTIME": null,
    "STATE": "0",
    "TASKID": 10000005,
    "TASKNAME": "任务2"
}
 */

@property (nonatomic,copy) NSString *BEGIN_TIME;
@property (nonatomic,copy) NSString *END_TIME;
@property (nonatomic,copy) NSString *EXECUTETIME;
@property (nonatomic,copy) NSString *ISVALID;
@property (nonatomic,copy) NSString *JOBACTION;
@property (nonatomic,copy) NSString *JOBDURATION;
@property (nonatomic,copy) NSString *JOBENDTIME;
@property (nonatomic,copy) NSString *JOBSTARTTIME;
@property (nonatomic,copy) NSString *JOBTYPE;
@property (nonatomic,copy) NSString *NEXTTIME;
@property (nonatomic,copy) NSString *STATE;
@property (nonatomic,strong) NSNumber *TASKID;
@property (nonatomic,copy) NSString *TASKNAME;

// 浇灌定时任务参数
@property (nonatomic,strong) NSNumber *lowValue;
@property (nonatomic,strong) NSNumber *upValue;

@end
