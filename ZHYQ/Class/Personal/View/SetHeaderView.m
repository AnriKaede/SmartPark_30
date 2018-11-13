//
//  SetHeaderView.m
//  ZHYQ
//
//  Created by 焦平 on 2017/10/26.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "SetHeaderView.h"

@implementation SetHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initSubView];
    }
    return self;
}

-(void)_initSubView
{
    _iconView = [[UIImageView alloc] init];
    _iconView.backgroundColor = [UIColor lightGrayColor];
    _iconView.image = [UIImage imageNamed:@"_member_icon"];
    [self addSubview:_iconView];
    
    if (kDevice_Is_iPhoneX) {
        self.iconView.frame = CGRectMake(18, 55, 70, 70);
    }else{
        self.iconView.frame = CGRectMake(18, 41, 70, 70);
    }
    
    self.signLab = [[UILabel alloc] init];
    self.signLab.textColor = [UIColor whiteColor];
    self.signLab.backgroundColor = [UIColor colorWithHexString:@"#6ba9e6"];
    self.signLab.font = [UIFont systemFontOfSize:10];
    self.signLab.backgroundColor = [UIColor orangeColor];
    self.signLab.layer.cornerRadius = 4;
    self.signLab.clipsToBounds = YES;
    self.signLab.text = @"-";
    self.signLab.textAlignment = NSTextAlignmentCenter;
    self.signLab.frame = CGRectMake(CGRectGetMinX(self.iconView.frame)+CGRectGetWidth(self.iconView.frame)/2 - 60/2, CGRectGetMaxY(self.iconView.frame)+8, 60, 15);
    [self addSubview:self.signLab];
    
    
    self.nameLab = [[UILabel alloc] init];
    self.nameLab.textColor = [UIColor blackColor];
    self.nameLab.backgroundColor = [UIColor clearColor];
    self.nameLab.font = [UIFont boldSystemFontOfSize:20];
    self.nameLab.text = @"-";
    [self addSubview:self.nameLab];
    
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.iconView);
        make.left.equalTo(self.iconView.mas_right).with.offset(16);
        make.right.mas_equalTo(-10);
    }];

    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    if (kDevice_Is_iPhoneX) {
        self.lineView.frame = CGRectMake(0, 159.5, KScreenWidth, 0.5);
    }else{
        self.lineView.frame = CGRectMake(0, 144.5, KScreenWidth, 0.5);
    }
    
    [self addSubview:self.lineView];
}

@end
