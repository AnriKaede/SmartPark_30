//
//  ParkFeeCountModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/18.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "BaseModel.h"
#import "ParkFeePayModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ParkFeeCountModel : BaseModel

/*
{
    "dodValue": 0,
    "items": [
              {
                  "payType": "010",
                  "payTypeName": "微信",
                  "totalFee": 56
              },
              ],
    "totalFee": 60
}
*/

@property (nonatomic,strong) NSNumber *dodValue;
@property (nonatomic,copy) NSArray *items;
@property (nonatomic,strong) NSNumber *totalFee;

@end

NS_ASSUME_NONNULL_END
