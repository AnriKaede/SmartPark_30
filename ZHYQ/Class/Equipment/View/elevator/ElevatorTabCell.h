//
//  ElevatorTabCell.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ElevatorModel.h"

@protocol ElevatorMonitorDelegate <NSObject>

- (void)elevatorMonitor:(ElevatorModel *)model;

@end

@interface ElevatorTabCell : UITableViewCell

@property (nonatomic, retain) ElevatorModel *elevatorModel;
@property (nonatomic,assign) id<ElevatorMonitorDelegate> elevatorDelegate;

@end
