//
//  PumpStateModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/8/16.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PumpStateModel : BaseModel

@property (nonatomic,copy) NSString *iconName;
@property (nonatomic,copy) NSString *pumpTitle;
@property (nonatomic,copy) NSString *pumpValue;
@property (nonatomic,copy) NSString *valueColor;

@end

NS_ASSUME_NONNULL_END
