//
//  WaterMonitorViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/3/12.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WaterMonitorViewController.h"
#import "DHVideoWnd.h"
#import "PreviewManager.h"
#import "TalkManager.h"

@interface WaterMonitorViewController ()
{
    DHVideoWnd  *videoWnd_;
    
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
    
    [self addNotification];
    
    [[PreviewManager sharedInstance] initData];
    
    [[PreviewManager sharedInstance]openRealPlay:(__bridge void *)(videoWnd_)];
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
    videoWnd_ = [[DHVideoWnd alloc]initWithFrame:CGRectMake(0, (KScreenHeight - 285*wScale - kTopHeight)/2, KScreenWidth, 285*wScale)];
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
    
    videoWnd_.transform = CGAffineTransformRotate(videoWnd_.transform, -M_PI_2);
    videoWnd_.frame = CGRectMake(0, (KScreenHeight - 285*wScale - kTopHeight)/2, KScreenWidth, 285*wScale);
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
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

@end
