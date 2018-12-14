//
//  LEDSendSucView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/16.
//  Copyright © 2018 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SendLedSucDelegate <NSObject>

- (void)confirmWithName:(NSString *)name;
@optional
- (void)cancel;

@end

@interface LEDSendSucView : UIView

@property (nonatomic,assign) id<SendLedSucDelegate> sendSucDelegate;

- (void)showSendSucView;
- (void)hidSendSucView;
@end

NS_ASSUME_NONNULL_END
