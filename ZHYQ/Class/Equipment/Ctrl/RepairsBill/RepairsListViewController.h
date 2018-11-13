//
//  RepairsListViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/17.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "RootViewController.h"
#import "BillListModel.h"

@protocol RepairDelegate <NSObject>

- (void)progressQuery:(BillListModel *)billListModel; // 传入model
- (void)billComplete:(BillListModel *)billListModel; // 传入model,确认完成

@end

typedef enum {
    RepairsAll = 0,
    RepairsUnReceive,
    RepairsIng,
    RepairsComplete,
    RepairsClose
}RepairsType;

@interface RepairsListViewController : RootViewController

@property (nonatomic,assign) RepairsType repairsType;
@property (nonatomic,assign) id<RepairDelegate> repairDelegate;

@end
