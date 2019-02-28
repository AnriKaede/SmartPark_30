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
}
- (IBAction)_helloAction:(id)sender {
}

- (IBAction)_upAction:(id)sender {
}
- (IBAction)_leftAction:(id)sender {
}
- (IBAction)_downAction:(id)sender {
}
- (IBAction)_rightAction:(id)sender {
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
