//
//  WorkListCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/20.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BillListModel.h"

@protocol WorkMethodDelegate <NSObject>

- (void)bottomLeftMethod:(BillListModel *) billListModel;   // 传Model
- (void)bottomRightMethod:(BillListModel *) billListModel;   // 传Model

@end

@interface WorkListCell : UITableViewCell

@property (nonatomic,assign) id<WorkMethodDelegate> workListDelegate;
@property (nonatomic,retain) BillListModel *billListModel;

@end
