//
//  PlayVideoViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/18.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "PlayVideoViewController.h"

#import "DHPlayWindow.h"
#import "DPSRTCamera.h"
#import "DHLoginManager.h"
#import "DHDataCenter.h"
#import "DSSPlayWndToolBar.h"
#import "DSSMainToolBar.h"
#import "DSSPtzToolBar.h"
#import "DSSRealPtzControlView.h"
#import "DHStreamSelectView.h"
#import "DHHudPrecess.h"

//#import "DHVideoWnd.h"
//#import "PreviewManager.h"
//#import "TalkManager.h"
//#import "PtzSinglePrepointInfo.h"
#import "PlaybackViewController.h"

#import "MonitorLogin.h"
#import "MonitorLoginInfoModel.h"

@interface PlayVideoViewController ()<UIGestureRecognizerDelegate, MediaPlayListenerProtocol, PTZListenerProtocol>
{
    __weak IBOutlet NSLayoutConstraint *_playViewHeight;
    
    __weak IBOutlet UIView *_playView;
    
    __weak IBOutlet UIView *_btBgView;
    __weak IBOutlet UIButton *_playBtUp;
    __weak IBOutlet UIButton *_playBtLeft;
    __weak IBOutlet UIButton *_playBtDown;
    __weak IBOutlet UIButton *_playBtRight;
    
    __weak IBOutlet UIButton *_playStopBt;
    __weak IBOutlet UIButton *_cameraBt;
    __weak IBOutlet UIButton *_addBt;
    __weak IBOutlet UIButton *_reduceBt;
    
    DHPlayWindow *_playWindow;
    
    __weak IBOutlet UIButton *_fullBt;
    UIButton *_colseBt;
    
    BOOL _isHidBar;
    
    BOOL _isCanSideBack;
}
//selected channelid
@property (copy, nonatomic) NSString *selectChannelId;
@end

@implementation PlayVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
    
    self.selectChannelId = ((DSSChannelInfo *)[DHDataCenter sharedInstance].selectNode.content).channelid;
    [self startToplay:self.selectChannelId winIndex:0 streamType:0];
    
    // 根据摄像机类型显示控制按钮
    if([_deviceType isEqualToString:@"1-2"]){
        // 球机
        
    }else {
    }
    
    // 禁止左滑
    id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
    [self.view addGestureRecognizer:pan];
    
    // 判断当前登录用户是否有控制权限
    [self _controllLoad];
}

- (void)_initView {
    self.title = @"视频监控";
    
    _playViewHeight.constant = _playViewHeight.constant*hScale;
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    //init playwindow
    //初始化就播放窗口数，正常情况下，使用1。 init play window count(default:1)
    _playWindow = [[DHPlayWindow alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, _playViewHeight.constant)];
    [_playWindow defultwindows:1];
    DSSUserInfo* userinfo = [DHLoginManager sharedInstance].userInfo;
    NSString *host = [[DHDataCenter sharedInstance] getHost];
    int port = [[DHDataCenter sharedInstance] getPort];
    [_playWindow setHost:host Port:port UserName:userinfo.userName];
    [_playWindow addMediaPlayListener:self];
    [_playWindow addPTZListener: self];
    _playWindow.hideDefultToolViews = YES;
    [self.view insertSubview:_playWindow belowSubview:_fullBt];
    
    // 旋转按钮
    _playBtLeft.transform = CGAffineTransformMakeRotation(M_PI_2*3);
    _playBtDown.transform = CGAffineTransformMakeRotation(M_PI_2*2);
    _playBtRight.transform = CGAffineTransformMakeRotation(M_PI_2);
    
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

#pragma mark 新版大华SDK播放
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
    [_playWindow playCamera:ymCamera withName:channelInfo.name at:winIndex deviceProvide:deviceInfo.deviceProvide];
    
}


#pragma mark 控制按钮是否可点击
- (void)controlBtClick:(BOOL)enable {
    _playBtUp.enabled = enable;
    _playBtLeft.enabled = enable;
    _playBtDown.enabled = enable;
    _playBtRight.enabled = enable;
    
    _playStopBt.enabled = enable;
    _cameraBt.enabled = enable;
    _addBt.enabled = enable;
    _reduceBt.enabled = enable;
}

- (void)_controllLoad {
    // 默认无权限
    [self controlBtClick:NO];
    
    NSString *videoUrlStr = [NSString stringWithFormat:@"%@/camera/cameraOperate?tagId=%@", Main_Url, self.selectChannelId];
    [[NetworkClient sharedInstance] GET:videoUrlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        if(responseObject[@"code"] != nil && ![responseObject[@"code"] isKindOfClass:[NSNull class]] && [responseObject[@"code"] isEqualToString:@"1"]){
            // 有权限
            [self controlBtClick:YES];
        }else if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
            [self showHint:responseObject[@"message"]];
        }
        //dpsdk_retval_e
    } failure:^(NSError *error) {
//        NSLog(@"%@", error);
    }];
}

-(BOOL)prefersStatusBarHidden
{
    return _isHidBar;
}

- (IBAction)fullPlay:(id)sender {
    [self fullAction];
}

// 全屏显示
- (void)fullAction {
    _isHidBar = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.navigationBar.hidden = YES;
    _colseBt.hidden = NO;
    _playWindow.userInteractionEnabled = NO;
    
    // 隐藏控制按钮放置点击
    _btBgView.hidden = YES;
    _playStopBt.hidden = YES;
    _cameraBt.hidden = YES;
    _addBt.hidden = YES;
    _reduceBt.hidden = YES;
    _fullBt.hidden = YES;
    
    // 改变视频frame
    _playWindow.transform = CGAffineTransformRotate(_playWindow.transform, M_PI_2);
    if(KScreenWidth > 440){ // ipad
        _playWindow.frame = CGRectMake(KScreenWidth, -44, -KScreenWidth, KScreenHeight);
    }else {
        _playWindow.frame = CGRectMake(KScreenWidth, 0, -KScreenWidth, KScreenHeight);
    }
}

- (void)closeFull {
    _isHidBar = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.navigationBar.hidden = NO;
    _colseBt.hidden = YES;
    _playWindow.userInteractionEnabled = YES;
    
    _btBgView.hidden = NO;
    _playStopBt.hidden = NO;
    _cameraBt.hidden = NO;
    _addBt.hidden = NO;
    _reduceBt.hidden = NO;
    _fullBt.hidden = NO;
    
    _playWindow.transform = CGAffineTransformRotate(_playWindow.transform, -M_PI_2);
    _playWindow.frame = CGRectMake(0, 0, KScreenWidth, _playViewHeight.constant);
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 视频操作
// 方向
- (IBAction)directionUpInsildAction:(id)sender {
    // 根据摄像机类型显示控制按钮
    if(![_deviceType isEqualToString:@"1-2"]){
        // 非 球机
        [self showHint:@"该设备不支持此控制"];
        return;
    }
    
    UIButton *upInsildBt = (UIButton *)sender;
    MBL_PTZ_DIRECTION_GO direction = MBL_PTZ_DIRECTION_GO_UP;
    if(upInsildBt == _playBtUp){
        direction = MBL_PTZ_DIRECTION_GO_UP;
    }else if (upInsildBt == _playBtLeft) {
        direction = MBL_PTZ_DIRECTION_GO_LEFT;
    }else if (upInsildBt == _playBtDown) {
        direction = MBL_PTZ_DIRECTION_GO_DOWN;
    }else if (upInsildBt == _playBtRight) {
        direction = MBL_PTZ_DIRECTION_GO_RIGHT;
    }

    NSError *error = nil;
    [[DHDeviceManager sharedInstance] ptz:self.selectChannelId direction:direction step:2 stop:YES error:&error];
}
- (IBAction)directionDownAction:(id)sender {
    // 根据摄像机类型显示控制按钮
    if(![_deviceType isEqualToString:@"1-2"]){
        // 非 球机
        return;
    }
    
    UIButton *upInsildBt = (UIButton *)sender;
    MBL_PTZ_DIRECTION_GO direction = MBL_PTZ_DIRECTION_GO_UP;
    if(upInsildBt == _playBtUp){
        direction = MBL_PTZ_DIRECTION_GO_UP;
    }else if (upInsildBt == _playBtLeft) {
        direction = MBL_PTZ_DIRECTION_GO_LEFT;
    }else if (upInsildBt == _playBtDown) {
        direction = MBL_PTZ_DIRECTION_GO_DOWN;
    }else if (upInsildBt == _playBtRight) {
        direction = MBL_PTZ_DIRECTION_GO_RIGHT;
    }
    
    NSError *error = nil;
    [[DHDeviceManager sharedInstance] ptz:self.selectChannelId direction:direction step:2 stop:NO error:&error];
}
- (void)threadPtzControl:(NSDictionary *)dicPtz
{
//    dpsdk_ptz_direct_e direction = (dpsdk_ptz_direct_e)[[dicPtz valueForKey:@"direction"]intValue];
//    int step = [[dicPtz valueForKey:@"step"]intValue];
//    BOOL stop = [[dicPtz valueForKey:@"stop"]boolValue];
//    int error = [[PreviewManager sharedInstance]ptzDirection:direction byStep:step stop:stop];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (error == 10) {
//            NSLog(@"未知通道");
//        }
//    });
    
}

- (IBAction)_playStopAction:(id)sender {
    UIButton *playBt = (UIButton *)sender;
    playBt.selected = !playBt.selected;
    int selectIndex = [_playWindow getSelectedWindowIndex];
    if(playBt.selected){
        // 暂停
        int nRet = [_playWindow resumePlay:selectIndex];
        NSLog(@"监控暂停 %d", nRet);
    }else {
        // 播放
        int nRet = [_playWindow play:selectIndex];
        NSLog(@"监控播放 %d", nRet);
    }
}
- (IBAction)_cameraAction:(id)sender {
//    [[PreviewManager sharedInstance]doSnap];
    int selectIndex = [_playWindow getSelectedWindowIndex];;
    BOOL isPlaying = [_playWindow isPlaying:selectIndex];
    if (isPlaying) {
        NSString *shot = [_playWindow snapshot:selectIndex];
        NSLog(@"%@", shot);
//        UIImage *shotImage = [_playWindow snapshotOutOfPath:selectIndex];
        UIImage *shotImage = [UIImage imageWithContentsOfFile:shot];
        
        UIImageWriteToSavedPhotosAlbum(shotImage, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
    }
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
}

- (IBAction)_addAction:(id)sender {
    if(![_deviceType isEqualToString:@"1-2"]){
        // 非 球机
        [self showHint:@"该设备不支持此控制"];
        return;
    }
//    [self addWithDic:DPSDK_CORE_PTZ_ADD_ZOOM withStop:YES];
    [[DHDeviceManager sharedInstance] ptz:self.selectChannelId operation:MBL_PTZ_OPERATION_ADD_ZOOM step:2 stop:YES error:nil];
}
- (IBAction)_addDownAction:(id)sender {
    if(![_deviceType isEqualToString:@"1-2"]){
        // 非 球机
        return;
    }
//    [self addWithDic:DPSDK_CORE_PTZ_ADD_ZOOM withStop:NO];
    [[DHDeviceManager sharedInstance] ptz:self.selectChannelId operation:MBL_PTZ_OPERATION_ADD_ZOOM step:2 stop:NO error:nil];
}
- (IBAction)_reduceAction:(id)sender {
    if(![_deviceType isEqualToString:@"1-2"]){
        // 非 球机
        [self showHint:@"该设备不支持此控制"];
        return;
    }
//    [self addWithDic:DPSDK_CORE_PTZ_REDUCE_ZOOM withStop:YES];
    [[DHDeviceManager sharedInstance] ptz:self.selectChannelId operation:MBL_PTZ_OPERATION_REDUCE_ZOOM step:2 stop:YES error:nil];
}
- (IBAction)_reduceDownAction:(id)sender {
    if(![_deviceType isEqualToString:@"1-2"]){
        // 非 球机
        return;
    }
//    [self addWithDic:DPSDK_CORE_PTZ_REDUCE_ZOOM withStop:NO];
    [[DHDeviceManager sharedInstance] ptz:self.selectChannelId operation:MBL_PTZ_OPERATION_REDUCE_ZOOM step:2 stop:NO error:nil];
}

#pragma mark - Notification process
-(void)addNotification
{
    NSNotificationCenter *notfiyCenter = [NSNotificationCenter defaultCenter];
    
//    [notfiyCenter addObserver:self selector:@selector(appHasGoneInForegroundNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
//    [notfiyCenter addObserver:self selector:@selector(appEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
}
-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

//    [[PreviewManager sharedInstance]stopRealPlay];
//    [[TalkManager sharedInstance]stopTalk];
//    [[PreviewManager sharedInstance]initData];
    
    [_playWindow stop:0];
}
-(void)dealloc
{
    [self removeNotification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 大华新版SDK
#pragma mark - PTZListenerProtocol
- (void)onPTZControl:(int)winIndex type:(PtzOperation)ptzType longPress:(BOOL)isLongPress {
    Camera* camera = [_playWindow getCamera:winIndex];
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
@end
