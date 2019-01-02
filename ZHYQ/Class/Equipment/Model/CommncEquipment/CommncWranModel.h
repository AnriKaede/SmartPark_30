//
//  CommncWranModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/29.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CommncWranModel : BaseModel

/*
{
    "id": "e4a25374145e4bc6a872a1e66a78f780",
    "equipCode": "fa7cf589-7489-45c3-a821-51085422e985",
    "equipSn": "868744030092302",
    "equipName": "创力光交04",
    "equipTypeCode": "InterBoxLock",
    "creStaff": "iottest2018010801",
    "latitude": "28.273955",
    "longitude": "112.989209",
    "provinceCode": 430000,
    "provinceName": "湖南省",
    "cityCode": 430100,
    "cityName": "长沙市",
    "areaCode": 430105,
    "areaName": "开福区",
    "addressInfo": "湖南省长沙市开福区迎霞路27",
    "serviceId": "Temperature",
    "serviceType": "3",
    "serviceName": "高温报警",
    "serviceStatus": "alarm",
    "serviceValue": "85.0",
    "threshold": "60.0",
    "triggerDate": "2018-12-27 18:03:46",
    "reportDate": "2018-12-27 17:56:07",
    "whetherAlarm": 1,
    "equipTypeCodeName": "光交锁",
    "serviceTypeName": "高温报警",
    "alarmLevel": "1",
    "alarmLevelName": "普通",
    "runingStatus": "ABNORMAL",
    "runingStatusName": "异常",
    "num": 1
}
 */

@property (nonatomic,copy) NSString *serviceName;
@property (nonatomic,copy) NSString *alarmLevel;
@property (nonatomic,copy) NSString *equipName;
@property (nonatomic,copy) NSString *equipSn;
@property (nonatomic,copy) NSString *runingStatusName;
@property (nonatomic,copy) NSString *serviceValue;
@property (nonatomic,copy) NSString *triggerDate;
@property (nonatomic,copy) NSString *reportDate;
@property (nonatomic,copy) NSString *addressInfo;

@end

NS_ASSUME_NONNULL_END
