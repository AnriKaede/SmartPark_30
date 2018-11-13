//
//  OpenDoorModel.h
//  XTF_SmartPart_UserTerminal
//
//  Created by 焦平 on 2017/12/18.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface OpenDoorModel : BaseModel
/*
 {
 "DEVICE_ADDR" = "\U4e00\U697c\U897f\U5411\U8d70\U5eca\U4e8c\Uff08\U51fa\Uff09";
 "DEVICE_ID" = "-513";
 "DEVICE_NAME" = "\U4e00\U697c\U897f\U5411\U8d70\U5eca\U4e8c\Uff08\U51fa\Uff09";
 "DEVICE_TYPE" = "4-1";
 "LAYER_A" = "192.168.207.32";
 "LAYER_B" = 175;
 "LAYER_C" = 2;
 "LAYER_ID" = 2;
 "LAYER_NAME" = "\U7814\U53d1\U4e00\U697c";
 TAGID = 347;
 }
 */

@property (nonatomic,copy) NSString *TAGID;
@property (nonatomic,copy) NSString *DEVICE_TYPE;
@property (nonatomic,copy) NSString *DEVICE_NAME;
@property (nonatomic,copy) NSString *LAYER_ID;
@property (nonatomic,copy) NSString *DEVICE_ADDR;

@property (nonatomic,copy) NSString *LAYER_C;
@property (nonatomic,copy) NSString *LAYER_B;
@property (nonatomic,copy) NSString *DEVICE_ID;
@property (nonatomic,copy) NSString *LAYER_A;
@property (nonatomic,copy) NSString *LAYER_NAME;

@end
