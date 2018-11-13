//
//  EquipmentHeaderView.m
//  ZHYQ
//
//  Created by 焦平 on 2017/10/30.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "EquipmentHeaderView.h"
#import "MenuModel.h"

@implementation EquipmentHeaderView

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
    //故障设备
    _leftBtn = [YQButton buttonWithType:UIButtonTypeCustom btnFrame:CGRectZero BtnTitle:@"故障设备" BtnImage:[UIImage imageNamed:@"equipment_brokenEquipment"] BtnHandler:^(UIButton *sender) {
        if (self.delegate != nil) {
            [self.delegate EquipmentBtnEvent:equipmentEventFaulty];
        };
    }];
    _leftBtn.backgroundColor = [UIColor clearColor];
    [self addSubview:_leftBtn];
    [_leftBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [_leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    CGFloat height = 125.0 - 40;
    _leftBtn.frame = CGRectMake(20, 10, height, height);
    
//    [_leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(10);
//        make.left.mas_equalTo(20);
//        make.width.height.mas_equalTo(height);
//    }];
    
    //维修派单
    _centerBtn = [YQButton buttonWithType:UIButtonTypeCustom btnFrame:CGRectZero BtnTitle:@"维修派单" BtnImage:[UIImage imageNamed:@"equipment_orderlist"] BtnHandler:^(UIButton *sender) {
        if (self.delegate != nil) {
            [self.delegate EquipmentBtnEvent:equipmentEventRepairOrderList];
        };
    }];
    [_centerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _centerBtn.backgroundColor = [UIColor clearColor];
    [_centerBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [self addSubview:_centerBtn];
    _centerBtn.frame = CGRectMake(0, 10, height, height);
    _centerBtn.centerX = self.centerX;
    
//    [_centerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self);
//        make.top.mas_equalTo(10);
//        make.width.height.mas_equalTo(height);
//    }];
    
    //信息发布
    _rightBtn = [YQButton buttonWithType:UIButtonTypeCustom btnFrame:CGRectZero BtnTitle:@"综合查询" BtnImage:[UIImage imageNamed:@"equipment_msgPost"] BtnHandler:^(UIButton *sender) {
        if (self.delegate != nil) {
            [self.delegate EquipmentBtnEvent:equipmentEventInfomationPost];
        };
    }];
    [_rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _rightBtn.backgroundColor = [UIColor clearColor];
    [_rightBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [self addSubview:_rightBtn];
    
    _rightBtn.frame = CGRectMake(KScreenWidth - height -20, 10, height, height);
    
    
//    [_rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(-20);
//        make.top.mas_equalTo(10);
//        make.width.height.mas_equalTo(height);
//    }];
    
    _vLineView = [[UIView alloc] init];
    _vLineView.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    [self addSubview:_vLineView];
    
    [_vLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_leftBtn).with.offset(20);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(5);
    }];
    
    _titleBackGroundView = [[UIView alloc] init];
    _titleBackGroundView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_titleBackGroundView];

    [_titleBackGroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_vLineView).with.offset(5);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(35);
    }];
    
    _hLineView = [[UIImageView alloc] init];
    _hLineView.image = [UIImage imageNamed:@"equipment_scqure"];
    [_titleBackGroundView addSubview:_hLineView];
    _hLineView.backgroundColor = [UIColor clearColor];
    
    [_hLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleBackGroundView).with.offset(15);
        make.bottom.equalTo(_titleBackGroundView).with.offset(-5);
        make.left.mas_equalTo(10);
        make.width.mas_equalTo(4);
    }];
    
    _titleLab = [[UILabel alloc] init];
    _titleLab.font = [UIFont boldSystemFontOfSize:17];
    _titleLab.textAlignment = NSTextAlignmentLeft;
    _titleLab.text = @"基础设备";
    _titleLab.backgroundColor = [UIColor clearColor];
    [_titleBackGroundView addSubview:_titleLab];
    
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleBackGroundView).with.offset(13);
        make.leftMargin.equalTo(_hLineView).with.offset(10);
    }];
    
    _hLineView1 = [[UIImageView alloc] init];
    _hLineView1.image = [UIImage imageNamed:@"weather_sep"];
    _hLineView1.frame = CGRectMake(KScreenWidth/3, 25, 0.5, 75);
    [self addSubview:_hLineView1];
    
    _hLineView2 = [[UIImageView alloc] init];
    _hLineView2.image = [UIImage imageNamed:@"weather_sep"];
    _hLineView2.frame = CGRectMake(KScreenWidth/3 * 2, 25, 0.5, 75);
    [self addSubview:_hLineView2];
}

- (void)setParentMenuModel:(ParentMenuModel *)parentMenuModel {
    _parentMenuModel = parentMenuModel;
    if(parentMenuModel.items && parentMenuModel.items.count > 0){
        MenuModel *model = parentMenuModel.items[0];
        if (model != nil) {
            [self.leftBtn setTitle:model.MENU_NAME forState:UIControlStateNormal];
            [self.leftBtn setImage:[UIImage imageNamed:model.MENU_ICON] forState:UIControlStateNormal];
            if ([model.MENU_ID integerValue] == 5) {
                [self.leftBtn removeAllTargets];
                [self.leftBtn addTarget:self action:@selector(equipmentEventFaulty) forControlEvents:UIControlEventTouchUpInside];
            }else if ([model.MENU_ID integerValue] == 6){
                [self.leftBtn removeAllTargets];
                [self.leftBtn addTarget:self action:@selector(equipmentEventRepairOrderList) forControlEvents:UIControlEventTouchUpInside];
            }else{
                [self.leftBtn removeAllTargets];
                [self.leftBtn addTarget:self action:@selector(equipmentEventInfomationPost) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
    
    if (parentMenuModel.items.count < 2) {
        _centerBtn.hidden = YES;
        _rightBtn.hidden = YES;
        _hLineView1.hidden = YES;
        _hLineView2.hidden = YES;
        
        _leftBtn.centerX = KScreenWidth/2;
        
        return;
    }
    
    if(parentMenuModel.items && parentMenuModel.items.count > 1){
        MenuModel *model1 = parentMenuModel.items[1];
        if (model1 != nil) {
            [self.centerBtn setTitle:model1.MENU_NAME forState:UIControlStateNormal];
            [self.centerBtn setImage:[UIImage imageNamed:model1.MENU_ICON] forState:UIControlStateNormal];
            if ([model1.MENU_ID integerValue] == 5) {
                [self.centerBtn removeAllTargets];
                [self.centerBtn addTarget:self action:@selector(equipmentEventFaulty) forControlEvents:UIControlEventTouchUpInside];
            }else if ([model1.MENU_ID integerValue] == 6){
                [self.centerBtn removeAllTargets];
                [self.centerBtn addTarget:self action:@selector(equipmentEventRepairOrderList) forControlEvents:UIControlEventTouchUpInside];
            }else{
                [self.centerBtn removeAllTargets];
                [self.centerBtn addTarget:self action:@selector(equipmentEventInfomationPost) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
    
    if (parentMenuModel.items.count <3) {
        CGFloat leftCenterX = KScreenWidth/4;
        _leftBtn.centerX = leftCenterX;
        _hLineView1.centerX = self.centerX;
        CGFloat centerX = (KScreenWidth/4)*3;
        _centerBtn.centerX = centerX;
        
        _centerBtn.hidden = NO;
        _hLineView1.hidden = NO;
        
        _rightBtn.hidden = YES;
        _hLineView2.hidden = YES;
        return;
    }
    
    if(parentMenuModel.items.count >= 3){
        CGFloat height = 125.0 - 40;
        
        _leftBtn.frame = CGRectMake(20, 10, height, height);
        
        _centerBtn.hidden = NO;
        _centerBtn.frame = CGRectMake(0, 10, height, height);
        _centerBtn.centerX = self.centerX;
        _hLineView1.hidden = NO;
        _hLineView1.frame = CGRectMake(KScreenWidth/3, 25, 0.5, 75);
        
        _rightBtn.hidden = NO;
        _rightBtn.frame = CGRectMake(KScreenWidth - height -20, 10, height, height);
        _hLineView2.hidden = NO;
        _hLineView2.frame = CGRectMake(KScreenWidth/3 * 2, 25, 0.5, 75);
    }
    
    if(parentMenuModel.items && parentMenuModel.items.count > 3){
        MenuModel *model2 = parentMenuModel.items[2];
        if (model2 != nil) {
            [self.rightBtn setTitle:model2.MENU_NAME forState:UIControlStateNormal];
            [self.rightBtn setImage:[UIImage imageNamed:model2.MENU_ICON] forState:UIControlStateNormal];
            if ([model2.MENU_ID integerValue] == 5) {
                [self.rightBtn removeAllTargets];
                [self.rightBtn addTarget:self action:@selector(equipmentEventFaulty) forControlEvents:UIControlEventTouchUpInside];
            }else if ([model2.MENU_ID integerValue] == 6){
                [self.rightBtn removeAllTargets];
                [self.rightBtn addTarget:self action:@selector(equipmentEventRepairOrderList) forControlEvents:UIControlEventTouchUpInside];
            }else{
                [self.rightBtn removeAllTargets];
                [self.rightBtn addTarget:self action:@selector(equipmentEventInfomationPost) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}

- (void)setSubTitle:(NSString *)subTitle {
    _subTitle = subTitle;
    
    _titleLab.text = subTitle;
}

-(void)equipmentEventFaulty
{
    if (self.delegate != nil) {
        [self.delegate EquipmentBtnEvent:equipmentEventFaulty];
    }
}

-(void)equipmentEventRepairOrderList
{
    if (self.delegate != nil) {
        [self.delegate EquipmentBtnEvent:equipmentEventRepairOrderList];
    }
}

-(void)equipmentEventInfomationPost
{
    if (self.delegate != nil) {
        [self.delegate EquipmentBtnEvent:equipmentEventInfomationPost];
    }
}

@end
