//
//  OverTaskModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/14.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OverTaskModel : BaseModel

/*
{
    "beginTime": 1547143200000,
    "createTime": 1547143200000,
    "endTime": 1547146800000,
    "operateUserId": "1",
    "operateUserName": "admin",
    "orderId": 1,
    "status": "1",
    "taskDesc": "测试任务",
    "taskId": 1,
    "taskName": "测试任务"
}
 */

@property (nonatomic,strong) NSNumber *beginTime;
@property (nonatomic,strong) NSNumber *createTime;
@property (nonatomic,strong) NSNumber *endTime;
@property (nonatomic,copy) NSString *operateUserId;
@property (nonatomic,copy) NSString *operateUserName;
@property (nonatomic,copy) NSString *orderId;
@property (nonatomic,copy) NSString *status;
@property (nonatomic,copy) NSString *taskDesc;
@property (nonatomic,strong) NSNumber *taskId;
@property (nonatomic,copy) NSString *taskName;

@end

NS_ASSUME_NONNULL_END
