//
//  CountCostView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/16.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountCostView : UIView

@property (nonatomic, copy) NSString *elcNum;
@property (nonatomic, assign) BOOL isElcUp;
@property (nonatomic, copy) NSString *elcRatio;

@property (nonatomic, copy) NSString *waterNum;
@property (nonatomic, assign) BOOL isWaterUp;
@property (nonatomic, copy) NSString *waterRatio;

@end
