//
//  DistributorDeviceModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/5.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DistributorDeviceModel : BaseModel

/*
{
    "DEGREE":"1",
    "DEVICEADDR":"西电井双电源",
    "DEVICEID": "-901210",
    "DEVICENAME": "西电井双电源",
    "DEVICEORDER":1,
    "DEVICEOVERNAME": "西电井双电源",
    "DEVICETYPE": "93-1",
    "LAYERID": 2,
    "TAGID": "cb061f2d-b964-42ff-9717-2b2220c92ca3"
}
 */

@property (nonatomic,copy) NSString *DEGREE;
@property (nonatomic,copy) NSString *DEVICEADDR;
@property (nonatomic,copy) NSString *DEVICEID;
@property (nonatomic,copy) NSString *DEVICENAME;
@property (nonatomic,strong) NSNumber *DEVICEORDER;
@property (nonatomic,copy) NSString *DEVICEOVERNAME;
@property (nonatomic,copy) NSString *DEVICETYPE;
@property (nonatomic,strong) NSNumber *LAYERID;
@property (nonatomic,copy) NSString *TAGID;

@end

NS_ASSUME_NONNULL_END
