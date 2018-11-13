//
//  UIViewController+WLAlert.h
//  WLAlert
//
//  Created by 魏唯隆 on 2017/6/9.
//  Copyright © 2017年 魏唯隆. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CancelAlert)(void);
typedef void (^CertainAlert)(void);

typedef void (^CertainTextField)(NSString *carno, NSString *info);

@interface UIViewController (WLAlert)

@property (nonatomic, assign) CancelAlert cancelAlert;
@property (nonatomic, assign) CertainAlert certainAlert;

@property (nonatomic, assign) CertainTextField certainTextField;

- (void)showMyAlert:(NSString *)title withCancelMsg:(NSString *)cancelMsg withCancelBlock:(CancelAlert)cancelAlert withCertainMsg:(NSString *)certainMsg withCertainBlock:(CertainAlert)certainAlert;

- (void)showTextFieldAlert:(NSString *)title withCarnoPlaceholder:(NSString *)carnoPlaceholder withInfoPlaceholder:(NSString *)infoPlaceholder withCancelMsg:(NSString *)cancelMsg withCancelBlock:(CancelAlert)cancelAlert withCertainMsg:(NSString *)certainMsg withCertainBlock:(CertainTextField)certainTextField isMsgAlert:(BOOL)isMsgAlert;

@end
