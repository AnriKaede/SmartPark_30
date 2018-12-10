//
//  StreetLampSubModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/9.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface StreetLampSubModel : BaseModel

/*
{
    "A": null,
    "B": null,
    "C": null,
    "DEVICE_ADDR": "上善若水西边",
    "DEVICE_ID": "850",
    "DEVICE_NAME": "上善若水西边",
    "DEVICE_ORDER": 850,
    "DEVICE_TYPE": "5",
    "LAYER_A": "250,57",
    "LAYER_B": "273,57",
    "LAYER_C": "261,79",
    "LAYER_ID": 20,
    "SUB_DEVICE_ADDR": "863703033590782",
    "SUB_DEVICE_ID": 90004,
    "SUB_DEVICE_NAME": "LED路灯",
    "SUB_DEVICE_TYPE": "18",
    "SUB_TAGID": "5a45f00298f1ac15eefab9ed",
    "TAGID": "7"
}
 */

@property (nonatomic,copy) NSString *DEVICE_ADDR;
@property (nonatomic,copy) NSString *DEVICE_NAME;
@property (nonatomic,copy) NSString *SUB_DEVICE_ADDR;
@property (nonatomic,copy) NSString *SUB_TAGID;
@property (nonatomic,copy) NSString *DEVICE_TYPE;

@property (nonatomic,assign) BOOL isConSelect;

@end
