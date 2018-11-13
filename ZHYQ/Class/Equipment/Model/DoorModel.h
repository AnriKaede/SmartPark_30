//
//  DoorModel.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/20.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface DoorModel : BaseModel

/*
 {
 "DEVICE_ADDR" = "\U5730\U4e0b\U8f66\U5e93\U5ba2\U68af\U65c1\U6d88\U8d39\U901a\U9053\U95e8\U7981";
 "DEVICE_ID" = 901;
 "DEVICE_NAME" = "\U5730\U4e0b\U8f66\U5e93\U5ba2\U68af\U65c1\U6d88\U8d39\U901a\U9053\U95e8\U7981";
 "DEVICE_TYPE" = 4;
 "DOOR_STATUS" = 1;
 LATITUDE = "<null>";
 "LAYER_A" = "<null>";
 "LAYER_B" = "<null>";
 "LAYER_C" = "<null>";
 "LAYER_ID" = 1;
 LONGITUDE = "<null>";
 "POINT_TYPE" = 2;
 TAGID = 901;
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
@property (nonatomic,strong) NSString *LAYER_ID;
@property (nonatomic,copy) NSString *DEVICE_ID;

@property (nonatomic,copy) NSString *DOOR_STATUS;

@property (nonatomic, assign) BOOL isSpread;

@end
