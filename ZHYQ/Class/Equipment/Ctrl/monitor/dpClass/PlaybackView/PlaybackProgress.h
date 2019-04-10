//
//  PlaybackProgress.h
//  Pods
//
//  Created by chenfeifei on 2017/3/31.
//
// 回放的进度条

#import <UIKit/UIKit.h>

@protocol PlaybackProgressDelegate <NSObject>

@optional

/**
 seek playback progress

 @param seekTime seekTime
 */
-(void)playbackProgressSeekAtTime:(NSTimeInterval)seekTime;
@end


@interface PlaybackProgress : UIView
//playback progress delegate
@property (nonatomic,weak) id<PlaybackProgressDelegate>  delegate;
//start time
@property (nonatomic,assign) NSTimeInterval startTime;
//end time
@property (nonatomic,assign) NSTimeInterval endTime;
//starttime label text color
@property (nonatomic,strong) UIColor       *colorStartText;   //设置显示开始时间文本颜色
//endtime label text color
@property (nonatomic,strong) UIColor       *colorEndTimeText;  //设置显示结束时间文本颜色
//progress background color
@property (nonatomic,strong) UIColor       *progressBackgroundColor;//进度条的背景色

/**
 update slider time
 更新进度条时间
 
 @param time slider time
 */
-(void)updateSliderTime:(NSTimeInterval)time;

/**
 set starttime label text
 设置开始时间文本

 @param time start time
 */
-(void)setStartTimeText:(NSTimeInterval)time;

/**
 reset time slider
 恢复进度条
 
 */
-(void)resetTimeSlider;

/**
 set progress thumb Color
 设置进度条滑块的颜色
 
 @param color color
 */
-(void)setProgressThumbColor:(UIColor *)color;

/**
 set progress min track color
 设置进度条填充的颜色

 @param color color
 */
-(void)setProgressMinTrackColor:(UIColor *)color;

/**
 set progress max track color
 设置进度条填充的颜色
 
 @param color color
 */
-(void)setProgressMaxTrackColor:(UIColor *)color;
@end
