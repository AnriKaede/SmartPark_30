//
//  RobotMenuView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/2/27.
//  Copyright © 2019 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OperateDelegate <NSObject>

- (void)livePlay;
- (void)closeMenu;

@end

@interface RobotMenuView : UIView
@property (nonatomic,assign) id<OperateDelegate> operateDelegate;
@end

NS_ASSUME_NONNULL_END
