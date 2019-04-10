//
//  PreviewViewController.m
//  DemoDPSDK
//
//  Created by jiang_bin on 14-4-21.
//  Copyright (c) 2014年 jiang_bin. All rights reserved.
//

#import "DHPreviewViewController.h"
#import "DHPlayWindow.h"
#import "DPSRTCamera.h"
#import "DHLoginManager.h"
#import "DHDataCenter.h"
#import "DSSPlayWndToolBar.h"
#import "DSSMainToolBar.h"
#import "DSSPtzToolBar.h"
#import "DSSRealPtzControlView.h"
#import "DHStreamSelectView.h"
#include <sys/mount.h>
#import "MBProgressHUD.h"
#import "DHHudPrecess.h"

#define MSG(title,msg,ok)  if(msg != nil && [msg length]>0) {\
[[DHHudPrecess sharedInstance] ShowTips:msg delayTime:1.5  atView:nil];}\

typedef enum : int {
    DSSMainStreamType = 1,
    DSSSubStreamType,
    DSSThirdStreamType,
}DSSStreamType;

@interface DHPreviewViewController () <UITableViewDelegate,UITableViewDataSource,DSSPtzToolbarDelegate,DSSMainToolBarDelegate,DSSPlayWndToolBarDelegate,DSSRealStreamViewDelegate,PtzControlViewDelegate,WindowOperationListenerProtocol,PTZListenerProtocol,TalkListenerProtocol,MediaPlayListenerProtocol,UIGestureRecognizerDelegate>
//selected channelid
@property (copy, nonatomic) NSString *selectChannelId;
//prepoint array
@property (strong, nonatomic) NSArray *presetArr;
//playwindow
@property (weak, nonatomic) IBOutlet DHPlayWindow *playWindow;
//播放视图 playwindow backgroundview
@property (weak, nonatomic) IBOutlet UIView *playWndView;
//播放窗口工具视图 playwindow tools
@property (weak, nonatomic) IBOutlet DSSPlayWndToolBar *playWndToolView;
//抓图 录像 对讲 云台视图 snapshot、record、talk、ptz
@property (weak, nonatomic) IBOutlet DSSMainToolBar *mainBarView;
//云台操作按钮 ptz operation tools
@property (weak, nonatomic) IBOutlet DSSPtzToolBar *ptzToolBarView;
//云台控制视图（缩放、焦距、光圈) ptz operation view
@property (weak, nonatomic) IBOutlet DSSRealPtzControlView *ptzControlView;
//码流选择视图 stream select view
@property (weak, nonatomic) IBOutlet DHStreamSelectView *streamSelectView;
//竖屏码流选择背景图 stream select background view
@property (weak, nonatomic) IBOutlet UIView *streamSelectBGView;
//码流选择视图取消按钮 stream select cancel button
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
//预置点背景视图 prepoint background view
@property (weak, nonatomic) IBOutlet UIView *lsPresetBGView;
//预置点视图 prepoint tableview
@property (weak, nonatomic) IBOutlet UITableView *lsPresetTableView;
@end

@implementation DHPreviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.ptzToolBarView.delegate = self;
    self.mainBarView.delegate = self;
    self.playWndToolView.delegate = self;
    self.ptzControlView.delegate = self;
    self.streamSelectView.delegate = self;
    self.ptzToolBarView.hidden = YES;      //竖屏云台
    self.ptzControlView.hidden = YES;      //竖屏焦距等
    self.streamSelectBGView.hidden = YES;  //竖屏码流选择视图
    //预置点
    self.lsPresetTableView.delegate = self;
    self.lsPresetTableView.dataSource = self;
    self.lsPresetBGView.hidden = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenPresetView)];
    tapGesture.delegate = self;
    [self.lsPresetBGView addGestureRecognizer:tapGesture];
    
    //init playwindow
    //初始化就播放窗口数，正常情况下，使用1。 init play window count(default:1)
    [self.playWindow defultwindows:1];
    DSSUserInfo* userinfo = [DHLoginManager sharedInstance].userInfo;
    NSString *host = [[DHDataCenter sharedInstance] getHost];
    int port = [[DHDataCenter sharedInstance] getPort];
    [self.playWindow setHost:host Port:port UserName:userinfo.userName];
    [self.playWindow addMediaPlayListener:self];
    [self.playWindow addPTZListener: self];
    [self.playWindow addTalkListener:self];
    self.playWindow.hideDefultToolViews = YES;
    
    self.selectChannelId = ((DSSChannelInfo *)[DHDataCenter sharedInstance].selectNode.content).channelid;
    [self startToplay:self.selectChannelId winIndex:0 streamType:0];
    [self setMainToolBarStreamBtnTitle];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.playWindow stop:0];
    [self updateBtnStatus:0];
}

- (void)setMainToolBarStreamBtnTitle{
    int streamType = [self getSelectStreamType];
    if(streamType == 3){
        [self.playWndToolView.streamBtn setTitle:@"LC" forState:UIControlStateNormal];
    } else if (streamType == 2) {
        [self.playWndToolView.streamBtn setTitle:@"SD" forState:UIControlStateNormal];
    } else {
        [self.playWndToolView.streamBtn setTitle:@"HD" forState:UIControlStateNormal];
    }
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self.streamSelectView resetHDViewButtonStatue];
    self.streamSelectBGView.hidden = YES;
}

- (void)startToplay:(NSString *)local_channelId winIndex:(int)winIndex streamType:(int)streamType{
    DSSUserInfo* userinfo = [DHLoginManager sharedInstance].userInfo;
    NSNumber* handleDPSDKEntity = (NSNumber*)[userinfo getInfoValueForKey:kUserInfoHandleDPSDKEntity];
  //  NSString* handleRestToken = [[DHDataCenter sharedInstance] getLoginToken];
    DPSRTCamera* ymCamera = [[DPSRTCamera alloc] init];
    ymCamera.dpHandle = [handleDPSDKEntity longValue];
    ymCamera.cameraID = local_channelId;
  //  ymCamera.dpRestToken = handleRestToken;
    ymCamera.server_ip = [[DHDataCenter sharedInstance] getHost];
    ymCamera.server_port = [[DHDataCenter sharedInstance] getPort];
    ymCamera.isCheckPermission = YES;
    ymCamera.mediaType = 1;
    //如果支持三码流，就默认播放辅码流，只有在用户主动选择三码流时才会去播放三码流
    //default stream ：subStream
    DSSChannelInfo* channelInfo = (DSSChannelInfo *)[DHDataCenter sharedInstance].selectNode.content;
    DSSDeviceInfo *deviceInfo = [[DHDeviceManager sharedInstance] getDeviceInfo:[channelInfo deviceId]];
    if ([self isThirdStreamSupported:local_channelId]) {
        ymCamera.streamType = 2;
    } else {
        if ([self isSubStreamSupported:local_channelId]) {
            ymCamera.streamType = 2;
        } else {
            ymCamera.streamType = 1;
        }
    }
    [self.playWindow playCamera:ymCamera withName:channelInfo.name at:winIndex deviceProvide:deviceInfo.deviceProvide];

}

#pragma mark - DSSRealUIServiceProtocol - 云台控制
//手指按下
- (void)ptzBtnClickAdd:(PtzControlType )type touchDown:(BOOL)isDown{
    switch (type) {
        case 0:
        {
            //手指离开时还需要调用stop为YES
            //touch up inside need stop
            NSError *error = nil;
            [[DHDeviceManager sharedInstance] ptz:self.selectChannelId operation:MBL_PTZ_OPERATION_ADD_ZOOM step:2 stop:isDown error:&error];
        }
            break;
        case 1:
        {
            //手指离开时还需要调用stop为YES
            //touch up inside need stop
            NSError *error = nil;
            [[DHDeviceManager sharedInstance] ptz:self.selectChannelId operation:MBL_PTZ_OPERATION_ADD_FOCUS step:2 stop:isDown error:&error];
        }
            break;
        case 2:
        {
            //手指离开时还需要调用stop为YES
            //touch up inside need stop
             NSError *error = nil;
             [[DHDeviceManager sharedInstance] ptz:self.selectChannelId operation:MBL_PTZ_OPERATION_ADD_APERTURE step:2 stop:isDown error:&error];
        }
            break;
            
        default:
            break;
    }
}

- (void)ptzBtnClickReduce:(PtzControlType )type touchDown:(BOOL)isDown{
    switch (type) {
        case 0:
        {
            //手指离开时还需要调用stop为YES
            NSError *error = nil;
            [[DHDeviceManager sharedInstance] ptz:self.selectChannelId operation:MBL_PTZ_OPERATION_REDUCE_ZOOM step:2 stop:isDown error:&error];
        }
            break;
        case 1:
        {
            //手指离开时还需要调用stop为YES
            NSError *error = nil;
            [[DHDeviceManager sharedInstance] ptz:self.selectChannelId operation:MBL_PTZ_OPERATION_REDUCE_FOCUS step:2 stop:isDown error:&error];
        }
            break;
        case 2:
        {
            //手指离开时还需要调用stop为YES
            NSError *error = nil;
            [[DHDeviceManager sharedInstance] ptz:self.selectChannelId operation:MBL_PTZ_OPERATION_REDUCE_APERTURE step:2 stop:isDown error:&error];
        }
            break;
        default:
            break;
    }
}

#pragma mark - DSSRealUIServiceProtocol - 播放工具栏
-(void)DSSPlayWndToolbarViewDidClickPlay:(BOOL)isOn{
    int selectIndex = [self.playWindow getSelectedWindowIndex];

    if (self.selectChannelId == nil || [self.selectChannelId isEqualToString:@""]) {
        NSLog(@"Before playing,add the channel first");
        return;
    }
    [self.playWndToolView.playBtn setEnabled:YES];
    if ([self isPlaying]) {
        int nRet = [self.playWindow resumePlay:selectIndex];
        if (nRet != 0) {
            self.playWndToolView.playBtn.selected = YES;
            NSLog(@"Failed to stop");
        }
    } else {
        int nRet = [self.playWindow play:selectIndex];
        if (nRet == 0) {
            // [[[Toast alloc]initWithText:_T(@"Successful recovery",BUNDLE_FOR_MODULE) delay:0 duration:1.0]show];
        } else {
            self.playWndToolView.playBtn.selected = NO;
            NSLog(@"Recovery failed");
        }
    }
}

-(void)DSSPlayWndToolbarViewDidClickVoice:(BOOL)isOn{
    int selectIndex = [self.playWindow getSelectedWindowIndex];
    if ([self isPlaying]) {
        if ([self isAudioOpen]) {
            [self.playWindow closeAudio:selectIndex];
        } else {
            if ([self isTalking]) {
                [self stopTalk];
            }else{
                [self.playWindow stopTalk:selectIndex];
            }
            [self.playWindow openAudio:selectIndex];
        }
    } else {
        [self.playWndToolView.voiceBtn setSelected:NO];
    }
}

-(void)DSSPlayWndToolbarViewDidClickStream:(BOOL)isOn{
    int winIndex = [self.playWindow getSelectedWindowIndex];
    Camera* camera = [self.playWindow getCamera:winIndex];
    if ([camera isKindOfClass:[DPSRTCamera class]]) {
        int streamType = [self getSelectStreamType];
        NSString *channelIdStr = self.selectChannelId;
        self.streamSelectBGView.hidden = NO;
        [self.streamSelectView resetHDBtnSelectedStatue:streamType];
        if ([self isThirdStreamSupported:channelIdStr]) {
            [self.streamSelectView.LCButton setEnabled:YES];
            [self.streamSelectView.SDButton setEnabled:YES];
            [self.streamSelectView.HDButton setEnabled:YES];
        } else {
            [self.streamSelectView.LCButton setEnabled:NO];
            [self.streamSelectView.HDButton setEnabled:YES];
            if ([self isSubStreamSupported:channelIdStr]) {
                [self.streamSelectView.SDButton setEnabled:YES];
            } else {
                [self.streamSelectView.SDButton setEnabled:NO];
            }
        }
    }
}

- (int )getSelectStreamType{
    int selectIndex = [self.playWindow getSelectedWindowIndex];
    Camera* camera = [self.playWindow getCamera:selectIndex];
    int streamType = 1;
    if ([camera isKindOfClass:[DPSRTCamera class]]) {
        DPSRTCamera* dpsRTCamera = (DPSRTCamera*)camera;
        streamType = dpsRTCamera.streamType;
    }
    return streamType;
}

- (BOOL)isSubStreamSupported:(NSString *)channelIDStr{
    if (channelIDStr != nil || ![channelIDStr isEqualToString:@""]) {
        DSSChannelInfo* channelInfo = (DSSChannelInfo *)[DHDataCenter sharedInstance].selectNode.content;
        if(channelInfo.encChannelInfo.streamtypeSupported == 2){
            return YES;
        }
        return NO;
    }
    return NO;
}
- (BOOL)isThirdStreamSupported:(NSString *)channelIDStr{
    if (channelIDStr != nil || ![channelIDStr isEqualToString:@""]) {
        DSSChannelInfo* channelInfo = (DSSChannelInfo *)[DHDataCenter sharedInstance].selectNode.content;
        if(channelInfo.encChannelInfo.streamtypeSupported == 3){
            return YES;
        }
        return NO;
    }
    return NO;
}

#pragma mark - DSSRealUIServiceProtocol - Snapshot、Record 、Talk、Ptz
-(void)mainToolbarViewDidClickSnapshot{
    int selectIndex = [self.playWindow getSelectedWindowIndex];;
    BOOL isPlaying = [self.playWindow isPlaying:selectIndex];
    if (isPlaying) {
        [self.playWindow snapshot:selectIndex];
    }
}
-(void)mainToolbarViewDidClickRecord:(BOOL)isOn{
    if ([self freeDiskSpaceInMBytes] < 10.0) {
        NSLog(@"空间不足");
        return;
    }
    int winIndex = [self.playWindow getSelectedWindowIndex];
    if ([self isPlaying]) {
        if ([self isRecording]) {
            [self.mainBarView.recordBtn setSelected:NO];
            [self.playWindow stopRecord:winIndex];
        } else {
            [self.mainBarView.recordBtn setSelected:YES];
            [self.playWindow startRecord:winIndex];
        }
    } else {
        [self.mainBarView.recordBtn setSelected:NO];
    }
}
//剩余内存 free disk space
- (double)freeDiskSpaceInMBytes
{
    struct statfs buf;
    long long freespace = -1;
    if(statfs("/var", &buf) >= 0)
    {
        freespace = (long long)(buf.f_bsize * buf.f_bfree);
    }
    return freespace/(1024.0*1024.0);
}
//对讲 talk
-(void)mainToolbarViewDidClickTalk:(BOOL)isOn{
    int selectIndex = [self.playWindow getSelectedWindowIndex];
    if ([self isPlaying]) {
        if ([self isTalking]) {
            int nRet = [self.playWindow stopTalk:selectIndex];
            if (nRet == 0) {
                 NSLog(@"Closed successfully");
                MSG("", @"Closed successfully", "");
            } else {
                [self.mainBarView.talkBtn setSelected:YES];
                NSLog(@"Closed Failed");
                MSG("", @"Closed Failed", "");
            }
        } else {
            if ([self isAudioOpen]) {
                [self.playWindow closeAudio:selectIndex];
                [self.playWndToolView.voiceBtn setSelected:NO];
            }
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.label.text = @"Loading";
            int nRet = [self.playWindow startTalk:selectIndex];
            if (nRet == 0) {
                NSLog(@"open talk success");
                MSG("", @"open talk success", "");
            } else {
                [self.mainBarView.talkBtn setSelected:NO];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSLog(@"Failed to open");
                MSG("", @"Failed to open", "");
            }
        }
    } else {
        [self.mainBarView.talkBtn setSelected:NO];
    }
}
- (void)stopTalk{
    int selectIndex = [self.playWindow getSelectedWindowIndex];
    int nRet = [self.playWindow stopTalk:selectIndex];
    if (nRet == 0) {
        [self.mainBarView.talkBtn setSelected:NO];
        NSLog(@"Closed successfully");
        MSG("", @"Closed successfully", "");
    } else {
        [self.mainBarView.talkBtn setSelected:YES];
      
        NSLog(@"Failed to close");
    }
}
//云台 ptz
-(void)mainToolbarViewDidClickPTZ:(BOOL)isOn{
    int selectIndex = [self.playWindow getSelectedWindowIndex];
   if ([self isPlaying]) {
        //获取预置点
        if ([self isOpenPtz]) {
            int nRet = [self.playWindow setEnablePtz:selectIndex enable:NO];
            if (nRet == -2) {
                NSLog(@"Before operation, double-click the window and maximize the window");
                [self.mainBarView.ptzBtn setSelected:YES];
                self.ptzToolBarView.hidden = NO;
                return;
            }
            if (nRet == 0) {
                self.ptzToolBarView.hidden = YES;
                self.ptzControlView.hidden = YES;
                [self.ptzToolBarView resetButtonStatue];
                [self.mainBarView.ptzBtn setSelected:NO];
            } else {
                NSLog(@"Failed to close PTZ");
            }
        } else {
            int nRet = [self.playWindow setEnablePtz:selectIndex enable:YES];
            if (nRet == -2) {
                NSLog(@"Before operation, double-click the window and maximize the window");
                [self.mainBarView.ptzBtn setSelected:NO];
                self.ptzToolBarView.hidden = YES;
                self.ptzControlView.hidden = YES;
                [self hiddenPtzView];
                return;
            }
            if (nRet == 0) {
                self.ptzToolBarView.hidden = NO;
                [self.mainBarView.ptzBtn setSelected:YES];
            } else {
                NSLog(@"Failed to open PTZ");
                [self.mainBarView.ptzBtn setSelected:NO];
            }
        }
    } else {
        [self.mainBarView.ptzBtn setSelected:NO];
    }
}
#pragma mark - Stream：HD、SD、LC
- (void)DSSStreamPanelDelegateSelectHD{
    int currentStreamType = [self getSelectStreamType];
    if (currentStreamType == DSSMainStreamType) {
        return;
    }
    [self changeStreamType:DSSMainStreamType];
}
- (void)DSSStreamPanelDelegateSelectSD{
    int currentStreamType = [self getSelectStreamType];
    if (currentStreamType == DSSSubStreamType) {
        return;
    }
    [self changeStreamType:DSSSubStreamType];
}
- (void)DSSStreamPanelDelegateSelectLC{
    int currentStreamType = [self getSelectStreamType];
    if (currentStreamType == DSSThirdStreamType) {
        return;
    }
    [self changeStreamType:DSSThirdStreamType];
}
//切换码流 change stream type
- (void)changeStreamType:(DSSStreamType)type{
   [self.streamSelectView resetHDBtnSelectedStatue:type];
    int selectIndex = [self.playWindow getSelectedWindowIndex];
    [self.playWindow stopRecord:selectIndex];
    [self.playWindow stopTalk:selectIndex];
    [self.playWindow setEnablePtz:selectIndex enable:NO];
    [self resetButtonsWithSelectedWindowIndex:selectIndex];
    
    int streamType = 1;
    if (type == DSSMainStreamType) {
        streamType = 1;
    } else if (type == DSSSubStreamType){
        streamType = 2;
    } else {
        streamType = 3;
    }
    //切换码流时，先停止播放然后取得Camera信息再播放
    //when change stream type, stop play ,then reset camera to play
    DSSUserInfo* userinfo = [DHLoginManager sharedInstance].userInfo;
    NSString *host = [[DHDataCenter sharedInstance].coreAdapter getHost];
    int port = [[DHDataCenter sharedInstance].coreAdapter getPort];
    NSNumber* handleDPSDKEntity = (NSNumber*)[userinfo getInfoValueForKey:kUserInfoHandleDPSDKEntity];
    DPSRTCamera* ymCamera = [[DPSRTCamera alloc] init];
    ymCamera.dpHandle = [handleDPSDKEntity longValue];
    ymCamera.dpRestToken = @"";
    ymCamera.server_ip = host;
    ymCamera.server_port = port;
    ymCamera.cameraID = self.selectChannelId;
    ymCamera.isCheckPermission = YES;
    ymCamera.mediaType = 1;
    ymCamera.streamType = streamType;
    DSSChannelInfo* channelInfo = (DSSChannelInfo *)[DHDataCenter sharedInstance].selectNode.content;
    DSSDeviceInfo *deviceInfo = [[DHDeviceManager sharedInstance] getDeviceInfo:[channelInfo deviceId]];
    if(ymCamera.streamType == 1){
        [self.playWndToolView.streamBtn setTitle:@"HD" forState:UIControlStateNormal];
    } else if (ymCamera.streamType == 2) {
        [self.playWndToolView.streamBtn setTitle:@"SD" forState:UIControlStateNormal];
    } else {
        [self.playWndToolView.streamBtn setTitle:@"Fluent" forState:UIControlStateNormal];
    }
    [self.playWindow playCamera:ymCamera withName:channelInfo.name at:0 deviceProvide:deviceInfo.deviceProvide];
}

#pragma mark PtzToolbarProtocol
-(void)DSSPtzToolbarViewDidClickZoom:(BOOL)isOn{
    self.ptzControlView.ptzType = PtzControlTypeZoom;
    [self.ptzControlView.ptzTitleBtn setTitle:@"Zoom" forState:UIControlStateNormal];
    self.ptzControlView.hidden = YES;
    if (!isOn) {
        self.ptzControlView.hidden = NO;
    }
    [self.ptzToolBarView resetBtnSelectStatue:0];
}

- (void)DSSPtzToolbarViewDidClickFocus:(BOOL)isOn{
    self.ptzControlView.ptzType = PtzControlTypeFocus;
    [self.ptzControlView.ptzTitleBtn setTitle:@"Focus" forState:UIControlStateNormal];
    self.ptzControlView.hidden = YES;
    if (!isOn) {
        self.ptzControlView.hidden = NO;
    }
    [self.ptzToolBarView resetBtnSelectStatue:1];
}
- (void)DSSPtzToolbarViewDidClickRing:(BOOL)isOn{
    self.ptzControlView.ptzType = PtzControlTypeAperture;
    [self.ptzControlView.ptzTitleBtn setTitle:@"Aperture" forState:UIControlStateNormal];
    self.ptzControlView.hidden = YES;
    if (!isOn) {
        self.ptzControlView.hidden = NO;
    }
    [self.ptzToolBarView resetBtnSelectStatue:2];
}

- (void)DSSPtzToolbarViewDidClickPoint:(BOOL)isOn{
    NSLog(@"Click prepoint");
    DSSChannelInfo *channelInfo = (DSSChannelInfo *)[DHDataCenter sharedInstance].selectNode.content;
    [self getPresetList:channelInfo.channelid];
    self.lsPresetBGView.hidden = NO;
}

- (void)getPresetList:(NSString *)local_channelId{
    NSError *error;
    self.presetArr = [[DHDeviceManager sharedInstance] queryPtzPrePoint:local_channelId error:&error];
    [self.lsPresetTableView reloadData];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:self.lsPresetTableView]) {
        return NO;
    }
    return YES;
}

- (void)hiddenPresetView {
    self.lsPresetBGView.hidden = YES;
}

#pragma mark - UITableViewDataSource prepoint
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.presetArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellId"];
    }
    DSSPtzPrePointInfo *info = nil;
    if (self.presetArr.count > 0) {
        info = [self.presetArr objectAtIndex:indexPath.row];
        cell.textLabel.text = info.name;
    }
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.backgroundColor = [UIColor clearColor];
    [cell.textLabel setTextColor:[UIColor blackColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;

    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    __block int code = 1;
    DSSPtzPrePointInfo *info = [[DSSPtzPrePointInfo alloc] init];
    if (self.presetArr.count > 0) {
        info = [self.presetArr objectAtIndex:indexPath.row];
        code = info.code;
    }
    NSError *error = nil;
    [[DHDeviceManager sharedInstance] ptz:self.selectChannelId location:code error:&error];
}

//暂停、移除窗口等操作时，同步按钮状态
- (void)updateBtnStatus:(int)winIndex{
    [self.playWndToolView.playBtn setSelected:NO];
    [self.mainBarView.recordBtn setSelected:NO];
    if ([self.playWindow isRecording:winIndex]) {
        [self.playWindow stopRecord:winIndex];
    }
    [self.playWndToolView.voiceBtn setSelected:NO];
    if ([self.playWindow isAudioOpened:winIndex]) {
        [self.playWindow closeAudio:winIndex];
    }
    [self.mainBarView.talkBtn setSelected:NO];
    if ([self.playWindow isTalking:winIndex]) {
        [self.playWindow stopTalk:winIndex];
    }
    
    if ([self.playWindow isPtzOpened:winIndex]) {
        self.ptzToolBarView.hidden = YES;
        self.ptzControlView.hidden = YES;
        [self hiddenPtzView];
        [self.mainBarView.ptzBtn setSelected:NO];
        [self.playWindow setEnablePtz:winIndex enable:NO];
    }
}

- (void)resetButtonsWithSelectedWindowIndex:(int)selectedWindowIndex{
    if (![self.playWindow isRecording:selectedWindowIndex]) {
        [self.mainBarView.recordBtn setSelected:NO];
    }else{
        [self.mainBarView.recordBtn setSelected:YES];
    }
    if (![self.playWindow isAudioOpened:selectedWindowIndex]) {
        [self.playWndToolView.voiceBtn setSelected:NO];
    }else{
        [self.playWndToolView.voiceBtn setSelected:YES];
    }
    if (![self.playWindow isTalking:selectedWindowIndex]) {
        [self.mainBarView.talkBtn setSelected:NO];
    }else{
        [self.mainBarView.talkBtn setSelected:YES];
    }
    if (![self.playWindow isPtzOpened:selectedWindowIndex]) {
        self.ptzToolBarView.hidden = YES;
        self.ptzControlView.hidden = YES;
        [self hiddenPtzView];
        [self.mainBarView.ptzBtn setSelected:NO];
    }else{
        self.ptzToolBarView.hidden = NO;
        [self.mainBarView.ptzBtn setSelected:YES];
    }
}

//隐藏云台操作视图 hide ptzview
- (void)hiddenPtzView{
    //恢复云台按钮状态 reset button status
    [self.ptzToolBarView resetButtonStatue];
}

#pragma mark - 播放状态等
- (BOOL)isRecording{
    int selectIndex = [self.playWindow getSelectedWindowIndex];
    BOOL isRecording = [self.playWindow isRecording:selectIndex];
    return isRecording;
}
- (BOOL)isPlaying{
    int selectIndex = [self.playWindow getSelectedWindowIndex];
    BOOL isPlaying = [self.playWindow isPlaying:selectIndex];
    return isPlaying;
}
- (BOOL)isTalking{
    int selectIndex = [self.playWindow getSelectedWindowIndex];
    BOOL isTalking = [self.playWindow isTalking:selectIndex];
    return isTalking;
}
- (BOOL)isOpenPtz{
    int selectIndex = [self.playWindow getSelectedWindowIndex];
    BOOL isPtzOpen = [self.playWindow isPtzOpened:selectIndex];
    return isPtzOpen;
}
- (BOOL)isAudioOpen{
    int selectIndex = [self.playWindow getSelectedWindowIndex];
    BOOL isAudioOpen = [self.playWindow isAudioOpened:selectIndex];
    return isAudioOpen;
}

#pragma mark - WindowOperationListenerProtocol
//点击窗口
- (void)onWindowSelected:(int)winIndex {
}

//点击窗口上的图标，用于选择通道，或者其他
- (void)onControlClick:(int)winIndex type:(WinControlType)controltype {

}

#pragma mark - MediaPlayListenerProtocol
- (void)onPlayeStatusCallback:(int)winIndex status:(PlayStatusType)status {
    switch (status) {
        case eNetworkaAbort:{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.playWindow resumePlay:winIndex];
                self.mainBarView.talkBtn.selected = NO;
                self.playWndToolView.playBtn.selected = NO;
                self.mainBarView.recordBtn.selected = NO;
                self.playWndToolView.voiceBtn.selected = NO;
                self.ptzToolBarView.hidden = YES;
                self.ptzControlView.hidden = YES;
                [self hiddenPtzView];
                self.mainBarView.ptzBtn.selected = NO;
            });
        }
            break;
        case ePlayFirstFrame:{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.playWndToolView setButtonIndex:0 Selected:[self isPlaying]];
                [self.playWndToolView setButtonIndex:1 Selected:[self isAudioOpen]];
            });
        }
            break;
        default:
            break;
    }
}

#pragma mark - PTZListenerProtocol
- (void)onPTZControl:(int)winIndex type:(PtzOperation)ptzType longPress:(BOOL)isLongPress {
    Camera* camera = [self.playWindow getCamera:winIndex];
    NSString* chanelid = nil;
    if ([camera isKindOfClass:[DPSRTCamera class]]) {
        DPSRTCamera* dpsRTCamera = (DPSRTCamera*)camera;
        chanelid = dpsRTCamera.cameraID;
    }
    else {
        NSAssert(NO, @"");
        return;
    }
    MBL_PTZ_DIRECTION_GO direction = MBL_PTZ_DIRECTION_GO_UP;
    
    if (ptzType & ePTZCtrl_DirectionLeft ) {
        direction = MBL_PTZ_DIRECTION_GO_LEFT;
    }
    else if (ptzType & ePTZCtrl_DirectionRight ) {
        direction = MBL_PTZ_DIRECTION_GO_RIGHT;
    }
    else if (ptzType & ePTZCtrl_DirectionUp ) {
        direction = MBL_PTZ_DIRECTION_GO_UP;
    }
    else if (ptzType & ePTZCtrl_DirectionDown ) {
        direction = MBL_PTZ_DIRECTION_GO_DOWN;
    }
    else if (ptzType & ePTZCtrl_DirectionLeftup ) {
        direction = MBL_PTZ_DIRECTION_GO_LEFTUP;
    }
    else if (ptzType & ePTZCtrl_DirectionRightup ) {
        direction = MBL_PTZ_DIRECTION_GO_RIGHTUP;
    }
    else if (ptzType & ePTZCtrl_DirectionLeftdown ) {
        direction = MBL_PTZ_DIRECTION_GO_LEFTDOWN;
    }
    else if (ptzType & ePTZCtrl_DirectionRightdown ) {
        direction = MBL_PTZ_DIRECTION_GO_RIGHTDOWN;
    }
    //手动放大缩小
    if (ptzType & ePTZCtrl_ZoomIn) {
        NSError *error = nil;
        [[DHDeviceManager sharedInstance] ptz:self.selectChannelId operation:MBL_PTZ_OPERATION_REDUCE_ZOOM step:2 stop:(ptzType & ePTZCtrl_End) error:&error];
        return;
    }
    if (ptzType & ePTZCtrl_ZoomOut) {
        NSError *error = nil;
        [[DHDeviceManager sharedInstance] ptz:self.selectChannelId operation:MBL_PTZ_OPERATION_ADD_ZOOM step:2 stop:(ptzType & ePTZCtrl_End) error:&error];
        return;
    }
    //手指离开时还需要调用stop为YES
    NSError *error = nil;
    [[DHDeviceManager sharedInstance] ptz:self.selectChannelId direction:direction step:2 stop:(ptzType & ePTZCtrl_End) error:&error];
}

#pragma mark - TalkListenerProtocol
- (void)onTalkResult:(int)winIndex result:(TalkResultType)talkResult {
    NSLog(@"---->对讲返回结果 %ld",(long)talkResult);
    if (talkResult == eTalkSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainBarView.talkBtn setSelected:YES];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"Open Successfully");
            MSG("", @"Open Successfully", "");
        });
    } else {
        int selectIndex = [self.playWindow getSelectedWindowIndex];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.playWindow stopTalk:selectIndex];
            [self.mainBarView.talkBtn setSelected:NO];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"Failed to open");
            MSG("", @"Failed to open", "");
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
