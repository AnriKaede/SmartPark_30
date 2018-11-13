//
//  FrontGroundTableViewCell.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/27.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParkLockModel.h"

@interface FrontGroundTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *headerLineView;

@property (nonatomic, retain) ParkLockModel *parkLockModel;

@end
