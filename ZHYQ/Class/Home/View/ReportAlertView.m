//
//  ReportAlertView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/24.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "ReportAlertView.h"

@interface ReportAlertView()<UITextViewDelegate>

@end

@implementation ReportAlertView
{
    UILabel *_msgLabel;
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
    _windowView = [[UIView alloc] initWithFrame:CGRectMake((KScreenWidth - 300)/2, 100, 300, 224)];
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
    titleLabel.text = @"故障报修";
    titleLabel.textColor = [UIColor colorWithHexString:@"#4DAEF8"];
    titleLabel.font = [UIFont systemFontOfSize:23];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [_windowView addSubview:titleLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, titleLabel.bottom, _windowView.width, 3)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#4DAEF8"];
    [_windowView addSubview:lineView];
    
    // 输入UITextView
    UITextView *remarksTV = [[UITextView alloc] initWithFrame:CGRectMake(12, lineView.bottom + 10, _windowView.width- 20, 81)];
    remarksTV.tag = 1001;
    remarksTV.font = [UIFont systemFontOfSize:17];
    remarksTV.delegate = self;
    remarksTV.backgroundColor = [UIColor colorWithHexString:@"#E2E2E2"];
    [_windowView addSubview:remarksTV];
    
    // tv 提示Label
    _msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 9, remarksTV.width - 4, 17)];
    _msgLabel.text = @"请描述故障情况";
    _msgLabel.textColor = [UIColor colorWithHexString:@"#c7c7cd"];
    _msgLabel.font = [UIFont systemFontOfSize:17];
    _msgLabel.textAlignment = NSTextAlignmentLeft;
    [remarksTV addSubview:_msgLabel];
    
    // 驳回按钮
    UIButton *rejectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rejectButton.layer.cornerRadius = 8;
    rejectButton.frame = CGRectMake(0, remarksTV.bottom + 12, _windowView.width/2, _windowView.height - remarksTV.bottom - 12);
    rejectButton.backgroundColor = [UIColor whiteColor];
    [rejectButton setTitle:@"取消" forState:UIControlStateNormal];
    [rejectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rejectButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [_windowView addSubview:rejectButton];
    
    // 确认完成按钮
    UIButton *completeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    completeButton.layer.cornerRadius = 8;
    completeButton.frame = CGRectMake(_windowView.width/2, rejectButton.top, _windowView.width/2, rejectButton.height);
    completeButton.backgroundColor = [UIColor whiteColor];
    [completeButton setTitle:@"立即上报" forState:UIControlStateNormal];
    [completeButton setTitleColor:[UIColor colorWithHexString:@"#FF4359"] forState:UIControlStateNormal];
    [completeButton addTarget:self action:@selector(reportAction) forControlEvents:UIControlEventTouchUpInside];
    [_windowView addSubview:completeButton];
    
    UIView *horLineView = [[UIView alloc] initWithFrame:CGRectMake(0, rejectButton.top, _windowView.width, 1)];
    horLineView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    [_windowView addSubview:horLineView];
    
    UIView *verLineView = [[UIView alloc] initWithFrame:CGRectMake(_windowView.width/2, rejectButton.top, 1, rejectButton.height)];
    verLineView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    [_windowView addSubview:verLineView];
    
}

- (void)endEdit {
    [self endEditing:YES];
}

#pragma mark 取消
- (void)cancelAction {
    if(_reportDelegate && [_reportDelegate respondsToSelector:@selector(cancel)]){
        [_reportDelegate cancel];
    }
}

#pragma mark 完成
- (void)reportAction {
    if(_reportDelegate && [_reportDelegate respondsToSelector:@selector(submitReport)]){
        [_reportDelegate submitReport];
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

- (void)showReport:(NSString *)codeId {
    self.hidden = NO;
    
    UITextView *remarksTV = [self viewWithTag:1001];
    [remarksTV becomeFirstResponder];
}
- (void)hidReport {
    self.hidden = YES;
}

@end
