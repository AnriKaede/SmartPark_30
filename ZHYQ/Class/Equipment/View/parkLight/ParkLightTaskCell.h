//
//  ParkLightTaskCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/27.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParkNightTaskModel.h"

@protocol TaskSwitchDelegate <NSObject>

- (void)taskSwitch:(ParkNightTaskModel *)model withOn:(BOOL)on;

@end

@interface ParkLightTaskCell : UITableViewCell

@property (nonatomic, retain) ParkNightTaskModel *parkTaskModel;
@property (nonatomic,assign) id<TaskSwitchDelegate> taskSwitchDelegate;

@end
