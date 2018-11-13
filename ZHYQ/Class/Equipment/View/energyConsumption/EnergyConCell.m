//
//  EnergyConCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/11.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "EnergyConCell.h"
#import "MonthMeterViewController.h"

@implementation EnergyConCell
{
    __weak IBOutlet UILabel *_nameLabel;
    
    __weak IBOutlet UILabel *_currentValueLabel;
    
    __weak IBOutlet UILabel *_addressLabel;
    
    __weak IBOutlet UIView *_monthValueView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _topLineView.backgroundColor = [UIColor colorWithHexString:@"e2e2e2"];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITapGestureRecognizer *monthTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(monthValue)];
    [_monthValueView addGestureRecognizer:monthTap];
}

- (void)setWaterListModel:(WaterListModel *)waterListModel {
    _waterListModel = waterListModel;
    
    _nameLabel.text = waterListModel.deviceName;
    _currentValueLabel.text = [NSString stringWithFormat:@"%@ 吨", waterListModel.deviceIoValue];
}

- (void)setElectricInfoModel:(ElectricInfoModel *)electricInfoModel {
    _electricInfoModel = electricInfoModel;
    
    _nameLabel.text = electricInfoModel.deviceName;
    _currentValueLabel.text = [NSString stringWithFormat:@"%@ kwh", electricInfoModel.deviceIoValue];
}

// 每月抄表
- (void)monthValue {
    MonthMeterViewController *monthMeterVC = [[MonthMeterViewController alloc] init];
    if(_waterListModel != nil){
        monthMeterVC.waterListModel = _waterListModel;
    }else if (_electricInfoModel != nil) {
        monthMeterVC.electricInfoModel = _electricInfoModel;
    }
    [[self viewController].navigationController pushViewController:monthMeterVC animated:YES];
}

@end
