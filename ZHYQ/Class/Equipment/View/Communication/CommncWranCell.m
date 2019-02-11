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
    [self wranLevel:wranModel.alarmLevelName withLevel:wranModel.alarmLevel];
    if(wranModel.equipName != nil && ![wranModel.equipName isKindOfClass:[NSNull class]]){
        _wranEquLabel.text = [NSString stringWithFormat:@"%@", wranModel.equipName];
    }else {
        _wranEquLabel.text = @"-";
    }
    _wranCodeLabel.text = [NSString stringWithFormat:@"%@", wranModel.equipSn];
    if(wranModel.runingStatusName != nil && ![wranModel.runingStatusName isKindOfClass:[NSNull class]]){
        _wranStateLabel.text = [NSString stringWithFormat:@"%@", wranModel.runingStatusName];
    }else {
        _wranStateLabel.text = @"-";
    }
    if(wranModel.serviceValue != nil && ![wranModel.serviceValue isKindOfClass:[NSNull class]]){
        _valueLabel.text = [NSString stringWithFormat:@"%@", wranModel.serviceValue];
    }else {
        _valueLabel.text = @"-";
    }
    _wranTimeLabel.text = [NSString stringWithFormat:@"%@", wranModel.triggerDate];
    _wranRepTimeLabel.text = [NSString stringWithFormat:@"%@", wranModel.reportDate];
    _wranAddressLabel.text = [NSString stringWithFormat:@"%@", wranModel.addressInfo];
}

- (void)wranLevel:(NSString *)levelName withLevel:(NSNumber *)level{
    
    _wranLevelNameLabel.text = [NSString stringWithFormat:@"%@", levelName];
    if(level != nil && ![level isKindOfClass:[NSNull class]]){
        if(level.integerValue == 1){
            _wranLevelNameLabel.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
        }else if(level.integerValue == 2){
            _wranLevelNameLabel.backgroundColor = [UIColor colorWithHexString:@"#F39800"];
        }else if(level.integerValue == 3){
            _wranLevelNameLabel.backgroundColor = [UIColor colorWithHexString:@"#E60012"];
        }
    }
}

@end
