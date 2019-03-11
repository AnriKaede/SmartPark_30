//
//  OverDealModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/11.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OverDealModel : BaseModel

/*
{
    "overallStatus": "2",
    "overallStatusCount": 0,
    "overallStatusName": "关闭"
}
 */

@property (nonatomic,copy) NSString *overallStatus;
@property (nonatomic,strong) NSNumber *overallStatusCount;
@property (nonatomic,copy) NSString *overallStatusName;

@end

NS_ASSUME_NONNULL_END
