//
//  EvnDelModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/3/6.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface EvnDelModel : BaseModel

@property (nonatomic,copy) NSString *datetime;
@property (nonatomic,strong) NSNumber *device_id;
@property (nonatomic,strong) NSNumber *period;
@property (nonatomic,copy) NSString *value;

@end
