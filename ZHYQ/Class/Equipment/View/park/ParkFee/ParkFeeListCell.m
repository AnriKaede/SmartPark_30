//
//  ParkFeeListCell.m
//  ZHYQ
//
//  Created by coder on 2018/10/24.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "ParkFeeListCell.h"

@implementation ParkFeeListCell
{
    __weak IBOutlet UILabel *_dayTitleLabel;
    __weak IBOutlet UILabel *_timeLabel;
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setParkConsumeModel:(ParkConsumeModel *)parkConsumeModel {
    _parkConsumeModel = parkConsumeModel;
    
    
}

@end
