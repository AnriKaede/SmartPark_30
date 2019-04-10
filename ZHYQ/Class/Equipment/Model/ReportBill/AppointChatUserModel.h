//
//  AppointChatUserModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/3/16.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppointChatUserModel : BaseModel

/*
{
    "companyId": 1,
    "loginName": "admin",
    "state": "1",
    "userId": "1",
    "userName": "超级管理员",
    "vstate": "启用",
    "yhjs": "管理端-超级管理员,管理端-通服管理员"
}
 */

@property (nonatomic,strong) NSNumber *companyId;
@property (nonatomic,copy) NSString *loginName;
@property (nonatomic,copy) NSString *state;
@property (nonatomic,copy) NSString *userId;
@property (nonatomic,copy) NSString *userName;
@property (nonatomic,copy) NSString *vstate;
@property (nonatomic,copy) NSString *yhjs;

@end

NS_ASSUME_NONNULL_END
