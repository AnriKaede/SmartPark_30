//
//  LEDCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LedListModel.h"

@protocol LEDSwitchDelegate <NSObject>

- (void)ledSwitch:(LedListModel *)ledListModel withOn:(BOOL)on;

@end

@interface LEDCell : UITableViewCell

@property (nonatomic,assign) id<LEDSwitchDelegate> ledSwitchDelegate;
@property (nonatomic,retain) LedListModel *ledListModel;

@end
