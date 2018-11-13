//
//  WranUndealModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/7.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface WranUndealModel : BaseModel

/*
{
    "alarmId": 68335,
    "alarmImage": null,
    "alarmInfo": "灯不亮",
    "alarmLocation": "研发楼306室",
    "alarmResource": "3",
    "alarmState": "0",
    "alarmTime": "2018-05-07 11:14:50",
    "alarmType": "5",
    "deviceId": null,
    "deviceName": "306灯",
    "modifyTime": null,
    "reportName": "管理员",
    "reporter": "2"
}
 
 {
     "alarmId": 1,
     "alarmImage": null,
     "alarmInfo": "测试故障信息1:admin",
     "alarmLocation": "园区西区",
     "alarmResource": "3",
     "alarmState": "2",
     "alarmTime": "2018-05-03 00:00:00",
     "alarmType": "5",
     "contactPhone": null,
     "contacts": null,
     "deviceId": "1",
     "deviceName": "led灯",
     "deviceOfferName": null,
     "modifyTime": "2018-05-16 11:13:01",
     "remark": null,
     "reportName": "测试",
     "reporter": "admin"
 }
 */

@property (nonatomic,copy) NSString *alarmId;
@property (nonatomic,copy) NSString *alarmInfo;
@property (nonatomic,copy) NSString *alarmLocation;
@property (nonatomic,copy) NSString *alarmResource;
@property (nonatomic,copy) NSString *alarmState;
@property (nonatomic,copy) NSString *alarmTime;
@property (nonatomic,copy) NSString *alarmType;
@property (nonatomic,copy) NSString *deviceName;
@property (nonatomic,copy) NSString *reportName;
@property (nonatomic,copy) NSString *reporter;

@property (nonatomic,copy) NSString *deviceOfferName;

@end
