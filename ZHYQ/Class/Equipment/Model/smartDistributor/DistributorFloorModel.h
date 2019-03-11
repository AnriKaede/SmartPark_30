//
//  DistributorFloorModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/5.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "BaseModel.h"
#import "DistributorDeviceModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DistributorFloorModel : BaseModel

/*
{
    "LAYERID": 2,
    "LAYERNAME": "研发一楼",
    "deviceInfoList": [{
        "DEGREE":"1",
        "DEVICEADDR":"西电井双电源",
        "DEVICEID": "-901210",
        "DEVICENAME": "西电井双电源",
        "DEVICEORDER":1,
        "DEVICEOVERNAME": "西电井双电源",
        "DEVICETYPE": "93-1",
        "LAYERID": 2,
        "TAGID": "cb061f2d-b964-42ff-9717-2b2220c92ca3"
    }]
}
*/

@property (nonatomic,strong) NSNumber *LAYERID;
@property (nonatomic,copy) NSString *LAYERNAME;
@property (nonatomic,copy) NSArray *deviceInfoList;
 
@end

NS_ASSUME_NONNULL_END
