//
//  PlayControlBar.m
//  CourtHearing
//
//  Created by jbin on 14-3-15.
//  Copyright (c) 2014年 dahatech. All rights reserved.
//

#import "PlayControlBar.h"
#import "PubDefine.h"
#import "TimeConvert.h"

@implementation PlayControlBar

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"SetPlaybackSpeedNotification" object:nil];
}

- (id)initWithFrame:(CGRect)frame delegate:(id<PlayControlDelegate>)delegate
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPlaybackSpeed:) name:@"SetPlaybackSpeedNotification" object:nil];
    _delegate_ = delegate;
    
    //标准尺寸720*75,以frame的宽度进行缩放
    float proportion   = frame.size.width / 720;
    frame.size.height  = 75*proportion*2;

    self = [super initWithFrame:frame];
    if (self)
    {
        isPaused_ = NO;
        self.backgroundColor = COLOR_DARK;
        
        //Add play button
        CGRect rectBtn = DHRectMakeByProportion(10, 70, 50, 50, proportion);
        btnPlay_ = [[UIButton alloc]initWithFrame:rectBtn];
        [btnPlay_ setBackgroundImage:[UIImage imageNamed:@"playback_play_n.png"]
                             forState:UIControlStateNormal];
        [btnPlay_ setBackgroundImage:[UIImage imageNamed:@"playback_play_h.png"]
                             forState:UIControlStateHighlighted];
        [btnPlay_ addTarget:self
                      action:@selector(onOpenClicked:)
            forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnPlay_];
        
        //Add pause button
        btnPause_ = [[UIButton alloc]initWithFrame:rectBtn];
        [btnPause_ setBackgroundImage:[UIImage imageNamed:@"playback_pause_n.png"]
                             forState:UIControlStateNormal];
        [btnPause_ setBackgroundImage:[UIImage imageNamed:@"playback_pause_h.png"]
                             forState:UIControlStateHighlighted];
        [btnPause_ addTarget:self
                       action:@selector(onPauseClicked:)
             forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnPlay_];
        [btnPause_ setHidden:YES];
        [self addSubview:btnPause_];
        
        //Add stop button
        rectBtn.origin.x += 10*proportion + rectBtn.size.width;
        btnStop = [[UIButton alloc]initWithFrame:rectBtn];
        [btnStop setBackgroundImage:[UIImage imageNamed:@"playback_stop_n.png"]
                           forState:UIControlStateNormal];
        [btnStop setBackgroundImage:[UIImage imageNamed:@"playback_stop_h.png"]
                           forState:UIControlStateHighlighted];
        [btnStop addTarget:self
                    action:@selector(onStopClicked:)
          forControlEvents:UIControlEventTouchUpInside];
        [btnStop setEnabled:NO];
        [self addSubview:btnStop];
        
        //Add volume button
        rectBtn.origin.x += 10*proportion + rectBtn.size.width;
        btnMuteVolume_ = [[UIButton alloc]initWithFrame:rectBtn];
        [btnMuteVolume_ setBackgroundImage:[UIImage imageNamed:@"playback_mute_n.png"]
                                  forState:UIControlStateNormal];
        [btnMuteVolume_ setBackgroundImage:[UIImage imageNamed:@"playback_mute_h.png"]
                                  forState:UIControlStateHighlighted];
        isMuted_ = YES;
        [btnMuteVolume_ addTarget:self
                        action:@selector(onMutedClick:)
              forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnMuteVolume_];
        
        
        rectBtn.origin.x += 10*proportion + rectBtn.size.width;
        btnSpeed_ = [[UIButton alloc]initWithFrame:CGRectMake(rectBtn.origin.x, rectBtn.origin.y, rectBtn.size.width + 20, rectBtn.size.height)];
       
        [btnSpeed_ setTitle:@"正常" forState:UIControlStateNormal];
        btnSpeed_.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [btnSpeed_ addTarget:self
                           action:@selector(onSpeedClick:)
                 forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnSpeed_];
        
        //Add label start time
        CGRect rectLabel = DHRectMakeByProportion(10, 20, 81, 20, proportion);
        rectLabel.size.height = 15;
        labelStartTime_ = [[UILabel alloc]initWithFrame:rectLabel];
        labelStartTime_.textColor = [UIColor whiteColor];
        labelStartTime_.adjustsFontSizeToFitWidth = YES;
        labelStartTime_.text = @"00:00:00";
        [self addSubview:labelStartTime_];
        
        //Add time slider
        CGRect rectSlider = DHRectMakeByProportion(0, 20, 533, 31, proportion);
        rectSlider.origin.x = CGRectGetMaxX(rectLabel) + 2;
        progressSlider_ = [[UISlider alloc]initWithFrame:rectSlider];
        [progressSlider_ setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [progressSlider_ setEnabled:NO];
        [progressSlider_ addTarget:self
                            action:@selector(sliderValuaChanged:)
                  forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:progressSlider_];
        
        //Add label end time
        rectLabel.origin.x = CGRectGetMaxX(rectSlider) + 2;
        labelEndTime_ = [[UILabel alloc]initWithFrame:rectLabel];
        labelEndTime_.textColor = [UIColor whiteColor];
        labelEndTime_.adjustsFontSizeToFitWidth = YES;
        labelEndTime_.text = @"00:00:00";
        [self addSubview:labelEndTime_];
        
        //Add begin time and end time
        //@Date:2014-4-17
        beginTime_ = [[NSDate alloc]init];
    }
    return self;
}

/**
 *  设置播放开始时间和结束时间
 *  @param beginTime 播放开始时间
 *  @param endTime   播放结束时间
 */
- (void)setBeginTime:(NSDate *)beginTime andEndTime:(NSDate *)endTime
{
    beginTime_ = [beginTime copy];
    labelStartTime_.text = [TimeConvert stringBeginWithHourFromDate:beginTime];
    labelEndTime_.text   = [TimeConvert stringBeginWithHourFromDate:endTime];
}

/**
 *  更新播放控制进度条
 *  @param playedTime 已经播放的时间
 */
- (void)updatePlayProgress:(NSTimeInterval)playedTime
{
//    if (playedTime < 0 || playedTime > totalTime_)
    if (playedTime > totalTime_)
    {
        playedTime = 0;
        if (_delegate_ && [_delegate_ respondsToSelector:@selector(playControlTimerEnd)])
        {
            [_delegate_ playControlTimerEnd];
        }
    }
    
    //设置播放信息
    timeLapsed_ = playedTime;
    
    //设置进度条
    if (![progressSlider_ isTouchInside])
    {
        progressSlider_.value = playedTime;
        
        NSDate *passedTime = [beginTime_ dateByAddingTimeInterval:timeLapsed_];
        NSString *currentTime = [TimeConvert stringBeginWithHourFromDate:passedTime];
        labelStartTime_.text = currentTime;
    }
}

- (void)onSpeedClick:(id)sender{
    if (_delegate_ && [_delegate_ respondsToSelector:@selector(playControlSetSpeed)])
    {
        [_delegate_ playControlSetSpeed];
    }

}

-(void)setPlaybackSpeed:(NSNotification*) notification{
    NSDictionary* theData = [notification userInfo];
    NSString* theRecordResult = [theData objectForKey:@"playbackSpeedText"];
    [btnSpeed_ setTitle:theRecordResult forState:UIControlStateNormal];
}

// 是否静音播放
- (BOOL)isMuted
{
    return  isMuted_;
}

/**
 *  外部手动停止播放
 */
- (void)stopPlay
{
    [btnStop setEnabled:NO];
    [progressSlider_ setEnabled:NO];
    [btnPlay_ setHidden:NO];
    [btnSpeed_ setEnabled:NO];
    [btnMuteVolume_ setEnabled:NO];
    [btnPause_ setHidden:YES];
    isStarted_ = NO;
    isPaused_  = NO;
    
    //增加停止时的进度恢复
    labelStartTime_.text  = @"00:00:00";
    labelEndTime_.text    = @"00:00:00";
    progressSlider_.value = 0;
}

- (void)openPlay
{
    isStarted_ = YES;
    [btnPlay_ setHidden:YES];
    [btnPause_ setHidden:NO];
    [btnStop setEnabled:YES];
    [btnMuteVolume_ setEnabled:YES];
    isMuted_ = YES;
    [self setMuted:isMuted_];
     [btnSpeed_ setEnabled:YES];
     [btnSpeed_ setTitle:@"正常" forState:UIControlStateNormal]; //恢复默认
    [progressSlider_ setEnabled:YES];
    
    //重置流逝时间
    timeLapsed_ = 0;
}

//播放失败,重置控件状态
- (void)resetOpenFailed
{
    isStarted_ = NO;
    [btnPlay_ setHidden:NO];
    [btnPause_ setHidden:YES];
    [btnStop setEnabled:NO];
    [progressSlider_ setEnabled:NO];
    
    //重置流逝时间
    timeLapsed_ = 0;
}

//设置总的播放时间
- (void)setTimeInterval:(NSTimeInterval)timeInterval
{
    totalTime_ = timeInterval
    ;
    
    //设置进度条的分隔
    progressSlider_.minimumValue = 0;
    progressSlider_.maximumValue = timeInterval;
    progressSlider_.value = 0;
}

// 获取当前进度条的数值,即已经播放的时间
- (NSTimeInterval)timeLapsed
{
    return timeLapsed_;
}

// 获取总播放时间
- (NSTimeInterval)playTotalTime {
    return totalTime_;
}

- (void)seekTime:(NSTimeInterval)timeoffset
{
    timeLapsed_ += timeoffset;
    if (timeLapsed_ >= totalTime_)
    {
        timeLapsed_ = totalTime_ - 1;
    }
    else if(timeLapsed_ <= 0)
    {
        timeLapsed_ = 0;
    }
}

//格式化数字,如果是一位变成0x
- (NSString *)formatFromInt:(int)number
{
    if (number < 10 && number >= 0)
    {
        return [NSString stringWithFormat:@"0%d",number];
    }
    else
    {
        return [NSString stringWithFormat:@"%d",number];
    }
}

//将时间间隔转化成hh:mm:ss格式
- (NSString *)formatTimeFromTimeInterval:(NSTimeInterval)timeInterval
{
    //计算结束时间差,hh-mm-ss,设置label
    int nHour = timeInterval / 3600;
    timeInterval = (int)timeInterval % 3600;
    int nMinute = timeInterval / 60;
    int nSecond = (int)timeInterval % 60;
    
    NSString *stringTime = [NSString stringWithFormat:@"%@:%@:%@",
                                [self formatFromInt:nHour],
                                [self formatFromInt:nMinute],
                                [self formatFromInt:nSecond]];
    return stringTime;
}

//开始播放点击响应
- (void)onOpenClicked:(id)sender
{
    [btnPlay_ setHidden:YES];
    [btnPause_ setHidden:NO];
    
    //开始播放
    if (NO == isStarted_)
    {
        isStarted_ = YES;
        if (_delegate_ && [_delegate_ respondsToSelector:@selector(playControlOpenPlay)])
        {
            [_delegate_ playControlOpenPlay];
        }
    }
    //继续播放
    else
    {
        isPaused_ = NO;
        if (_delegate_ && [_delegate_ respondsToSelector:@selector(playControlPausePlay:)])
        {
            [_delegate_ playControlPausePlay:NO];
        }
    }
}

//暂停播放点击响应
- (void)onPauseClicked:(id)sender
{
    [btnPause_ setHidden:YES];
    [btnPlay_ setHidden:NO];
    isPaused_ = YES;
    
    if (_delegate_ && [_delegate_ respondsToSelector:@selector(playControlPausePlay:)])
    {
        [_delegate_ playControlPausePlay:YES];
    }
}

//停止播放点击响应
- (void)onStopClicked:(id)sender
{
    [self stopPlay];
    
    if (_delegate_ && [_delegate_ respondsToSelector:@selector(playControlPausePlay:)])
    {
        [_delegate_ playControlStopPlay];
    }
}

//静音点击响应
- (void)onMutedClick:(id)sender
{
    isMuted_ = !isMuted_;
    [self setMuted:isMuted_];
    if (_delegate_ && [_delegate_ respondsToSelector:@selector(playControlMuted:)])
    {
        [_delegate_ playControlMuted:isMuted_];
    }
}

//静音按钮设置
- (void)setMuted:(BOOL)isMuted
{
    if (isMuted)
    {
        [btnMuteVolume_ setBackgroundImage:[UIImage imageNamed:@"playback_mute_n.png"]
                               forState:UIControlStateNormal];
        [btnMuteVolume_ setBackgroundImage:[UIImage imageNamed:@"playback_mute_h.png"]
                               forState:UIControlStateHighlighted];
    }
    else
    {
        [btnMuteVolume_ setBackgroundImage:[UIImage imageNamed:@"playback_volume_n.png"]
                               forState:UIControlStateNormal];
        [btnMuteVolume_ setBackgroundImage:[UIImage imageNamed:@"playback_volume_h.png"]
                               forState:UIControlStateHighlighted];
    }
}

//进度条响应
- (void)sliderValuaChanged:(id)sender
{
    //slider值改变后传出delegate
    if (lastSliderValue_ != progressSlider_.value)
    {
        if (_delegate_ && [_delegate_ respondsToSelector:@selector(playControlSliderValueChanged:)])
        {
            //最多允许滑到倒数1s
            if (progressSlider_.value >= totalTime_)
            {
                progressSlider_.value = totalTime_ - 1;
            }
            [_delegate_ playControlSliderValueChanged:progressSlider_.value];
        }
    }
    
    //滑动时强制,取消暂停
    if (isPaused_)
    {
        [self onOpenClicked:Nil];
    }
    
    lastSliderValue_ = progressSlider_.value;
    timeLapsed_ = progressSlider_.value;
    
    //更新开始时间
    NSDate *passedTime = [beginTime_ dateByAddingTimeInterval:timeLapsed_];
    //NSString *currentTime = [NetTimeConvert stringBeginWithHourFromDate:passedTime];
   // labelStartTime_.text = currentTime;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    float x = progressSlider_.value;
    if (0 != totalTime_)
    {
        x = CGRectGetMinX(progressSlider_.frame) + (x * 393.0)/totalTime_;
        float y = progressSlider_.frame.origin.y + 25;
        CGRect rectToDrawIn = CGRectMake(x, y, 30, 20);
        CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
        CGContextFillRect(context, rectToDrawIn);
        [self drawLeftAlignedLableInRect:rectToDrawIn];
    }
}

//绘制播放时间文字信息
- (void)drawLeftAlignedLableInRect:(CGRect)rect
{
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.adjustsFontSizeToFitWidth = YES;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = totalTime_ ? [self formatTimeFromTimeInterval:timeLapsed_] : @"";
    label.font = [UIFont systemFontOfSize:13];                  //默认文字大小
    label.textColor = [UIColor whiteColor];                     //文字颜色
    [label drawTextInRect:rect];
}
@end
