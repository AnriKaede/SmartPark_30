//
//  InquiryDeviceTableViewCell.m
//  ZHYQ
//
//  Created by 焦平 on 2018/4/19.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "InquiryDeviceTableViewCell.h"

@interface InquiryDeviceTableViewCell()
{
    __weak IBOutlet UILabel *carameNameLab;
    
    __weak IBOutlet UILabel *carameIDLab;
}

@end

@implementation InquiryDeviceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setDeviceInfoModel:(DeviceInfoModel *)deviceInfoModel {
    _deviceInfoModel = deviceInfoModel;
    
    carameNameLab.text = [NSString stringWithFormat:@"%@", deviceInfoModel.DEVICE_NAME];
    carameIDLab.text = [NSString stringWithFormat:@"%@", deviceInfoModel.DEVICE_ID];
    
}

@end
