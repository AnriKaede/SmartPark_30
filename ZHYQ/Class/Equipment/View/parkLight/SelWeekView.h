//
//  SelWeekView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/28.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelCompleteDelegate <NSObject>

- (void)selWeekDay:(NSArray *)days;

@end

@interface SelWeekView : UIView

@property (nonatomic,assign) id<SelCompleteDelegate> selComDelegate;

@end
