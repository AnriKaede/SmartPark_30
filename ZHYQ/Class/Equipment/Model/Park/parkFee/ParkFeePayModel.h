//
//  ParkFeePayModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/18.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ParkFeePayModel : BaseModel

/*
{
    "payType": "010",
    "payTypeName": "微信",
    "totalFee": 56
}
 */

@property (nonatomic,copy) NSString *payType;
@property (nonatomic,copy) NSString *payTypeName;
@property (nonatomic,strong) NSNumber *totalFee;

@end

NS_ASSUME_NONNULL_END
