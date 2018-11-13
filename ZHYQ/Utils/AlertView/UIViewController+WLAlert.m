//
//  UIViewController+WLAlert.m
//  WLAlert
//
//  Created by 魏唯隆 on 2017/6/9.
//  Copyright © 2017年 魏唯隆. All rights reserved.
//

#import "UIViewController+WLAlert.h"
#import <objc/runtime.h>
#import "CalculateHeight.h"

typedef enum
{
    MyAlertLabel = 0,
    MyAlertTextField
}MyAlertType;

static const void *cancelAlertKey = &cancelAlertKey;
static const void *certainAlertKey = &certainAlertKey;
static const void *certainTextFieldKey = &certainTextFieldKey;

@implementation UIViewController (WLAlert)

- (CancelAlert)cancelAlert {
    return objc_getAssociatedObject(self, cancelAlertKey);
}
- (void)setCancelAlert:(CancelAlert)cancelAlert {
    objc_setAssociatedObject(self, cancelAlertKey, cancelAlert, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CertainAlert)certainAlert {
    return objc_getAssociatedObject(self, certainAlertKey);
}
- (void)setCertainAlert:(CertainAlert)certainAlert {
    objc_setAssociatedObject(self, certainAlertKey, certainAlert, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CertainTextField)certainTextField {
    return objc_getAssociatedObject(self, certainTextFieldKey);
}
- (void)setCertainTextField:(CertainTextField)certainTextField {
    objc_setAssociatedObject(self, certainTextFieldKey, certainTextField, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)showMyAlert:(NSString *)title withCancelMsg:(NSString *)cancelMsg withCancelBlock:(CancelAlert)cancelAlert withCertainMsg:(NSString *)certainMsg withCertainBlock:(CertainAlert)certainAlert {
    if(cancelAlert != nil){
        self.cancelAlert = cancelAlert;
    }
    if(certainAlert != nil){
        self.certainAlert = certainAlert;
    }
    
    [self.view endEditing:YES];
    
    [self _createView:MyAlertLabel withCarnoPlaceholder:nil withInfoPlaceholder:nil withTitle:title withCancelMsg:cancelMsg withCertainMsg:certainMsg isMsgAlert:NO];
    
}

- (void)showTextFieldAlert:(NSString *)title withCarnoPlaceholder:(NSString *)carnoPlaceholder withInfoPlaceholder:(NSString *)infoPlaceholder withCancelMsg:(NSString *)cancelMsg withCancelBlock:(CancelAlert)cancelAlert withCertainMsg:(NSString *)certainMsg withCertainBlock:(CertainTextField)certainTextField isMsgAlert:(BOOL)isMsgAlert {
    if(cancelAlert != nil){
        self.cancelAlert = cancelAlert;
    }
    if(certainTextField != nil){
        self.certainTextField = certainTextField;
    }
    
    [self.view endEditing:YES];
    
    [self _createView:MyAlertTextField withCarnoPlaceholder:carnoPlaceholder withInfoPlaceholder:infoPlaceholder withTitle:title withCancelMsg:cancelMsg withCertainMsg:certainMsg isMsgAlert:isMsgAlert];
}

#pragma mark 创建视图
- (void)_createView:(MyAlertType)myAlertType withCarnoPlaceholder:(NSString *)carnoPlaceholder withInfoPlaceholder:(NSString *)infoPlaceholder withTitle:(NSString *)title withCancelMsg:(NSString *)cancelMsg withCertainMsg:(NSString *)certainMsg isMsgAlert:(BOOL)isMsgAlert {
    // 创建视图
    UIView *bgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    bgView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.5];
    bgView.tag = 4001;
    [UIApplication.sharedApplication.delegate.window addSubview:bgView];
    
    CGFloat alertWidth = KScreenWidth - 60;
    
    UIView *alertView = [[UIView alloc] initWithFrame:CGRectZero];
    alertView.tag = 4002;
    alertView.backgroundColor = [UIColor whiteColor];
    alertView.layer.borderWidth = 1;
    alertView.layer.borderColor = [UIColor grayColor].CGColor;
    alertView.layer.masksToBounds = YES;
    alertView.layer.cornerRadius = 10;
    [bgView addSubview:alertView];
    
    /*
    // 设置alertView的背景图片
    UIImageView *shareBgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, alertWidth, alertView.frame.size.height)];
    UIImage *bgImg = [UIImage imageNamed:@""];
    UIEdgeInsets edge = UIEdgeInsetsMake(107, 0, 30, 0);
    bgImg = [bgImg resizableImageWithCapInsets:edge resizingMode:UIImageResizingModeStretch];
    UIImage *image = bgImg;
    shareBgImgView.image = image;
    [alertView insertSubview:shareBgImgView atIndex:0];
    */
     
    CGFloat titleHeight = [CalculateHeight heightForString:title fontSize:17 andWidth:alertWidth];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 20, alertWidth - 20, titleHeight)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.text = title;
    titleLabel.numberOfLines = 0;
    [alertView addSubview:titleLabel];
    
    CGFloat alertHeight = titleHeight + 90;
    if(myAlertType == MyAlertTextField){
        alertHeight += 100;
    }
    if(carnoPlaceholder == nil || carnoPlaceholder.length <= 0){
        alertHeight -= 40;
    }
    CGRect alertFrame = CGRectMake(30, 100, alertWidth, alertHeight);
    alertView.frame = alertFrame;
    
    CGFloat top;
    if(myAlertType == MyAlertTextField){
        // 第一行frame
        CGRect topFrame;
        if(carnoPlaceholder == nil || carnoPlaceholder.length <= 0){
            topFrame = CGRectMake(alertView.frame.size.width/9, titleLabel.frame.origin.y + titleLabel.frame.size.height + 10, 0, 0);
        }else {
            topFrame = CGRectMake(alertView.frame.size.width/9, titleLabel.frame.origin.y + titleLabel.frame.size.height + 10, alertView.frame.size.width*7/9, 40);
        }
        
        UITextField *carnoTextField = [[UITextField alloc] initWithFrame:topFrame];
        carnoTextField.backgroundColor = [UIColor whiteColor];
        carnoTextField.tag = 4003;
        if(isMsgAlert){
            carnoTextField.text = carnoPlaceholder;
            carnoTextField.enabled = NO;
            carnoTextField.borderStyle = UITextBorderStyleNone;
        }else {
            carnoTextField.placeholder = carnoPlaceholder;
            carnoTextField.borderStyle = UITextBorderStyleRoundedRect;
            [carnoTextField becomeFirstResponder];
        }
        [alertView addSubview:carnoTextField];
        
        UITextField *infoTextField = [[UITextField alloc] initWithFrame:CGRectMake(alertView.frame.size.width/9, carnoTextField.frame.origin.y + carnoTextField.frame.size.height + 6, alertView.frame.size.width*7/9, 40)];
        infoTextField.backgroundColor = [UIColor whiteColor];
        infoTextField.tag = 4004;
        infoTextField.borderStyle = UITextBorderStyleRoundedRect;
        infoTextField.placeholder = infoPlaceholder;
        [alertView addSubview:infoTextField];
        
        if(isMsgAlert){
            infoTextField.keyboardType = UIKeyboardTypeNumberPad;
            [infoTextField becomeFirstResponder];
        }
        
        top = alertView.frame.size.height - 60;
    }else {
        top = alertView.frame.size.height - 60;
    }
    
    if(cancelMsg != nil){
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.layer.masksToBounds = YES;
        cancelButton.layer.cornerRadius = 4;
        cancelButton.layer.borderWidth = 1;
        cancelButton.layer.borderColor = [UIColor grayColor].CGColor;
        cancelButton.frame = CGRectMake(alertView.frame.size.width/9, top, alertView.frame.size.width/3, 35);
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [cancelButton setTitle:cancelMsg forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        cancelButton.backgroundColor = [UIColor whiteColor];
        [cancelButton addTarget:self action:@selector(cancelAlertAction) forControlEvents:UIControlEventTouchUpInside];
        [alertView addSubview:cancelButton];
        
        if(certainMsg == nil){
            cancelButton.frame = CGRectMake((alertView.frame.size.width - alertView.frame.size.width/3)/2, top, alertView.frame.size.width/3, 35);
        }
    }
    
    if(certainMsg != nil){
        UIButton *shareBt = [UIButton buttonWithType:UIButtonTypeCustom];
        shareBt.layer.masksToBounds = YES;
        shareBt.layer.cornerRadius = 4;
        shareBt.layer.borderWidth = 1;
        shareBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
        shareBt.frame = CGRectMake(alertView.frame.size.width*5/9, top, alertView.frame.size.width/3, 35);
        shareBt.titleLabel.font = [UIFont systemFontOfSize:17];
        [shareBt setTitle:certainMsg forState:UIControlStateNormal];
        [shareBt setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
        shareBt.backgroundColor = [UIColor whiteColor];
        if(myAlertType == MyAlertTextField){
            [shareBt addTarget:self action:@selector(certainTextFieldAction) forControlEvents:UIControlEventTouchUpInside];
        }else {
            [shareBt addTarget:self action:@selector(certainAlertAction) forControlEvents:UIControlEventTouchUpInside];
        }
        [alertView addSubview:shareBt];
        
        if(cancelMsg == nil){
            shareBt.frame = CGRectMake((alertView.frame.size.width - alertView.frame.size.width/3)/2, top, alertView.frame.size.width/3, 35);
        }
    }
    
    // 视图加动画
    alertView.alpha = 0;
    [UIView animateWithDuration:0.1 animations:^{
        alertView.alpha = 1;
    }];
    
    // 点击结束编辑
    UITapGestureRecognizer *endEditTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditAction)];
    [bgView addGestureRecognizer:endEditTap];
}
- (void)endEditAction {
    UIView *bgView = [UIApplication.sharedApplication.delegate.window viewWithTag:4001];
    [bgView endEditing:YES];
}

#pragma mark 取消
- (void)cancelAlertAction {
    [self closeView];
    if(self.cancelAlert != nil){
        self.cancelAlert();
    }
}

#pragma mark Label确定
- (void)certainAlertAction {
    [self closeView];
    if(self.certainAlert != nil){
        self.certainAlert();
    }
}

#pragma mark TextField确定
- (void)certainTextFieldAction {
    UIView *bgView = [UIApplication.sharedApplication.delegate.window viewWithTag:4001];
    UIView *alertView = [bgView viewWithTag:4002];
    UITextField *carnoTextField = [alertView viewWithTag:4003];
    UITextField *infoTextField = [alertView viewWithTag:4004];
    if(self.certainTextField != nil){
        self.certainTextField(carnoTextField.text, infoTextField.text);
    }
    
    [self closeView];
}

- (void)closeView {
    UIView *bgView = [UIApplication.sharedApplication.delegate.window viewWithTag:4001];
    bgView.hidden = YES;
    [bgView removeFromSuperview];
    bgView = nil;
}


@end
