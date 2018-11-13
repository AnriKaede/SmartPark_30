//
//  SelWeekView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/28.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "SelWeekView.h"

@implementation SelWeekView
{
    UIView *_bgView;
    
    UIButton *_allSelBt;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    if(self){
        [self _initView];
    }
    return self;
}

- (void)_initView {
    self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
    self.hidden = YES;
    [[UIApplication sharedApplication].delegate.window addSubview:self];
    
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, KScreenHeight - 235, KScreenWidth, 235)];
    _bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_bgView];
    
    // 头部视图
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 50)];
    [_bgView addSubview:titleView];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(2, 0, 50, 50);
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor colorWithHexString:@"#FF4359"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:cancelButton];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((KScreenWidth - 100)/2, 15, 100, 20)];
    titleLabel.text = @"重复日期";
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleView addSubview:titleLabel];
    
    UIButton *cerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cerButton.frame = CGRectMake(KScreenWidth - 52, 0, 50, 50);
    [cerButton setTitle:@"确认" forState:UIControlStateNormal];
    [cerButton setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
    [cerButton addTarget:self action:@selector(cerAction) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:cerButton];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.frame = CGRectMake(3,49.5,KScreenWidth - 3,0.5);
    lineView.backgroundColor = [UIColor colorWithHexString:@"#BEBEBE"];
    [titleView addSubview:lineView];
    
    // 日期选择按钮
    _allSelBt = [UIButton buttonWithType:UIButtonTypeCustom];
    _allSelBt.frame = CGRectMake(10, titleView.bottom + 15, 60, 20);
    [_allSelBt setTitle:@"全选" forState:UIControlStateNormal];
    [_allSelBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_allSelBt setImage:[UIImage imageNamed:@"login_check_no"] forState:UIControlStateNormal];
    [_allSelBt setImage:[UIImage imageNamed:@"login_check"] forState:UIControlStateSelected];
    [_allSelBt addTarget:self action:@selector(allSelAction:) forControlEvents:UIControlEventTouchUpInside];
    [_bgView addSubview:_allSelBt];
    
    CGFloat itemWidth = 77;
    CGFloat itemHeight = 40;
    NSArray *days = @[@"一", @"二", @"三", @"四", @"五", @"六", @"日"];
    for (int i=0; i<7; i++) {
        CGFloat buttonleft = 0;
        switch (i%3) {
            case 0:
                buttonleft = 10;
                break;
            case 1:
                buttonleft = (KScreenWidth - itemWidth)/2;
                break;
            case 2:
                buttonleft = KScreenWidth - itemWidth - 10;
                break;
                
            default:
                break;
        }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 3000 + i;
        button.frame = CGRectMake(buttonleft, i/3*itemHeight + _allSelBt.bottom + 7, itemWidth, itemHeight);
        [button setTitle:[NSString stringWithFormat:@"星期%@", days[i]] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"login_check_no"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"login_check"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(selDayAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bgView addSubview:button];
    }
    
}

#pragma mark 取消
- (void)cancelAction {
    self.hidden = YES;
}

#pragma mark 确认
- (void)cerAction {
    self.hidden = YES;
    
    NSMutableArray *selDays = @[].mutableCopy;
    for (int i=0; i<7; i++) {
        UIButton *dayBt = [_bgView viewWithTag:3000 + i];
        if(dayBt.selected){
            [selDays addObject:[NSNumber numberWithInteger:1]];
        }else {
            [selDays addObject:[NSNumber numberWithInteger:0]];
        }
    }
    
    if(_selComDelegate){
        [_selComDelegate selWeekDay:selDays];
    }
}

#pragma mark 全选
- (void)allSelAction:(UIButton *)allSelButton {
    allSelButton.selected = !allSelButton.selected;
    if(allSelButton.selected){
        // 全选
        [self selAllBt:YES];
    }else {
        // 全不选
        [self selAllBt:NO];
    }
}
- (void)selAllBt:(BOOL)isSel {
    for (int i=0; i<7; i++) {
        UIButton *dayBt = [_bgView viewWithTag:3000 + i];
        dayBt.selected = isSel;
    }
}

// 选择一周某一天
- (void)selDayAction:(UIButton *)selDayButton {
    selDayButton.selected = !selDayButton.selected;
    
    BOOL _allSel = YES;
    for (int i=0; i<7; i++) {
        UIButton *dayBt = [_bgView viewWithTag:3000 + i];
        if(!dayBt.selected){
            _allSel = NO;
        }
    }
    _allSelBt.selected = _allSel;
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    
    if(!hidden){
        // 显示加动画
        CGRect frame = _bgView.frame;
        _bgView.frame = CGRectMake(0, KScreenHeight, frame.size.width, frame.size.height);
        [UIView animateWithDuration:0.2 animations:^{
            _bgView.frame = frame;
        }];
    }
}

@end
