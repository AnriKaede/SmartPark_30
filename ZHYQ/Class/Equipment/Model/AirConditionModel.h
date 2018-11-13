//
//  AirConditionModel.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/23.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"
#import "MeetRoomStateModel.h"

@interface AirConditionModel : BaseModel
/*
 {
 "DEVICE_ADDR" = "\U7814\U53d1\U697c\U4e8c\U697c\U897f\U4fa7\U4f1a\U8bae\U5ba4\U7a7a\U8c03";
 "DEVICE_ID" = 1230;
 "DEVICE_NAME" = "\U7814\U53d1\U697c\U4e8c\U697c\U897f\U4fa7\U4f1a\U8bae\U5ba4\U7a7a\U8c03";
 "DEVICE_TYPE" = 6;
 "EQUIP_STATUS" = 1;
 LATITUDE = "<null>";
 "LAYER_A" = "395,1076";
 "LAYER_B" = "428,1076";
 "LAYER_C" = "410,1101";
 "LAYER_ID" = 3;
 LONGITUDE = "<null>";
 "POINT_TYPE" = 2;
 TAGID = 1230;
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

@property (nonatomic,retain) MeetRoomStateModel *stateModel;
@property (nonatomic,retain) MeetRoomStateModel *failureModel;
@property (nonatomic,retain) MeetRoomStateModel *tempModel;
@property (nonatomic,retain) MeetRoomStateModel *windModel;
@property (nonatomic,retain) MeetRoomStateModel *modelModel;

//@property (nonatomic,assign) BOOL isSwitch;

@property (nonatomic,assign) BOOL isSeparate;

@end
