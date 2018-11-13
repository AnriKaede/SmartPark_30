//
//  ManholeCoverModel.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/13.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface ManholeCoverModel : BaseModel

/*
 {
 "business_state " = "\U4e0a\U9501";
 comment = "\U7269\U8054\U7f511";
 "cover_signature" = "THolecover__33ffd8054d42363120641543";
 id = 9146;
 "iot_cover_id" = 39;
 "is_alarming " = 0;
 "is_online" = false;
 "is_opening" = 0;
 "is_smart" = 1;
 "manhole_id" = 825;
 model = 2;
 "model_name" = "iMHC-1";
 "model_picture" = "https://api.renjinggai.com/files/uploaded/normal-files/cbb37b7db6104257919c18363d73a89e.png";
 name = 01;
 "serial_number " = "<null>";
 state = 1;
 "tongue_state" = 0;
 }
 */

@property (nonatomic,copy) NSString *id_2;
@property (nonatomic,copy) NSString *state;
@property (nonatomic,copy) NSString *model_name;
@property (nonatomic,copy) NSString *business_state;
@property (nonatomic,assign) BOOL is_opening;

@property (nonatomic,copy) NSString *model_picture;
@property (nonatomic,copy) NSString *cover_signature;
@property (nonatomic,copy) NSString *comment;

@property (nonatomic,copy) NSString *is_online;
@property (nonatomic,copy) NSString *tongue_state;
@property (nonatomic,strong) NSNumber *iot_cover_id;
@property (nonatomic,assign) BOOL is_smart;
@property (nonatomic,copy) NSString *manhole_id;

@property (nonatomic,strong) NSNumber *serial_number;
@property (nonatomic,copy) NSString *model;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,assign) BOOL *is_alarming;

@end
