//
//  RobotMenuView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/2/27.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "RobotMenuView.h"

@implementation RobotMenuView
{
    
}

- (IBAction)_liveAction:(id)sender {
    if(_operateDelegate && [_operateDelegate respondsToSelector:@selector(livePlay)]){
        [_operateDelegate livePlay];
    }
}
- (IBAction)_colorAction:(id)sender {
    if(_operateDelegate && [_operateDelegate respondsToSelector:@selector(changeColor)]){
        [_operateDelegate changeColor];
    }
}
- (IBAction)_helloAction:(id)sender {
    if(_operateDelegate && [_operateDelegate respondsToSelector:@selector(shakeHeader)]){
        [_operateDelegate shakeHeader];
    }
}

- (IBAction)_upAction:(id)sender {
    if(_operateDelegate && [_operateDelegate respondsToSelector:@selector(robotMove:)]){
        [_operateDelegate robotMove:RobotMoveTop];
    }
}
- (IBAction)_leftAction:(id)sender {
    if(_operateDelegate && [_operateDelegate respondsToSelector:@selector(robotMove:)]){
        [_operateDelegate robotMove:RobotMoveLeft];
    }
}
- (IBAction)_downAction:(id)sender {
    if(_operateDelegate && [_operateDelegate respondsToSelector:@selector(robotMove:)]){
        [_operateDelegate robotMove:RobotMoveDown];
    }
}
- (IBAction)_rightAction:(id)sender {
    if(_operateDelegate && [_operateDelegate respondsToSelector:@selector(robotMove:)]){
        [_operateDelegate robotMove:RobotMoveRight];
    }
}

- (IBAction)closeAction:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, KScreenHeight, KScreenWidth, 188);
    }completion:^(BOOL finished) {
        if(_operateDelegate && [_operateDelegate respondsToSelector:@selector(closeMenu)]){
            [_operateDelegate closeMenu];
        }
    }];
}


@end
