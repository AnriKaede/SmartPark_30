//
//  YQSwitch.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/6.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol switchTapDelegate <NSObject>

-(void)switchTap:(BOOL)on;

@end

@interface YQSwitch : UIControl

@property (nonatomic, assign, getter = isOn) BOOL on;

@property (nonatomic, strong) UIColor *onTintColor;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *thumbTintColor;

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) NSString *onText;
@property (nonatomic, strong) NSString *offText;

- (void)setOn:(BOOL)on animated:(BOOL)animated;

@property (nonatomic,weak) id<switchTapDelegate> switchDelegate;

@end
