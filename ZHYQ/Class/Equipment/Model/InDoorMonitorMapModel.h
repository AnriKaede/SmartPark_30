//
//  InDoorMonitorMapModel.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/16.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface InDoorMonitorMapModel : BaseModel

/*
 {
 "CAMERA_STATUS" = 1;
 "DEVICE_ADDR" = "\U897f\U4fa7\U8d27\U68af\U5de6";
 "DEVICE_ID" = 610;
 "DEVICE_NAME" = "\U5730\U4e0b\U8f66\U5e931F-\U534a\U7403\U673a\U8d27\U68af1";
 "DEVICE_TYPE" = "1-3";
 LATITUDE = "<null>";
 "LAYER_A" = "776,1599";
 "LAYER_B" = "786,1597";
 "LAYER_C" = "782,1610";
 "LAYER_ID" = 1;
 LONGITUDE = "<null>";
 "POINT_TYPE" = 2;
 TAGID = 610;
 }
 */
@property (nonatomic,strong) NSNumber *LATITUDE;
@property (nonatomic,copy) NSString *LAYER_A;
@property (nonatomic,copy) NSString *DEVICE_ADDR;
@property (nonatomic,copy) NSString *DEVICE_TYPE;
@property (nonatomic,copy) NSString *LAYER_C;
@property (nonatomic,copy) NSString *DEVICE_NAME;
@property (nonatomic,copy) NSString *POINT_TYPE;
@property (nonatomic,copy) NSString *TAGID;
@property (nonatomic,strong) NSNumber *LONGITUDE;
@property (nonatomic,copy) NSString *LAYER_B;
@property (nonatomic,strong) NSNumber *LAYER_ID;
@property (nonatomic,copy) NSString *CAMERA_STATUS;
@property (nonatomic,copy) NSString *DEVICE_ID;

@end
