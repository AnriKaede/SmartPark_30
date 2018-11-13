//
//  WifiCountTimeModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/6.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WifiCountTimeModel : BaseModel
@property (nonatomic,copy) NSString *userCount;
@property (nonatomic,copy) NSString *onlineTime;
@end

NS_ASSUME_NONNULL_END
