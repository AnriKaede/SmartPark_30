//
//  AirSiwtchCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/7/13.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FloorModel.h"

@protocol AirSwitchDelegate <NSObject>

- (void)airSwitch:(FloorModel *)floorModel withOn:(BOOL)on;

@end

@interface AirSiwtchCell : UITableViewCell

@property (nonatomic, retain) FloorModel *floorModel;
@property (nonatomic,assign) id<AirSwitchDelegate> airSwitchDelegate;

@end
