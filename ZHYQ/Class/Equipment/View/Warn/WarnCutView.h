//
//  WarnCutView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/25.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CutDelegate <NSObject>

- (void)cutIndex:(NSInteger)index;

@end

@interface WarnCutView : UIView

@property (nonatomic,assign) id<CutDelegate> cutDelegate;

- (instancetype)initWithFrame:(CGRect)frame withTitleDatas:(NSArray *)titles;

- (void)setSelIndex:(NSInteger)index withAnimation:(BOOL)Animation;

@end
