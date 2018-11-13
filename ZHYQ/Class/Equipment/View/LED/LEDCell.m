//
//  LEDCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "LEDCell.h"
#import "YQSwitch.h"
#import "LEDDetailViewController.h"
#import "ParkTimeViewController.h"

@interface LEDCell()<switchTapDelegate>
{
    
}
@end

@implementation LEDCell
{
    __weak IBOutlet UILabel *_ledName;
    YQSwitch *_yqSwitch;
    
    __weak IBOutlet UIView *_clockView;
    __weak IBOutlet UILabel *_timeLabel;
    
    __weak IBOutlet UIButton *_viewDetailBt;
    
    __weak IBOutlet UILabel *_msgLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _yqSwitch = [[YQSwitch alloc] initWithFrame:CGRectMake(KScreenWidth - 76, 20, 60, 30)];
    _yqSwitch.onText = @"ON";
    _yqSwitch.offText = @"OFF";
    _yqSwitch.backgroundColor = [UIColor clearColor];
    _yqSwitch.onTintColor = [UIColor colorWithHexString:@"6BDB6A"];
    _yqSwitch.tintColor = [UIColor colorWithHexString:@"FF4359"];
//    [_yqSwitch addTarget:self action:@selector(_ledOnOrOffClick:) forControlEvents:UIControlEventValueChanged];
    _yqSwitch.switchDelegate = self;
    [self addSubview:_yqSwitch];
    
    UITapGestureRecognizer *clockTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(colockClick)];
    _clockView.userInteractionEnabled = YES;
    [_clockView addGestureRecognizer:clockTap];
}

- (void)setLedListModel:(LedListModel *)ledListModel {
    _ledListModel = ledListModel;
    
    _ledName.text = ledListModel.deviceName;
    
    if([ledListModel.type isEqualToString:@"1"]){
        // 可控制
        _yqSwitch.onTintColor = [UIColor colorWithHexString:@"6BDB6A"];
        _yqSwitch.tintColor = [UIColor colorWithHexString:@"FF4359"];
    }else {
        _yqSwitch.onTintColor = [UIColor grayColor];
        _yqSwitch.tintColor = [UIColor grayColor];
    }
    
    if([ledListModel.status isEqualToString:@"0"]){
        // 离线
        _yqSwitch.on = NO;
    }else {
        // 在线
        _yqSwitch.on = YES;
    }
    
    _timeLabel.hidden = YES;
}

// 设置闹钟
- (void)colockClick {
    if([_ledListModel.type isEqualToString:@"1"]){
        ParkTimeViewController *parkTimeVC = [[ParkTimeViewController alloc] init];
        parkTimeVC.timeTaskType = LEDTask;
        parkTimeVC.navTitle = @"LED屏定时开关";
        parkTimeVC.tagId = _ledListModel.tagid;
        [[self viewController].navigationController pushViewController:parkTimeVC animated:YES];
    }else{
        [[self viewController] showHint:@"此LED屏不支持定时操作"];
    }
}

// 查看详情
- (IBAction)viewDetail:(id)sender {
    
    /*
    LEDDetailViewController *LEDDetailVC = [[LEDDetailViewController alloc] init];
    [[self viewController].navigationController pushViewController:LEDDetailVC animated:YES];
     */
}

// 开关方法
-(void)switchTap:(BOOL)on {
    if(_ledSwitchDelegate && [_ledSwitchDelegate respondsToSelector:@selector(ledSwitch:withOn:)]){
        [_ledSwitchDelegate ledSwitch:_ledListModel withOn:_yqSwitch.on];
    }
}

@end
