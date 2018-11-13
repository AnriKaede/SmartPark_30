//
//  StopParkSelDayView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/9/29.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SelDayDelegate <NSObject>

- (void)selDay:(NSString *)day;

@end

@interface StopParkSelDayView : UIView

@property (nonatomic,assign) id<SelDayDelegate> selDayDelegate;

- (void)showView:(NSInteger)index;

@end
