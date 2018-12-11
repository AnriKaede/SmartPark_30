//
//  CarRoundView.h
//  TCBuildingSluice
//
//  Created by 魏唯隆 on 2018/8/20.
//  Copyright © 2018年 魏唯隆. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CarRoundView : UIView

@property (nonatomic,assign) CGFloat maintainEndNum;
@property (nonatomic,assign) NSInteger freParkNum;

- (void)setDataTitle:(NSString *)dataTitle;
- (void)setSubTitle:(NSString *)subTitle;

@end

NS_ASSUME_NONNULL_END
