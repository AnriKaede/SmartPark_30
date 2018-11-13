//
//  ReservedFilterView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/9/14.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReservedFilterDelegate <NSObject>

- (void)reservedCloseFilter;
- (void)reservedResetFilter;
- (void)filterWithStart:(NSString *)startTime withEndTime:(NSString *)endTime withOperateMan:(NSString *)operateMan withOperateKey:(NSString *)operateKey;

@end

@interface ReservedFilterView : UIView

@property (nonatomic,assign) id<ReservedFilterDelegate> reservedFilterDelegate;

@end

