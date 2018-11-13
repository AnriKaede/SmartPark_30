//
//  LogFilterView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/8/30.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LogFilterTimeDelegate <NSObject>

- (void)closeFilter;
- (void)resetFilter;
- (void)filterWithStart:(NSString *)startTime withEndTime:(NSString *)endTime withOperateMan:(NSString *)operateMan withOperateKey:(NSString *)operateKey;

@end

@interface LogFilterView : UIView

@property (nonatomic,assign) id<LogFilterTimeDelegate> filterTimeDelegate;

@end

