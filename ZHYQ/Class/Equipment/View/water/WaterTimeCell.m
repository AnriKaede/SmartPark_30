//
//  WaterTimeCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/3/8.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WaterTimeCell.h"
#import "YQSwitch.h"

@interface WaterTimeCell() <switchTapDelegate>
{
    
}
@end

@implementation WaterTimeCell
{
    
    __weak IBOutlet UILabel *_nameLabel;
    
    __weak IBOutlet UILabel *_rangeLabel;
    
    __weak IBOutlet YQSwitch *_yqSwitch;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _yqSwitch.onText = @"ON";
    _yqSwitch.offText = @"OFF";
    _yqSwitch.on = YES;
    _yqSwitch.backgroundColor = [UIColor clearColor];
    _yqSwitch.onTintColor = [UIColor colorWithHexString:@"6BDB6A"];
    _yqSwitch.tintColor = [UIColor colorWithHexString:@"FF4359"];
    _yqSwitch.switchDelegate = self;
}

-(void)switchTap:(BOOL)on {
    [_taskSwitchDelegate taskSwitch:_taskModel withOn:_yqSwitch.on];
}

- (void)setTaskModel:(ParkNightTaskModel *)taskModel {
    _taskModel = taskModel;
    
    _nameLabel.text = taskModel.TASKNAME;
    
    _rangeLabel.text = [NSString stringWithFormat:@"水分<%.1f%%开，水分>%.1f%%关", taskModel.lowValue.floatValue, taskModel.upValue.floatValue];
    
    // 是否启用 0不启用  1启用
    if([taskModel.ISVALID isEqualToString:@"0"]){
        _yqSwitch.on = NO;
    }else {
        _yqSwitch.on = YES;
    }
}

@end
