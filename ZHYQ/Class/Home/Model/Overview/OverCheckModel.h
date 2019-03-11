//
//  OverCheckModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/11.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OverCheckModel : BaseModel

/*
{
    "routingOrderStatus": "1",
    "routingOrderStatusCount": 0,
    "routingOrderStatusName": "待执行"
}
 */

@property (nonatomic,copy) NSString *routingOrderStatus;
@property (nonatomic,strong) NSNumber *routingOrderStatusCount;
@property (nonatomic,copy) NSString *routingOrderStatusName;

@end

NS_ASSUME_NONNULL_END
