//
//  AptListModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/6/20.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"
#import "AptOrderModel.h"
#import "AptParkingAreaModel.h"
#import "AptParkingSpaceModel.h"


@interface AptListModel : BaseModel

/*
 "cunrentTime": "2018-06-14 08:47:07",

{
    "order": {
        "carNo": "湘A12345",
        "createTime": "2018-06-12 14:40:39",
        "custId": "83a61ebdede24f2d8f3fadbd13859aae",
        "custName": "马浩然",
        "delFlag": null,
        "invalidTime": "2018-06-12 15:10:39",
        "lockId": "40f0011",
        "lockType": "1",
        "orderId": "2018061275501",
        "orderPrice": null,
        "orderTime": "2018-06-12 14:40:39",
        "parkingSpaceId": "3002",
        "parkingSpaceName": "前坪车位01",
        "payMode": null,
        "payOrderId": null,
        "payTag": null,
        "payTime": null,
        "remark": null,
        "reservedTime": 1800,
        "status": "2",
        "updateTime": null
    },
    "parkingArea": {
        "availableSpaceNum": null,
        "latitude": "28.198722",
        "longitude": "113.069875",
        "parkingAreaDesc": null,
        "parkingAreaId": "2001",
        "parkingAreaName": "前坪停车区",
        "parkingId": "1001",
        "remark": null,
        "status": "0",
        "totalSpaceNum": null
    },
    "parkingSpace": {
        "carNo": "湘A8V37V",
        "changeRelaId": "2018061475647",
        "changeResion": "车位预约!",
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
        "parkingStatus": "1",
        "parkingType": "0",
        "position1": null,
        "position2": null,
        "version": 36
    }
}
 */

@property (nonatomic,retain) AptOrderModel *orderModel;
@property (nonatomic,retain) AptParkingAreaModel *parkingAreaModel;
@property (nonatomic,retain) AptParkingSpaceModel *parkingSpaceModel;

@property (nonatomic,copy) NSString *cunrentTime;    // 数据库时间

@property (nonatomic,assign) BOOL isSelect; // 批量取消预约 是否选中

@end

