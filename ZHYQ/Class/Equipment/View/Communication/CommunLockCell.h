//
//  CommunLockCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/21.
//  Copyright © 2018 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CommnncLockModel.h"
#import "CommnncCoverModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CellLockMenuDelegate <NSObject>

- (void)unLock:(CommnncLockModel *)lockModel;
- (void)queryLock:(CommnncLockModel *)lockModel;

- (void)queryCover:(CommnncCoverModel *)coverModel;

@end

@interface CommunLockCell : UITableViewCell

@property (nonatomic,retain) CommnncLockModel *lockModel;
@property (nonatomic,retain) CommnncCoverModel *coverModel;

@property (nonatomic,assign) id<CellLockMenuDelegate> cellMemuDelegate;

@end

NS_ASSUME_NONNULL_END
