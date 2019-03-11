//
//  OverDeviceInfoModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/11.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OverDeviceInfoModel : BaseModel

/*
{
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
}
*/

@property (nonatomic,copy) NSString *deviceName;
@property (nonatomic,copy) NSString *deviceAddr;
 
@end

NS_ASSUME_NONNULL_END
