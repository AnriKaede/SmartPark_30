//
//  WifiMapModel.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface WifiMapModel : BaseModel
/*
 {
 "DEVICE_ADDR" = "\U8fdc\U5927\U8def\U5317\U5927\U95e8\U5165\U53e3";
 "DEVICE_ID" = 1;
 "DEVICE_NAME" = "WIFI-AP";
 "DEVICE_TYPE" = 2;
 LATITUDE = "28.200086";
 "LAYER_A" = "<null>";
 "LAYER_B" = "<null>";
 "LAYER_C" = "<null>";
 "LAYER_ID" = 20;
 LONGITUDE = "113.069852";
 "POINT_TYPE" = 1;
 TAGID = "<null>";
 }
 */

@property (nonatomic,copy) NSString *LATITUDE;
@property (nonatomic,copy) NSString *LAYER_A;
@property (nonatomic,copy) NSString *DEVICE_ADDR;
@property (nonatomic,copy) NSString *LAYER_C;

@property (nonatomic,copy) NSString *LAYER_B;
@property (nonatomic,copy) NSString *DEVICE_TYPE;
@property (nonatomic,copy) NSString *DEVICE_NAME;
@property (nonatomic,copy) NSString *POINT_TYPE;

@property (nonatomic,copy) NSString *TAGID;
@property (nonatomic,copy) NSString *LONGITUDE;
@property (nonatomic,strong) NSNumber *LAYER_ID;
@property (nonatomic,copy) NSString *DEVICE_ID;

@property (nonatomic,copy) NSString *WIFI_STATUS;

@end
