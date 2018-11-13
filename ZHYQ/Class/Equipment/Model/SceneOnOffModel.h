//
//  SceneOnOffModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/17.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface SceneOnOffModel : BaseModel

@property (nonatomic, copy) NSString *modelName;
@property (nonatomic, copy) NSString *modelId;
@property (nonatomic, strong) NSNumber *onOff;
//@property (nonatomic, copy) NSString *uuid;

@end
