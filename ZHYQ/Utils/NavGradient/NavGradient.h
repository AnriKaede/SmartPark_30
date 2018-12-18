//
//  NavGradient.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/18.
//  Copyright © 2018 焦平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NavGradient : NSObject

+ (UIImage *)navBgColorImg;
+ (void)viewAddGradient:(UIView *)view;
+ (UIImage *)searchAddGradient:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
