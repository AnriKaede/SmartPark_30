//
//  NewLEDCell.h
//  ZHYQ
//
//  Created by coder on 2018/10/23.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LedListModel.h"

@protocol LEDListDelegate <NSObject>

- (void)lookScreenShotWithModel:(LedListModel*)ledListModel;

- (void)ledSwitch:(BOOL)on withModel:(LedListModel*)ledListModel;
- (void)ledPlay:(LedListModel*)ledListModel;
- (void)ledRestart:(LedListModel*)ledListModel;
- (void)ledClose:(LedListModel*)ledListModel;

- (void)resumeDefault:(LedListModel*)ledListModel;

@end

NS_ASSUME_NONNULL_BEGIN

@interface NewLEDCell : UITableViewCell

@property (nonatomic,weak) id<LEDListDelegate> delegate;
@property (nonatomic,retain) LedListModel *ledListModel;

@end

NS_ASSUME_NONNULL_END
