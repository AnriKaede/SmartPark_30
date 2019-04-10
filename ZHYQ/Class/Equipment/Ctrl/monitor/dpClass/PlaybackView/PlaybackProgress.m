//
//  PlaybackProgress.m
//  Pods
//
//  Created by chenfeifei on 2017/3/31.
//
//

#import "PlaybackProgress.h"

#define RunOnMainThread(code)   {dispatch_async(dispatch_get_main_queue(), ^{code;});}

@interface PlaybackProgress()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (nonatomic,assign) NSTimeInterval oldValue;

@end

@implementation PlaybackProgress

#pragma mark--初始化
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self LoadNibName];
    }
    
    return self;

}
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self LoadNibName];
    }
    
    return self;
}
-(void)LoadNibName
{
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
    
    
    view.frame = self.bounds;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.translatesAutoresizingMaskIntoConstraints = YES;
    
    [self addSubview:view];
}

-(void)awakeFromNib
{
    [super awakeFromNib];

}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    self.contentView.backgroundColor = backgroundColor;
    [self.contentView.subviews makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:backgroundColor];
}

#pragma mark--时间设置
-(void)setStartTime:(NSTimeInterval)startTime
{
    if (startTime < 0) {
        startTime = 0;
    }
    
    _startTime = startTime;
    NSString *strStartTime = [self stringBeginWithHourOfTimeNow:startTime];
    [self.startTimeLabel setText:strStartTime];
    
    _progressSlider.minimumValue = 0;
}
-(void)setEndTime:(NSTimeInterval)endTime
{
    if (endTime > _startTime && endTime > 0) {
        
        _endTime = endTime - 1;
        [_endTimeLabel setText:[self stringBeginWithHourOfTimeNow:_endTime]];
        _progressSlider.maximumValue = _endTime -_startTime;
        [_progressSlider setEnabled:YES];
    }
    else
    {
        //结束时间不正确 恢复默认 不允许滑动
        [self resetTimeSlider];
        _endTime = _startTime;
        _progressSlider.maximumValue = _progressSlider.minimumValue;
    }
}
-(void)updateSliderTime:(NSTimeInterval)time
{
    _oldValue = time - _startTime;
    
    if (!_progressSlider.isTouchInside) {
        RunOnMainThread(_progressSlider.value = time -_startTime;);
    }
}

-(void)setStartTimeText:(NSTimeInterval)time
{
    RunOnMainThread(
                    _startTimeLabel.text = [self stringBeginWithHourOfTimeNow:time];
                    );
}
-(void)setProgressThumbColor:(UIColor *)color
{
     [_progressSlider setThumbTintColor:color];
}
#pragma mark--颜色设置
-(void)setColorStartText:(UIColor *)colorStartText
{
    [self.startTimeLabel setTextColor:colorStartText];

}
-(void)setColorEndTimeText:(UIColor *)colorEndTimeText
{
    [self.endTimeLabel setTextColor:colorEndTimeText];
}
//设置进度条背景
-(void)setProgressBackgroundColor:(UIColor *)progressBackgroundColor
{
    [self setBackgroundColor:progressBackgroundColor];
}

-(void)setProgressMinTrackColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [_progressSlider setMinimumTrackImage:image forState:UIControlStateNormal];

}
//设置进度条填充的颜色
-(void)setProgressMaxTrackColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
   [_progressSlider setMaximumTrackImage:image forState:UIControlStateNormal];
}
-(void)resetTimeSlider
{
    _startTime = 0;
    _endTime   = 0;
    _progressSlider.value = 0;
    _progressSlider.maximumValue = 0;
    _progressSlider.minimumValue = 0;
    _startTimeLabel.text = @"00:00:00";
    _endTimeLabel.text   = @"00:00:00";
}

- (IBAction)sliderTouchUp:(id)sender {
   
    //定位到0.5s的差距
    float absDiff = _oldValue > _progressSlider.value ? _oldValue - _progressSlider.value :
    _progressSlider.value - _oldValue;
    if (absDiff > 0.5 &&
        [_delegate respondsToSelector:@selector(playbackProgressSeekAtTime:)])
    {
        NSTimeInterval seekTime = 0;
        if (_progressSlider.value + _startTime < _startTime) {
            seekTime = _startTime;
            _progressSlider.value = 0;
        }
        else if(_progressSlider.value  > _endTime)
        {
            seekTime = _endTime;
            _progressSlider.value = _endTime - _startTime;
        }
        else
        {
            seekTime = _progressSlider.value + _startTime;
        }
        
        [_delegate playbackProgressSeekAtTime:seekTime];
        _oldValue = _progressSlider.value;
    }
    
}
- (IBAction)sliderTouchCancel:(id)sender {
  
    //定位到0.5s的差距
    float absDiff = _oldValue > _progressSlider.value ? _oldValue - _progressSlider.value :
    _progressSlider.value - _oldValue;
    
    if (absDiff > 0.5 &&
        [_delegate respondsToSelector:@selector(playbackProgressSeekAtTime:)])
    {
        NSTimeInterval seekTime = 0;
        if (_progressSlider.value + _startTime < _startTime) {
            seekTime = _startTime;
            _progressSlider.value = 0;
        }
        else if(_progressSlider.value + _endTime > _endTime)
        {
            seekTime = _endTime;
            _progressSlider.value = _endTime - _startTime;
        }
        else
        {
            seekTime = _progressSlider.value + _startTime;
        }
        
        [_delegate playbackProgressSeekAtTime:seekTime];
        _oldValue = _progressSlider.value;
    }
}
- (IBAction)sliderValueChange:(id)sender {
    if (_endTime <= _startTime)
    {
        return;
    }
  
    double fPos = _progressSlider.value;
    double width = _progressSlider.frame.size.width;
    double origin = _progressSlider.frame.origin.x;
    double x = (width - 20) * (fPos - _progressSlider.minimumValue) /
    (_progressSlider.maximumValue - _progressSlider.minimumValue) + origin + 10;
}
#pragma mark--时间转换功能
-(NSDateFormatter*)dateFormatter
{
    NSTimeZone * tz = [NSTimeZone localTimeZone];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:tz];
    return formatter;
}
/** 转化为以时钟开始的字符串 起始时间为当前时间 */
-(NSString *)stringBeginWithHourOfTimeNow:(NSTimeInterval)time
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm:ss"];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |
    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
     NSDateComponents *components = [calendar components:unitFlags fromDate:date];
    
    NSInteger year = components.year;
    if (year <= 1970) {
        return [NSString stringWithFormat:@"%02d:%02d:%02d", (int)time/3600, ((int)time/60)%60, (int)time%60];
    }
    else
    {
        NSString *strTime = [formatter stringFromDate:date];
        return strTime;
    }
}
@end
