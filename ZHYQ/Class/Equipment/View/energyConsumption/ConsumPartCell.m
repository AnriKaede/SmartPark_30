//
//  ConsumPartCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/15.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ConsumPartCell.h"

@implementation ConsumPartCell
{
    __weak IBOutlet UIImageView *_imgVIew;
    
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UILabel *_valueLabel;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setElectricUseModel:(EnergyElectricUseModel *)electricUseModel {
    _electricUseModel = electricUseModel;
    
    _nameLabel.text = [NSString stringWithFormat:@"%@", electricUseModel.companyName];
    
    _valueLabel.text = [NSString stringWithFormat:@"%@ kwh", electricUseModel.costValue];
}

- (void)setWaterUseModel:(EnergyWaterUseModel *)waterUseModel {
    _waterUseModel = waterUseModel;
    
    _nameLabel.text = [NSString stringWithFormat:@"%@", waterUseModel.deviceName];
    
    _valueLabel.text = [NSString stringWithFormat:@"%@ 吨", waterUseModel.costValue];
}

@end
