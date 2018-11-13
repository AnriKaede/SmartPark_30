//
//  DeviceInfoModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/18.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface DeviceInfoModel : BaseModel

/*
{
    " DEVICE_ID": "1",
    " DEVICE_NAME": "设备名称1"
    "DEVICE_OFFER_NAME" = "<null>";
    "DEVICE_ORDER" = "-1";
    "ROW_ID" = 2;
    "DEVICE_ADDR" = "\U673a\U623f";
}
 */


@property (nonatomic,copy) NSString *DEVICE_ID;
@property (nonatomic,copy) NSString *DEVICE_NAME;
@property (nonatomic,copy) NSString *DEVICE_ADDR;

@end
