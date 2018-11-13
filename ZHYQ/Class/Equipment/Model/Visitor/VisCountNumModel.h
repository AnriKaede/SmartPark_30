//
//  VisCountModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/24.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface VisCountNumModel : BaseModel

/*
{
    "avgDuration": 5070,
    "dodPersent": "0.00",
    "duration": 55770,
    "female": 6,
    "leave": 5,
    "male": 5,
    "preTotal": 0,
    "stay": 6,
    "total": 11
}
 */

@property (nonatomic,strong) NSNumber *avgDuration;
@property (nonatomic,copy) NSString *dodPersent;
@property (nonatomic,strong) NSNumber *duration;
@property (nonatomic,strong) NSNumber *female;
@property (nonatomic,strong) NSNumber *leave;
@property (nonatomic,strong) NSNumber *male;
@property (nonatomic,strong) NSNumber *preTotal;
@property (nonatomic,strong) NSNumber *stay;
@property (nonatomic,strong) NSNumber *total;

@end
