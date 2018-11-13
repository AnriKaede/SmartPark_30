//
//  WifiStateCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/10/26.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WifiStateCell.h"

@implementation WifiStateCell
{
    __weak IBOutlet UILabel *_allNumLabel;
    
    __weak IBOutlet UILabel *_unlineNumLabel;
    __weak IBOutlet UILabel *_warnNumLabel;
    __weak IBOutlet UILabel *_entrustNumLabel;
    __weak IBOutlet UILabel *_onlineNumLabel;
    
    __weak IBOutlet NSLayoutConstraint *_unlineWidth;
    __weak IBOutlet NSLayoutConstraint *_wranWidth;
    __weak IBOutlet NSLayoutConstraint *_entrustWidth;
    __weak IBOutlet NSLayoutConstraint *_onlineWidth;
    // x 210  right 47
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setApNumModel:(APNumModel *)apNumModel {
    _apNumModel = apNumModel;
    
    _allNumLabel.text = [NSString stringWithFormat:@"%@", apNumModel.APtotal];
    _unlineNumLabel.text = [NSString stringWithFormat:@"%@", apNumModel.outNum];
    _warnNumLabel.text = [NSString stringWithFormat:@"%@", apNumModel.alarmNum];
    _entrustNumLabel.text = [NSString stringWithFormat:@"%@", apNumModel.trusteeshipNum];
    _onlineNumLabel.text = [NSString stringWithFormat:@"%@", apNumModel.okNum];
    
    if(apNumModel != nil){
        _unlineWidth.constant = apNumModel.outNum.floatValue/apNumModel.APtotal.floatValue * (KScreenWidth-257);
        _wranWidth.constant = apNumModel.alarmNum.floatValue/apNumModel.APtotal.floatValue * (KScreenWidth-257);
        _entrustWidth.constant = apNumModel.trusteeshipNum.floatValue/apNumModel.APtotal.floatValue * (KScreenWidth-257);
        _onlineWidth.constant = apNumModel.okNum.floatValue/apNumModel.APtotal.floatValue * (KScreenWidth-257);
    }
}

@end
