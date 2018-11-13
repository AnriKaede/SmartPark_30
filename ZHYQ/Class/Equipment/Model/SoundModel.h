//
//  SoundModel.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/22.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface SoundModel : BaseModel
/*
 "tid": 2,
 "sid": 26,
 "status": 1,
 "type": 3,
 "grade": 500,
 "t_play": 1,
 "t_total": 200,
 "iFile": 0,
 "name": "SleepAway"
 */

@property (nonatomic,strong) NSNumber *tid;
@property (nonatomic,strong) NSNumber *sid;
@property (nonatomic,strong) NSNumber *status;
@property (nonatomic,copy) NSString *type;
@property (nonatomic,strong) NSNumber *grade;
@property (nonatomic,strong) NSNumber *t_play;
@property (nonatomic,strong) NSNumber *t_total;
@property (nonatomic,copy) NSString *iFile;
@property (nonatomic,copy) NSString *name;

@end
