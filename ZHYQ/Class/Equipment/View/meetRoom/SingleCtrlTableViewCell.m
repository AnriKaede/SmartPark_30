//
//  SingleCtrlTableViewCell.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/28.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "SingleCtrlTableViewCell.h"

#import "YQSwitch.h"
#import "YQSlider.h"

@interface SingleCtrlTableViewCell()<switchTapDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *typeImageView;
@property (weak, nonatomic) IBOutlet UILabel *typeNameLab;
@property (weak, nonatomic) IBOutlet UILabel *adjustNumLab;

@property (weak, nonatomic) IBOutlet YQSwitch *singleCtrlSwitch;

@property (weak, nonatomic) IBOutlet YQSlider *singleCtrlSlider;

// 空调
@property (weak, nonatomic) IBOutlet UIView *airBgView;

@property (weak, nonatomic) IBOutlet UIImageView *modelImgView;
@property (weak, nonatomic) IBOutlet UILabel *modelLab;
@property (weak, nonatomic) IBOutlet UILabel *tempLab;
@property (weak, nonatomic) IBOutlet UIImageView *windSpeedImgView;
@property (weak, nonatomic) IBOutlet UILabel *windSpeedLab;

@property (weak, nonatomic) IBOutlet UIImageView *speedImgView;
@property (weak, nonatomic) IBOutlet UILabel *speedLab;

@property (weak, nonatomic) IBOutlet UIButton *reduceBt;
@property (weak, nonatomic) IBOutlet UIButton *addBt;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *speedWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *speedHeight;

@property (weak, nonatomic) IBOutlet UIView *conBgView;

@property (weak, nonatomic) IBOutlet UIButton *modelBt;
@property (weak, nonatomic) IBOutlet UIButton *speedBt;

@property (weak, nonatomic) IBOutlet UIView *airLineView;

@end

@implementation SingleCtrlTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _singleCtrlSwitch.onText = @"ON";
    _singleCtrlSwitch.offText = @"OFF";
    _singleCtrlSwitch.on = YES;
    _singleCtrlSwitch.backgroundColor = [UIColor clearColor];
    _singleCtrlSwitch.onTintColor = [UIColor colorWithHexString:@"6BDB6A"];
    _singleCtrlSwitch.tintColor = [UIColor colorWithHexString:@"FF4359"];
//    [_singleCtrlSwitch addTarget:self action:@selector(_waterOnOrOffClick:) forControlEvents:UIControlEventValueChanged];
    _singleCtrlSwitch.switchDelegate = self;
    
    UIImage *stetchLeftTrack= [UIImage imageNamed:@"_light_zero_icon"];
    UIImage *stetchRightTrack = [UIImage imageNamed:@"_light_full_icon"];
    //滑块图片
    UIImage *thumbImage = [UIImage imageNamed:@"Slider"];
    _singleCtrlSlider.backgroundColor = [UIColor clearColor];
    _singleCtrlSlider.minimumTrackTintColor = [UIColor colorWithHexString:@"0068B8"];
    _singleCtrlSlider.unitStr = @"%";
    _singleCtrlSlider.value=1.0;
    _singleCtrlSlider.minimumValue=0;
    _singleCtrlSlider.maximumValue=1.0;
    _singleCtrlSlider.minimumValueImage = stetchLeftTrack;
    _singleCtrlSlider.maximumValueImage = stetchRightTrack;
    _singleCtrlSlider.minimumTrackImageName = @"_light_full_bg";
    //滑动拖动后的事件
    [_singleCtrlSlider addTarget:self action:@selector(sliderDragUp:) forControlEvents:UIControlEventTouchUpInside];
    [_singleCtrlSlider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [_singleCtrlSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    
    _modelBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    _modelBt.layer.borderWidth = 0.8;
    _modelBt.layer.cornerRadius = 4;
    _speedBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    _speedBt.layer.borderWidth = 0.8;
    _speedBt.layer.cornerRadius = 4;
}

-(void)setModel:(MeetRoomModel *)model
{
    _model = model;
    
    _typeImageView.image = [UIImage imageNamed:@"筒灯"];
    _adjustNumLab.text = @"亮度调节";
    _singleCtrlSwitch.tag = 101;
    _singleCtrlSlider.tag = 201;
    
    _singleCtrlSwitch.enabled = YES;
    if([model.current_state isEqualToString:@"0"] || model.current_state.length <= 0){
        _singleCtrlSwitch.on = [self dealShadow:model.DEVICE_TYPE withOn:NO];
    }else {
        // 开启 1-255
        _singleCtrlSwitch.on = [self dealShadow:model.DEVICE_TYPE withOn:YES];
    }
    
    [self hidAirView:YES];  // 空调默认隐藏
    
    _airLineView.hidden = YES;
    
    if([model.DEVICE_TYPE isEqualToString:@"18-1"] && ![model.current_state isEqualToString:@"0"] && model.DEVICE_TYPE.length > 0){
        _adjustNumLab.hidden = NO;
        _singleCtrlSlider.hidden = NO;
        if(model.current_state != nil && ![model.current_state isKindOfClass:[NSNull class]] && model.current_state.integerValue != 0){
            _singleCtrlSlider.value = model.current_state.floatValue/255;
        }else {
            _singleCtrlSlider.value = 0;
        }
    }else if([model.DEVICE_TYPE isEqualToString:@"6"]) {
        //空调
        _adjustNumLab.hidden = YES;
        _singleCtrlSlider.hidden = YES;
        
        if(_isEdit){
            // 场景模式编辑
        }else {        
            [self airDeviceState];
        }
    }else {
        _adjustNumLab.hidden = YES;
        _singleCtrlSlider.hidden = YES;
    }
    
    _typeNameLab.text = [NSString stringWithFormat:@"%@",model.DEVICE_NAME];
    
    // 图片
    if([model.DEVICE_TYPE isEqualToString:@"18-1"]){
        _typeImageView.image = [UIImage imageNamed:@"筒灯"];
    }else if([model.DEVICE_TYPE isEqualToString:@"18-3"]){
        _typeImageView.image = [UIImage imageNamed:@"灯箱"];
    }else if([model.DEVICE_TYPE isEqualToString:@"18-3"]){
        _typeImageView.image = [UIImage imageNamed:@"灯箱"];
    }else if([model.DEVICE_TYPE isEqualToString:@"18-2"]){
        _typeImageView.image = [UIImage imageNamed:@"灯带"];
    }else if([model.DEVICE_TYPE isEqualToString:@"18-2"]){
        _typeImageView.image = [UIImage imageNamed:@"灯带"];
    }else if([model.DEVICE_TYPE isEqualToString:@"19-1"]){
        _typeImageView.image = [UIImage imageNamed:@"meetroom_screen"];
    }else if([model.DEVICE_TYPE isEqualToString:@"19"]){
        _typeImageView.image = [UIImage imageNamed:@"scene_edit_curtain"];
    }else if([model.DEVICE_TYPE isEqualToString:@"20"]){
        _typeImageView.image = [UIImage imageNamed:@"scene_edit_scene"];
    }else if([model.DEVICE_TYPE isEqualToString:@"6"]){
        _typeImageView.image = [UIImage imageNamed:@"air_icon"];
    }
    
    // 是否是场景吗模式编辑
    if(_isEdit){
        [self hidAirView:YES];  // 空调隐藏
    }
}
- (void)airDeviceState {
    // AIRSTATUS 表示空调开关机状态、TEMPERATUR 表示温度、WINDSPEED表示风速、WORKMODE表示工作模式，FAILURE 表示故障（不展现）
    [_model.airList
     enumerateObjectsUsingBlock:^(MeetRoomDeviceModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
         if([model.TAGNAME isEqualToString:@"AIRSTATUS"]){
             if([model.current_state isEqualToString:@"0"]){
                 [self hidAirView:YES];
                 _singleCtrlSwitch.on = NO;
             }else {
                 [self hidAirView:NO];
                 _singleCtrlSwitch.on = YES;
                 _airLineView.hidden = NO;
             }
         }
         if([model.TAGNAME isEqualToString:@"TEMPERATUR"]){
             _tempLab.text = [NSString stringWithFormat:@"%@℃", model.current_state];
         }
         if([model.TAGNAME isEqualToString:@"WINDSPEED"]){
             _speedWidth.constant = 25;
             _speedHeight.constant = 15;
             if([model.current_state isEqualToString:@"3"]){
                 _windSpeedLab.text = @"低";
                 _windSpeedImgView.image = [UIImage imageNamed:@"wind_low_icon"];
             }
             if([model.current_state isEqualToString:@"2"]){
                 _windSpeedLab.text = @"中";
                 _windSpeedImgView.image = [UIImage imageNamed:@"wind_medium_icon"];
             }
             if([model.current_state isEqualToString:@"1"]){
                 _windSpeedLab.text = @"高";
                 _windSpeedImgView.image = [UIImage imageNamed:@"wind_max_icon"];
             }
             if([model.current_state isEqualToString:@"0"]){
                 _windSpeedLab.text = @"自动";
                 _windSpeedImgView.image = [UIImage imageNamed:@"wind_auto_icon"];
                 _speedWidth.constant = 20;
                 _speedHeight.constant = 20;
             }
         }
         if([model.TAGNAME isEqualToString:@"WORKMODE"]){
             if([model.current_state isEqualToString:@"1"]){
                 _modelLab.text = @"制热";
                 _modelImgView.image = [UIImage imageNamed:@"air_hot_icon"];
             }
             if([model.current_state isEqualToString:@"2"]){
                 _modelLab.text = @"制冷";
                 _modelImgView.image = [UIImage imageNamed:@"air_cold_icon"];
             }
             if([model.current_state isEqualToString:@"4"]){
                 _modelLab.text = @"除湿";
                 _modelImgView.image = [UIImage imageNamed:@"air_wet_icon"];
             }
             if([model.current_state isEqualToString:@"3"]){
                 _modelLab.text = @"通风";
                 _modelImgView.image = [UIImage imageNamed:@"air_wind_icon"];
             }
         }
     }];
}

-(void)setSceneModel:(SceneEquipmentModel *)sceneModel {
    _sceneModel = sceneModel;
    
    _typeImageView.image = [UIImage imageNamed:@"筒灯"];
    _adjustNumLab.text = @"亮度调节";
    
    _airLineView.hidden = YES;
    
    _singleCtrlSwitch.enabled = YES;
    if([sceneModel.tagStatus isEqualToString:@"ON"]){  // 开启
        _singleCtrlSwitch.on = [self dealShadow:sceneModel.deviceType withOn:YES];
    }else if([sceneModel.tagStatus isEqualToString:@"OFF"]){
        // 离线
        _singleCtrlSwitch.on = [self dealShadow:sceneModel.deviceType withOn:NO];
    }else {
        _singleCtrlSwitch.on = [self dealShadow:sceneModel.deviceType withOn:NO];
    }
    
    if([sceneModel.deviceType isEqualToString:@"18-1"] && [sceneModel.tagStatus isEqualToString:@"ON"]){
        _adjustNumLab.hidden = NO;
        _singleCtrlSlider.hidden = NO;
        _singleCtrlSlider.value = sceneModel.tagValue.floatValue/100;
        
        [self hidAirView:YES];
    }
    /* 空调
     else if() {
     _adjustNumLab.hidden = YES;
     _singleCtrlSlider.hidden = YES;
     
     [self hidAirView:NO];
     }
     */
    else {
        _adjustNumLab.hidden = YES;
        _singleCtrlSlider.hidden = YES;
        
        [self hidAirView:YES];
    }
    
    _typeNameLab.text = [NSString stringWithFormat:@"%@",sceneModel.tagName];
    
    // 图片
    if([sceneModel.deviceType isEqualToString:@"18-1"]){
        _typeImageView.image = [UIImage imageNamed:@"筒灯"];
    }else if([sceneModel.deviceType isEqualToString:@"18-3"]){
        _typeImageView.image = [UIImage imageNamed:@"灯箱"];
    }else if([sceneModel.deviceType isEqualToString:@"18-3"]){
        _typeImageView.image = [UIImage imageNamed:@"灯箱"];
    }else if([sceneModel.deviceType isEqualToString:@"18-2"]){
        _typeImageView.image = [UIImage imageNamed:@"灯带"];
    }else if([sceneModel.deviceType isEqualToString:@"18-2"]){
        _typeImageView.image = [UIImage imageNamed:@"灯带"];
    }else if([sceneModel.deviceType isEqualToString:@"19-1"]){
        _typeImageView.image = [UIImage imageNamed:@"meetroom_screen"];
    }else if([sceneModel.deviceType isEqualToString:@"19"]){
        _typeImageView.image = [UIImage imageNamed:@"scene_edit_curtain"];
    }else if([sceneModel.deviceType isEqualToString:@"20"]){
        _typeImageView.image = [UIImage imageNamed:@"scene_edit_scene"];
    }else if([sceneModel.deviceType isEqualToString:@"6"]){
        _typeImageView.image = [UIImage imageNamed:@"air_icon"];
    }
    
    // 是否是场景吗模式编辑
    if(_isEdit){
        [self hidAirView:YES];  // 空调隐藏
    }
}

- (void)sliderDragUp:(YQSlider *)yqSlider {
    if(_isEdit){
        _sceneModel.tagValue = [NSString stringWithFormat:@"%f", yqSlider.value * 100];
        if(_lightDelegare && [_lightDelegare respondsToSelector:@selector(sliderSceneValue:withValue:)]){
            [_lightDelegare sliderSceneValue:_sceneModel withValue:yqSlider.value];
        }
    }else {
        if(_lightDelegare && [_lightDelegare respondsToSelector:@selector(sliderValue:withValue:)]){
            [_lightDelegare sliderValue:_model withValue:yqSlider.value];
        }
    }
}

// switch点击
- (void)switchTap:(BOOL)on {
    if(_isEdit){
        if(_lightDelegare && [_lightDelegare respondsToSelector:@selector(switchSceneOnOff:withOpen:)]){
            [_lightDelegare switchSceneOnOff:_sceneModel withOpen:[self dealShadow:_sceneModel.deviceType withOn:_singleCtrlSwitch.on]];
        }
    }else {
        if(_isScene){
            if(_lightDelegare && [_lightDelegare respondsToSelector:@selector(switchSceneOnOff:withOpen:)]){
                [_lightDelegare switchSceneOnOff:_sceneModel withOpen:[self dealShadow:_sceneModel.deviceType withOn:_singleCtrlSwitch.on]];
            }
        }else {
            if([_model.DEVICE_TYPE isEqualToString:@"6"]){
                [self airOperate:@"AIRSTATUS" withValue:[NSString stringWithFormat:@"%d", _singleCtrlSwitch.on]];
            }else {
                if(_lightDelegare && [_lightDelegare respondsToSelector:@selector(switchOnOff:withOpen:)]){
                    [_lightDelegare switchOnOff:_model withOpen:[self dealShadow:_model.DEVICE_TYPE withOn:_singleCtrlSwitch.on]];
                }
            }
        }
    }
}

- (void)hidAirView:(BOOL)hid {
    _airBgView.hidden = hid;
    _modelImgView.hidden = hid;
    _modelLab.hidden = hid;
    _tempLab.hidden = hid;
    _windSpeedImgView.hidden = hid;
    _windSpeedLab.hidden = hid;
    _speedImgView.hidden = hid;
    _speedLab.hidden = hid;
    _reduceBt.hidden = hid;
    _addBt.hidden = hid;
    _conBgView.hidden = hid;
}

#pragma mark 温度控制
- (IBAction)reduceAction:(id)sender {
    NSString *tepmStr = _tempLab.text;
    tepmStr = [tepmStr stringByReplacingOccurrencesOfString:@"℃" withString:@""];
    if(tepmStr != nil && tepmStr.length > 0){
        NSInteger tempValue = tepmStr.integerValue - 1;
        [self airOperate:@"TEMPERATUR" withValue:[NSString stringWithFormat:@"%ld", tempValue]];
    }
}

- (IBAction)addAction:(id)sender {
    NSString *tepmStr = _tempLab.text;
    tepmStr = [tepmStr stringByReplacingOccurrencesOfString:@"℃" withString:@""];
    if(tepmStr != nil && tepmStr.length > 0){
        NSInteger tempValue = tepmStr.integerValue + 1;
        [self airOperate:@"TEMPERATUR" withValue:[NSString stringWithFormat:@"%ld", tempValue]];
    }
}

- (IBAction)modelAction:(id)sender {
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"请选择空调模式" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *coldAction = [UIAlertAction actionWithTitle:@"制冷模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self airOperate:@"WORKMODE" withValue:@"2"];
    }];
    UIAlertAction *hotAction = [UIAlertAction actionWithTitle:@"制热模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self airOperate:@"WORKMODE" withValue:@"1"];
    }];
    UIAlertAction *wetAction = [UIAlertAction actionWithTitle:@"除湿模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self airOperate:@"WORKMODE" withValue:@"4"];
    }];
    UIAlertAction *windAction = [UIAlertAction actionWithTitle:@"通风模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self airOperate:@"WORKMODE" withValue:@"3"];
    }];
    
    [alertCon addAction:cancelAction];
    [alertCon addAction:wetAction];
    [alertCon addAction:coldAction];
    [alertCon addAction:hotAction];
    [alertCon addAction:windAction];
    
    if (alertCon.popoverPresentationController != nil) {
        alertCon.popoverPresentationController.sourceView = self.contentView;
        alertCon.popoverPresentationController.sourceRect = self.contentView.bounds;
    }
    
    [[self viewController] presentViewController:alertCon animated:YES completion:nil];
}

- (IBAction)speedAction:(id)sender {
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"请选择风速" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *lowAction = [UIAlertAction actionWithTitle:@"低风速" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self airOperate:@"WINDSPEED" withValue:@"3"];
    }];
    UIAlertAction *midstAction = [UIAlertAction actionWithTitle:@"中风速" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self airOperate:@"WINDSPEED" withValue:@"2"];
    }];
    UIAlertAction *heightAction = [UIAlertAction actionWithTitle:@"高风速" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self airOperate:@"WINDSPEED" withValue:@"1"];
    }];
    UIAlertAction *autoAction = [UIAlertAction actionWithTitle:@"自动风速" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self airOperate:@"WINDSPEED" withValue:@"0"];
    }];
    [alertCon addAction:cancelAction];
    [alertCon addAction:lowAction];
    [alertCon addAction:midstAction];
    [alertCon addAction:heightAction];
    [alertCon addAction:autoAction];
    
    if (alertCon.popoverPresentationController != nil) {
        alertCon.popoverPresentationController.sourceView = self.contentView;
        alertCon.popoverPresentationController.sourceRect = self.contentView.bounds;
    }
    
    [[self viewController] presentViewController:alertCon animated:YES completion:nil];
}

- (void)airOperate:(NSString *)tagName withValue:(NSString *)value {
    // 温度控制范围
    if([tagName isEqualToString:@"TEMPERATUR"]){
        if(value.integerValue >= AirMinTemp && value.integerValue <= AirMaxTemp){
        }else {
            [[self viewController] showHint:@"超出可控温度"];
        }
    }
    
    if(_lightDelegare && [_lightDelegare respondsToSelector:@selector(modelCutData:withDeviceId:withTagName:withValue:withMeetModel:)]){
        __block NSString *tagId;
        [_model.airList enumerateObjectsUsingBlock:^(MeetRoomDeviceModel *deviceModel, NSUInteger idx, BOOL * _Nonnull stop) {
            if([deviceModel.TAGNAME isEqualToString:tagName]){
                tagId = deviceModel.WRITE_ID;
            }
        }];
        [_lightDelegare modelCutData:tagId withDeviceId:_model.DEVICE_ID withTagName:tagName withValue:value withMeetModel:_model];
    }
}

// 幕布特殊处理
- (BOOL)dealShadow:(NSString *)deviceType withOn:(BOOL)on {
    if([deviceType isEqualToString:@"20"]){
        return !on;
    }else {
        return on;
    }
}

@end
