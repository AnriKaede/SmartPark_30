//
//  WaterTimeCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/3/8.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParkNightTaskModel.h"

@protocol TaskSwitchDelegate <NSObject>

- (void)taskSwitch:(ParkNightTaskModel *)model withOn:(BOOL)on;

@end

@interface WaterTimeCell : UITableViewCell

@property (nonatomic,retain) ParkNightTaskModel *taskModel;
@property (nonatomic,assign) id<TaskSwitchDelegate> taskSwitchDelegate;

@end
