//
//  OverOffLineModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/11.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "BaseModel.h"
#import "OverDeviceInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OverOffLineModel : BaseModel

/*
{
    "alarmTag": 0,
    "alarmTime": 1547139600000,
    "deviceId": "2",
    "deviceInfo": {
        "deviceAddr": "国际会议厅前坪1",
        "deviceAttrId": null,
        "deviceId": "2",
        "deviceImage": null,
        "deviceName": "室外WIFI-AP-国际会议厅前坪1",
        "deviceNo": null,
        "deviceOfferName": null,
        "deviceOrder": 2,
        "deviceOverName": null,
        "deviceType": "2-3",
        "ipAddr": null,
        "isIp": null,
        "layerId": 20,
        "macAddr": null,
        "parentDeviceId": null,
        "program": null,
        "qrImage": null,
        "remark": null,
        "status": null,
        "tagid": "1栋3层-DA-1A"
    },
    "deviceName": "测试设备2",
    "deviceType": "1",
    "layerId": 1,
    "offlineTime": 1547139600000,
    "onlineTag": "0",
    "status": "0",
    "statusTime": 1547136060000,
    "updateTime": 1547139600000
}
 */

@property (nonatomic,strong) NSNumber *offlineTime;
//@property (nonatomic,retain) OverDeviceInfoModel *infoModel;
@property (nonatomic,copy) NSString *deviceName;
@property (nonatomic,copy) NSString *deviceAddr;

@end

NS_ASSUME_NONNULL_END
