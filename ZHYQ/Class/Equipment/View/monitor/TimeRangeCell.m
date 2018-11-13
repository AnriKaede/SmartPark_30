//
//  TimeRangeCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/9.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "TimeRangeCell.h"

@implementation TimeRangeCell
{
    __weak IBOutlet UILabel *_timeLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _timeLabel.layer.borderColor = [UIColor grayColor].CGColor;
    _timeLabel.layer.borderWidth = 0.3;
    _timeLabel.layer.cornerRadius = 3;
}

- (void)setCellTimeRange:(NSString *)cellTimeRange {
    _cellTimeRange = cellTimeRange;
    
    _timeLabel.text = cellTimeRange;
}

@end
