//
//  CheckTaskHomeCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/7.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "CheckTaskHomeCell.h"

@implementation CheckTaskHomeCell
{
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UILabel *_timeLabel;
    __weak IBOutlet UILabel *_contenntLabel;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setTaskModel:(OverTaskModel *)taskModel {
    _taskModel = taskModel;
    
    _nameLabel.text = [NSString stringWithFormat:@"%@", taskModel.taskName];
    if(taskModel.beginTime != nil && [taskModel.beginTime isKindOfClass:[NSNumber class]]){
        _timeLabel.text = [Utils timeStrWithInt:taskModel.beginTime];
    }else {
        _timeLabel.text = @"";
    }
    _contenntLabel.text = [NSString stringWithFormat:@"%@", taskModel.taskDesc];
}

@end
