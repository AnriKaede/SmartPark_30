//
//  BillConfirmView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/20.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WindowChooseDelegate <NSObject>

- (void)reject:(NSString *)orderId withRemark:(NSString *)remark;
- (void)confirmComplete:(NSString *)orderId withRemark:(NSString *)remark;

@end

@interface BillConfirmView : UIView

@property (nonatomic,assign) id<WindowChooseDelegate> chooseDelegate;

- (void)showProgress:(NSString *)billId;
- (void)hidProgress;

@end
