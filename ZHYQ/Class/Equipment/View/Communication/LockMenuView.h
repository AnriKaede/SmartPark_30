//
//  LockMenuView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/21.
//  Copyright © 2018 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LockMenuDelegate <NSObject>

//- (void)lookScreenShotWithModel:(LedListModel*)ledListModel;
//
//- (void)ledSwitch:(BOOL)on withModel:(LedListModel*)ledListModel;
//- (void)ledPlay:(LedListModel*)ledListModel;
//- (void)ledRestart:(LedListModel*)ledListModel;
//- (void)ledClose:(LedListModel*)ledListModel;
//
//- (void)resumeDefault:(LedListModel*)ledListModel;

@end

NS_ASSUME_NONNULL_BEGIN

@interface LockMenuView : UIView

@property (nonatomic,assign) id<LockMenuDelegate> lockMenuDelegate;

- (void)reloadMenu;

@end

NS_ASSUME_NONNULL_END
