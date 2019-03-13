//
//  RobotMenuView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/2/27.
//  Copyright © 2019 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    RobotMoveTop = 0,
    RobotMoveLeft,
    RobotMoveDown,
    RobotMoveRight
}RobotMove;

typedef enum {
    RobotShakeHeadLeft = 0,
    RobotShakeHeadRight,
    RobotShakeHeadCenter
}RobotShakeHead;

@protocol OperateDelegate <NSObject>

- (void)livePlay;
- (void)closeMenu;
- (void)robotMove:(RobotMove)robotMove;
- (void)changeColor;
- (void)shakeHand;
- (void)shakeHead:(RobotShakeHead)robotShakeHeader;

@end

@interface RobotMenuView : UIView
@property (nonatomic,assign) id<OperateDelegate> operateDelegate;
@end

NS_ASSUME_NONNULL_END
