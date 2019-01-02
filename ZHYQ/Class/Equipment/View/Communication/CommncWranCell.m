//
//  CommncWranCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/24.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "CommncWranCell.h"

@implementation CommncWranCell
{
    __weak IBOutlet UILabel *_wranNameLabel;
    __weak IBOutlet UILabel *_wranLevelNameLabel;
    __weak IBOutlet UILabel *_wranEquLabel;
    __weak IBOutlet UILabel *_wranCodeLabel;
    __weak IBOutlet UILabel *_wranStateLabel;
    __weak IBOutlet UILabel *_valueLabel;
    __weak IBOutlet UILabel *_wranTimeLabel;
    __weak IBOutlet UILabel *_wranRepTimeLabel;
    __weak IBOutlet UILabel *_wranAddressLabel;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setWranModel:(CommncWranModel *)wranModel {
    _wranModel = wranModel;
    
    _wranNameLabel.text = [NSString stringWithFormat:@"%@", wranModel.serviceName];
    _wranLevelNameLabel.text = [NSString stringWithFormat:@"%@", wranModel.alarmLevel];
    _wranEquLabel.text = [NSString stringWithFormat:@"%@", wranModel.equipName];
    _wranCodeLabel.text = [NSString stringWithFormat:@"%@", wranModel.equipSn];
    _wranStateLabel.text = [NSString stringWithFormat:@"%@", wranModel.runingStatusName];
    _valueLabel.text = [NSString stringWithFormat:@"%@", wranModel.serviceValue];
    _wranTimeLabel.text = [NSString stringWithFormat:@"%@", wranModel.triggerDate];
    _wranRepTimeLabel.text = [NSString stringWithFormat:@"%@", wranModel.reportDate];
    _wranAddressLabel.text = [NSString stringWithFormat:@"%@", wranModel.addressInfo];
}

@end
