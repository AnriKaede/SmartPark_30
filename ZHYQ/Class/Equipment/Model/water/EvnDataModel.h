//
//  EvnDataModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/3/6.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface EvnDataModel : BaseModel

@property (nonatomic,strong) NSNumber *device_id;
@property (nonatomic,copy) NSString *device_name;
@property (nonatomic,copy) NSString *value;
@property (nonatomic,strong) NSNumber *sensor_type_id;
@property (nonatomic,copy) NSString *datetime;

@end
