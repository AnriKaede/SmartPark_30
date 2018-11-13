//
//  OperateLogModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/2/7.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface OperateLogModel : BaseModel

/*
{
    "createTime": 1517898465000,
    "deviceId": "1231",
    "deviceName": "sdfaf",
    "expand1": null,
    "expand2": null,
    "expand3": null,
    "expand4": null,
    "expand5": null,
    "id": "201802060227R969960837406",
    "operateChannel": null,
    "operateDes": "士大夫撒旦",
    "operateDeviceId": null,
    "operateDeviceName": null,
    "operateLocation": "508",
    "operateName": "sdf",
    "operateTime": 1517898465000,
    "operateUrl": "sdfsdf",
    "operateValue": null,
    "userId": "123",
    "userName": "ss"
}
 */

@property (nonatomic,strong) NSNumber *createTime;
@property (nonatomic,strong) NSNumber *operateTime;
@property (nonatomic,copy) NSString *deviceId;  // 操作设备ID
@property (nonatomic,copy) NSString *deviceName;
//@property (nonatomic,copy) NSString *id;  // id
@property (nonatomic,copy) NSString *operateChannel; //操作渠道 (PC,  IOS,  Android)
@property (nonatomic,copy) NSString *operateDes;
@property (nonatomic,copy) NSString *operateDeviceId;    // 被操作设备ID
@property (nonatomic,copy) NSString *operateDeviceName;    //操作设备名
@property (nonatomic,copy) NSString *operateLocation;   // //操作地点 (如办公室508)
@property (nonatomic,copy) NSString *operateName;
@property (nonatomic,copy) NSString *operateUrl;
@property (nonatomic,copy) NSString *operateValue;      //操作值  (如音量大小)
@property (nonatomic,copy) NSString *userId;
@property (nonatomic,copy) NSString *userName;

@end
