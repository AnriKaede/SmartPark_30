//
//  BillListModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/15.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface BillListModel : BaseModel

/*
{
    "alarmContent": "测试故障处理工单",
    "alarmId": 1,
    "alarmImage": null,
    "createDate": null,
    "createrId": "123",
    "createrName": "测试",
    "dealDate": "2018-05-03 00:00:00.0",
    "deviceId": "68322",
    "deviceName": null,
    "deviceOfferName": null,
    "expectDate": null,
    "orderId": "1",
    "orderState": "02",
    "remark": null,
    "repairId": null,
    "repairName": null
}
*/

@property (nonatomic,copy) NSString *alarmContent;
@property (nonatomic,strong) NSNumber *alarmId;
@property (nonatomic,copy) NSString *createrId;
@property (nonatomic,copy) NSString *createDate;
@property (nonatomic,copy) NSString *createrName;
@property (nonatomic,copy) NSString *dealDate;
@property (nonatomic,copy) NSString *deviceId;
@property (nonatomic,copy) NSString *orderId;
@property (nonatomic,copy) NSString *orderState;
@property (nonatomic,copy) NSString *deviceName;
@property (nonatomic,copy) NSString *expectDate;
@property (nonatomic,copy) NSString *repairName;
@property (nonatomic,copy) NSString *repairId;
@property (nonatomic,copy) NSString *remark;
 
@end
