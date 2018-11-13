//
//  PointViewSelect.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/6.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "PointViewSelect.h"

@implementation PointViewSelect

+ (void)pointImageSelect:(UIView *)selView {
    [UIView animateWithDuration:0.2 animations:^{
        selView.transform = CGAffineTransformScale(selView.transform, 2, 2);
        
        selView.layer.shadowOffset = CGSizeMake(0, 3);
        selView.layer.shadowRadius = 5.0;
        selView.layer.shadowColor = [UIColor blackColor].CGColor;
        selView.layer.shadowOpacity = 0.8;
        
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            selView.transform = CGAffineTransformScale(selView.transform, 0.6, 0.6);
        }];
    }];
    
}
+ (void)recoverSelImgView:(UIView *)selView {
    selView.layer.shadowOffset = CGSizeMake(0, 0);
    selView.layer.shadowRadius = 0;
    selView.layer.shadowColor = [UIColor clearColor].CGColor;
    selView.transform = CGAffineTransformScale(selView.transform, 0.8333, 0.8333);
    selView.layer.shadowOpacity = 0;
}

@end
