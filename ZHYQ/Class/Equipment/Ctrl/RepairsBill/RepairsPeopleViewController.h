//
//  RepairsPeopleViewController.h
//  ZHYQ
//
//  Created by 焦平 on 2018/4/19.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseTableViewController.h"
@class RepairsManModel;

@protocol SelRepairManDelegate <NSObject>

- (void)selRepairMan:(RepairsManModel *)repairsManModel;

@end

@interface RepairsPeopleViewController : BaseTableViewController

@property (nonatomic,assign) id<SelRepairManDelegate> selRepairManDelegate;

@end
