//
//  CommnncCoverModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/24.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CommnncCoverModel : BaseModel

/*
{
    "addressInfo": "湖南省长沙市芙蓉区",
    "alarmCount": "1",
    "disarmState": "1",
    "disarmStateName": "已布防",
    "doorState": "1",
    "doorStateName": "开",
    "equipCode": "32622de0-dc8b-4778-87e4-f941b34763ce",
    "equipName": "湖南通服01#演示光交锁",
    "equipSn": "868744030735967",
    "equipTypeCode": "31",
    "equipTypeCodeName": "光交锁",
    "firstMonitored": "1",
    "id": "0cd5a8fd12ac41cf8732c9b1257f952d",
    "imageUrl": "/app/local/uploadImg/20180622|b118d53983dc49a09fb7cae1450f6e9c.jpg",
    "isAlarm": "1",
    "latitude": "868744030093078",
    "lockState": "2",
    "lockStateName": "关",
    "logicId": "100000000000000000049145",
    "longitude": "868744030093078",
    "manageState": "2",
    "manageStateName": "启用",
    "manufactureCode": "MakePower",
    "manufactureName": "浙江创力",
    "modelCode": "MPACS-BPL",
    "modelName": "MPACS-BPL",
    "referencePosition": "113.024634,28.193063 东方之珠35967 香菲酒店门口",
    "remark": "",
    "runingStatus": "ABNORMAL",
    "runingStatusDate": "2018-12-27 04:48:23",
    "runingStatusDetail": "长时间开门报警",
    "runingStatusName": "异常",
    "serviceTypeName": "长时间开门报警",
    "signalNoise": "6",
    "signalStateName": "",
    "signalStrength": "-75",
    "state": "ONLINE",
    "stateDetail": "NONE",
    "triggerDate": "2018-12-27 04:50:57"
}
*/

@property (nonatomic,copy) NSString *equipName;
@property (nonatomic,copy) NSString *deviceName;
@property (nonatomic,copy) NSString *state; // 状态，ONLINE:在线，OFFLINE：离线，INBOX：停用
@property (nonatomic,copy) NSString *equipSn;
@property (nonatomic,copy) NSString *equipCode;
@property (nonatomic,copy) NSString *stateDetail;
@property (nonatomic,copy) NSString *triggerDate;
@property (nonatomic,copy) NSString *addressInfo;
@property (nonatomic,copy) NSString *runingStatus;  //运行状态，NORMAL：正常;ABNORMAL：异常;FAULT：故障
@property (nonatomic,copy) NSString *modelCode;
@property (nonatomic,copy) NSString *modelName;
@property (nonatomic,copy) NSString *manufactureName;
@property (nonatomic,copy) NSString *runingStatusDetail;

@property (nonatomic,copy) NSString *latitude;
@property (nonatomic,copy) NSString *longitude;

@property (nonatomic,assign) BOOL isSelect;

@end

NS_ASSUME_NONNULL_END
