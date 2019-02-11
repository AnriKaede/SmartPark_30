//
//  OverUseListModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/15.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OverUseListModel : BaseModel

/*
{
    "cnt": 1,
    "deviceType": "1",
    "deviceTypeName": "监控设备"
}
 */

@property (nonatomic,strong) NSNumber *cnt;
@property (nonatomic,copy) NSString *deviceType;
@property (nonatomic,copy) NSString *deviceTypeName;

@end

NS_ASSUME_NONNULL_END
