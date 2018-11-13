//
//  IllegalMangeViewController.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/8.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IllegalMangeViewController : BaseTabbarCtrl

/**
 设置小红点
 
 @param index tabbar下标
 @param isShow 是显示还是隐藏
 */
-(void)setRedDotWithIndex:(NSInteger)index isShow:(BOOL)isShow;

@end
