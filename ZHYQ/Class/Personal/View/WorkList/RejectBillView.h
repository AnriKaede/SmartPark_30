//
//  RejectBillView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/16.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RejectWindowChooseDelegate <NSObject>

- (void)cancel;
- (void)confirmReject:(NSString *)orderId withRemark:(NSString *)remark;

@end

@interface RejectBillView : UIView

@property (nonatomic,assign) id<RejectWindowChooseDelegate> chooseDelegate;

- (void)showRejectView:(NSString *)billId;
- (void)hidRejectView;

- (void)changeTitle:(NSString *)title;

@end
