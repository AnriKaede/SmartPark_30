//
//  WorkListViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/19.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "RootViewController.h"
@class BillListModel;

typedef enum {
    WorkAll = 0,
//    WorkUnReceive,
    WorkRepairsIng,
    WorkWaitConfirm,
    WorkClose
}WorkListType;

@protocol WorkListMethodDelegate <NSObject>

- (void)progressQuery:(BillListModel *)billListModel; // 传入model
- (void)rejectBill:(BillListModel *)billListModel; // 传入model

@end

@interface WorkListViewController : RootViewController

@property (nonatomic,assign) WorkListType workListType;
@property (nonatomic,assign) id<WorkListMethodDelegate> workDelegate;

@end
