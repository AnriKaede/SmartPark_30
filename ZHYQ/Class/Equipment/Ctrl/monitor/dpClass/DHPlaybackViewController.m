//
//  DHPlaybackViewController.m
//  DataAdapterExample_Example
//
//  Created by 32943 on 2018/2/8.
//  Copyright © 2018年 ly. All rights reserved.
//

#import "DHPlaybackViewController.h"
#import "DHPlaybackManager.h"
#import "DHLoginManager.h"
#import "DHDataCenter.h"
#import "PlaybackProgress.h"
#import "ZComBoxView.h"
#import "DHPlayWindow.h"
#import "DPSPBCamera.h"

@interface DHPlaybackViewController () <MediaPlayListenerProtocol,PlaybackProgressDelegate,ZComBoxViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet DHPlayWindow *dhPlayWindow;   //播放窗口 play window
@property (weak, nonatomic) IBOutlet UIButton *playBtn;            //播放按钮 play button
@property (weak, nonatomic) IBOutlet UIButton *voiceBtn;           //声音按钮 voice button
@property (weak, nonatomic) IBOutlet UIButton *speedBtn;           //播放速度 play speed button
@property (weak, nonatomic) IBOutlet PlaybackProgress *playbackProgress;  //进度条 progress
@property (weak, nonatomic) IBOutlet UITableView *recordTable;
@property (copy, nonatomic) NSString *selectChannelId;              //通道id selected channelid
@property (strong, nonatomic) DSSRecordInfo *selectRecord;             //选中录像 selected recordinfo
@property (assign, nonatomic) NSTimeInterval timeFileSeeking;    //seek的时间 seek time
@property (assign, nonatomic) BOOL bSeeking;                 //是否正在定位中 is seeking
@property (assign, nonatomic) float playSpeed;                //播放速度 play speed
@end

@implementation DHPlaybackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.selectChannelId = ((DSSChannelInfo *)[DHDataCenter sharedInstance].selectNode.content).channelid;
    //初始化播放窗口数，正常情况下，使用1
    //init play window count(default:1)
    [self.dhPlayWindow defultwindows:1];
    //初始化窗口信息
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
    self.recordTable.dataSource = self;
    self.recordTable.delegate = self;
    _selectRecord = [_recordsArray firstObject];
    [self startPlayback];
    
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

- (void)startPlayback {
    NSString* channelid = self.selectChannelId;
    if (!channelid.length || !self.recordsArray.count) {
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
#pragma mark - tableview

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self stopPlay];
    _selectRecord = _recordsArray[indexPath.row];
    [self startPlayback];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recordCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"recordCell"];
    }
    DSSRecordInfo *info = _recordsArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@--%@",[self stringBeginWithHourOfTimeNow:info.startTime], [self stringBeginWithHourOfTimeNow:info.endTime]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _recordsArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark--PlaybackProgressDelegate
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
