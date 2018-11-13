//
//  AirModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/23.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface AirModel : BaseModel
/*
 {
 "DEVICE_ADDR": "远大路北大门入口",   --地址名称
 "DEVICE_ID": "1",   --设备编号
 "DEVICE_NAME": "WIFI-AP",---设备名称
 "DEVICE_TYPE": "2",   --设备类型
 "LATITUDE": " ",  --高德坐标
 "LAYER_A": "1234,1234 ",  ---平面图位置
 "LAYER_B": "1234,1234", ---平面图位置
 "LAYER_C": "513,13251", ---平面图位置
 "LAYER_ID": 20,----楼层，20表示室外
 "LONGITUDE": " ",--高德坐标
 "POINT_TYPE": "1",  --点位类型，1表示坐标 2 表示平面图位置
 "TAGID": null   ,----楼控系统的设备编码
 " EQUIP_STATUS ": "1"    -当前设备状态 1 正常 0故障 2离线
 }
 */


@property (nonatomic, copy) NSString *DEVICE_ADDR;
@property (nonatomic, copy) NSString *DEVICE_ID;
@property (nonatomic, copy) NSString *DEVICE_NAME;
@property (nonatomic, copy) NSString *DEVICE_TYPE;
@property (nonatomic, copy) NSString *EQUIP_STATUS;
@property (nonatomic, copy) NSString *LATITUDE;
@property (nonatomic, copy) NSString *LAYER_A;
@property (nonatomic, copy) NSString *LAYER_B;
@property (nonatomic, copy) NSString *LAYER_C;
@property (nonatomic, strong) NSNumber *LAYER_ID;
@property (nonatomic, copy) NSString *LONGITUDE;
@property (nonatomic, copy) NSString *POINT_TYPE;
@property (nonatomic, copy) NSString *TAGID;

@end
