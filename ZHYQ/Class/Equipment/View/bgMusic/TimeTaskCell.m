//
//  TimeTaskCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "TimeTaskCell.h"
#import "YQSlider.h"

@interface TimeTaskCell ()<YQSliderDelegate>
{
    
}
@end

@implementation TimeTaskCell
{
    __weak IBOutlet UIImageView *_playingImgView;
    __weak IBOutlet UILabel *_musicNameLabel;
    
    __weak IBOutlet UILabel *_playStateLabel;
    
    __weak IBOutlet UIButton *_playBt;
    
    __weak IBOutlet UILabel *_musTitleLabel;
    __weak IBOutlet YQSlider *_yqSlider;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [NSTimer scheduledTimerWithTimeInterval:0.01 block:^(NSTimer * _Nonnull timer) {
        _playingImgView.transform = CGAffineTransformRotate(_playingImgView.transform, M_PI_4/50);
    } repeats:YES];
    
    
    _musTitleLabel.hidden = YES;
    
    // 音量调节slider
    // Initialization code
    UIImage *stetchLeftTrack= [UIImage imageNamed:@"_volume_redecing"];
    UIImage *stetchRightTrack = [UIImage imageNamed:@"_volume_addition"];
    //滑块图片
    UIImage *thumbImage = [UIImage imageNamed:@"Slider"];
    _yqSlider.backgroundColor = [UIColor clearColor];
    _yqSlider.hidden = YES;
    _yqSlider.minimumTrackTintColor = [UIColor colorWithHexString:@"0068B8"];
    _yqSlider.maxValue = @"56";
    _yqSlider.unitStr = @"";
    _yqSlider.delegate = self;
    _yqSlider.value = 1.0;
    _yqSlider.minimumValue = 0;
    _yqSlider.maximumValue = 1.0;
    _yqSlider.minimumValueImage = stetchLeftTrack;
    _yqSlider.maximumValueImage = stetchRightTrack;
    _yqSlider.minimumTrackImageName = @"_light_full_bg";
    //滑动拖动后的事件
    [_yqSlider addTarget:self action:@selector(sliderDragUp:) forControlEvents:UIControlEventTouchUpInside];
    [_yqSlider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [_yqSlider setThumbImage:thumbImage forState:UIControlStateNormal];
}

- (void)setMusicTimeModel:(MusicTimeModel *)musicTimeModel {
    _musicTimeModel = musicTimeModel;
    
    _playingImgView.hidden = YES;
    if(musicTimeModel.status.integerValue == 0){
        // 未开启
        _playingImgView.hidden = YES;
        
        // 播放时间
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *playDate = [dateFormatter dateFromString:musicTimeModel.startTime];
        NSDateFormatter *viewFormatter = [[NSDateFormatter alloc] init];
        [viewFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [viewFormatter setDateFormat:@"MM-dd HH:mm"];
        NSString *playTimeStr = [viewFormatter stringFromDate:playDate];
        
        _playStateLabel.text = [NSString stringWithFormat:@"%@ 开始播放", playTimeStr];
        _playStateLabel.textColor = [UIColor blackColor];
        
        _playBt.selected = NO;
    }else if(musicTimeModel.status.integerValue == 1){
        // 已开启
        _playingImgView.hidden = NO;
        _playStateLabel.text = @"播放中";
        _playStateLabel.textColor = [UIColor colorWithHexString:@"#FF4359"];
        
        _playBt.selected = YES;
    }
    
    if(musicTimeModel.isSelect){
        _musTitleLabel.hidden = NO;
        _yqSlider.hidden = NO;
    }else {
        _musTitleLabel.hidden = YES;
        _yqSlider.hidden = YES;
    }
    
    _musicNameLabel.text = musicTimeModel.name;
    
    // 音量
    _yqSlider.value = musicTimeModel.vol.floatValue/56.000000f;
}

- (IBAction)playOrStop:(id)sender {
    if(_musicDelegate && [_musicDelegate respondsToSelector:@selector(playStopMusic:)]){
        [_musicDelegate playStopMusic:_musicTimeModel];
    }
    
}

// 滑动
- (void)sliderDragUp:(YQSlider *)yqSlider {
    if(_musicDelegate && [_musicDelegate respondsToSelector:@selector(sliderModel:withVol:)]){
        [_musicDelegate sliderModel:_musicTimeModel withVol:yqSlider.value];
    }
}

-(void)minimumTrackBtnAction:(YQSlider *)slider {
    if(slider.value <= 0){
        return;
    }else {
        slider.value = slider.value - slider.value/56.000000f;
        if(_musicDelegate && [_musicDelegate respondsToSelector:@selector(sliderModel:withVol:)]){
            [_musicDelegate sliderModel:_musicTimeModel withVol:_yqSlider.value];
        }
    }
    
}
-(void)maximumTrackBtnAction:(YQSlider *)slider {
    if(slider.value >= 1){
        return;
    }else {
        slider.value = slider.value + slider.value/56.000000f;
        if(_musicDelegate && [_musicDelegate respondsToSelector:@selector(sliderModel:withVol:)]){
            [_musicDelegate sliderModel:_musicTimeModel withVol:_yqSlider.value];
        }
    }
    
}

@end
