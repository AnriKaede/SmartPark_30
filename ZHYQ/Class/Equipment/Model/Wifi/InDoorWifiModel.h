//
//  InDoorWifiModel.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/16.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface InDoorWifiModel : BaseModel
/*
 {
 "DEVICE_ADDR" = "\U5730\U4e0b\U8f66\U5e93\U5317\U4fa7";
 "DEVICE_ID" = 651;
 "DEVICE_NAME" = "\U5730\U4e0b\U8f66\U5e93\U5317\U4fa7AP1";
 "DEVICE_TYPE" = 2;
 LATITUDE = "<null>";
 "LAYER_A" = "2313,1197";
 "LAYER_B" = "2385,1197";
 "LAYER_C" = "2357,1225";
 "LAYER_ID" = 1;
 LONGITUDE = "<null>";
 "POINT_TYPE" = 2;
 TAGID = 651;
 "WIFI_STATUS" = 1;
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
@property (nonatomic,copy) NSString *WIFI_STATUS;
@property (nonatomic,copy) NSString *DEVICE_ID;

@end
