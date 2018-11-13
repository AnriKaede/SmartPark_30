//
//  WifiUserInfoCell.m
//  ZHYQ
//
//  Created by coder on 2018/10/25.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WifiUserInfoCell.h"

@implementation WifiUserInfoCell
{
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UILabel *_ipLabel;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setWifiUserModel:(WifiUserModel *)wifiUserModel {
    _wifiUserModel = wifiUserModel;
    
    if(wifiUserModel.computer != nil && ![wifiUserModel.computer isKindOfClass:[NSNull class]] && wifiUserModel.computer.length > 0){
        _nameLabel.text = [NSString stringWithFormat:@"%@", wifiUserModel.computer];
    }else {
        _nameLabel.text = [NSString stringWithFormat:@"%@", wifiUserModel.username];
    }
    
    _ipLabel.text = [NSString stringWithFormat:@"%@", wifiUserModel.ip];
}

@end
