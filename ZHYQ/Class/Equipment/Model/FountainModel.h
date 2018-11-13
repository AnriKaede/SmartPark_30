//
//  FountainModel.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/23.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface FountainModel : BaseModel
/*
 {
 "DEVICE_ADDR" = "\U4f11\U95f2\U6e56\U55b7\U6cc91";
 "DEVICE_ID" = 1240;
 "DEVICE_NAME" = "\U4f11\U95f2\U6e56\U55b7\U6cc91";
 "DEVICE_TYPE" = 21;
 "EQUIP_STATUS" = 1;
 LATITUDE = "<null>";
 "LAYER_A" = "<null>";
 "LAYER_B" = "<null>";
 "LAYER_C" = "<null>";
 "LAYER_ID" = 20;
 LONGITUDE = "<null>";
 "POINT_TYPE" = 2;
 TAGID = 1240;
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

@property (nonatomic,assign) BOOL isOpen;  // 是否打开

@end
