//
//  ParkLightTaskCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/27.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ParkLightTaskCell.h"
#import "YQSwitch.h"

@interface ParkLightTaskCell ()<switchTapDelegate>
{
    
}
@end

@implementation ParkLightTaskCell
{
    __weak IBOutlet UILabel *_nameLabel;
    
    __weak IBOutlet UILabel *_rangeLabel;
    
    __weak IBOutlet UILabel *_dayTimeLabel;
    
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

- (void)setParkTaskModel:(ParkNightTaskModel *)parkTaskModel {
    _parkTaskModel = parkTaskModel;
    
    _nameLabel.text = parkTaskModel.TASKNAME;
    
    // 任务类型  1 每天 2 每周
    if([parkTaskModel.JOBTYPE isEqualToString:@"1"]){
        _dayTimeLabel.hidden = YES;
        _rangeLabel.text = [NSString stringWithFormat:@"每天%@-%@开灯", parkTaskModel.BEGIN_TIME, parkTaskModel.END_TIME];
    }else {
        _rangeLabel.text = [self weekWithDays:parkTaskModel.JOBDURATION];
        _dayTimeLabel.hidden = NO;
        _dayTimeLabel.text = [NSString stringWithFormat:@"每天%@-%@开灯", parkTaskModel.BEGIN_TIME, parkTaskModel.END_TIME];
    }
    
    // 是否启用 0不启用  1启用
    if([parkTaskModel.ISVALID isEqualToString:@"0"]){
        _yqSwitch.on = NO;
    }else {
        _yqSwitch.on = YES;
    }
}

#pragma mark Switch 协议
-(void)switchTap:(BOOL)on {
    if(_taskSwitchDelegate){
        [_taskSwitchDelegate taskSwitch:_parkTaskModel withOn:_yqSwitch.on];
    }
}

#pragma mark 字符串分割
- (NSString *)weekWithDays:(NSString *)dayStr {
    if(dayStr == nil || [dayStr isKindOfClass:[NSNull class]]){
        return @"星期 ";
    }
    
    NSMutableString *weekStr = @"".mutableCopy;
    NSArray *weekDayStr = @[@" 一", @" 二", @" 三", @" 四", @" 五", @" 六", @" 日"];
    for (int i=0; i<dayStr.length; i++) {
        NSString *chartStr = [dayStr substringWithRange:NSMakeRange(i, 1)];
        if(chartStr.integerValue == 1){
            if(i < weekDayStr.count){
                [weekStr appendString:weekDayStr[i]];
            }
        }
    }
    
    weekStr = [NSString stringWithFormat:@"星期%@", weekStr].mutableCopy;
    
    return weekStr;
}

@end
