//
//  VisFilterView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/8/29.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterTimeDelegate <NSObject>

- (void)closeFilter;
- (void)resetFilter;
- (void)filterWithStart:(NSString *)startTime withEndTime:(NSString *)endTime withVisName:(NSString *)visName;

@end

@interface VisFilterView : UIView

@property (nonatomic,assign) id<FilterTimeDelegate> filterTimeDelegate;

- (void)changeBeginTimeText:(NSString *)beginText withEndText:(NSString *)endText;

@end

