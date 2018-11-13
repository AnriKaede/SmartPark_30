//
//  PlayControlBar.h
//  CourtHearing
//
//  Created by jbin on 14-3-15.
//  Copyright (c) 2014年 dahatech. All rights reserved.
//  回放控制按钮,标准尺寸718*75,自动缩放

#import <UIKit/UIKit.h>

@protocol PlayControlDelegate;
@interface PlayControlBar : UIView
{
    UIButton        *btnPlay_;              //播放/继续
    UIButton        *btnPause_;             //暂停
    UIButton        *btnStop;               //停止
    UIButton        *btnMuteVolume_;        //静音
    UIButton        *btnSpeed_;             //播放速度
    UILabel         *labelStartTime_;       //开始时间
    UILabel         *labelEndTime_;         //结事时间
    UISlider        *progressSlider_;       //时间进度条
    BOOL            isStarted_;             //是否已经开开始
    BOOL            isPaused_;              //是否暂停
    BOOL            isMuted_;               //是否静音
    NSTimeInterval  totalTime_;             //时间进度条,结束与开始时间差(s)
    NSTimeInterval  lastSliderValue_;       //上一次slider位置
    NSTimeInterval  timeLapsed_;            //开始播放后的时间流逝(s)
  
    NSDate          *beginTime_;            /**< 播放开始时间 */
}
@property (assign,nonatomic)   id<PlayControlDelegate> delegate_;
- (id)initWithFrame:(CGRect)frame delegate:(id<PlayControlDelegate>)delegate;

/**
 *  设置播放开始时间和结束时间
 *  @param beginTime 播放开始时间
 *  @param endTime   播放结束时间
 */
- (void)setBeginTime:(NSDate *)beginTime andEndTime:(NSDate *)endTime;

/**
 *  更新播放控制进度条
 *  @param playedTime 已经播放的时间
 */
- (void)updatePlayProgress:(NSTimeInterval)playedTime;

/**
 * @description 设置播放进度条的时间长度(s)
 * @param timeInterval 总时间长度
 */
- (void)setTimeInterval:(NSTimeInterval)timeInterval;

/**
 * @description 外层开始播放成功后,调用此接口设置相应控件的状态
 */
- (void)openPlay;


/**
 获取此段视频总播放时间 秒数

 @return 总播放时间
 */
- (NSTimeInterval)playTotalTime;

/**
 * @description 获取当前进度条的数值,即已经播放的时间
 * @return 已播放时间
 */
- (NSTimeInterval)timeLapsed;

/**
 *  @desc 开始播放失败,控件状态恢复
 */
- (void)resetOpenFailed;

/**
 *  设置播放时间偏移
 *  @param timeoffset 时间偏移量
 */
- (void)seekTime:(NSTimeInterval)timeoffset;

/**
 *  是否静音播放
 *  @return YES静音,NO取消静音
 */
- (BOOL)isMuted;

/**
 *  外部手动停止播放
 */
- (void)stopPlay;
@end



@protocol PlayControlDelegate <NSObject>
@optional

- (void)playControlOpenPlay;

- (void)playControlPausePlay:(BOOL)paused;

- (void)playControlStopPlay;

- (void)playControlMuted:(BOOL)muted;

- (void)playControlSliderValueChanged:(NSTimeInterval)value;

- (void)playControlTimerEnd;

- (void)playControlSetSpeed;
@end
