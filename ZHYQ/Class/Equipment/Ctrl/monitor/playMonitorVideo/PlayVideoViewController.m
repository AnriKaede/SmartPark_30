//
//  PlayVideoViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/18.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "PlayVideoViewController.h"
#import "DHVideoWnd.h"
#import "PreviewManager.h"
#import "TalkManager.h"
#import "PtzSinglePrepointInfo.h"
#import "PlaybackViewController.h"

@interface PlayVideoViewController ()<UIGestureRecognizerDelegate>
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
    
    DHVideoWnd  *videoWnd_;
    
    UIButton *_colseBt;
    BOOL _isHidBar;
    
    BOOL _isCanSideBack;
}
@end

@implementation PlayVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
    
    [self addNotification];
    
    [[PreviewManager sharedInstance] initData];
    
    [[PreviewManager sharedInstance]openRealPlay:(__bridge void *)(videoWnd_)];
    
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
    
    // 旋转按钮
    _playBtLeft.transform = CGAffineTransformMakeRotation(M_PI_2*3);
    _playBtDown.transform = CGAffineTransformMakeRotation(M_PI_2*2);
    _playBtRight.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    // 创建视频播放视图
    videoWnd_ = [[DHVideoWnd alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, _playViewHeight.constant)];
    videoWnd_.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:videoWnd_];
    
    UITapGestureRecognizer *fullTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullAction)];
    fullTap.numberOfTapsRequired = 2;
    [videoWnd_ addGestureRecognizer:fullTap];
    
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
    
    NSString *videoUrlStr = [NSString stringWithFormat:@"%@/camera/cameraOperate?tagId=%@", Main_Url, [DHDataCenter sharedInstance].channelID];
    [[NetworkClient sharedInstance] GET:videoUrlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        if(responseObject[@"code"] != nil && ![responseObject[@"code"] isKindOfClass:[NSNull class]] && [responseObject[@"code"] isEqualToString:@"1"]){
            // 有权限
            [self controlBtClick:YES];
        }else if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
            [self showHint:responseObject[@"message"]];
        }
        
    } failure:^(NSError *error) {
//        NSLog(@"%@", error);
    }];
}

-(BOOL)prefersStatusBarHidden
{
    return _isHidBar;
}
// 全屏显示
- (void)fullAction {
    _isHidBar = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.navigationBar.hidden = YES;
    _colseBt.hidden = NO;
    videoWnd_.userInteractionEnabled = NO;
    
    // 隐藏控制按钮放置点击
    _btBgView.hidden = YES;
    _playStopBt.hidden = YES;
    _cameraBt.hidden = YES;
    _addBt.hidden = YES;
    _reduceBt.hidden = YES;
    
    // 改变视频frame
    videoWnd_.transform = CGAffineTransformRotate(videoWnd_.transform, M_PI_2);
    if(KScreenWidth > 440){ // ipad
        videoWnd_.frame = CGRectMake(KScreenWidth, -44, -KScreenWidth, KScreenHeight);
    }else {
        videoWnd_.frame = CGRectMake(KScreenWidth, 0, -KScreenWidth, KScreenHeight);
    }
}

- (void)closeFull {
    _isHidBar = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.navigationBar.hidden = NO;
    _colseBt.hidden = YES;
    videoWnd_.userInteractionEnabled = YES;
    
    _btBgView.hidden = NO;
    _playStopBt.hidden = NO;
    _cameraBt.hidden = NO;
    _addBt.hidden = NO;
    _reduceBt.hidden = NO;
    
    videoWnd_.transform = CGAffineTransformRotate(videoWnd_.transform, -M_PI_2);
    videoWnd_.frame = CGRectMake(0, 0, KScreenWidth, _playViewHeight.constant);
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
    dpsdk_ptz_direct_e direction = DPSDK_CORE_PTZ_GO_UP;
    if(upInsildBt == _playBtUp){
        direction = DPSDK_CORE_PTZ_GO_UP;
    }else if (upInsildBt == _playBtLeft) {
        direction = DPSDK_CORE_PTZ_GO_LEFT;
    }else if (upInsildBt == _playBtDown) {
        direction = DPSDK_CORE_PTZ_GO_DOWN;
    }else if (upInsildBt == _playBtRight) {
        direction = DPSDK_CORE_PTZ_GO_RIGHT;
    }
    
    NSMutableDictionary *dicPtz = [NSMutableDictionary dictionary];
    [dicPtz setObject:[NSNumber numberWithInt:direction] forKey:@"direction"];
    [dicPtz setObject:[NSNumber numberWithInt:1] forKey:@"step"];
    [dicPtz setObject:[NSNumber numberWithBool:YES] forKey:@"stop"];
    [self performSelectorInBackground:@selector(threadPtzControl:) withObject:dicPtz];
}
- (IBAction)directionDownAction:(id)sender {
    // 根据摄像机类型显示控制按钮
    if(![_deviceType isEqualToString:@"1-2"]){
        // 非 球机
        return;
    }
    
    UIButton *upInsildBt = (UIButton *)sender;
    dpsdk_ptz_direct_e direction = DPSDK_CORE_PTZ_GO_UP;
    if(upInsildBt == _playBtUp){
        direction = DPSDK_CORE_PTZ_GO_UP;
    }else if (upInsildBt == _playBtLeft) {
        direction = DPSDK_CORE_PTZ_GO_LEFT;
    }else if (upInsildBt == _playBtDown) {
        direction = DPSDK_CORE_PTZ_GO_DOWN;
    }else if (upInsildBt == _playBtRight) {
        direction = DPSDK_CORE_PTZ_GO_RIGHT;
    }
    
    NSMutableDictionary *dicPtz = [NSMutableDictionary dictionary];
    [dicPtz setObject:[NSNumber numberWithInt:direction] forKey:@"direction"];
    [dicPtz setObject:[NSNumber numberWithInt:1] forKey:@"step"];
    [dicPtz setObject:[NSNumber numberWithBool:NO] forKey:@"stop"];
    [self performSelectorInBackground:@selector(threadPtzControl:) withObject:dicPtz];
}
- (void)threadPtzControl:(NSDictionary *)dicPtz
{
    dpsdk_ptz_direct_e direction = (dpsdk_ptz_direct_e)[[dicPtz valueForKey:@"direction"]intValue];
    int step = [[dicPtz valueForKey:@"step"]intValue];
    BOOL stop = [[dicPtz valueForKey:@"stop"]boolValue];
    int error = [[PreviewManager sharedInstance]ptzDirection:direction byStep:step stop:stop];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error == 10) {
            NSLog(@"未知通道");
        }
    });
    
}

- (IBAction)_playStopAction:(id)sender {
    UIButton *playBt = (UIButton *)sender;
    playBt.selected = !playBt.selected;
    if(playBt.selected){
        // 停止
        [[PreviewManager sharedInstance]stopRealPlay];
        [[PreviewManager sharedInstance]initData];
    }else {
        // 播放
        [[PreviewManager sharedInstance]openRealPlay:(__bridge void *)(videoWnd_)];
    }
}
- (IBAction)_cameraAction:(id)sender {
    [[PreviewManager sharedInstance]doSnap];
}

- (IBAction)_addAction:(id)sender {
    if(![_deviceType isEqualToString:@"1-2"]){
        // 非 球机
        [self showHint:@"该设备不支持此控制"];
        return;
    }
    [self addWithDic:DPSDK_CORE_PTZ_ADD_ZOOM withStop:YES];
}
- (IBAction)_addDownAction:(id)sender {
    if(![_deviceType isEqualToString:@"1-2"]){
        // 非 球机
        return;
    }
    [self addWithDic:DPSDK_CORE_PTZ_ADD_ZOOM withStop:NO];
}
- (IBAction)_reduceAction:(id)sender {
    if(![_deviceType isEqualToString:@"1-2"]){
        // 非 球机
        [self showHint:@"该设备不支持此控制"];
        return;
    }
    [self addWithDic:DPSDK_CORE_PTZ_REDUCE_ZOOM withStop:YES];
}
- (IBAction)_reduceDownAction:(id)sender {
    if(![_deviceType isEqualToString:@"1-2"]){
        // 非 球机
        return;
    }
    [self addWithDic:DPSDK_CORE_PTZ_REDUCE_ZOOM withStop:NO];
}
- (void)addWithDic:(dpsdk_camera_operation_e)dpsdk_camera_operation_e withStop:(BOOL)stop {
    NSMutableDictionary *dicOperation = [NSMutableDictionary dictionary];
    [dicOperation setObject:[NSNumber numberWithInt:dpsdk_camera_operation_e] forKey:@"operation"];
    [dicOperation setObject:[NSNumber numberWithInt:5] forKey:@"step"];
    [dicOperation setObject:[NSNumber numberWithBool:stop] forKey:@"stop"];
    
    [self performSelectorInBackground:@selector(threadPtzCamera:)
                           withObject:dicOperation];
}


- (void)threadPtzCamera:(NSDictionary *)dicOperation
{
    dpsdk_camera_operation_e operation = [[dicOperation valueForKey:@"operation"]intValue];
    int step = [[dicOperation valueForKey:@"step"]intValue];
    BOOL stop = [[dicOperation valueForKey:@"stop"]boolValue];
    [[PreviewManager sharedInstance]ptzCamara:operation
                                       byStep:step
                                         stop:stop];
}

#pragma mark - Notification process
-(void)addNotification
{
    NSNotificationCenter *notfiyCenter = [NSNotificationCenter defaultCenter];
    
    [notfiyCenter addObserver:self selector:@selector(appHasGoneInForegroundNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
    [notfiyCenter addObserver:self selector:@selector(appEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
}
-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)appHasGoneInForegroundNotification
{
    //重新进入前台的时候 app重新打开之前后台关闭的视频
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[PreviewManager sharedInstance]openRealPlay:(__bridge void *)(videoWnd_)];
    });
    NSLog(@"appHasGoneInForegroundNotification--openRealPlay");
}
-(void)appEnterBackgroundNotification
{
    //进入后台之后
    //如果当前打开视频的话 需要默认关闭
    [[PreviewManager sharedInstance]stopRealPlay];
    [[TalkManager sharedInstance]stopTalk];
    [_playStopBt setSelected:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[PreviewManager sharedInstance]stopRealPlay];
    [[TalkManager sharedInstance]stopTalk];
    [[PreviewManager sharedInstance]initData];
}
-(void)dealloc
{
    [self removeNotification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
