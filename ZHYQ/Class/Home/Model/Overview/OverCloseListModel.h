//
//  OverCloseListModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/18.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OverCloseListModel : BaseModel

/*
{
    "alarmTag": 0,
    "alarmTime": 1547139600000,
    "deviceId": "3",
    "deviceName": "测试设备3",
    "deviceType": "2",
    "layerId": 1,
    "offlineTime": 1547139600000,
    "onlineTag": "0",
    "remark": null,
    "status": "2",
    "statusTime": 1547136060000,
    "updateTime": 1547139600000
}
 */

@property (nonatomic,copy) NSString *deviceName;
@property (nonatomic,strong) NSNumber *statusTime;
@property (nonatomic,copy) NSString *deviceAddr;

@end

NS_ASSUME_NONNULL_END
