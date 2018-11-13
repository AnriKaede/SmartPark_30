//
//  EquipmentScedheaderView.m
//  ZHYQ
//
//  Created by 焦平 on 2017/10/30.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "EquipmentScedheaderView.h"

@implementation EquipmentScedheaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initView];
    }
    return self;
}

-(void)_initView
{
    [self addSubview:self.vLineView];
    [self addSubview:self.hLineView];
    [self addSubview:self.titleLab];
    
    [_vLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self).with.offset(0);
        make.height.mas_equalTo(0.5);
    }];
    
    [_hLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(15);
        make.bottom.equalTo(self).with.offset(-5);
        make.left.mas_equalTo(10);
        make.width.mas_equalTo(4);
    }];
    
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self).with.offset(13);
        make.leftMargin.equalTo(_hLineView).with.offset(10);
        
    }];
}

-(UIView *)vLineView
{
    if (_vLineView == nil) {
        _vLineView = [[UIView alloc] init];
        _vLineView.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    }
    return _vLineView;
}

-(UILabel *)titleLab
{
    if (_titleLab == nil) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont boldSystemFontOfSize:17];
        _titleLab.textAlignment = NSTextAlignmentLeft;
        _titleLab.backgroundColor = [UIColor clearColor];
    }
    return _titleLab;
}

-(UIImageView *)hLineView
{
    if (_hLineView == nil) {
        _hLineView = [[UIImageView alloc] init];
        _hLineView.image = [UIImage imageNamed:@"equipment_scqure"];
        _hLineView.backgroundColor = [UIColor clearColor];
    }
    return _hLineView;
}

@end
