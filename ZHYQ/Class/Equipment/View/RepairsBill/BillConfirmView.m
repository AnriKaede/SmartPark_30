//
//  BillConfirmView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/20.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BillConfirmView.h"

@interface BillConfirmView()<UITextViewDelegate>
{
    UILabel *_msgLabel;
    
    NSString *_billId;
}
@end

@implementation BillConfirmView
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
    _windowView = [[UIView alloc] initWithFrame:CGRectMake((KScreenWidth - 310)/2, 75, 310, 343)];
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
    titleLabel.text = @"完成确认";
    titleLabel.textColor = [UIColor colorWithHexString:@"#4DAEF8"];
    titleLabel.font = [UIFont systemFontOfSize:23];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [_windowView addSubview:titleLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, titleLabel.bottom, _windowView.width, 3)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#4DAEF8"];
    [_windowView addSubview:lineView];
    
    // 提示label
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, lineView.bottom + 14, _windowView.width - 20, 47)];
    msgLabel.text = @"请确认设备是否已修复，未修复可驳回，已修复可确认完成，工单结束。";
    msgLabel.numberOfLines = 2;
    msgLabel.textColor = [UIColor blackColor];
    msgLabel.font = [UIFont systemFontOfSize:17];
    msgLabel.textAlignment = NSTextAlignmentLeft;
    [_windowView addSubview:msgLabel];
    
    // 输入UITextView
    UITextView *remarksTV = [[UITextView alloc] initWithFrame:CGRectMake(12, msgLabel.bottom + 16, _windowView.width- 20, 115)];
    remarksTV.tag = 1001;
    remarksTV.font = [UIFont systemFontOfSize:17];
    remarksTV.delegate = self;
    remarksTV.backgroundColor = [UIColor colorWithHexString:@"#E2E2E2"];
    [_windowView addSubview:remarksTV];
    
    // tv 提示Label
    _msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 9, remarksTV.width - 4, 17)];
    _msgLabel.text = @"备注";
    _msgLabel.textColor = [UIColor colorWithHexString:@"#c7c7cd"];
    _msgLabel.font = [UIFont systemFontOfSize:17];
    _msgLabel.textAlignment = NSTextAlignmentLeft;
    [remarksTV addSubview:_msgLabel];
    
    // 驳回按钮
    UIButton *rejectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rejectButton.layer.cornerRadius = 8;
    rejectButton.frame = CGRectMake(0, remarksTV.bottom + 30, _windowView.width/2, _windowView.height - remarksTV.bottom - 30);
    rejectButton.backgroundColor = [UIColor whiteColor];
    [rejectButton setTitle:@"驳回" forState:UIControlStateNormal];
    [rejectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rejectButton addTarget:self action:@selector(rejectAction) forControlEvents:UIControlEventTouchUpInside];
    [_windowView addSubview:rejectButton];
    
    // 确认完成按钮
    UIButton *completeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    completeButton.layer.cornerRadius = 8;
    completeButton.frame = CGRectMake(_windowView.width/2, remarksTV.bottom + 30, _windowView.width/2, rejectButton.height);
    completeButton.backgroundColor = [UIColor whiteColor];
    [completeButton setTitle:@"确认完成" forState:UIControlStateNormal];
    [completeButton setTitleColor:[UIColor colorWithHexString:@"#FF4359"] forState:UIControlStateNormal];
    [completeButton addTarget:self action:@selector(completeAction) forControlEvents:UIControlEventTouchUpInside];
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

- (void)endEdit {
    [self endEditing:YES];
}

- (void)closeAction {
    [self hidProgress];
}

#pragma mark 驳回
- (void)rejectAction {
    UITextView *remarksTV = [_windowView viewWithTag:1001];
    if(remarksTV.text == nil || remarksTV.text.length <= 0){
        [[self viewController] showHint:@"请填写备注"];
        return;
    }
    if(_chooseDelegate && [_chooseDelegate respondsToSelector:@selector(reject:withRemark:)]){
        [_chooseDelegate reject:_billId withRemark:remarksTV.text];
    }
}

#pragma mark 完成
- (void)completeAction {
    UITextView *remarksTV = [_windowView viewWithTag:1001];
    if(remarksTV.text == nil || remarksTV.text.length <= 0){
        [[self viewController] showHint:@"请填写备注"];
        return;
    }
    if(_chooseDelegate && [_chooseDelegate respondsToSelector:@selector(confirmComplete:withRemark:)]){
        [_chooseDelegate confirmComplete:_billId withRemark:remarksTV.text];
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

- (void)showProgress:(NSString *)billId {
    self.hidden = NO;
    
    _billId = billId;
}
- (void)hidProgress {
    self.hidden = YES;
    
    UITextView *remarksTV = [_windowView viewWithTag:1001];
    remarksTV.text = @"";
    _msgLabel.hidden = NO;
}

@end
