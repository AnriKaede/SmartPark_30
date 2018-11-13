//
//  AirConditionCollViewCell.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "AirConditionCollViewCell.h"

@interface AirConditionCollViewCell()

@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UIImageView *errorImageView;
@property (weak, nonatomic) IBOutlet UILabel *errorLab;
@property (weak, nonatomic) IBOutlet UIImageView *airconditionView;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@end

@implementation AirConditionCollViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.contentView insertSubview:_bgView atIndex:0];
    
    _errorImageView.hidden = YES;
    _errorLab.hidden = YES;
}

-(void)setModel:(AirConditionModel *)model
{
    _model = model;
    
    _nameLab.text = [NSString stringWithFormat:@"%@",model.DEVICE_NAME];
    _nameLab.textColor = [UIColor whiteColor];
    
    
    // " EQUIP_STATUS ": "1"    -当前设备状态 1 正常 0故障 2离线
    
    if ([model.EQUIP_STATUS isEqualToString:@"1"]) {
        _bgView.backgroundColor = [UIColor colorWithHexString:@"1B82D1"];
        _errorImageView.hidden = YES;
        _errorLab.hidden = YES;
        _airconditionView.image = [UIImage imageNamed:@"aircondition_work"];
    }else if([model.EQUIP_STATUS isEqualToString:@"0"]){
        _bgView.backgroundColor = [UIColor colorWithHexString:@"FF4359"];
        _errorImageView.hidden = NO;
        _errorLab.hidden = NO;
        _airconditionView.image = [UIImage imageNamed:@""];
    }else{
        _bgView.backgroundColor = [UIColor colorWithHexString:@"757575"];
        _errorImageView.hidden = YES;
        _errorLab.hidden = YES;
        _airconditionView.image = [UIImage imageNamed:@"aircondition_stop"];
    }
    
    
}

@end
