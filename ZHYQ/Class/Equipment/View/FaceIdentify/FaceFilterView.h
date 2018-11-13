//
//  FaceFilterView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/8/30.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FaceFilterTimeDelegate <NSObject>

- (void)closeFilter;
- (void)resetFilter;
- (void)filterWithStart:(NSString *)startTime withEndTime:(NSString *)endTime withSimValue:(NSNumber *)simValue;

@end

@interface FaceFilterView : UIView

@property (nonatomic,assign) id<FaceFilterTimeDelegate> filterTimeDelegate;

@end

