//
//  WranConfirmView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/7.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WranConfirmView.h"
#import "CalculateHeight.h"

@implementation WranConfirmView
{
    UIView *_windowView;
    
    UILabel *_nameLabel;
    UILabel *_wranNoteLabel;
    
    WranUndealModel *_wranUndealModel;
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
    _windowView = [[UIView alloc] initWithFrame:CGRectMake((KScreenWidth - 310)/2, 75, 310, 270)];
    _windowView.backgroundColor = [UIColor whiteColor];
    _windowView.layer.cornerRadius = 8;
    [self addSubview:_windowView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _windowView.width, 57)];
    titleLabel.text = @"设备故障确认";
    titleLabel.textColor = [UIColor colorWithHexString:@"#4DAEF8"];
    titleLabel.font = [UIFont systemFontOfSize:23];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [_windowView addSubview:titleLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, titleLabel.bottom, _windowView.width, 3)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#4DAEF8"];
    [_windowView addSubview:lineView];
    
    // 设备名label
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, lineView.bottom + 14, 68, 47)];
    msgLabel.tag = 2000;
    msgLabel.text = @"设备名 :";
    msgLabel.numberOfLines = 2;
    msgLabel.textColor = [UIColor blackColor];
    msgLabel.font = [UIFont systemFontOfSize:17];
    msgLabel.textAlignment = NSTextAlignmentLeft;
    [_windowView addSubview:msgLabel];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(msgLabel.right + 2, lineView.bottom + 14, _windowView.width - 12 - msgLabel.right, 47)];
    _nameLabel.text = @"故障设备名";
    _nameLabel.numberOfLines = 2;
    _nameLabel.textColor = [UIColor blackColor];
    _nameLabel.font = [UIFont systemFontOfSize:17];
    _nameLabel.textAlignment = NSTextAlignmentLeft;
    [_windowView addSubview:_nameLabel];
    
    // 故障说明label
//    UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, msgLabel.bottom + 14, 84, 17)];
//    noteLabel.tag = 2000;
//    noteLabel.text = @"故障说明 :";
//    noteLabel.numberOfLines = 2;
//    noteLabel.textColor = [UIColor blackColor];
//    noteLabel.font = [UIFont systemFontOfSize:17];
//    noteLabel.textAlignment = NSTextAlignmentLeft;
//    [_windowView addSubview:noteLabel];
    
    _wranNoteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _wranNoteLabel.text = @"故障说明";
    _wranNoteLabel.numberOfLines = 0;
    _wranNoteLabel.textColor = [UIColor blackColor];
    _wranNoteLabel.font = [UIFont systemFontOfSize:17];
    _wranNoteLabel.textAlignment = NSTextAlignmentLeft;
    [_windowView addSubview:_wranNoteLabel];
    
    // 驳回按钮
    UIButton *rejectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rejectButton.tag = 2001;
    rejectButton.layer.cornerRadius = 8;
    rejectButton.frame = CGRectZero;
    rejectButton.backgroundColor = [UIColor whiteColor];
    [rejectButton setTitle:@"忽略故障" forState:UIControlStateNormal];
    [rejectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rejectButton addTarget:self action:@selector(rejectAction) forControlEvents:UIControlEventTouchUpInside];
    [_windowView addSubview:rejectButton];
    
    // 确认完成按钮
    UIButton *completeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    completeButton.layer.cornerRadius = 8;
    completeButton.tag = 2002;
    completeButton.frame = CGRectZero;
    completeButton.backgroundColor = [UIColor whiteColor];
    [completeButton setTitle:@"故障派单" forState:UIControlStateNormal];
    [completeButton setTitleColor:[UIColor colorWithHexString:@"#FF4359"] forState:UIControlStateNormal];
    [completeButton addTarget:self action:@selector(completeAction) forControlEvents:UIControlEventTouchUpInside];
    [_windowView addSubview:completeButton];
    
    UIView *horLineView = [[UIView alloc] initWithFrame:CGRectZero];
    horLineView.tag = 2003;
    horLineView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    [_windowView addSubview:horLineView];
    
    UIView *verLineView = [[UIView alloc] initWithFrame:CGRectZero];
    verLineView.tag = 2004;
    verLineView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    [_windowView addSubview:verLineView];
    
    // 关闭按钮
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.tag = 2005;
    closeButton.frame = CGRectZero;
    [closeButton setBackgroundImage:[UIImage imageNamed:@"window_close_icon"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
}

- (void)endEdit {
    [self endEditing:YES];
}

- (void)closeAction {
    [self hidConfirm];
}

#pragma mark 忽略
- (void)rejectAction {
    if(_warnConfirmDelegate && [_warnConfirmDelegate respondsToSelector:@selector(ingore:)]){
        [_warnConfirmDelegate ingore:_wranUndealModel];
    }
}

#pragma mark 派单
- (void)completeAction {
    if(_warnConfirmDelegate && [_warnConfirmDelegate respondsToSelector:@selector(sendBill:)]){
        [_warnConfirmDelegate sendBill:_wranUndealModel];
    }
}

- (void)showConfirm:(WranUndealModel *)wranUndealModel {
    _wranUndealModel = wranUndealModel;
    
    self.hidden = NO;
    
    UILabel *msgLabel = [_windowView viewWithTag:2000];
    CGFloat noteWidth = _windowView.width - 20;
    
    _nameLabel.text = wranUndealModel.deviceName;
    
    _wranNoteLabel.text = [NSString stringWithFormat:@"故障说明 : %@", wranUndealModel.alarmInfo];
    CGFloat height = [CalculateHeight heightForString:_wranNoteLabel.text fontSize:17 andWidth:noteWidth];
    
    _wranNoteLabel.frame = CGRectMake(10, msgLabel.bottom + 10, noteWidth, height);
    
    _windowView.frame = CGRectMake(_windowView.left, _windowView.top, _windowView.width, _wranNoteLabel.bottom + 20 + 60);
    
    // 根据数据计算高度布局
    UIButton *rejectButton = [_windowView viewWithTag:2001];
    rejectButton.frame = CGRectMake(0, _wranNoteLabel.bottom + 20, _windowView.width/2, _windowView.height - _wranNoteLabel.bottom - 20);
    
    UIButton *completeButton = [_windowView viewWithTag:2002];
    completeButton.frame = CGRectMake(_windowView.width/2, rejectButton.top, _windowView.width/2, rejectButton.height);
    
    UIView *horLineView = [_windowView viewWithTag:2003];
    horLineView.frame = CGRectMake(0, rejectButton.top, _windowView.width, 1);
    
    UIView *verLineView = [_windowView viewWithTag:2004];
    verLineView.frame = CGRectMake(_windowView.width/2, horLineView.top, 1, rejectButton.height);
    
    UIButton *closeButton = [self viewWithTag:2005];
    closeButton.frame = CGRectMake((self.width - 40)/2, _windowView.bottom + 34, 40, 40);
    
}

- (void)hidConfirm {
    self.hidden = YES;
}

@end
