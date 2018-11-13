//
//  inDoorMusicTabCell.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/7.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "inDoorMusicTabCell.h"
#import "YQSwitch.h"
#import "YQSlider.h"

@interface inDoorMusicTabCell()
{
    
    __weak IBOutlet UILabel *_indoorMusicLab;
    
    __weak IBOutlet UILabel *stateLabel;
    
    __weak IBOutlet UILabel *_volumeAdjustLab;
    
    __weak IBOutlet UIImageView *_chooseMusicView;
    YQSlider *sliderA;
    
    __weak IBOutlet UILabel *currentMusic;
    
    CGFloat _volum;
}

@end

@implementation inDoorMusicTabCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self _initView];
}

-(void)_initView
{
    
    sliderA = [[YQSlider alloc]initWithFrame:CGRectMake(KScreenWidth-255, 0, 240, 8)];
    sliderA.centerY = _volumeAdjustLab.centerY;
    sliderA.backgroundColor = [UIColor clearColor];
    
    // 设置音量最大值
    sliderA.maxValue = @"56";
    sliderA.unitStr = @"";
    
    sliderA.value = 1.0;
//    sliderA.unitStr = @"%";
//    sliderA.leftTitleStr = @"最低温";
//    sliderA.rightTitleStr = @"最高温";
    sliderA.minimumValue = 0;
    sliderA.maximumValue = 1.0;
    sliderA.minimumValueImage = [UIImage imageNamed:@"_volume_redecing"];
    sliderA.maximumValueImage = [UIImage imageNamed:@"_volume_addition"];
    //滑块拖动时的事件
    [sliderA addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    //滑动拖动后的事件
    [sliderA addTarget:self action:@selector(sliderDragUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:sliderA];
    
    _chooseMusicView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_chooseMusicTap:)];
    [_chooseMusicView addGestureRecognizer:tap];
}

- (void)setMusicGroupModel:(MusicGroupModel *)musicGroupModel {
    _musicGroupModel = musicGroupModel;
    
    _indoorMusicLab.text = musicGroupModel.name;
    
    NSString *_stateStr;
    UIColor *_stateColor;
    
    _stateStr = @"正常开启中";
    _stateColor = [UIColor colorWithHexString:@"#189517"];
    
    if(musicGroupModel.status.integerValue == 1){
         // 正常播放
         _stateStr = @"正常开启中";
         _stateColor = [UIColor colorWithHexString:@"#189517"];
        currentMusic.text = musicGroupModel.musicname;    // 当前音乐
    }else if(musicGroupModel.status.integerValue == 0){
        // 离线
        _stateStr = @"停止";
        _stateColor = [UIColor grayColor];
        currentMusic.text = @"";    // 当前音乐
    }else if(musicGroupModel.status.integerValue == 2){
        // 暂停
        _stateStr = @"暂停";
        _stateColor = [UIColor blackColor];
        currentMusic.text = musicGroupModel.musicname;    // 当前音乐
    }else if(musicGroupModel.status.integerValue == 5){
        // 暂停
        _stateStr = @"故障";
        _stateColor = [UIColor blackColor];
        currentMusic.text = musicGroupModel.musicname;    // 当前音乐
    }else {
        _stateStr = @"离线";
        _stateColor = [UIColor grayColor];
        currentMusic.text = @"";    // 当前音乐
    }
    
    stateLabel.text = _stateStr;
    stateLabel.textColor = _stateColor;

    _volum = musicGroupModel.vol.floatValue/56;
//    _volum = musicGroupModel.     // 音量
    sliderA.value = _volum;
}

#pragma mark 开关
-(void)_waterOnOrOffClick:(id)sender
{
    
}

#pragma mark 滑块相关方法
-(void)sliderValueChanged:(id)sender {
    YQSlider *slider = (YQSlider *)sender;
    _volum = slider.value;
}

-(void)sliderDragUp:(id)sender
{
    
}

#pragma mark 选择音乐
-(void)_chooseMusicTap:(id)sender
{
    if (_inDoorDelegate != nil) {
        [_inDoorDelegate inDoor_chooseMusicTap:_musicGroupModel withVolum:_volum];
    }
}

#pragma mark 查看更多详情
- (IBAction)_pushDetail:(id)sender {
    if (_inDoorDelegate != nil) {
        [_inDoorDelegate inDoor_seeDetailsClick:_musicGroupModel];
    }
}


#pragma mark 音乐菜单
- (IBAction)upAction:(id)sender {
    if(_inDoorDelegate && [_inDoorDelegate respondsToSelector:@selector(upMusic:)]){
        [_inDoorDelegate upMusic:_musicGroupModel];
    }
}

- (IBAction)pauseAction:(id)sender {
    if(_inDoorDelegate && [_inDoorDelegate respondsToSelector:@selector(pauseMusic:)]){
        [_inDoorDelegate pauseMusic:_musicGroupModel];
    }
}

- (IBAction)playAction:(id)sender {
    if(_inDoorDelegate && [_inDoorDelegate respondsToSelector:@selector(playMusic:withVolum:)]){
        [_inDoorDelegate playMusic:_musicGroupModel withVolum:_volum];
    }
}

- (IBAction)stopAction:(id)sender {
    if(_inDoorDelegate && [_inDoorDelegate respondsToSelector:@selector(stopMusic:)]){
        [_inDoorDelegate stopMusic:_musicGroupModel];
    }
}

- (IBAction)downAction:(id)sender {
    if(_inDoorDelegate && [_inDoorDelegate respondsToSelector:@selector(downMusic:)]){
        [_inDoorDelegate downMusic:_musicGroupModel];
    }
}

@end
