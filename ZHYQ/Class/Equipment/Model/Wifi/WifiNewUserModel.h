//
//  WifiNewUserModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/7.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WifiNewUserModel : BaseModel

@property (nonatomic,copy) NSString *addNewUser;   // 时间
@property (nonatomic,copy) NSString *userCount;

@end

NS_ASSUME_NONNULL_END
