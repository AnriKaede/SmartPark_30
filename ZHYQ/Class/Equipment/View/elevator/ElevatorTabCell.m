//
//  ElevatorTabCell.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ElevatorTabCell.h"
#import "YQSwitch.h"

@implementation ElevatorTabCell
{
    __weak IBOutlet UIView *_topView;
    
    __weak IBOutlet UIImageView *_bgImgView;
    
    __weak IBOutlet UILabel *_nameLabel;
    
    __weak IBOutlet UIImageView *_stateImgView;
    
    __weak IBOutlet NSLayoutConstraint *_stateImgHeight;
    __weak IBOutlet NSLayoutConstraint *_stateImgWidth;
    
    __weak IBOutlet UILabel *_stateLabel;
    
    __weak IBOutlet UILabel *_placeLabel;
    
    __weak IBOutlet UILabel *_musicLabel;
    
    __weak IBOutlet UIButton *_monitorBt;
    
    __weak IBOutlet UILabel *_musicStateLabel;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _stateLabel.textColor = [UIColor whiteColor];
    _stateLabel.layer.masksToBounds = YES;
    _stateLabel.layer.cornerRadius = 4;
    
    _placeLabel.font = [UIFont fontWithName:@"DBLCDTempBlack" size:18];
}

#pragma mark 浇灌的开关
-(void)_elevatorOnOrOffClick:(id)sender
{
    YQSwitch *yqswitch = (YQSwitch *)sender;
    _elevatorModel.isOpenMusic = yqswitch.on;
    if (yqswitch.on) {
        DLog(@"YES");
    }else{
        DLog(@"NO");
    }
}

- (void)setElevatorModel:(ElevatorModel *)elevatorModel {
    
    // 动画
    if(_elevatorModel != nil){
        [self animotionFloorNum:elevatorModel];
    }
    
    _elevatorModel = elevatorModel;
    
    _nameLabel.text = elevatorModel.DEVICE_NAME;
    /*
    if([elevatorModel.EQUIP_STATUS isEqualToString:@"1"]){  // 正常
        _stateLabel.hidden = YES;
        self.backgroundColor = [UIColor whiteColor];
        _bgImgView.backgroundColor = [UIColor whiteColor];
    }else if([elevatorModel.EQUIP_STATUS isEqualToString:@"0"]){  // 故障
        _stateLabel.hidden = NO;
        _stateLabel.backgroundColor = [UIColor colorWithHexString:@"#FF4359"];
        _stateLabel.text = @"故障";
        _topView.backgroundColor = [UIColor colorWithHexString:@"#FF4359"];
        _bgImgView.backgroundColor = [UIColor colorWithHexString:@"#FFF8F9"];
    }else if([elevatorModel.EQUIP_STATUS isEqualToString:@"2"]){  // 离线
        _stateLabel.hidden = NO;
        _stateLabel.backgroundColor = [UIColor grayColor];
        _stateLabel.text = @"离线";
        _topView.backgroundColor = [UIColor grayColor];
        _bgImgView.backgroundColor = [UIColor colorWithHexString:@"eff1f5"];
    }
     */
    
    _stateImgView.image = [UIImage imageNamed:@"elevator_stop_icon"];
    _stateImgHeight.constant = 23;
    _stateImgWidth.constant = 30;
    
    if([elevatorModel.runState isEqualToString:@"4"]){
        _stateImgView.image = [UIImage imageNamed:@"elevator_up_icon"];
    }else if([elevatorModel.runState isEqualToString:@"2"]){
        _stateImgView.image = [UIImage imageNamed:@"elevator_down_icon"];
    }else if([elevatorModel.runState isEqualToString:@"1"]){
        _stateImgView.image = [UIImage imageNamed:@"elevator_stop_icon"];
    }
    
    if([elevatorModel.warnState isEqualToString:@"1"]){  // 正常
        _stateLabel.hidden = YES;
        self.backgroundColor = [UIColor whiteColor];
        _bgImgView.backgroundColor = [UIColor whiteColor];
    }else if([elevatorModel.warnState isEqualToString:@"8"]){  // 故障
        _stateImgView.image = [UIImage imageNamed:@"elevator_warn_icon"];
//        _stateLabel.hidden = NO;
        _stateLabel.backgroundColor = [UIColor colorWithHexString:@"#FF4359"];
        _stateLabel.text = @"故障";
        _topView.backgroundColor = [UIColor colorWithHexString:@"#FF4359"];
        _bgImgView.backgroundColor = [UIColor colorWithHexString:@"#FFF8F9"];
    }else {  // 默认正常
        _stateLabel.hidden = YES;
        self.backgroundColor = [UIColor whiteColor];
        _bgImgView.backgroundColor = [UIColor whiteColor];
    }
    
//    _musicLabel.text = @"无参数";
//    _musicStateLabel.text = @"无参数";
    
    [self fullFloorNum:elevatorModel];
}

- (void)animotionFloorNum:(ElevatorModel *)elevatorModel {
    NSString *floorNum = [NSString stringWithFormat:@"%@", elevatorModel.floorNum];
    if([floorNum isEqualToString:@"0"]){
        floorNum = @"-1";
    }
    if(_elevatorModel.floorNum != nil && ![_elevatorModel.floorNum isKindOfClass:[NSNull class]] && elevatorModel.floorNum != nil && ![elevatorModel.floorNum isKindOfClass:[NSNull class]] && ![floorNum isEqualToString:_placeLabel.text]){
        
        CATransition *transtion = [CATransition animation];
        transtion.duration = 0.5;
        [transtion setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        [transtion setType:@"cube"];
        if(floorNum.integerValue > _placeLabel.text.integerValue){
            [transtion setSubtype:kCATransitionFromTop];
        }else {
            [transtion setSubtype:kCATransitionFromBottom];
        }
        [_placeLabel.layer addAnimation:transtion forKey:@"transtionKey"];
        
    }
}

// 更新楼层数
- (void)fullFloorNum:(ElevatorModel *)elevatorModel {
    NSString *floorStr = @"";
    if(elevatorModel.floorNum != nil && ![elevatorModel.floorNum isKindOfClass:[NSNull class]]){
        if([elevatorModel.floorNum isEqualToString:@"0"]){
            floorStr = @"-1";
        }else {
            floorStr = [NSString stringWithFormat:@"%@", elevatorModel.floorNum];
        }
        
    }else {
        floorStr = @"-";
    }
    _placeLabel.text = [NSString stringWithFormat:@"%@", floorStr];
}

- (IBAction)playMonitor:(id)sender {
    if(_elevatorDelegate && [_elevatorDelegate respondsToSelector:@selector(elevatorMonitor:)]){
        [_elevatorDelegate elevatorMonitor:_elevatorModel];
    }
}

@end
