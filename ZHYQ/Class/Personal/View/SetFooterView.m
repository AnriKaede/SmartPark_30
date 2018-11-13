//
//  SetFooterView.m
//  ZHYQ
//
//  Created by 焦平 on 2017/10/27.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "SetFooterView.h"

@implementation SetFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
        [self _initSubView];
    }
    return self;
}

-(void)_initSubView
{
    self.logOutBtn = [[UIButton alloc] init];
    [self.logOutBtn addTarget:self action:@selector(logOutBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    self.logOutBtn.backgroundColor = [UIColor colorWithHexString:@"e8e8e8"];
    self.logOutBtn.backgroundColor = [UIColor whiteColor];
    self.logOutBtn.layer.borderColor = [UIColor colorWithHexString:@"6E6E6E"].CGColor;
    self.logOutBtn.layer.borderWidth = 0.5;
    self.logOutBtn.layer.cornerRadius = 4;
    self.logOutBtn.clipsToBounds = YES;
    [self.logOutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [self.logOutBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [self.logOutBtn setTitleColor:[UIColor colorWithHexString:@"6ba9e6"] forState:UIControlStateNormal];
    [self addSubview:self.logOutBtn];
    
    [self.logOutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(self);
        make.top.mas_equalTo(35);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(50);
        
    }];
}

//退出登录
-(void)logOutBtnClick:(id)sender
{
    if (self.delegate != nil) {
        [self.delegate DismissContactsCtrl];
    }
}

@end
