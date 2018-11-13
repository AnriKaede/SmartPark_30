//
//  AirConTableView_m
//  ZHYQ
//
//  Created by 焦平 on 2018/1/13.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "AirConTableViewCell.h"
#import "MeetRoomStateModel.h"

@interface AirConTableViewCell ()<switchTapDelegate>{
    
    __weak IBOutlet NSLayoutConstraint *_speedHeight;
    __weak IBOutlet NSLayoutConstraint *_speedWidth;
    
    __weak IBOutlet NSLayoutConstraint *_switchTop;
    
    __weak IBOutlet UIImageView *_airIconImgView;
    
    // 布局约束
    __weak IBOutlet NSLayoutConstraint *_modelLabelLeft;
    __weak IBOutlet NSLayoutConstraint *_modelLabelCen;
    
    __weak IBOutlet NSLayoutConstraint *_windIconLeft;
    __weak IBOutlet NSLayoutConstraint *_windIconCon;
    
    __weak IBOutlet NSLayoutConstraint *_speedIconLeft;
    __weak IBOutlet NSLayoutConstraint *_speedIconCon;
    
    __weak IBOutlet NSLayoutConstraint *_tempLabelCen;
    __weak IBOutlet NSLayoutConstraint *_tempLabelTop;
    
}
@end

@implementation AirConTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _openOrCloseSwitch.onText = @"ON";
    _openOrCloseSwitch.offText = @"OFF";
    _openOrCloseSwitch.on = YES;
    _openOrCloseSwitch.backgroundColor = [UIColor clearColor];
    _openOrCloseSwitch.onTintColor = [UIColor colorWithHexString:@"6BDB6A"];
    _openOrCloseSwitch.tintColor = [UIColor colorWithHexString:@"FF4359"];
    _openOrCloseSwitch.switchDelegate = self;
    
    _modelBt.layer.cornerRadius = 4;
    _modelBt.layer.borderWidth = 0.8;
    _modelBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    
    _speedBt.layer.cornerRadius = 4;
    _speedBt.layer.borderWidth = 0.8;
    _speedBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
}

#pragma mark 空调开关
-(void)switchTap:(BOOL)on {
    if(_switchDelegate && [_switchDelegate respondsToSelector:@selector(siwtchAir:withDeviceId:withOn:withModel:)]){
        [_switchDelegate siwtchAir:_model.stateModel.writeId withDeviceId:_model.DEVICE_ID withOn:_openOrCloseSwitch.on withModel:_model];
    }
}

- (void)switchState:(BOOL)on {
    if(on){
        _modelImgView.hidden = NO;
        _modelLab.hidden = NO;
        _tempLab.hidden = NO;
        _windSpeedImgView.hidden = NO;
        _windSpeedLab.hidden = NO;
        _speedImgView.hidden = NO;
        _speedLab.hidden = NO;
        
        _reduceBt.hidden = NO;
        _addBt.hidden = NO;
        _lineView.hidden = NO;
        _modelBt.hidden = NO;
        _speedBt.hidden = NO;
        
        _closeLab.hidden = YES;
        
        _stateLab.text = @"开启";
        _stateLab.textColor = [UIColor colorWithHexString:@"#189517"];
    }else {
        _modelImgView.hidden = YES;
        _modelLab.hidden = YES;
        _tempLab.hidden = YES;
        _windSpeedImgView.hidden = YES;
        _windSpeedLab.hidden = YES;
        _speedImgView.hidden = YES;
        _speedLab.hidden = YES;
        
        _reduceBt.hidden = YES;
        _addBt.hidden = YES;
        _lineView.hidden = YES;
        _modelBt.hidden = YES;
        _speedBt.hidden = YES;
        
        _closeLab.hidden = NO;
        
        _stateLab.text = @"关闭";
        _stateLab.textColor = [UIColor colorWithHexString:@"#FF4359"];
    }
}

-(void)setModel:(AirConditionModel *)model
{
    _model = model;
    
    _nameLab.text = [NSString stringWithFormat:@"%@",model.DEVICE_NAME];
    
    // 开关状态
    if(model.stateModel.value != nil && ![model.stateModel.value isKindOfClass:[NSNull class]] && [model.stateModel.value isEqualToString:@"0"]){
        _openOrCloseSwitch.on = NO;
        _stateLab.text = @"关闭中";
        _stateLab.textColor = [UIColor colorWithHexString:@"#FF4359"];
        _airIconImgView.image = [UIImage imageNamed:@"air_icon_close"];
    }else {
        _openOrCloseSwitch.on = YES;
        _stateLab.text = @"开启中";
        _stateLab.textColor = [UIColor colorWithHexString:@"#189517"];
        _airIconImgView.image = [UIImage imageNamed:@"air_icon"];
    }
    [self switchState:_openOrCloseSwitch.on];
    // 是否可控
    if(model.stateModel.actionType != nil && ![model.stateModel.actionType isKindOfClass:[NSNull class]] && [model.stateModel.actionType isEqualToString:@"1"]){
        _openOrCloseSwitch.enabled = YES;
    }else {
        _openOrCloseSwitch.enabled = NO;
    }
    
    // 风速
    if(model.windModel.value != nil && ![model.windModel.value isKindOfClass:[NSNull class]]){
        _speedWidth.constant = 25;
        _speedHeight.constant = 15;
        if([model.windModel.value isEqualToString:@"3"]){
            _windSpeedLab.text = @"低";
            _windSpeedImgView.image = [UIImage imageNamed:@"wind_low_icon"];
        }
        if([model.windModel.value isEqualToString:@"2"]){
            _windSpeedLab.text = @"中";
            _windSpeedImgView.image = [UIImage imageNamed:@"wind_medium_icon"];
        }
        if([model.windModel.value isEqualToString:@"1"]){
            _windSpeedLab.text = @"高";
            _windSpeedImgView.image = [UIImage imageNamed:@"wind_max_icon"];
        }
        if([model.windModel.value isEqualToString:@"0"]){
            _windSpeedLab.text = @"自动";
            _windSpeedImgView.image = [UIImage imageNamed:@"wind_auto_icon"];
            _speedWidth.constant = 20;
            _speedHeight.constant = 20;
        }
    }
    // 是否可控
    if(model.windModel.actionType != nil && ![model.windModel.actionType isKindOfClass:[NSNull class]] && [model.windModel.actionType isEqualToString:@"1"]){
        _speedBt.enabled = YES;
        [_speedBt setImage:[UIImage imageNamed:@"air_wind_speed_blue_icon"] forState:UIControlStateNormal];
        [_speedBt setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
        _speedBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    }else {
        _speedBt.enabled = NO;
        [_speedBt setImage:[UIImage imageNamed:@"air_wind_speed_gray_icon"] forState:UIControlStateNormal];
        [_speedBt setTitleColor:[UIColor colorWithHexString:@"#A8A8A8"] forState:UIControlStateNormal];
        _speedBt.layer.borderColor = [UIColor colorWithHexString:@"#A8A8A8"].CGColor;
    }
    
    // 模式
    if(model.modelModel.value != nil && ![model.modelModel.value isKindOfClass:[NSNull class]]){
        if([model.modelModel.value isEqualToString:@"1"]){
            _modelLab.text = @"制热";
            _modelImgView.image = [UIImage imageNamed:@"air_hot_icon"];
        }
        if([model.modelModel.value isEqualToString:@"2"]){
            _modelLab.text = @"制冷";
            _modelImgView.image = [UIImage imageNamed:@"air_cold_icon"];
        }
        if([model.modelModel.value isEqualToString:@"4"]){
            _modelLab.text = @"除湿";
            _modelImgView.image = [UIImage imageNamed:@"air_wet_icon"];
        }
        if([model.modelModel.value isEqualToString:@"3"]){
            _modelLab.text = @"通风";
            _modelImgView.image = [UIImage imageNamed:@"air_wind_icon"];
        }
    }
    if(model.modelModel.actionType != nil && ![model.modelModel.actionType isKindOfClass:[NSNull class]] && [model.modelModel.actionType isEqualToString:@"1"]){
        _modelBt.enabled = YES;
        [_modelBt setImage:[UIImage imageNamed:@"air_model_change"] forState:UIControlStateNormal];
        [_modelBt setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
        _modelBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    }else {
        _modelBt.enabled = NO;
        [_modelBt setImage:[UIImage imageNamed:@"air_model_change_uneble"] forState:UIControlStateNormal];
        [_modelBt setTitleColor:[UIColor colorWithHexString:@"#A8A8A8"] forState:UIControlStateNormal];
        _modelBt.layer.borderColor = [UIColor colorWithHexString:@"#A8A8A8"].CGColor;
    }
    
    // 温度
    if(model.tempModel.value != nil && ![model.tempModel.value isKindOfClass:[NSNull class]]){
        _tempLab.text = [NSString stringWithFormat:@"%@℃", model.tempModel.value];
    }
    // 是否可控
    if(model.tempModel.actionType != nil && ![model.tempModel.actionType isKindOfClass:[NSNull class]] && [model.tempModel.actionType isEqualToString:@"1"]){
        _reduceBt.enabled = YES;
        [_reduceBt setBackgroundImage:[UIImage imageNamed:@"air_speed_reduce"] forState:UIControlStateNormal];
        _addBt.enabled = YES;
        [_addBt setBackgroundImage:[UIImage imageNamed:@"air_speed_add"] forState:UIControlStateNormal];
    }else {
        _reduceBt.enabled = NO;
        [_reduceBt setBackgroundImage:[UIImage imageNamed:@"air_speed_reduce_unable"] forState:UIControlStateNormal];
        _addBt.enabled = NO;
        [_addBt setBackgroundImage:[UIImage imageNamed:@"air_speed_add_unable"] forState:UIControlStateNormal];
    }
    
    // 是否故障
    if(model.failureModel.value != nil && ![model.failureModel.value isKindOfClass:[NSNull class]] && ![model.failureModel.value isEqualToString:@"0"]){
        _stateLab.text = @"故障";
        _stateLab.textColor = [UIColor grayColor];
    }
    
    // 模式隐藏/显示view
    if(model.isSeparate){
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"F8FCFF"];
        if(model.stateModel.value != nil && ![model.stateModel.value isKindOfClass:[NSNull class]] && ![model.stateModel.value isEqualToString:@"0"]){
            _openOrCloseSwitch.on = YES;
            _modelImgView.hidden = NO;
            _modelLab.hidden = NO;
            _tempLab.hidden = NO;
            _windSpeedImgView.hidden = NO;
            _windSpeedLab.hidden = NO;
            _speedImgView.hidden = NO;
            _speedLab.hidden = NO;
            
            _reduceBt.hidden = NO;
            _addBt.hidden = NO;
            _lineView.hidden = NO;
            _modelBt.hidden = NO;
            _speedBt.hidden = NO;
            
            _closeLab.hidden = YES;
            _switchTop.constant = 50;
            
            // 判断是否有控制权限
            [self judgementCon];
        }else {
            _openOrCloseSwitch.on = NO;
            _modelImgView.hidden = YES;
            _modelLab.hidden = YES;
            _tempLab.hidden = YES;
            _windSpeedImgView.hidden = YES;
            _windSpeedLab.hidden = YES;
            _speedImgView.hidden = YES;
            _speedLab.hidden = YES;
            
            _reduceBt.hidden = YES;
            _addBt.hidden = YES;
            _lineView.hidden = YES;
            _modelBt.hidden = YES;
            _speedBt.hidden = YES;
            
            _closeLab.hidden = NO;
            _switchTop.constant = 20;
        }
        _selectView.hidden = NO;
        _openOrCloseSwitch.hidden = NO;
    }else {
        self.contentView.backgroundColor = [UIColor whiteColor];
        _modelImgView.hidden = YES;
        _modelLab.hidden = YES;
        _tempLab.hidden = YES;
        _windSpeedImgView.hidden = YES;
        _windSpeedLab.hidden = YES;
        _speedImgView.hidden = YES;
        _speedLab.hidden = YES;
        
        _selectView.hidden = YES;
        _openOrCloseSwitch.hidden = YES;
        
        _closeLab.hidden = YES;
        
        _reduceBt.hidden = YES;
        _addBt.hidden = YES;
        _lineView.hidden = YES;
        _modelBt.hidden = YES;
        _speedBt.hidden = YES;
    }
    
}
- (void)judgementCon {
    // 根据是否有权限显示隐藏view
    if((_model.modelModel.actionType != nil && ![_model.modelModel.actionType isKindOfClass:[NSNull class]] && [_model.modelModel.actionType isEqualToString:@"1"]) ||
       (_model.tempModel.actionType != nil && ![_model.tempModel.actionType isKindOfClass:[NSNull class]] && [_model.tempModel.actionType isEqualToString:@"1"]) ||
       (_model.windModel.actionType != nil && ![_model.windModel.actionType isKindOfClass:[NSNull class]] && [_model.windModel.actionType isEqualToString:@"1"])){
        // 有模式、温度、风速权限
        [self controlView:YES];
    }else {
        [self controlView:NO];
    }
}
- (void)controlView:(BOOL)isCon {
    
    _reduceBt.hidden = !isCon;
    _addBt.hidden = !isCon;
    _lineView.hidden = !isCon;
    _modelBt.hidden = !isCon;
    _speedBt.hidden = !isCon;
    
    if(isCon){
        // 可控
        _modelLabelLeft.constant = 10;
        _modelLabelCen.constant = 0;
        
        _windIconLeft.constant = 50;
        _windIconCon.constant = 0;
        
        _speedIconLeft.constant = 15;
        _speedIconCon.constant = 0;
        
        _tempLabelCen.constant = 0;
        _tempLabelTop.constant = 25;
        
        _switchTop.constant = 50;
    }else {
        // 不可控
        _modelLabelLeft.constant = -30;
        _modelLabelCen.constant = 45;
        
        _windIconLeft.constant = 150;
        _windIconCon.constant = -2;
        
        _speedIconLeft.constant = -58;
        _speedIconCon.constant = 40;
        
        _tempLabelCen.constant = -80;
        _tempLabelTop.constant = -8;

        _switchTop.constant = 42;
    }
}

#pragma mark 空调控制
- (IBAction)reduceAction:(id)sender {
    NSString *tepmStr = _tempLab.text;
    tepmStr = [tepmStr stringByReplacingOccurrencesOfString:@"℃" withString:@""];
    if(tepmStr != nil && tepmStr.length > 0){
        NSInteger tempValue = tepmStr.integerValue - 1;
        [self tepmCut:[NSString stringWithFormat:@"%ld", tempValue]];
    }
}
- (IBAction)addAction:(id)sender {
    NSString *tepmStr = _tempLab.text;
    tepmStr = [tepmStr stringByReplacingOccurrencesOfString:@"℃" withString:@""];
    if(tepmStr != nil && tepmStr.length > 0){
        NSInteger tempValue = tepmStr.integerValue + 1;
        [self tepmCut:[NSString stringWithFormat:@"%ld", tempValue]];
    }
}
- (void)tepmCut:(NSString *)tepmStr {
    if(_switchDelegate && [_switchDelegate respondsToSelector:@selector(tempCut:withWriteId:withDeviceId:withModel:)]){
        [_switchDelegate tempCut:tepmStr withWriteId:_model.tempModel.writeId withDeviceId:_model.DEVICE_ID withModel:_model];
    }
}

#pragma mark 模式切换
- (IBAction)modelAction:(id)sender {
    if(_switchDelegate && [_switchDelegate respondsToSelector:@selector(modelCut:withDeviceId:withModel:)]){
        [_switchDelegate modelCut:_model.modelModel.writeId withDeviceId:_model.DEVICE_ID withModel:_model];
    }
}
#pragma mark 风速控制
- (IBAction)speedAction:(id)sender {
    if(_switchDelegate && [_switchDelegate respondsToSelector:@selector(speedCut:withDeviceId:withModel:)]){
        [_switchDelegate speedCut:_model.windModel.writeId withDeviceId:_model.DEVICE_ID withModel:_model];
    }
}

@end
