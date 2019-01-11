//
//  WranHomeCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/7.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "WranHomeCell.h"

@implementation WranHomeCell
{
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UILabel *_timeLabel;
    __weak IBOutlet UILabel *_contenntLabel;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setDetailWranModel:(OverDetailWranModel *)detailWranModel {
    _detailWranModel = detailWranModel;
    
    _nameLabel.text = [NSString stringWithFormat:@"%@", detailWranModel.reportName];
    _timeLabel.text = [NSString stringWithFormat:@"%@", detailWranModel.alarmTime];
    _contenntLabel.text = [NSString stringWithFormat:@"%@", detailWranModel.alarmInfo];
}

@end
