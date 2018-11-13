//
//  FrontGroundTableViewCell.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/27.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "FrontGroundTableViewCell.h"

@implementation FrontGroundTableViewCell
{
    __weak IBOutlet UILabel *_parkNameLabel;
    __weak IBOutlet UILabel *_stateLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setParkLockModel:(ParkLockModel *)parkLockModel {
    _parkLockModel = parkLockModel;
    
    if(parkLockModel.lockName != nil && ![parkLockModel.lockName isKindOfClass:[NSNull class]]){
        _parkNameLabel.text = [NSString stringWithFormat:@"%@", parkLockModel.lockName];
    }else {
        _parkNameLabel.text = @"-";
    }
    
    // 0空闲(降下) 1占用(降下) 2预约中(升起)  92异常(不能操作)
    if([parkLockModel.lockFlag isEqualToString:@"0"]){
        _stateLabel.textColor = [UIColor colorWithHexString:@"#189517"];
        _stateLabel.text = @"暂未停车";
    }else if([parkLockModel.lockFlag isEqualToString:@"1"]){
        _stateLabel.textColor = [UIColor colorWithHexString:@"#FF4359"];
        _stateLabel.text = @"已停车";
    }else if([parkLockModel.lockFlag isEqualToString:@"2"]){
        _stateLabel.textColor = [UIColor colorWithHexString:@"#FFB400"];
        _stateLabel.text = @"预约中";
    }else if([parkLockModel.lockFlag isEqualToString:@"92"]){
        _stateLabel.textColor = [UIColor colorWithHexString:@"#FF4359"];
        _stateLabel.text = @"异常";
    }else {
        _stateLabel.text = @"-";
    }
}

@end
