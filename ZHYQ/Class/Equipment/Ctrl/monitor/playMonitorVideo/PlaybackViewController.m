//
//  PlaybackViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/2.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "PlaybackViewController.h"
#import "PlaybackManager.h"
#import "WSDatePickerView.h"
#import "DHVideoWnd.h"
#import "DHHudPrecess.h"

#import "MonitorTimeViewController.h"

@interface PlaybackViewController ()<SelTimeDelegate>
{
    UILabel *startLabel;
    UILabel *endLabel;
    
    UIView *_startTimeView;
    UIView *_endTimeView;
    UIButton *_searchBt;
    
    UIButton *_colseBt;
    BOOL _isHidBar;
    
    NSInteger _timeIndex;
    
    UIPickerView *_speedPicker;
    UIToolbar *accessoryView;
    
    NSMutableArray *_speedData;
    NSInteger _currentRow;
}
@end

@implementation PlaybackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _speedData = @[@"正常",@"2倍",@"4倍",@"8倍",@"1/2倍",@"1/4倍",@"1/8倍"].mutableCopy;
    _timeIndex = 0;
    
    [self _initPlayView];
    
    [self _initView];
    
    // 禁止左滑
    id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
    [self.view addGestureRecognizer:pan];
}

- (void)_initPlayView {
    CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 400*hScale);
    playbackView_ = [[PlayBackView alloc]initWithFrame:rect delegate:self];
    [self.view addSubview:playbackView_];
    
    rect.origin.y += CGRectGetHeight(playbackView_.frame);
    controlBar_ = [[PlayControlBar alloc]initWithFrame:rect delegate:self];
    [self.view addSubview:controlBar_];
    
    [[PlaybackManager sharedInstance]initPlaybackManager];
    
    [self startTimer];
    [self pauseTimer];
    
    [PlaybackManager sharedInstance].recordResourceValue = 3;
    [PlaybackManager sharedInstance].recordTypeValue = 0;
    [PlaybackManager sharedInstance].isPlayBackByFile = YES;
    
    pView = [[UIApplication sharedApplication] keyWindow];
    if(NULL == pView)
    {
        return;
    }
    
    //回放设置功能的回调函数
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setTimeText:) name:@"SetTimeNotification" object:nil];
    
    UITapGestureRecognizer *fullTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullAction)];
    fullTap.numberOfTapsRequired = 2;
    [playbackView_ addGestureRecognizer:fullTap];
    
    _colseBt = [UIButton buttonWithType:UIButtonTypeCustom];
    _colseBt.hidden = YES;
    _colseBt.frame = CGRectMake(KScreenWidth - 80, KScreenHeight - 60, 50, 50);
    if(KScreenWidth > 440){ // ipad
        _colseBt.frame = CGRectMake(KScreenWidth - 80, KScreenHeight - 60 - 44, 50, 50);
    }else {
        _colseBt.frame = CGRectMake(KScreenWidth - 80, KScreenHeight - 60, 50, 50);
    }
    [_colseBt setBackgroundImage:[UIImage imageNamed:@"show_menu_close"] forState:UIControlStateNormal];
    [_colseBt addTarget:self action:@selector(closeFull) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_colseBt];
}

- (void)_initView {
    self.view.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    
    self.title = @"历史录像";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    // 开始时间
    _startTimeView = [[UIView alloc] initWithFrame:CGRectMake(0, controlBar_.bottom + 5, KScreenWidth, 60)];
    _startTimeView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_startTimeView];
    UITapGestureRecognizer *startTimeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startTime)];
    [_startTimeView addGestureRecognizer:startTimeTap];
    
    UILabel *startTitleLabel = [[UILabel alloc] init];
    startTitleLabel.frame = CGRectMake(10,20,75,17);
    startTitleLabel.text = @"查看日期: ";
    startTitleLabel.font = [UIFont systemFontOfSize:17];
    startTitleLabel.textColor = [UIColor colorWithRed:0/255 green:0/255 blue:0/255 alpha:1];
    [_startTimeView addSubview:startTitleLabel];
    
    startLabel = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth - 215, 21, 180, 20)];
    startLabel.text = @"请选择需要查看的日期";
    startLabel.textColor = [UIColor grayColor];
    startLabel.font = [UIFont systemFontOfSize:17];
    startLabel.textAlignment = NSTextAlignmentRight;
    [_startTimeView addSubview:startLabel];
    
    UIImageView *startImgView = [[UIImageView alloc] initWithFrame:CGRectMake(KScreenWidth - 30, 20, 20, 20)];
    startImgView.image = [UIImage imageNamed:@"door_list_right_narrow"];
    [_startTimeView addSubview:startImgView];
    
    UIView *lineVie = [[UIView alloc] initWithFrame:CGRectMake(0, _startTimeView.height - 0.5, KScreenWidth, 0.5)];
    lineVie.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    [_startTimeView addSubview:lineVie];
    
    // 结束时间
    _endTimeView = [[UIView alloc] initWithFrame:CGRectMake(0, _startTimeView.bottom, KScreenWidth, 60)];
    _endTimeView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_endTimeView];
    UITapGestureRecognizer *endTimeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endTime)];
    [_endTimeView addGestureRecognizer:endTimeTap];
    
    UILabel *endTitleLabel = [[UILabel alloc] init];
    endTitleLabel.frame = CGRectMake(10,20,75,17);
    endTitleLabel.text = @"查看时段: ";
    endTitleLabel.font = [UIFont systemFontOfSize:17];
    endTitleLabel.textColor = [UIColor colorWithRed:0/255 green:0/255 blue:0/255 alpha:1];
    [_endTimeView addSubview:endTitleLabel];
    
    endLabel = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth - 215, 21, 180, 20)];
    endLabel.text = @"请选择需要查看的时段";
    endLabel.textColor = [UIColor grayColor];
    endLabel.font = [UIFont systemFontOfSize:17];
    endLabel.textAlignment = NSTextAlignmentRight;
    [_endTimeView addSubview:endLabel];
    
    UIImageView *endImgView = [[UIImageView alloc] initWithFrame:CGRectMake(KScreenWidth - 30, 20, 20, 20)];
    endImgView.image = [UIImage imageNamed:@"door_list_right_narrow"];
    [_endTimeView addSubview:endImgView];
    
    // 查询按钮
    _searchBt = [UIButton buttonWithType:UIButtonTypeCustom];
    _searchBt.hidden = YES;
    _searchBt.frame = CGRectMake((KScreenWidth - 120)/2, _endTimeView.bottom + 20, 120, 50);
    _searchBt.layer.borderColor = [UIColor grayColor].CGColor;
    _searchBt.layer.borderWidth = 0.6;
    _searchBt.layer.cornerRadius = 4;
    _searchBt.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF"];
    [_searchBt setTitle:@"搜索播放" forState:UIControlStateNormal];
    [_searchBt setImage:[UIImage imageNamed:@"play_search"] forState:UIControlStateNormal];
    [_searchBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_searchBt addTarget:self action:@selector(onBtnQueryRecord) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_searchBt];
    
    // 速度选择器
    _speedPicker = [[UIPickerView alloc]init];
    _speedPicker.hidden = YES;
    _speedPicker.frame = CGRectMake(0, KScreenHeight - 215 - 64, KScreenWidth, 215);
    _speedPicker.backgroundColor = [UIColor whiteColor];
    _speedPicker.delegate = self;
    _speedPicker.dataSource = self;
    [self.view addSubview:_speedPicker];
    
    accessoryView = [[UIToolbar alloc] init];
    accessoryView.hidden = YES;
    accessoryView.frame=CGRectMake(0, _speedPicker.top - 38, KScreenWidth, 38);
    accessoryView.backgroundColor = [UIColor grayColor];
    UIBarButtonItem *cancelBtn=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(calcelAction)];
    UIBarButtonItem *doneBtn=[[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(selectDoneAction)];
    UIBarButtonItem *spaceBtn=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    accessoryView.items=@[cancelBtn,spaceBtn,doneBtn];
    [self.view addSubview:accessoryView];
}
- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
    // 释放定时器
    if ([progressTimer_ isValid])
    {
        [progressTimer_ invalidate];
        progressTimer_ = nil;
    }
    
    [[PlaybackManager sharedInstance] stopPlayback];
}

-(BOOL)prefersStatusBarHidden
{
    return _isHidBar;
}
#pragma mark 全屏显示
- (void)fullAction {
    _isHidBar = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.navigationBar.hidden = YES;
    _colseBt.hidden = NO;
    playbackView_.userInteractionEnabled = NO;
    
    // 隐藏控制按钮放置点击
    _startTimeView.hidden = YES;
    _endTimeView.hidden = YES;
    _searchBt.hidden = YES;
    
    controlBar_.hidden = YES;
    
    _speedPicker.hidden = YES;
    accessoryView.hidden = YES;
    
    // 改变视频frame
    playbackView_.transform = CGAffineTransformRotate(playbackView_.transform, M_PI_2);
//    controlBar_.transform = CGAffineTransformRotate(controlBar_.transform, M_PI_2);
    if(KScreenWidth > 440){ // ipad
//        playbackView_.frame = CGRectMake(KScreenWidth, -44, -KScreenWidth, KScreenHeight);
    }else {
        playbackView_.frame = CGRectMake(KScreenWidth, 0, -KScreenWidth, KScreenHeight);
        playbackView_.backgroundColor = [UIColor orangeColor];
        playbackView_.videoWnd.frame = CGRectMake(0, 0, KScreenHeight, KScreenWidth);
    
        UIScrollView *bgScrollView = [playbackView_ viewWithTag:2001];
        bgScrollView.frame = CGRectMake(0, 0, KScreenHeight, KScreenWidth);
        
//        controlBar_.frame = CGRectMake(70, 0, -70, KScreenHeight);
    }
}
- (void)closeFull {
    _isHidBar = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.navigationBar.hidden = NO;
    _colseBt.hidden = YES;
    playbackView_.userInteractionEnabled = YES;
    
    _startTimeView.hidden = NO;
    _endTimeView.hidden = NO;
//    _searchBt.hidden = NO;
    
    controlBar_.hidden = NO;
    
    playbackView_.transform = CGAffineTransformRotate(playbackView_.transform, -M_PI_2);
    CGRect frame = CGRectMake(0, 0, KScreenWidth, 400*hScale);
    float proportion   = frame.size.width / 718;
    frame.size.height  = 480*proportion;
    playbackView_.frame = frame;
    playbackView_.videoWnd.frame = frame;
    
    UIScrollView *bgScrollView = [playbackView_ viewWithTag:2001];
    bgScrollView.frame = frame;
}

- (void)startTime {
    [PlaybackManager sharedInstance].isStartTime = YES;
    
    WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDay scrollToDate:[NSDate date] CompleteBlock:^(NSDate *selectDate) {
        NSString *date = [selectDate stringWithFormat:@"yyyy-MM-dd"];
        startLabel.text = date;
        startLabel.textColor = [UIColor blackColor];
        
    }];
    datepicker.dateLabelColor = [UIColor colorWithHexString:@"1B82D1"];//年-月-日-时-分 颜色
    datepicker.datePickerColor = [UIColor blackColor];//滚轮日期颜色
    datepicker.doneButtonColor = [UIColor colorWithHexString:@"1B82D1"];//确定按钮的颜色
    datepicker.yearLabelColor = [UIColor clearColor];//大号年份字体颜色
    [datepicker show];
}

- (void)endTime {
    if([startLabel.text isEqualToString:@"请选择需要查看的日期"]){
        [self showHint:@"请先选择需要查看的日期"];
        return;
    }
    
    [PlaybackManager sharedInstance].isStartTime = NO;
    
//    endLabel.text = date;
    
    MonitorTimeViewController *timeVC = [[MonitorTimeViewController alloc] init];
    timeVC.queryDate = startLabel.text;
    timeVC.timeDelegate = self;
    [self.navigationController pushViewController:timeVC animated:YES];
}
- (void)selTime:(NSInteger)index withRange:(NSString *)timeRange {
    endLabel.textColor = [UIColor blackColor];
    endLabel.text = timeRange;
    
    _timeIndex = index;
    
    // 直接调用播放
    [self playControlOpenPlay];
}

#pragma mark 查询方法
- (void)onBtnQueryRecord {
    
    [[DHHudPrecess sharedInstance]showWaiting:@""
                               WhileExecuting:@selector(threadQueryRecord)
                                     onTarget:self
                                   withObject:Nil
                                     animated:NO
                                       atView:KEYWINDOW];
}

#pragma mark 通知方法
-(void)setTimeText:(NSNotification*) notification
{
    NSDictionary* theData = [notification userInfo];
    NSDate* theDate = [theData objectForKey:@"timeText"];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    if([PlaybackManager sharedInstance].isStartTime == YES)
    {
        startLabel.text = [dateFormatter stringFromDate:theDate];
    }
    else
    {
        endLabel.text = [dateFormatter stringFromDate:theDate];
    }
}

#pragma mark 播放速度
- (void)playControlSetSpeed {
    _speedPicker.hidden = NO;
    accessoryView.hidden = NO;
}

#pragma mark 视频操作协议
- (void)timerProcess:(NSTimer *)timer
{
    PlaybackManager *pManager = [PlaybackManager sharedInstance];
    int playedTime = [pManager playedTime];
    
    //设置播放进度条(未处于seek状态时才更新)
//    if (!isSeeking_)
    
    // 判断回放是否播放完毕
    {
        [controlBar_ updatePlayProgress:playedTime];
        NSLog(@"----进度已播放时间：%ld", playedTime);
    }
}

- (void)startTimer
{
    if (![progressTimer_ isValid])
    {
        progressTimer_ = [NSTimer scheduledTimerWithTimeInterval:0.2f
                                                          target:self
                                                        selector:@selector(timerProcess:)
                                                        userInfo:Nil
                                                         repeats:YES];
    }
}

- (void)stopTimer
{
    if ([progressTimer_ isValid])
    {
        [progressTimer_ invalidate];
        progressTimer_ = nil;
    }
}

- (void)pauseTimer
{
    if (![progressTimer_ isValid])
    {
        return ;
    }
    
    [progressTimer_ setFireDate:[NSDate distantFuture]];
}

- (void)resumeTimer
{
    if (![progressTimer_ isValid])
    {
        return ;
    }
    
    [progressTimer_ setFireDate:[NSDate date]];
}
// 回放播放完毕
- (void)playControlTimerEnd {
    NSLog(@"+++++++播放完成");
//    [PlaybackManager sharedInstance].playbackSpeed = DPSDK_CORE_PB_NORMAL;
    [self playControlStopPlay];
}

#pragma mark 查询
- (void)threadQueryRecord
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    
    NSTimeZone* localzone = [NSTimeZone localTimeZone];
    NSTimeZone* GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [dateFormatter setTimeZone:GTMzone];
    
    NSDate *queryDate =[dateFormatter dateFromString:startLabel.text];
    NSDate *laterDate =[dateFormatter dateFromString:endLabel.text];

    int nError = [[PlaybackManager sharedInstance]queryRecordByStart:queryDate withEnd:laterDate];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([PlaybackManager sharedInstance].isFileExisted == NO) {
            [self showHint:@"该时间段内没有录像"];
        }else if (0 != nError) {
            [self showHint:@"查询失败"];
        }
        // 查询成功 直接播放
        if(nError == 0) {
            // 停止
            [self playControlStopPlay];
            // 播放
            [self playControlOpenPlay];
        }
    });
    
}

#pragma mark - PlayControl Delegate
- (void)playControlOpenPlay
{
    // 回归正常播放速度，停止正在播放
    NSDictionary* dataDict = [NSDictionary dictionaryWithObject:@"正常" forKey:@"playbackSpeedText"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SetPlaybackSpeedNotification" object:nil userInfo:dataDict];
    [[PlaybackManager sharedInstance] stopPlayback];
    
    if ([PlaybackManager sharedInstance].isFileExisted)
    {
        [[DHHudPrecess sharedInstance]showWaiting:@"正在请求码流..."
                                   WhileExecuting:@selector(threadOpenPlayback)
                                         onTarget:self
                                       withObject:Nil
                                         animated:NO
                                           atView:KEYWINDOW];
    }
    else
    {
        [controlBar_ resetOpenFailed];
    }
}

- (void)playControlStopPlay
{
    [[PlaybackManager sharedInstance]stopPlayback];
    [self pauseTimer];
}

- (void)playControlPausePlay:(BOOL)paused
{
    [[PlaybackManager sharedInstance]pausePlayback:paused];
    paused ? [self pauseTimer] : [self resumeTimer];
}

- (void)playControlMuted:(BOOL)muted{
    if (muted) {
        [[PlaybackManager sharedInstance] closeVoice];
    }else{
        [[PlaybackManager sharedInstance] openVoice];
    }
}

- (void)playControlSliderValueChanged:(NSTimeInterval)value{
    [[PlaybackManager sharedInstance] pausePlayback:YES];
    [self pauseTimer];
    [[PlaybackManager sharedInstance ] seekByTime:value];
    [[PlaybackManager sharedInstance] pausePlayback:NO];
    sleep(1);
    [self resumeTimer];
    
    NSDictionary* dataDict = [NSDictionary dictionaryWithObject:@"正常" forKey:@"playbackSpeedText"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SetPlaybackSpeedNotification" object:nil userInfo:dataDict];
}

static NSDate * extracted(PlaybackManager *pManager) {
    return [pManager endTimeOfFile:0];
}

- (void)threadOpenPlayback
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showHudInView:self.view hint:@""];
    });
    
    int nRet;
    if(![PlaybackManager sharedInstance].isPlayBackByFile)
    {
        nRet = [[PlaybackManager sharedInstance]playBackByTimeOnWindow:(__bridge void *)playbackView_.videoWnd];
    }
    else
    {
        nRet = [[PlaybackManager sharedInstance]playBackByFile:_timeIndex onWindow:(__bridge void *)(playbackView_.videoWnd)];
    }
    
    if (0 != nRet)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showHint:@"播放失败"];
        });
        [controlBar_ resetOpenFailed];
    }
    PlaybackManager *pManager = [PlaybackManager sharedInstance];
    if(![PlaybackManager sharedInstance].isPlayBackByFile){
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
        NSDate *begin = [dateFormatter dateFromString:startLabel.text];
        NSDate *end = [dateFormatter dateFromString:endLabel.text];
        NSTimeInterval interval =[end timeIntervalSince1970] - [begin timeIntervalSince1970];
        [controlBar_ setTimeInterval:interval];
        [controlBar_ setBeginTime:begin
                       andEndTime:end];
        
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [controlBar_ setTimeInterval:[pManager timeIntervalOfFile:_timeIndex]];
            [controlBar_ setBeginTime:[pManager beginTimeOfFile:_timeIndex] andEndTime:[pManager endTimeOfFile:_timeIndex]];
        
            [self hideHud];
        });
    }
    
    [controlBar_ openPlay];
    [self resumeTimer];
}

#pragma mark UIPickView协议
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _speedData.count;
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _speedData[row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _currentRow = row;
}

#pragma mark datepicker tool方法
- (void)calcelAction {
    _speedPicker.hidden = YES;
    accessoryView.hidden = YES;
}

- (void)selectDoneAction {
    _speedPicker.hidden = YES;
    accessoryView.hidden = YES;
    
    NSString* playbackSpeed = [_speedData objectAtIndex:_currentRow];
    switch (_currentRow) {
        case 0:
            [PlaybackManager sharedInstance].playbackSpeed = DPSDK_CORE_PB_NORMAL;
            break;
        case 1:
            [PlaybackManager sharedInstance].playbackSpeed = DPSDK_CORE_PB_FAST2;
            break;
        case 2:
            [PlaybackManager sharedInstance].playbackSpeed = DPSDK_CORE_PB_FAST4;
            break;
        case 3:
            [PlaybackManager sharedInstance].playbackSpeed = DPSDK_CORE_PB_FAST8;
            break;
//        case 4:
//            [PlaybackManager sharedInstance].playbackSpeed = DPSDK_CORE_PB_FAST16;
            break;
        case 4:
            [PlaybackManager sharedInstance].playbackSpeed = DPSDK_CORE_PB_SLOW2;
            break;
        case 5:
            [PlaybackManager sharedInstance].playbackSpeed = DPSDK_CORE_PB_SLOW4;
            break;
        case 6:
            [PlaybackManager sharedInstance].playbackSpeed = DPSDK_CORE_PB_SLOW8;
            break;
        default:
            break;
    }
    NSDictionary* dataDict = [NSDictionary dictionaryWithObject:playbackSpeed forKey:@"playbackSpeedText"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SetPlaybackSpeedNotification" object:nil userInfo:dataDict];
}

@end
