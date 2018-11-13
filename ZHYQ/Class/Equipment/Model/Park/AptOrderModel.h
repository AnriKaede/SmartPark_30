//
//  AptOrderModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/6/20.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface AptOrderModel : BaseModel

/*
{
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
}
 */


@property (nonatomic,copy) NSString *status;    // 订单状态 0预约中 1入场 2取消 3超时取消 4完成

@property (nonatomic,copy) NSString *orderId;
@property (nonatomic,copy) NSString *parkingSpaceId;
@property (nonatomic,copy) NSString *carNo;
@property (nonatomic,copy) NSString *parkingSpaceName;
@property (nonatomic,copy) NSString *custName;
@property (nonatomic,copy) NSString *phone;
@property (nonatomic,copy) NSString *orderTime;
@property (nonatomic,copy) NSString *invalidTime;
@property (nonatomic,copy) NSString *updateTime;
@property (nonatomic,copy) NSString *remark;

@end

