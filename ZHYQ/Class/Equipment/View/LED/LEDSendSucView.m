//
//  LEDSendSucView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/16.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "LEDSendSucView.h"
@interface LEDSendSucView()<UITextViewDelegate>
{
    UILabel *_msgLabel;
}
@end

@implementation LEDSendSucView
{
    UIView *_windowView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        
        [self _initView];
    }
    return self;
}

- (void)_initView {
    self.hidden = YES;
    self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.6];
    
    UITapGestureRecognizer *endEditTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEdit)];
    [self addGestureRecognizer:endEditTap];
    
    // 弹窗背景
    _windowView = [[UIView alloc] initWithFrame:CGRectMake((KScreenWidth - 310)/2, 110, 310, 250)];
    _windowView.backgroundColor = [UIColor whiteColor];
    _windowView.layer.cornerRadius = 8;
    [self addSubview:_windowView];
    /*
     _windowView.layer.shadowOffset = CGSizeMake(5, 5);
     _windowView.layer.shadowColor = [UIColor blackColor].CGColor;
     _windowView.layer.shadowOpacity = 0.7;
     _windowView.layer.shadowRadius = 4;
     */
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _windowView.width, 57)];
    titleLabel.tag = 2003;
    titleLabel.text = @"发布成功";
    titleLabel.textColor = [UIColor colorWithHexString:@"#4DAEF8"];
    titleLabel.font = [UIFont systemFontOfSize:23];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [_windowView addSubview:titleLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, titleLabel.bottom, _windowView.width, 3)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#4DAEF8"];
    [_windowView addSubview:lineView];
    
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, lineView.bottom + 12, _windowView.width, 50)];
    msgLabel.tag = 2003;
    msgLabel.text = @"信息发布成功，是否需要将该内容存为模板，下次直接使用？";
    msgLabel.textColor = [UIColor blackColor];
    msgLabel.font = [UIFont systemFontOfSize:17];
    msgLabel.textAlignment = NSTextAlignmentLeft;
    msgLabel.numberOfLines = 2;
    [_windowView addSubview:msgLabel];
    
    // 输入UITextView
    UITextView *remarksTV = [[UITextView alloc] initWithFrame:CGRectMake(12, msgLabel.bottom + 12, _windowView.width- 20, 40)];
    remarksTV.tag = 1001;
    remarksTV.font = [UIFont systemFontOfSize:17];
    remarksTV.delegate = self;
    remarksTV.backgroundColor = [UIColor colorWithHexString:@"#E2E2E2"];
    [_windowView addSubview:remarksTV];
    
    // tv 提示Label
    _msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 9, remarksTV.width - 4, 17)];
    _msgLabel.text = @"模板名称";
    _msgLabel.textColor = [UIColor colorWithHexString:@"#c7c7cd"];
    _msgLabel.font = [UIFont systemFontOfSize:17];
    _msgLabel.textAlignment = NSTextAlignmentLeft;
    [remarksTV addSubview:_msgLabel];
    
    // 取消按钮
    UIButton *rejectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rejectButton.layer.cornerRadius = 8;
    rejectButton.frame = CGRectMake(0, remarksTV.bottom + 15, _windowView.width/2, _windowView.height - remarksTV.bottom - 15);
    rejectButton.backgroundColor = [UIColor whiteColor];
    [rejectButton setTitle:@"取消" forState:UIControlStateNormal];
    [rejectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rejectButton addTarget:self action:@selector(cancelReject) forControlEvents:UIControlEventTouchUpInside];
    [_windowView addSubview:rejectButton];
    
    // 确认退回按钮
    UIButton *completeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    completeButton.layer.cornerRadius = 8;
    completeButton.frame = CGRectMake(_windowView.width/2, remarksTV.bottom + 15, _windowView.width/2, rejectButton.height);
    completeButton.backgroundColor = [UIColor whiteColor];
    [completeButton setTitle:@"保存为模板" forState:UIControlStateNormal];
    [completeButton setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
    [completeButton addTarget:self action:@selector(confirmReject) forControlEvents:UIControlEventTouchUpInside];
    [_windowView addSubview:completeButton];
    
    UIView *horLineView = [[UIView alloc] initWithFrame:CGRectMake(0, completeButton.top, _windowView.width, 1)];
    horLineView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    [_windowView addSubview:horLineView];
    
    UIView *verLineView = [[UIView alloc] initWithFrame:CGRectMake(_windowView.width/2, horLineView.bottom - 1, 1, rejectButton.height)];
    verLineView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    [_windowView addSubview:verLineView];
    
    // 关闭按钮
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake((self.width - 40)/2, _windowView.bottom + 34, 40, 40);
    [closeButton setBackgroundImage:[UIImage imageNamed:@"window_close_icon"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
}
- (void)changeTitle:(NSString *)title {
    UILabel *titleLabel = [_windowView viewWithTag:2003];
    titleLabel.text = title;
}

- (void)endEdit {
    [self endEditing:YES];
}

- (void)closeAction {
    [self hidSendSucView];
    
    [self cancelReject];
}

#pragma mark 取消
- (void)cancelReject {
    [self hidSendSucView];
    if(_sendSucDelegate && [_sendSucDelegate respondsToSelector:@selector(cancel)]){
        [_sendSucDelegate cancel];
    }
}

#pragma mark 确认驳回
- (void)confirmReject {
    UITextView *remarksTV = [_windowView viewWithTag:1001];
    if(remarksTV.text == nil || remarksTV.text.length <= 0){
        [[self viewController] showHint:@"模板名称"];
        return;
    }
    
    if(_sendSucDelegate && [_sendSucDelegate respondsToSelector:@selector(confirmWithName:)]){
        [_sendSucDelegate confirmWithName:remarksTV.text];
    }
}

#pragma mark UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *tvString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if(tvString.length <= 0){
        _msgLabel.hidden = NO;
    }else {
        _msgLabel.hidden = YES;
    }
    
    return YES;
}

- (void)showSendSucView {
    self.hidden = NO;
    _msgLabel.hidden = NO;
}
- (void)hidSendSucView {
    self.hidden = YES;
    
    UITextView *remarksTV = [_windowView viewWithTag:1001];
    remarksTV.text = nil;
    _msgLabel.hidden = YES;
}

@end
