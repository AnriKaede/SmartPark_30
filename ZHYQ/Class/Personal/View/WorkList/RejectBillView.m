//
//  RejectBillView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/16.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "RejectBillView.h"
@interface RejectBillView()<UITextViewDelegate>
{
    UILabel *_msgLabel;
    NSString *_billId;
}
@end

@implementation RejectBillView
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
    _windowView = [[UIView alloc] initWithFrame:CGRectMake((KScreenWidth - 310)/2, 110, 310, 280)];
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
    titleLabel.text = @"退回工单";
    titleLabel.textColor = [UIColor colorWithHexString:@"#4DAEF8"];
    titleLabel.font = [UIFont systemFontOfSize:23];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [_windowView addSubview:titleLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, titleLabel.bottom, _windowView.width, 3)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#4DAEF8"];
    [_windowView addSubview:lineView];
    
    // 输入UITextView
    UITextView *remarksTV = [[UITextView alloc] initWithFrame:CGRectMake(12, lineView.bottom + 16, _windowView.width- 20, 115)];
    remarksTV.tag = 1001;
    remarksTV.font = [UIFont systemFontOfSize:17];
    remarksTV.delegate = self;
    remarksTV.backgroundColor = [UIColor colorWithHexString:@"#E2E2E2"];
    [_windowView addSubview:remarksTV];
    
    // tv 提示Label
    _msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 9, remarksTV.width - 4, 17)];
    _msgLabel.text = @"请填写退回工单的原因";
    _msgLabel.textColor = [UIColor colorWithHexString:@"#c7c7cd"];
    _msgLabel.font = [UIFont systemFontOfSize:17];
    _msgLabel.textAlignment = NSTextAlignmentLeft;
    [remarksTV addSubview:_msgLabel];
    
    // 取消按钮
    UIButton *rejectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rejectButton.layer.cornerRadius = 8;
    rejectButton.frame = CGRectMake(0, remarksTV.bottom + 30, _windowView.width/2, _windowView.height - remarksTV.bottom - 30);
    rejectButton.backgroundColor = [UIColor whiteColor];
    [rejectButton setTitle:@"取消" forState:UIControlStateNormal];
    [rejectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rejectButton addTarget:self action:@selector(cancelReject) forControlEvents:UIControlEventTouchUpInside];
    [_windowView addSubview:rejectButton];
    
    // 确认退回按钮
    UIButton *completeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    completeButton.layer.cornerRadius = 8;
    completeButton.frame = CGRectMake(_windowView.width/2, remarksTV.bottom + 30, _windowView.width/2, rejectButton.height);
    completeButton.backgroundColor = [UIColor whiteColor];
    [completeButton setTitle:@"确认退回" forState:UIControlStateNormal];
    [completeButton setTitleColor:[UIColor colorWithHexString:@"#FF4359"] forState:UIControlStateNormal];
    [completeButton addTarget:self action:@selector(confirmReject) forControlEvents:UIControlEventTouchUpInside];
    [_windowView addSubview:completeButton];
    
    UIView *horLineView = [[UIView alloc] initWithFrame:CGRectMake(0, remarksTV.bottom + 30, _windowView.width, 1)];
    horLineView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    [_windowView addSubview:horLineView];
    
    UIView *verLineView = [[UIView alloc] initWithFrame:CGRectMake(_windowView.width/2, remarksTV.bottom + 30, 1, rejectButton.height)];
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
    [self hidRejectView];
    
    [self cancelReject];
}

#pragma mark 取消
- (void)cancelReject {
    [self hidRejectView];
    if(_chooseDelegate && [_chooseDelegate respondsToSelector:@selector(cancel)]){
        [_chooseDelegate cancel];
    }
}

#pragma mark 确认驳回
- (void)confirmReject {
    UITextView *remarksTV = [_windowView viewWithTag:1001];
    if(remarksTV.text == nil || remarksTV.text.length <= 0){
        [[self viewController] showHint:@"请填写退回原因"];
        return;
    }
    
    if(_chooseDelegate && [_chooseDelegate respondsToSelector:@selector(confirmReject:withRemark:)]){
        [_chooseDelegate confirmReject:_billId withRemark:remarksTV.text];
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

- (void)showRejectView:(NSString *)billId {
    self.hidden = NO;
    _msgLabel.hidden = NO;
    _billId = billId;
}
- (void)hidRejectView {
    self.hidden = YES;
    
    UITextView *remarksTV = [_windowView viewWithTag:1001];
    remarksTV.text = nil;
    _msgLabel.hidden = YES;
}

@end
