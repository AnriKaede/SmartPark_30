//
//  SubDeviceModel.h
//  ZHYQ
//
//  Created by 焦平 on 2017/12/5.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface SubDeviceModel : BaseModel
/*
 {
 "DEVICE_ID" = 850;
 "DEVICE_NAME" = "\U7403\U673a\U6444\U50cf\U673a";
 "DEVICE_TYPE" = "1-2";
 "LAYER_A" = "184,161";
 "LAYER_B" = "207,161";
 "LAYER_C" = "194,184";
 "SUB_DEVICE_ID" = 90001;
 TAGID = "1000014$1$0$0";
 DEVICE_ADDR = ;
 }
 */

@property (nonatomic,copy) NSString *TAGID;
@property (nonatomic,copy) NSString *DEVICE_TYPE;
@property (nonatomic,copy) NSString *DEVICE_NAME;
@property (nonatomic,strong) NSNumber *SUB_DEVICE_ID;
@property (nonatomic,copy) NSString *LAYER_C;
@property (nonatomic,copy) NSString *LAYER_A;
@property (nonatomic,copy) NSString *LAYER_B;
@property (nonatomic,copy) NSString *DEVICE_ID;
@property (nonatomic,copy) NSString *DEVICE_ADDR;

@end
