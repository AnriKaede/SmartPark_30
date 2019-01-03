//
//  LockMenuView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/21.
//  Copyright © 2018 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommnncLockModel.h"

@protocol LockMenuDelegate <NSObject>

- (void)unLock:(CommnncLockModel *)lockModel;
- (void)queryLock:(CommnncLockModel *)lockModel;

@end

NS_ASSUME_NONNULL_BEGIN

@interface LockMenuView : UIView

@property (nonatomic,assign) id<LockMenuDelegate> lockMenuDelegate;

@property (nonatomic,retain) CommnncLockModel *lockModel;

- (void)reloadMenu;

@end

NS_ASSUME_NONNULL_END
