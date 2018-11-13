//
//  WranConfirmView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/7.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WranUndealModel.h"

@protocol WarnConfirmDelegate <NSObject>

- (void)ingore:(WranUndealModel *)wranUndealModel;
- (void)sendBill:(WranUndealModel *)wranUndealModel;

@end

@interface WranConfirmView : UIView

@property (nonatomic,assign) id<WarnConfirmDelegate> warnConfirmDelegate;

- (void)showConfirm:(WranUndealModel *)wranUndealModel;
- (void)hidConfirm;

@end
