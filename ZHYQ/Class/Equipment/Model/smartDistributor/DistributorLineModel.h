//
//  DistributorLineModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/5.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DistributorLineModel : BaseModel

/*
{
    "deviceId": "-901210",
    " pointOrder": 0,
    " pointType": "START",
    " uuid": 1,
    " xx": "2102.9539004",
    " yy": "955",
}
*/

@property (nonatomic,copy) NSString *deviceId;
@property (nonatomic,strong) NSNumber *pointOrder;
@property (nonatomic,copy) NSString *pointType;
@property (nonatomic,strong) NSNumber *uuid;
@property (nonatomic,copy) NSString *xx;
@property (nonatomic,copy) NSString *yy;
 
@end

NS_ASSUME_NONNULL_END
