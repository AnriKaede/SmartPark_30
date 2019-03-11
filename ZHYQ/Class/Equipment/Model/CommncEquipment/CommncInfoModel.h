//
//  CommncInfoModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/3.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CommncInfoModel : BaseModel

/*
{
    "reporTime": "2018-12-28 04:34:40",
    "serviceId": "Network",
    "serviceName": "信号",
    "serviceValue": "-82"
}
 */

@property (nonatomic,copy) NSString *reporTime;
@property (nonatomic,copy) NSString *serviceId;
@property (nonatomic,copy) NSString *serviceName;
@property (nonatomic,copy) NSString *serviceValue;

@end

NS_ASSUME_NONNULL_END
