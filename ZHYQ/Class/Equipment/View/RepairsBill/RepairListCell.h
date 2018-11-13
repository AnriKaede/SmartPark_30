//
//  RepairListCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/17.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BillListModel.h"

@protocol RepairMethodDelegate <NSObject>

- (void)progressMethod:(BillListModel *)billListModel; // 传入model
- (void)rightMethod:(BillListModel *)billListModel;    //传入model

@end

@interface RepairListCell : UITableViewCell

@property (nonatomic,assign) id<RepairMethodDelegate> repairMethodDelegate;
@property (nonatomic,retain) BillListModel *billListModel;

@end
