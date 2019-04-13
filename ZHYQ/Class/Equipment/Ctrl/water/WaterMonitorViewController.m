//
//  WaterMonitorViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/3/12.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WaterMonitorViewController.h"
//#import "PreviewManager.h"
//#import "TalkManager.h"

#import "DHPlayWindow.h"
#import "DPSRTCamera.h"
#import "DHLoginManager.h"
#import "DHDataCenter.h"
#import "DSSPlayWndToolBar.h"

@interface WaterMonitorViewController ()
{
    DHPlayWindow *_playWindow;
    
    UIButton *_fullBt;
    UIButton *_colseBt;
    BOOL _isHidBar;
    
    BOOL _isCanSideBack;
}
@end

@implementation WaterMonitorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self _initView];
    
    NSString *channelId = ((DSSChannelInfo *)[DHDataCenter sharedInstance].selectNode.content).channelid;
    [self startToplay:channelId winIndex:0 streamType:0];
}

- (void)_initView {
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.title = @"实景视频";
    
    // 禁止左滑
    id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
    [self.view addGestureRecognizer:pan];
    
    // 创建视频播放视图
    _playWindow = [[DHPlayWindow alloc] initWithFrame:CGRectMake(0, (KScreenHeight - 285*wScale - kTopHeight)/2, KScreenWidth, 285*wScale)];
    [_playWindow defultwindows:1];
    DSSUserInfo* userinfo = [DHLoginManager sharedInstance].userInfo;
    NSString *host = [[DHDataCenter sharedInstance] getHost];
    int port = [[DHDataCenter sharedInstance] getPort];
    [_playWindow setHost:host Port:port UserName:userinfo.userName];
    _playWindow.hideDefultToolViews = YES;
    [self.view addSubview:_playWindow];
    
    _fullBt = [UIButton buttonWithType:UIButtonTypeCustom];
    _fullBt.frame = CGRectMake(KScreenWidth - 33, _playWindow.bottom - 29, 25, 25);
    [_fullBt setBackgroundImage:[UIImage imageNamed:@"FullScreen"] forState:UIControlStateNormal];
    [_fullBt addTarget:self action:@selector(fullAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_fullBt];
    
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
    _playWindow.userInteractionEnabled = NO;
    
    // 隐藏控制按钮放置点击
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
    
    _fullBt.hidden = NO;
    
    _playWindow.transform = CGAffineTransformRotate(_playWindow.transform, -M_PI_2);
    _playWindow.frame = CGRectMake(0, (KScreenHeight - 285*wScale - kTopHeight)/2, KScreenWidth, 285*wScale);
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
    [_playWindow stopAll];
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
