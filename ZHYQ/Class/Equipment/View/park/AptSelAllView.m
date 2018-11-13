//
//  AptSelAllView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/6/15.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "AptSelAllView.h"

@implementation AptSelAllView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initView];
    }
    return self;
}

- (void)_initView {
    self.backgroundColor = [UIColor whiteColor];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 1)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    [self addSubview:lineView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = 3001;
    button.frame = CGRectMake(10, 20, 70, 20);
    [button setImage:[UIImage imageNamed:@"park_cancel_apt_normal"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"park_cancel_apt_select"] forState:UIControlStateSelected];
    [button setTitle:@" 全选" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(selAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
    UIButton *operateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    operateButton.frame = CGRectMake(KScreenWidth - 160, 10, 150, 40);
    [operateButton setTitle:@"批量预约取消" forState:UIControlStateNormal];
    [operateButton setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
    [operateButton addTarget:self action:@selector(clickAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:operateButton];
    
    operateButton.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    operateButton.layer.borderWidth = 1;
    operateButton.layer.cornerRadius = 8;
}

- (void)selAction:(UIButton *)button {
    button.selected = !button.selected;
    
    if(_batchAptDelegate && [_batchAptDelegate respondsToSelector:@selector(batchSelect:)]){
        [_batchAptDelegate batchSelect:button.selected];
    }
}

- (void)clickAction {
    if(_batchAptDelegate && [_batchAptDelegate respondsToSelector:@selector(batchClick)]){
        [_batchAptDelegate batchClick];
    }
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    
    UIButton *button = [self viewWithTag:3001];
    button.selected = NO;
}

@end
