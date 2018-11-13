//
//  YQAutoScrolLab.h
//  ZHYQ
//
//  Created by 焦平 on 2017/12/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,DirtionType){
    
    DirtionTypeLeft, //left
    DirtionTypeRight //right
    
};

@interface YQAutoScrolLab : UIScrollView

@property (nonatomic, copy) NSString *text;

@property (nonatomic, assign) NSInteger labelBetweenGap;

@property (nonatomic, assign) NSInteger pauseTime;

@property (nonatomic, assign) DirtionType dirtionType;

@property (nonatomic, assign) NSInteger speed;

@property (nonatomic, strong) UIColor  *textColor;

- (void)rejustlabels;

@end
