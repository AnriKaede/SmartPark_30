//
//  WorkDetailViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/16.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseTableViewController.h"
#import "BillListModel.h"

@interface WorkDetailViewController : BaseTableViewController

//@property (nonatomic,retain) BillListModel *billListModel;
@property (nonatomic,copy) NSString *orderId;

@end
