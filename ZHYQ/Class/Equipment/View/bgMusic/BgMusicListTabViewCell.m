//
//  BgMusicListTabViewCell.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/16.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BgMusicListTabViewCell.h"
#import "YQSlider.h"
#import "YQSwitch.h"

@interface BgMusicListTabViewCell ()<YQSliderDelegate>
{
    
}
@end

@implementation BgMusicListTabViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UIImage *stetchLeftTrack= [UIImage imageNamed:@"_volume_redecing"];
    UIImage *stetchRightTrack = [UIImage imageNamed:@"_volume_addition"];
    //滑块图片
    UIImage *thumbImage = [UIImage imageNamed:@"Slider"];
    _volumeAdjustSlider.backgroundColor = [UIColor clearColor];
    _volumeAdjustSlider.minimumTrackTintColor = [UIColor colorWithHexString:@"0068B8"];
    _volumeAdjustSlider.maxValue = @"56";
    _volumeAdjustSlider.unitStr = @"";
    _volumeAdjustSlider.delegate = self;
    _volumeAdjustSlider.value = 1.0;
    _volumeAdjustSlider.minimumValue = 0;
    _volumeAdjustSlider.maximumValue = 1.0;
    _volumeAdjustSlider.minimumValueImage = stetchLeftTrack;
    _volumeAdjustSlider.maximumValueImage = stetchRightTrack;
    _volumeAdjustSlider.minimumTrackImageName = @"_light_full_bg";
    //滑动拖动后的事件
    [_volumeAdjustSlider addTarget:self action:@selector(sliderDragUp:) forControlEvents:UIControlEventTouchUpInside];
    [_volumeAdjustSlider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [_volumeAdjustSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    
}

-(void)setModel:(BgMusicMapModel *)model
{
    _model = model;
    _equipmentNameLab.text = [NSString stringWithFormat:@"%@",model.DEVICE_NAME];
    
    NSString *_stateStr;
    UIColor *_stateColor;
    if([model.MUSIC_STATUS isEqualToString:@"1"]){
        // 正常
        _stateStr = @"正常开启中";
        _stateColor = [UIColor colorWithHexString:@"#189517"];
    }else if([model.MUSIC_STATUS isEqualToString:@"0"]){
        // 故障
        _stateStr = @"设备故障";
        _stateColor = [UIColor colorWithHexString:@"#FF4359"];
    }if([model.MUSIC_STATUS isEqualToString:@"2"]){
        // 离线
        _stateStr = @"离线";
        _stateColor = [UIColor grayColor];
    }
    _stateLabel.text = _stateStr;
    _stateLabel.textColor = _stateColor;
    
    _currentMusicDetailLab.text = model.currentMusic;
}

-(void)setInDoorModel:(InDoorBgMusicMapModel *)inDoorModel
{
    _inDoorModel = inDoorModel;
    
    _equipmentNameLab.text = [NSString stringWithFormat:@"%@",inDoorModel.DEVICE_NAME];
    
    NSString *_stateStr;
    UIColor *_stateColor;
    if([inDoorModel.MUSIC_STATUS isEqualToString:@"1"]){
        // 正常
        _stateStr = @"正常开启中";
        _stateColor = [UIColor colorWithHexString:@"#189517"];
    }else if([inDoorModel.MUSIC_STATUS isEqualToString:@"0"]){
        // 停止
        _stateStr = @"停止";
        _stateColor = [UIColor grayColor];
    }else if([inDoorModel.MUSIC_STATUS isEqualToString:@"2"]){
        // 暂停
        _stateStr = @"暂停";
        _stateColor = [UIColor blackColor];
    }else {
        _stateStr = @"离线";
        _stateColor = [UIColor grayColor];
    }
    _stateLabel.text = _stateStr;
    _stateLabel.textColor = _stateColor;
    
    _currentMusicDetailLab.text = inDoorModel.currentMusic;
    _volumeAdjustSlider.value = 0;
}

- (void)setVolum:(CGFloat)volum {
    _volum = volum;
    
    _volumeAdjustSlider.value = volum;
}

- (void)sliderDragUp:(YQSlider *)yqSlider {
    _volum = yqSlider.value;
    if([_cellPlayMusicDelegate respondsToSelector:@selector(sliderVolumValue:)]){
        [_cellPlayMusicDelegate sliderVolumValue:_volum];
    }
}

-(void)_musicOnOrOffClick:(YQSwitch *)yqSwitch {
    
}

// 更换音乐
- (IBAction)volumeAdjustBtn:(id)sender {
    if(_cellPlayMusicDelegate && [_cellPlayMusicDelegate respondsToSelector:@selector(chooseMusicList)]){
        [_cellPlayMusicDelegate chooseMusicList];
    }
}

- (IBAction)upAction:(id)sender {
    if(_cellPlayMusicDelegate && [_cellPlayMusicDelegate respondsToSelector:@selector(upMusic)]){
        [_cellPlayMusicDelegate upMusic];
    }
}

- (IBAction)pauseAction:(id)sender {
    if(_cellPlayMusicDelegate && [_cellPlayMusicDelegate respondsToSelector:@selector(pauseMusic)]){
        [_cellPlayMusicDelegate pauseMusic];
    }
}

- (IBAction)playAction:(id)sender {
    if(_cellPlayMusicDelegate && [_cellPlayMusicDelegate respondsToSelector:@selector(playMusic)]){
        [_cellPlayMusicDelegate playMusic];
    }
}

- (IBAction)stopAction:(id)sender {
    if(_cellPlayMusicDelegate && [_cellPlayMusicDelegate respondsToSelector:@selector(stopMusic)]){
        [_cellPlayMusicDelegate stopMusic];
    }
}

- (IBAction)downAction:(id)sender {
    if(_cellPlayMusicDelegate && [_cellPlayMusicDelegate respondsToSelector:@selector(downMusic)]){
        [_cellPlayMusicDelegate downMusic];
    }
}

-(void)minimumTrackBtnAction:(YQSlider *)slider
{
    if(slider.value <= 0){
        return;
    }else {
        slider.value = slider.value - slider.value/56;
        [self sliderDragUp:slider];
    }
}

-(void)maximumTrackBtnAction:(YQSlider *)slider
{
    if(slider.value >= 1){
        return;
    }else {
        slider.value = slider.value + slider.value/56;
        [self sliderDragUp:slider];
    }
}

@end
