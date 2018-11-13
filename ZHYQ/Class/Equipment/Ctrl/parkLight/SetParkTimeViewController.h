//
//  SetParkTimeViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/27.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseTableViewController.h"
#import "ParkNightTaskModel.h"
#import "ParkTimeViewController.h"


@protocol addCompleteDelegate <NSObject>

- (void)addTaskComplete;

@end

@interface SetParkTimeViewController : BaseTableViewController

@property (nonatomic,assign) id<addCompleteDelegate> addDelegate;

@property (nonatomic,assign) BOOL isUpdate;
@property (nonatomic,retain) ParkNightTaskModel *parkNightTaskModel;

@property (nonatomic,assign) TimeTaskType timeTaskType;
@property (nonatomic,copy) NSString *tagId;

@end
