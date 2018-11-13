//
//  AptCancelView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/6/19.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WindowChooseDelegate <NSObject>

- (void)confirmComplete:(NSString *)orderId withRemark:(NSString *)remark;
@optional
- (void)cancel:(NSString *)orderId withRemark:(NSString *)remark;

@end

@interface AptCancelView : UIView

@property (nonatomic,assign) id<WindowChooseDelegate> chooseDelegate;

- (void)showWindow:(NSString *)billId;
- (void)hidWindow;

- (void)setAlertTitle:(NSString *)title;
- (void)setAlertMessage:(NSString *)message;

@end

