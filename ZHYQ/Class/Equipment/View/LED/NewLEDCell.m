//
//  NewLEDCell.m
//  ZHYQ
//
//  Created by coder on 2018/10/23.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "NewLEDCell.h"
#import "YQSwitch.h"

@interface NewLEDCell ()<switchTapDelegate>
{
    
    __weak IBOutlet UILabel *ledNameLab;
    __weak IBOutlet UILabel *clockTimeLab;
    __weak IBOutlet UIView *clockBgView;
    __weak IBOutlet UIImageView *clockView;
    
    __weak IBOutlet UILabel *_currentImgLabel;
    __weak IBOutlet NSLayoutConstraint *_currentImgTop;
    __weak IBOutlet UIImageView *screenshotView;
    
    __weak IBOutlet UILabel *_stateLabel;
    
    __weak IBOutlet UIButton *_playBt;
    __weak IBOutlet UIButton *_restartBt;
    __weak IBOutlet UIButton *_closeBt;
    
    YQSwitch *_yqSwitch;
    
    __weak IBOutlet UIButton *_currentProLabel;
    __weak IBOutlet UIButton *_resumeBt;
}

@end

@implementation NewLEDCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    screenshotView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lookScreenAction)];
    [screenshotView addGestureRecognizer:tap];
    
    _yqSwitch = [[YQSwitch alloc] initWithFrame:CGRectMake(KScreenWidth - 71, 18, 60, 30)];
    _yqSwitch.onText = @"ON";
    _yqSwitch.offText = @"OFF";
    _yqSwitch.backgroundColor = [UIColor clearColor];
    _yqSwitch.onTintColor = [UIColor colorWithHexString:@"6BDB6A"];
    _yqSwitch.tintColor = [UIColor colorWithHexString:@"FF4359"];
    _yqSwitch.switchDelegate = self;
    [self addSubview:_yqSwitch];
    
    _stateLabel.layer.cornerRadius = 5;
    _stateLabel.layer.masksToBounds = YES;
}

-(void)lookScreenAction
{
    if (self.delegate != nil&&[self.delegate respondsToSelector:@selector(lookScreenShotWithModel:)]) {
        [self.delegate lookScreenShotWithModel:_ledListModel];
    }
}

- (void)setLedListModel:(LedListModel *)ledListModel {
    _ledListModel = ledListModel;
    
    if(ledListModel.deviceType == nil){
        if(ledListModel.type != nil && ![ledListModel.type isKindOfClass:[NSNull class]] && [ledListModel.type isEqualToString:@"1"]){
            ledListModel.deviceType = @"14-1";
        }
    }
    
    ledNameLab.text = [NSString stringWithFormat:@"%@", ledListModel.deviceName];
    
    /*
     // 是否可操控
    if([ledListModel.type isEqualToString:@"1"]){
        // 可控制
        _yqSwitch.onTintColor = [UIColor colorWithHexString:@"6BDB6A"];
        _yqSwitch.tintColor = [UIColor colorWithHexString:@"FF4359"];
    }else {
        _yqSwitch.onTintColor = [UIColor grayColor];
        _yqSwitch.tintColor = [UIColor grayColor];
    }
     */
    
    if([ledListModel.status isEqualToString:@"1"]){
        // 在线
        _yqSwitch.on = YES;
        _stateLabel.text = @"已开启";
        _stateLabel.backgroundColor = [UIColor colorWithHexString:@"#009CF3"];
        
        screenshotView.userInteractionEnabled = YES;
        _playBt.enabled = NO;
        _restartBt.enabled = YES;
        _closeBt.enabled = YES;
        [_playBt setBackgroundImage:[UIImage imageNamed:@"led_closeOpen_enable_icon"] forState:UIControlStateNormal];
        [_restartBt setBackgroundImage:[UIImage imageNamed:@"led_restart_icon"] forState:UIControlStateNormal];
        [_closeBt setBackgroundImage:[UIImage imageNamed:@"led_close_icon"] forState:UIControlStateNormal];
        _resumeBt.enabled = YES;
    }else {
        // 离线
        _yqSwitch.on = NO;
        _stateLabel.text = @"关闭";
        _stateLabel.backgroundColor = [UIColor colorWithHexString:@"#A5A5A5"];
        
        screenshotView.userInteractionEnabled = NO;
        _playBt.enabled = YES;
        _restartBt.enabled = NO;
        _closeBt.enabled = NO;
        [_playBt setBackgroundImage:[UIImage imageNamed:@"led_play_icon"] forState:UIControlStateNormal];
        [_restartBt setBackgroundImage:[UIImage imageNamed:@"led_restart_enable_icon"] forState:UIControlStateNormal];
        [_closeBt setBackgroundImage:[UIImage imageNamed:@"led_closeOpen_enable_icon"] forState:UIControlStateNormal];
        _resumeBt.enabled = NO;
    }
    
    if(_ledListModel.program != nil && ![_ledListModel.program isKindOfClass:[NSNull class]] && ![_ledListModel.program isEqualToString:@"null"]){
        [_currentProLabel setTitle:[NSString stringWithFormat:@"%@", _ledListModel.program] forState:UIControlStateNormal];
    }else {
        [_currentProLabel setTitle:[NSString stringWithFormat:@"%@", @"无"] forState:UIControlStateNormal];
    }
    
//    _timeLabel.hidden = YES;
    
    // 路灯屏
    if([ledListModel.type isEqualToString:@"1"]){
        _playBt.enabled = NO;
        _closeBt.enabled = NO;
        [_playBt setBackgroundImage:[UIImage imageNamed:@"led_closeOpen_enable_icon"] forState:UIControlStateNormal];
        [_closeBt setBackgroundImage:[UIImage imageNamed:@"led_closeOpen_enable_icon"] forState:UIControlStateNormal];
        
        if([ledListModel.mainstatus isEqualToString:@"1"]){
            _yqSwitch.on = YES;
        }else {
            _yqSwitch.on = NO;
        }
        
//        _currentImgTop.constant = 30;
//        _currentImgLabel.hidden = YES;
//        screenshotView.hidden = YES;
    }else {
//        _currentImgTop.constant = 58;
//        _currentImgLabel.hidden = NO;
//        screenshotView.hidden = NO;
    }
}

-(void)switchTap:(BOOL)on {
    NSLog(@"%d", on);
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(ledSwitch:withModel:)]) {
        [self.delegate ledSwitch:_yqSwitch.on withModel:_ledListModel];
    }
}

- (IBAction)playAction:(id)sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(ledPlay:)]) {
        [self.delegate ledPlay:_ledListModel];
    }
}

- (IBAction)restartAction:(id)sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(ledRestart:)]) {
        [self.delegate ledRestart:_ledListModel];
    }
}

- (IBAction)closeAction:(id)sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(ledClose:)]) {
        [self.delegate ledClose:_ledListModel];
    }
}

- (IBAction)resumeDefault:(id)sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(resumeDefault:)]) {
        [self.delegate resumeDefault:_ledListModel];
    }
}


@end
