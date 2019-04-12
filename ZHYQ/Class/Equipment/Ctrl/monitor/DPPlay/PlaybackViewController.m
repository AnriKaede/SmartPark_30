//
//  PlaybackViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/2.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "PlaybackViewController.h"
//#import "PlaybackManager.h"
#import "WSDatePickerView.h"
//#import "DHVideoWnd.h"
//#import "DHHudPrecess.h"

#import "DHPlaybackManager.h"
#import "DHLoginManager.h"
#import "DHDataCenter.h"
#import "PlaybackProgress.h"
#import "ZComBoxView.h"
#import "DHPlayWindow.h"
#import "DPSPBCamera.h"

#import "MonitorTimeViewController.h"

@interface PlaybackViewController ()<SelTimeDelegate, MediaPlayListenerProtocol, PlaybackProgressDelegate>
{
    UILabel *startLabel;
    UILabel *endLabel;
    
    UIView *_startTimeView;
    UIView *_endTimeView;
    
    BOOL _isHidBar;
    
    UIButton *_colseBt;
}
#pragma mark 大华新SDK
@property (weak, nonatomic) IBOutlet DHPlayWindow *dhPlayWindow;   //播放窗口 play window
@property (weak, nonatomic) IBOutlet UIView *toolBgView;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;            //播放按钮 play button
@property (weak, nonatomic) IBOutlet UIButton *voiceBtn;           //声音按钮 voice button
@property (weak, nonatomic) IBOutlet UIButton *speedBtn;           //播放速度 play speed button
@property (weak, nonatomic) IBOutlet PlaybackProgress *playbackProgress;  //进度条 progress
@property (copy, nonatomic) NSString *selectChannelId;              //通道id selected channelid
@property (strong, nonatomic) DSSRecordInfo *selectRecord;             //选中录像 selected recordinfo
@property (assign, nonatomic) NSTimeInterval timeFileSeeking;    //seek的时间 seek time
@property (assign, nonatomic) BOOL bSeeking;                 //是否正在定位中 is seeking
@property (assign, nonatomic) float playSpeed;                //播放速度 play speed

@end

@implementation PlaybackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
    
    [self setupDP];
    
    // 禁止左滑
    id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
    [self.view addGestureRecognizer:pan];
}

- (void)setupDP {
    self.selectChannelId = ((DSSChannelInfo *)[DHDataCenter sharedInstance].selectNode.content).channelid;
    //初始化播放窗口数，正常情况下，使用1
    [self.dhPlayWindow defultwindows:1];
    //init play window
    DSSUserInfo *userinfo = [DHLoginManager sharedInstance].userInfo;
    NSString *host = [[DHDataCenter sharedInstance].coreAdapter getHost];
    int port = [[DHDataCenter sharedInstance].coreAdapter getPort];
    [self.dhPlayWindow setHost:host Port:port UserName:userinfo.userName];
    [self.dhPlayWindow addMediaPlayListener:self];
    self.dhPlayWindow.hideDefultToolViews = YES;
    
    self.playSpeed = 1.0;
    self.playbackProgress.delegate = self;
    self.playBtn.selected = YES;
    // 初始化
    // 开始播放
//    [self startPlayback];
}

- (void)startPlayback {
    NSString* channelid = self.selectChannelId;
    if (!channelid.length || !self.selectRecord) {
        return;
    }
    RecordSource recordSource = RecordSource_platform;
    NSMutableArray<DPSPBCameraArg*>* arrDPSPBCameraArg = [[NSMutableArray alloc] initWithCapacity:1];
    DPSPBCameraArg* arg = [[DPSPBCameraArg alloc] init];
    arg.fileName = _selectRecord.name;
    arg.ssId = _selectRecord.dssExtendRecordInfo.ssId;
    arg.fileHander = _selectRecord.dssExtendRecordInfo.fileHandle;
    arg.diskId = _selectRecord.dssExtendRecordInfo.diskId;
    arg.startTime = [NSDate dateWithTimeIntervalSince1970:_selectRecord.startTime];
    arg.endTime = [NSDate dateWithTimeIntervalSince1970:_selectRecord.endTime];
    arg.filelen = _selectRecord.length;
    arg.recordSource = 1;////1-所有 all 2-设备录像 device record 3-平台录像 platform record
    if (_selectRecord.source == RecordSource_all)
        arg.recordSource = 1;
    else if (_selectRecord.source == RecordSource_device)
        arg.recordSource = 2;
    else if (_selectRecord.source == RecordSource_platform)
        arg.recordSource = 3;
    [arrDPSPBCameraArg addObject:arg];
    recordSource = _selectRecord.source;
    if ([arrDPSPBCameraArg count] == 0) {
        return;
    }
    //初始化播放信息
    // init camera
    DSSUserInfo *userinfo = [DHLoginManager sharedInstance].userInfo;
    NSString *host = [[DHDataCenter sharedInstance].coreAdapter getHost];
    int port = [[DHDataCenter sharedInstance].coreAdapter getPort];
    NSNumber* handleDPSDKEntity = (NSNumber*)[userinfo getInfoValueForKey:kUserInfoHandleDPSDKEntity];
    // NSString* handleRestToken = [[DHDataCenter sharedInstance] getLoginToken];
    DPSPBCamera* ymCamera = [[DPSPBCamera alloc] init];
    ymCamera.arrayCameraArg = arrDPSPBCameraArg;
    ymCamera.cameraId = channelid;
    //录像用按照时间播放， 中心文件 按照 文件播放
    ymCamera.isPlayBackByTime = (recordSource == RecordSource_device);
    ymCamera.dpHandle = [handleDPSDKEntity longValue];
    //  ymCamera.dpRestToken = handleRestToken;
    ymCamera.server_ip = host;
    ymCamera.server_port = port;
    ymCamera.needBeginTime = 0;
    
    DSSChannelInfo *channelInfo = (DSSChannelInfo *)[DHDataCenter sharedInstance].selectNode.content;
    DSSDeviceInfo *deviceInfo = [[DHDeviceManager sharedInstance] getDeviceInfo:[channelInfo deviceId]];
    
    [self.dhPlayWindow playCamera:ymCamera withName:channelInfo.name?:@"" at:0 deviceProvide:deviceInfo.deviceProvide];
    [self.dhPlayWindow setEnableElectricZoom:0 enable:YES];
    
    self.playbackProgress.startTime = _selectRecord.startTime;
    self.playbackProgress.endTime = _selectRecord.endTime;
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
    #warning 大华SDK旧版本
    _startTimeView = [[UIView alloc] initWithFrame:CGRectMake(0, _toolBgView.bottom + 5, KScreenWidth, 60)];
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
- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
    
    // 停止播放
    #warning 大华SDK旧版本
//    [[PlaybackManager sharedInstance] stopPlayback];
}

#warning 大华SDK旧版本
#pragma mark 全屏显示
- (void)fullAction {
    _isHidBar = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.navigationBar.hidden = YES;
    _colseBt.hidden = NO;
    _dhPlayWindow.userInteractionEnabled = NO;
    
    // 隐藏控制按钮放置点击
    _startTimeView.hidden = YES;
    _endTimeView.hidden = YES;
    
    _toolBgView.hidden = YES;
    
    // 改变视频frame
    _dhPlayWindow.transform = CGAffineTransformRotate(_dhPlayWindow.transform, M_PI_2);
    if(KScreenWidth > 440){ // ipad
//        playbackView_.frame = CGRectMake(KScreenWidth, -44, -KScreenWidth, KScreenHeight);
    }else {
        _dhPlayWindow.frame = CGRectMake(KScreenWidth, 0, -KScreenWidth, KScreenHeight);
        _dhPlayWindow.backgroundColor = [UIColor orangeColor];
        _dhPlayWindow.frame = CGRectMake(0, 0, KScreenHeight, KScreenWidth);
    
        UIScrollView *bgScrollView = [_dhPlayWindow viewWithTag:2001];
        bgScrollView.frame = CGRectMake(0, 0, KScreenHeight, KScreenWidth);
    }
}
- (void)closeFull {
    _isHidBar = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.navigationBar.hidden = NO;
    _colseBt.hidden = YES;
    _dhPlayWindow.userInteractionEnabled = YES;
    
    _startTimeView.hidden = NO;
    _endTimeView.hidden = NO;

    _toolBgView.hidden = NO;
    
    _dhPlayWindow.transform = CGAffineTransformRotate(_dhPlayWindow.transform, -M_PI_2);
    CGRect frame = CGRectMake(0, 0, KScreenWidth, 400*hScale);
    float proportion   = frame.size.width / 718;
    frame.size.height  = 480*proportion;
    _dhPlayWindow.frame = frame;
    
    UIScrollView *bgScrollView = [_dhPlayWindow viewWithTag:2001];
    bgScrollView.frame = frame;
}
-(BOOL)prefersStatusBarHidden
{
    return _isHidBar;
}

- (void)startTime {
    #warning 大华SDK旧版本
//    [PlaybackManager sharedInstance].isStartTime = YES;
    
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
    
    #warning 大华SDK旧版本
//    [PlaybackManager sharedInstance].isStartTime = NO;
    
    MonitorTimeViewController *timeVC = [[MonitorTimeViewController alloc] init];
    timeVC.queryDate = startLabel.text;
    timeVC.timeDelegate = self;
    [self.navigationController pushViewController:timeVC animated:YES];
}
- (void)selTime:(NSInteger)index withRange:(NSString *)timeRange withDSSRecordInfo:(DSSRecordInfo *)recordInfo {
    endLabel.textColor = [UIColor blackColor];
//    endLabel.text = timeRange;
    
//    _timeIndex = index;
#pragma mark 返回查询的recordInfo
    self.selectRecord = recordInfo;
    // 直接调用播放
    [self startPlayback];
}

#pragma mark 大华新SDK协议方法
#pragma mark - MediaPlayListenerProtocol
//播放时间回调 play time callback
- (void) onPlayTime:(int)winIndex time:(long)time stamp:(int)stamp{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!_bSeeking) {
            [self.playbackProgress updateSliderTime:time];
            [self.playbackProgress setStartTimeText:time];
        }
    });
}
//播放状态回调 play status Callback
- (void) onPlayeStatusCallback:(int)winIndex status:(PlayStatusType)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.voiceBtn.selected = [self.dhPlayWindow isAudioOpened:0];
        
        switch (status) {
            case ePlayFirstFrame:
            {
                _bSeeking = NO;
                _timeFileSeeking = 0;
                self.playBtn.selected = YES;
                [self.dhPlayWindow setPlaySpeed:self.playSpeed atWinIndex:0];
            }
                break;
            case ePlayDataOver:
            {
                [self stopPlay];
            }
                break;
            case eNetworkaAbort:
            {
                NSLog(@"Network error");
                [self stopPlay];
            }
                break;
            case ePlayFailed:
            {
                NSLog(@"Play error");
                [self stopPlay];
            }
                break;
            case eBadFile:
            {
                NSLog(@"Play file error");
                [self stopPlay];
            }
                break;
            case eSeekSuccess:
            {
                _bSeeking = NO;
                _timeFileSeeking = 0;
                self.playBtn.selected = YES;
            }
                break;
            case eSeekFailed:
            {
                NSLog(@"Failed to drag");
                _bSeeking = NO;
                _timeFileSeeking = 0;
                [self pausePlay];
            }
                break;
            case eSeekCrossBorder:
            {
                NSLog(@"No record");
                _bSeeking = NO;
                _timeFileSeeking = 0;
                [self pausePlay];
            }
                break;
            case ePlayNoAuthority:
            {
                NSLog(@"No video play right");
                [self stopPlay];
            }
                break;
            default:
                break;
        }
    });
}

/** 转化为以时钟开始的字符串 起始时间为当前时间 */
// transform time
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

#pragma mark--PlaybackProgressDelegate 进度条
-(void)playbackProgressSeekAtTime:(NSTimeInterval)seekTime
{
    [self seek:seekTime];
}

-(void)seek:(NSTimeInterval)seekTime
{
    _timeFileSeeking = (int)seekTime;
    Camera *camera = [_dhPlayWindow getCamera:0];
    if (camera == nil) {
        return;
    } else {
        _bSeeking = YES;  //定位中
        [_dhPlayWindow seek:0 byTime:seekTime];
        sleep(1);
        [_dhPlayWindow setPlaySpeed:self.playSpeed atWinIndex:0];
    }
}

- (IBAction)playBtnClicked:(id)sender {
    if ([self.dhPlayWindow getCamera:0] == nil){
        ((UIButton *)sender).selected = YES;
        [self startPlayback];
    }else if (![self.dhPlayWindow isPause:0]) {
        ((UIButton *)sender).selected = NO;
        [self pausePlay];
    } else if ([self.dhPlayWindow isPause:0]) {
        ((UIButton *)sender).selected = YES;
        [self resumePlay];
    }
}
- (IBAction)voiceBtnClicked:(id)sender {
    if ([self.dhPlayWindow getCamera:0] == nil){
        ((UIButton *)sender).selected = NO;
    }else if ([self.dhPlayWindow isAudioOpened:0]) {
        ((UIButton *)sender).selected = NO;
        [self.dhPlayWindow closeAudio:0];
    } else if (![self.dhPlayWindow isAudioOpened:0]) {
        ((UIButton *)sender).selected = YES;
        [self.dhPlayWindow openAudio:0];
    }
}

- (IBAction)speedBtnClicked:(id)sender {
    ZComBoxView* comBox = [[ZComBoxView alloc] initFrameSetPlaybackSpeed:[[UIApplication sharedApplication] keyWindow].frame];
    comBox.delegate = self;
    [[[UIApplication sharedApplication] keyWindow] addSubview:comBox];
}

//停止播放
- (void)stopPlay {
    [self.dhPlayWindow stop:0];
    [self resetBtnStatus];
}
//暂停播放
- (void)pausePlay {
    [self.dhPlayWindow pause:0];
}
//恢复播放
- (void)resumePlay {
    [self.dhPlayWindow resume:0];
}
//重置按钮状态
- (void)resetBtnStatus {
    self.playBtn.selected = NO;
    self.voiceBtn.selected = NO;
    [self.playbackProgress resetTimeSlider];
    
}

#pragma mark - zcombox
- (void)setPlaybackSpeed:(int)type {
    switch (type) {
        case 0:
        {
            self.playSpeed = 1.0/8;
            [self.speedBtn setTitle:@"1/8X" forState:UIControlStateNormal];
            
        }
            break;
        case 1:
        {
            self.playSpeed = 1.0/4;
            [self.speedBtn setTitle:@"1/4X" forState:UIControlStateNormal];
        }
            break;
        case 2:
        {
            self.playSpeed = 1.0/2;
            [self.speedBtn setTitle:@"1/2X" forState:UIControlStateNormal];
        }
            break;
        case 3:
        {
            self.playSpeed = 1.0;
            [self.speedBtn setTitle:@"1X" forState:UIControlStateNormal];
        }
            break;
        case 4:
        {
            self.playSpeed = 2.0;
            [self.speedBtn setTitle:@"2X" forState:UIControlStateNormal];
        }
            break;
        case 5:
        {
            self.playSpeed = 4.0;
            [self.speedBtn setTitle:@"4X" forState:UIControlStateNormal];
        }
            break;
        case 6:
        {
            self.playSpeed = 8.0;
            [self.speedBtn setTitle:@"8X" forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
    [self.dhPlayWindow setPlaySpeed:self.playSpeed atWinIndex:0];
}

@end
