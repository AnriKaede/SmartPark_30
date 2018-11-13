//
//  ParkSpaceModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/6/19.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"


@interface ParkSpaceModel : BaseModel

/*
{
    "carNo": "湘A8V37V",
    "changeRelaId": "2018061975730",
    "changeResion": "取消预约!",
    "changeTime": null,
    "lockId": "40f0011",
    "lockStatus": "0",
    "lockType": "1",
    "parkingAreaId": "2001",
    "parkingAreaName": "前坪停车区",
    "parkingId": "1001",
    "parkingName": "天园停车场",
    "parkingSpaceId": "3002",
    "parkingSpaceName": "前坪车位01",
    "parkingStatus": "0",
    "parkingType": "0",
    "position1": null,
    "position2": null,
    "version": 48
}
*/

@property (nonatomic,copy) NSString *carNo;
@property (nonatomic,copy) NSString *parkingStatus; // 车位状态 0空闲 1预占 2已占 3禁止预约 4异常 5 非预约占用
@property (nonatomic,copy) NSString *changeRelaId;  // 状态变更关联id (工单id,定时任务id等)
@property (nonatomic,copy) NSString *parkingSpaceName;

@property (nonatomic,copy) NSString *parkingSpaceId;
@property (nonatomic,strong) NSNumber *version;
@property (nonatomic,copy) NSString *parkingAreaId;

@property (nonatomic,copy) NSString *lockStatus;    //0 上锁  1 锁d打开

@property (nonatomic,copy) NSString *ledStatus; // 升降 车位锁led状态0关 1开

@property (nonatomic,assign) BOOL isSelect; // 批量操作是否选中

@end

