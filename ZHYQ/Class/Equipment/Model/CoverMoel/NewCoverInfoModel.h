//
//  NewCoverInfoModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/25.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface NewCoverInfoModel : BaseModel

/*
{
    "address": "湖南省长沙市芙蓉区东岸街道邦电培育中心天园假日小区",
    "alarming": true,
    "area": "绿化带",
    "business_state": "上锁",
    "cover_material": "复合材料",
    "env_picture": "//static.renjinggai.com/static/facility-pictures/2017/12/23/LU47DBKhbtoUTp0RzwcQ.jpg",
    "id": "848",
    "iot_cover": "48",
    "is_open": true,
    "latitude_amap": "28.197630624269",
    "longitude_amap": "113.070058143717",
    "name": "湖南通服01#实物井盖",
    "picture": "//static.renjinggai.com/static/facility-pictures/2017/12/23/0TcB7uTdrz4n9zwpml8N.jpg",
    "shape": "圆形"
}
 */

@property (nonatomic,copy) NSString *address;
@property (nonatomic,strong) NSNumber *is_open; // BOOL
@property (nonatomic,copy) NSString *iot_cover;

@end
