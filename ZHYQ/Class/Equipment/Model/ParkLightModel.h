//
//  ParkLightModel.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/23.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface ParkLightModel : BaseModel
/*
 {
 "DEVICE_ADDR" = "VIP\U8f66\U9053\U7167\U660e\U706f1";
 "DEVICE_ID" = 1200;
 "DEVICE_NAME" = "VIP\U8f66\U9053\U7167\U660e\U706f1";
 "DEVICE_TYPE" = 18;
 "EQUIP_STATUS" = 1;
 LATITUDE = "<null>";
 "LAYER_A" = "32,221";
 "LAYER_B" = "69,221";
 "LAYER_C" = "43.243";
 "LAYER_ID" = 1;
 LONGITUDE = "<null>";
 "POINT_TYPE" = 2;
 TAGID = 1200;
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
@property (nonatomic,copy) NSString *EQUIP_STATUS;
@property (nonatomic,copy) NSString *DEVICE_ID;

@property (nonatomic,copy) NSString *current_states;

@end
