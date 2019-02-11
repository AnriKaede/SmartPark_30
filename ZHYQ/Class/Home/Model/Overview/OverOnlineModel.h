//
//  OverOnlineModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/11.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OverOnlineModel : BaseModel

/*
{
    "onlineStatus": "1",
    "onlineStatusCount": 0,
    "onlineStatusName": "在线"
}
 */

@property (nonatomic,copy) NSString *onlineStatus;
@property (nonatomic,strong) NSNumber *onlineStatusCount;
@property (nonatomic,copy) NSString *onlineStatusName;

@end

NS_ASSUME_NONNULL_END
