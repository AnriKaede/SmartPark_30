//
//  YQSlider.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/7.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YQSlider;

@protocol YQSliderDelegate <NSObject>

@optional

-(void)minimumTrackBtnAction:(YQSlider *)slider;
-(void)maximumTrackBtnAction:(YQSlider *)slider;

@end

@interface YQSlider : UISlider

@property (nonatomic, copy) NSString *minimumTrackImageName;
@property (nonatomic, copy) NSString *maximumTrackImageName;

@property (nonatomic,copy) NSString *unitStr;
@property (nonatomic,copy) NSString *leftTitleStr;
@property (nonatomic,copy) NSString *rightTitleStr;

@property (nonatomic,copy) NSString *maxValue;  // 最大值设置标题比例

@property (nonatomic,weak) id <YQSliderDelegate> delegate;

@property (nonatomic, strong) UIButton *minTrackBtn;
@property (nonatomic, strong) UIButton *maxTrackBtn;

@end
