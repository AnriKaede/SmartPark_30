//
//  FgUnParkTableViewCell.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/27.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YQSwitch.h"
#import "ParkLockModel.h"

@protocol LockDelegate <NSObject>

- (void)parkLock:(YQSwitch *)yqSwitch;

@end

@interface FgUnParkTableViewCell : UITableViewCell

@property (nonatomic, assign) BOOL isOpen;

@property (nonatomic,assign) id<LockDelegate> lockDelegate;

@property (nonatomic, retain) ParkLockModel *parkLockModel;

@end
