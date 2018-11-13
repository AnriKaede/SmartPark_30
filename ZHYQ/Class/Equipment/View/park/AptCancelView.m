//
//  AptCancelView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/6/19.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "AptCancelView.h"

@interface AptCancelView()<UITextViewDelegate>
{
    UILabel *_msgLabel;
    
    NSString *_billId;
}
@end

@implementation AptCancelView
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
    _windowView = [[UIView alloc] initWithFrame:CGRectMake((KScreenWidth - 310)/2, 75, 310, 262)];
    _windowView.backgroundColor = [UIColor whiteColor];
    _windowView.layer.cornerRadius = 8;
    [self addSubview:_windowView];
    /*
     _windowView.layer.shadowOffset = CGSizeMake(5, 5);
     _windowView.layer.shadowColor = [UIColor blackColor].CGColor;
     _windowView.layer.shadowOpacity = 0.7;
     _windowView.layer.shadowRadius = 4;
     */
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 120, 57)];
    titleLabel.tag = 4001;
    titleLabel.text = @"取消确认";
    titleLabel.textColor = [UIColor colorWithHexString:@"#4DAEF8"];
    titleLabel.font = [UIFont systemFontOfSize:23];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [_windowView addSubview:titleLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, titleLabel.bottom, _windowView.width, 3)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#4DAEF8"];
    [_windowView addSubview:lineView];
    
    // 提示label
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, lineView.bottom + 14, _windowView.width - 20, 62)];
    msgLabel.tag = 4002;
    msgLabel.text = @"取消车位预约将不再为员工保留该车位，确认取消？";
    msgLabel.numberOfLines = 0;
    msgLabel.textColor = [UIColor blackColor];
    msgLabel.font = [UIFont systemFontOfSize:17];
    msgLabel.textAlignment = NSTextAlignmentLeft;
    [_windowView addSubview:msgLabel];
    
    // 输入UITextView
    UITextView *remarksTV = [[UITextView alloc] initWithFrame:CGRectMake(12, msgLabel.bottom + 16, _windowView.width- 20, 45)];
    remarksTV.tag = 1001;
    remarksTV.font = [UIFont systemFontOfSize:17];
    remarksTV.delegate = self;
    remarksTV.backgroundColor = [UIColor colorWithHexString:@"#E2E2E2"];
    [_windowView addSubview:remarksTV];
    
    // tv 提示Label
    _msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 9, remarksTV.width - 4, 17)];
    _msgLabel.text = @"取消备注";
    _msgLabel.textColor = [UIColor colorWithHexString:@"#c7c7cd"];
    _msgLabel.font = [UIFont systemFontOfSize:17];
    _msgLabel.textAlignment = NSTextAlignmentLeft;
    [remarksTV addSubview:_msgLabel];
    
    // 驳回按钮
    UIButton *rejectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rejectButton.layer.cornerRadius = 8;
    rejectButton.frame = CGRectMake(0, remarksTV.bottom + 10, _windowView.width/2, _windowView.height - remarksTV.bottom - 10);
    rejectButton.backgroundColor = [UIColor whiteColor];
    [rejectButton setTitle:@"取消" forState:UIControlStateNormal];
    [rejectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rejectButton addTarget:self action:@selector(rejectAction) forControlEvents:UIControlEventTouchUpInside];
    [_windowView addSubview:rejectButton];
    
    // 确认完成按钮
    UIButton *completeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    completeButton.layer.cornerRadius = 8;
    completeButton.frame = CGRectMake(_windowView.width/2, remarksTV.bottom + 10, _windowView.width/2, rejectButton.height);
    completeButton.backgroundColor = [UIColor whiteColor];
    [completeButton setTitle:@"确认" forState:UIControlStateNormal];
    [completeButton setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
    [completeButton addTarget:self action:@selector(completeAction) forControlEvents:UIControlEventTouchUpInside];
    [_windowView addSubview:completeButton];
    
    UIView *horLineView = [[UIView alloc] initWithFrame:CGRectMake(0, remarksTV.bottom + 10, _windowView.width, 1)];
    horLineView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    [_windowView addSubview:horLineView];
    
    UIView *verLineView = [[UIView alloc] initWithFrame:CGRectMake(_windowView.width/2, remarksTV.bottom + 10, 1, rejectButton.height)];
    verLineView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    [_windowView addSubview:verLineView];
    
}

- (void)endEdit {
    [self endEditing:YES];
}

- (void)closeAction {
    [self hidWindow];
}

#pragma mark 取消
- (void)rejectAction {
    [self endEditing:YES];
    UITextView *remarksTV = [_windowView viewWithTag:1001];
    if(_chooseDelegate && [_chooseDelegate respondsToSelector:@selector(cancel:withRemark:)]){
        [_chooseDelegate cancel:_billId withRemark:remarksTV.text];
    }
    [self hidWindow];
}

#pragma mark 完成
- (void)completeAction {
    [self endEditing:YES];
    UITextView *remarksTV = [_windowView viewWithTag:1001];
//    if(remarksTV.text == nil || remarksTV.text.length <= 0){
//        [[self viewController] showHint:@"请填写备注"];
//        return;
//    }
    if(_chooseDelegate && [_chooseDelegate respondsToSelector:@selector(confirmComplete:withRemark:)]){
        [_chooseDelegate confirmComplete:_billId withRemark:remarksTV.text];
    }
    
    [self hidWindow];
}

#pragma mark UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *tvString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if(tvString.length <= 0){
        _msgLabel.hidden = NO;
    }else {
        _msgLabel.hidden = YES;
    }
    
    if(tvString.length >= 100){
        return NO;
    }
    
    return YES;
}

- (void)showWindow:(NSString *)billId {
    self.hidden = NO;
    
    _billId = billId;
}
- (void)hidWindow {
    self.hidden = YES;
    
    UITextView *remarksTV = [_windowView viewWithTag:1001];
    remarksTV.text = @"";
    _msgLabel.hidden = NO;
}

- (void)setAlertTitle:(NSString *)title {
    UILabel *titleLabel = [_windowView viewWithTag:4001];
    
    titleLabel.text = title;
}

- (void)setAlertMessage:(NSString *)message {
    UILabel *messageLabel = [_windowView viewWithTag:4002];
    
    messageLabel.text = message;
}

@end
