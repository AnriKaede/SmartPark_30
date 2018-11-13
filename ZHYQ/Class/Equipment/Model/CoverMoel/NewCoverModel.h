//
//  NewCoverModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/25.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

#import "NewCoverInfoModel.h"

@interface NewCoverModel : BaseModel

/*
{
    "DEVICE_ADDR": "湖南省长沙市芙蓉区天园研发大楼前坪道路侧靠上善若水东侧",
    "DEVICE_ID": "-3123125",
    "DEVICE_NAME": "848:湖南通服01#实物井盖",
    "DEVICE_TYPE": "30-2",
    "IS_ALARM": "0",
    "LATITUDE": "28.198527",
    "LAYER_A": null,
    "LAYER_B": null,
    "LAYER_C": null,
    "LAYER_ID": 20,
    "LONGITUDE": "113.06984",
    "POINT_TYPE": "2",
    "TAGID": "825"
}
 */

@property (nonatomic,copy) NSString *DEVICE_ADDR;
@property (nonatomic,copy) NSString *DEVICE_ID;
@property (nonatomic,copy) NSString *DEVICE_NAME;
@property (nonatomic,copy) NSString *DEVICE_TYPE;
@property (nonatomic,copy) NSString *IS_ALARM;
@property (nonatomic,copy) NSString *LATITUDE;
@property (nonatomic,strong) NSNumber *LAYER_ID;
@property (nonatomic,copy) NSString *LONGITUDE;
@property (nonatomic,copy) NSString *POINT_TYPE;
@property (nonatomic,copy) NSString *TAGID;

@property (nonatomic,retain) NewCoverInfoModel *platItem;

@end
