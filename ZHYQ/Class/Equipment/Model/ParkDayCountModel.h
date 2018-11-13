//
//  ParkDayCountModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"
#import "ParkFlowCountModel.h"
#import "FlowTraceModel.h"

@interface ParkDayCountModel : BaseModel

@property (nonatomic,retain) ParkFlowCountModel *flowCountModel;
@property (nonatomic,strong) NSNumber *dodPersent;
@property (nonatomic,retain) FlowTraceModel *flowTraceModel;

@end
