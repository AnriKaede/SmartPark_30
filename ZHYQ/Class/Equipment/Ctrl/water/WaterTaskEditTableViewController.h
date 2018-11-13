//
//  WaterTaskEditTableViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/3/9.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseTableViewController.h"
#import "ParkNightTaskModel.h"

@protocol addCompleteDelegate <NSObject>

- (void)addTaskComplete;

@end

@interface WaterTaskEditTableViewController : BaseTableViewController

@property (nonatomic, retain) ParkNightTaskModel *parkNightTaskModel;
@property (nonatomic,assign) id<addCompleteDelegate> addDelegate;

@end
