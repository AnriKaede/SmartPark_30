//
//  InDoorBgMusicMapModel.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/16.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface InDoorBgMusicMapModel : BaseModel

/*
 {
 "DEVICE_ADDR" = "\U897f\U4fa7\U8d27\U68af1";
 "DEVICE_ID" = 210;
 "DEVICE_NAME" = "\U80cc\U666f\U97f3\U4e50";
 "DEVICE_TYPE" = 3;
 LATITUDE = "<null>";
 "LAYER_A" = "458,658";
 "LAYER_B" = "504,662";
 "LAYER_C" = "493,677";
 "LAYER_ID" = 3;
 LONGITUDE = "<null>";
 "MUSIC_STATUS" = 1;
 "POINT_TYPE" = 2;
 TAGID = 210;
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
@property (nonatomic,copy) NSString *MUSIC_STATUS;
@property (nonatomic,copy) NSString *DEVICE_ID;

@property (nonatomic,assign) BOOL isOpen;

@property (nonatomic,copy) NSString *currentMusic;

@end
