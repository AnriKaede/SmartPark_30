//
//  StreetLightModel.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/25.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface StreetLightModel : BaseModel
/*
 {
 "DEVICE_ADDR" = "\U4e03\U9879\U5168\U80fd\U667a\U6167\U8def\U706f";
 "DEVICE_ID" = 850;
 "DEVICE_NAME" = "\U5168\U80fd\U667a\U6167\U706f\U6746";
 "DEVICE_TYPE" = 5;
 "LAYER_ID" = 20;
 "POINT_TYPE" = 1;
 TAGID = 7;
 }
 */

@property (nonatomic,copy) NSString *TAGID;
@property (nonatomic,copy) NSString *DEVICE_TYPE;
@property (nonatomic,copy) NSString *DEVICE_NAME;
@property (nonatomic,strong) NSNumber *LAYER_ID;
@property (nonatomic,copy) NSString *DEVICE_ADDR;
@property (nonatomic,copy) NSString *DEVICE_ID;
@property (nonatomic,copy) NSString *POINT_TYPE;

@property (nonatomic,copy) NSString *LATITUDE;
@property (nonatomic,copy) NSString *LONGITUDE;
@property (nonatomic,strong) NSNumber *LAYER_A;
@property (nonatomic,copy) NSString *LAYER_B;
@property (nonatomic,copy) NSString *LAYER_C;

@property (nonatomic,strong) NSMutableArray *graphData;
@property (nonatomic,strong) NSMutableArray *grapArr;

@property (nonatomic,assign) BOOL isConSelect;    // 全部通知的是否选中状态

@property (nonatomic,assign) BOOL isColor;

@end
