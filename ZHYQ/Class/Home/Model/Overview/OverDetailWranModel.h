//
//  OverDetailWranModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/11.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OverDetailWranModel : BaseModel

/*
{
    "alarmId": -1,
    "alarmImage": null,
    "alarmInfo": "危险，快跑",
    "alarmLevel": "1",
    "alarmLocation": "23",
    "alarmResource": "3",
    "alarmState": "0",
    "alarmTime": "2019-01-11 11:33:12",
    "alarmType": "5",
    "contactPhone": null,
    "contacts": null,
    "deviceId": "68371",
    "deviceName": "23",
    "deviceOfferName": null,
    "modifyTime": "2018-05-18 12:55:43",
    "remark": "2:hntf",
    "reportName": "周弦旋",
    "reporter": "396aa5b7b50949418692a356eeffe377"
}
*/

@property (nonatomic,copy) NSString *deviceName;
@property (nonatomic,copy) NSString *reportName;
@property (nonatomic,copy) NSString *alarmTime;
@property (nonatomic,copy) NSString *alarmInfo;

@end

NS_ASSUME_NONNULL_END
