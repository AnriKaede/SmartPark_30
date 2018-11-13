//
//  ManholeCoverMapModel.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/13.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"
#import "ManholeCoverModel.h"

@interface ManholeCoverMapModel : BaseModel

/*
 {
     {
     address = "\U6e56\U5357\U7701\U957f\U6c99\U5e02\U8299\U84c9\U533a\U8fdc\U5927\U4e8c\U8def236";
     area = "\U7eff\U5316\U5e26";
     "build_date" = "<null>";
     "cover_material" = "\U94f8\U94c1";
     deep = "<null>";
     "env_picture" = "//static.renjinggai.com/static/facility-pictures/2017/10/24/zfJ8gsvaq5l2MZ3Sr4fl.jpg";
     id = 825;
     "is_alarming" = 1;
     "is_authorized_open" = 1;
     "is_open" = 1;
     latitude = "<null>";
     "latitude_amap" = "28.199729146563";
     "latitude_baidu" = "28.20573";
     long = 0;
     longitude = "<null>";
     "longitude_amap" = "113.069948503257";
     "longitude_baidu" = "113.076448";
     "manhole_cover" =     {
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
     };
 "manhole_signature" = "TManhole__825";
 name = "\U5929\U56ed\U6f14\U793a\U4e95\U76d6";
 picture = "//static.renjinggai.com/static/facility-pictures/2017/10/24/5CJFigKky9iSJhlGpoVQ.jpg";
 shape = "\U5706\U5f62";
 size = 60;
 width = 0;
 }
 */

@property (nonatomic,copy) NSString *manhole_signature;
@property (nonatomic,assign) BOOL is_alarming;
@property (nonatomic,strong) NSNumber *longitude_amap;
@property (nonatomic,copy) NSString *env_picture;

@property (nonatomic,strong) NSNumber *latitude_amap;
@property (nonatomic,copy) NSString *picture;
@property (nonatomic,strong) NSNumber *latitude;
@property (nonatomic,assign) BOOL is_authorized_open;
@property (nonatomic,strong) NSNumber *longitude_baidu;

@property (nonatomic,copy) NSString *deep;
@property (nonatomic,assign) BOOL is_open;
@property (nonatomic,strong) NSNumber *long_1;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,strong) NSNumber *size;

@property (nonatomic,strong) ManholeCoverModel *holeModel;
@property (nonatomic,strong) NSNumber *id_1;
@property (nonatomic,copy) NSString *shape;
@property (nonatomic,strong) NSNumber *latitude_baidu;
@property (nonatomic,strong) NSNumber *longitude;

@property (nonatomic,copy) NSString *build_date;
@property (nonatomic,strong) NSNumber *width;
@property (nonatomic,copy) NSString *area;
@property (nonatomic,copy) NSString *cover_material;
@property (nonatomic,copy) NSString *address;

@property (nonatomic,strong) NSNumber *iot_cover_id;

@end
