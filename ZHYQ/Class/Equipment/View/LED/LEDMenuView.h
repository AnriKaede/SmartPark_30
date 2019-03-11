//
//  LEDMenuView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/5.
//  Copyright © 2018 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LedListModel.h"

@protocol LEDMenuDelegate <NSObject>

- (void)lookScreenShotWithModel:(LedListModel*)ledListModel;

- (void)ledSwitch:(BOOL)on withModel:(LedListModel*)ledListModel;
- (void)ledPlay:(LedListModel*)ledListModel;
- (void)ledRestart:(LedListModel*)ledListModel;
- (void)ledClose:(LedListModel*)ledListModel;

- (void)resumeDefault:(LedListModel*)ledListModel;

@end

NS_ASSUME_NONNULL_BEGIN

@interface LEDMenuView : UIView

@property (nonatomic,assign) id<LEDMenuDelegate> ledMenuDelegate;

@property (nonatomic,strong) NSArray *modelAry;

- (void)reloadMenu;

@end

NS_ASSUME_NONNULL_END
