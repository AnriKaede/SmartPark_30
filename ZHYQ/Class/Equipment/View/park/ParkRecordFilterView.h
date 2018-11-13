//
//  ParkRecordFilterView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/9/17.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterTimeDelegate <NSObject>

- (void)closeFilter;
- (void)resetFilter;
- (void)filterWithStart:(NSString *)startTime withEndTime:(NSString *)endTime;

@end

@interface ParkRecordFilterView : UIView

@property (nonatomic,assign) id<FilterTimeDelegate> filterTimeDelegate;

@end
