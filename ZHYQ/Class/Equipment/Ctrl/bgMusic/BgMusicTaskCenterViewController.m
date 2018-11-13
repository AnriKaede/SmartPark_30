//
//  BgMusicTaskCenterViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/12/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BgMusicTaskCenterViewController.h"

#import "DefineTimeTaskViewController.h"
#import "BgMusicViewController.h"

@interface BgMusicTaskCenterViewController ()

@property (nonatomic, strong) NSArray *titleData;
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

@end

@implementation BgMusicTaskCenterViewController

//动态更新状态栏颜色
- (UIStatusBarStyle)preferredStatusBarStyle{
    return _statusBarStyle;
}
-(void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle{
    _statusBarStyle = statusBarStyle;
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark 标题数组
- (NSArray *)titleData {
    if (!_titleData) {
        _titleData = @[@"定时任务", @"区域列表"];
    }
    return _titleData;
}

#pragma mark 初始化代码
- (instancetype)init {
    if (self = [super init]) {
        self.titleSizeNormal = 15;
        self.titleSizeSelected = 15;
        self.titleColorSelected = [UIColor colorWithHexString:@"#1B82D1"];
        self.menuViewStyle = WMMenuViewStyleLine;
        self.menuItemWidth = [UIScreen mainScreen].bounds.size.width / self.titleData.count;
        self.menuHeight = 60;
        self.menuViewBottomSpace = 0;
        self.progressHeight = 5;
        self.scrollEnable = NO;
        self.progressColor = [UIColor colorWithHexString:@"#1B82D1"];
    }
    return self;
}

#pragma mark - Datasource & Delegate

#pragma mark 返回子页面的个数
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.titleData.count;
}

#pragma mark 返回某个index对应的页面
- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    switch (index) {
        case 0:{
            DefineTimeTaskViewController *defVC = [[DefineTimeTaskViewController alloc] init];
            defVC.title = @"定时任务";
            return defVC;
            
        }
            break;
            
        default:
            {
                BgMusicViewController *bgMusciVC = [[BgMusicViewController alloc] init];
                bgMusciVC.title = @"区域任务";
                bgMusciVC.menuID = @"13";
                return bgMusciVC;
            }
            break;
    }
}

#pragma mark 返回index对应的标题
- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    
    return self.titleData[index];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initNavItems];
    
    [self _initView];
    
    self.statusBarStyle = UIStatusBarStyleLightContent;
}

-(void)_initNavItems
{
    self.view.backgroundColor = [UIColor colorWithHexString:@"#E2E2E2"];
    
    self.title = @"背景音乐";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"一键关停" style:UIBarButtonItemStylePlain target:self action:@selector(stopAllPlay)];
    
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)_initView
{
    for (int i=1; i<2; i++) {
        UIImageView *hLineView = [[UIImageView alloc] init];
        hLineView.image = [UIImage imageNamed:@"LED_seperateline_blue"];
        hLineView.frame = CGRectMake(KScreenWidth/2 * i, 15, 0.5, 32);
        [self.menuView addSubview:hLineView];
    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.menuHeight, KScreenWidth, 0.5)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#E2E2E2"];
    [self.menuView addSubview:lineView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)stopAllPlay {
    UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确定停止所有播放音乐?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *stop = [UIAlertAction actionWithTitle:@"停止" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        // 停止
        NSString *stopUrl = [NSString stringWithFormat:@"%@/music/stopalltids", Main_Url];
        [[NetworkClient sharedInstance] GET:stopUrl dict:nil progressFloat:nil succeed:^(id responseObject) {
            if(responseObject[@"code"] != nil && ![responseObject[@"code"] isKindOfClass:[NSNull class]] && [responseObject[@"code"] isEqualToString:@"1"]){
                // 刷新音乐分组列表
                [[NSNotificationCenter defaultCenter] postNotificationName:@"StopAllMusic" object:nil];
                // 记录日志
                [self logRecord];
            }
            /*
            NSDictionary *responseData = responseObject[@"responseData"];
            if(responseData != nil && ![responseData isKindOfClass:[NSNull class]] && [responseData isKindOfClass:[NSDictionary class]] && [responseData.allKeys containsObject:@"result" ]){
                NSString *resutl = responseData[@"result"];
                if(resutl != nil && ![resutl isKindOfClass:[NSNull class]] && [resutl isKindOfClass:[NSDictionary class]]){
                    if([resutl isEqualToString:@"success"]){
                        // 刷新音乐分组列表
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"StopAllMusic" object:nil];
                        // 记录日志
                        [self logRecord];
                    }
                }
            }
             */
        } failure:^(NSError *error) {

        }];
    }];
    
    
    [alertControl addAction:cancel];
    [alertControl addAction:stop];
    [self presentViewController:alertControl animated:YES completion:nil];
    
}

- (void)logRecord {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:@"背景音乐一键关停" forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:@"背景音乐一键关停" forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"music/stopalltids" forKey:@"operateUrl"];//操作url
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"背景音乐" forKey:@"operateDeviceName"];//操作设备名  模块
//    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

@end
