//
//  WifiCountTypeModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/6.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WifiCountTypeModel : BaseModel
@property (nonatomic,copy) NSString *clientType;
@property (nonatomic,copy) NSString *userCount;
@end

NS_ASSUME_NONNULL_END
