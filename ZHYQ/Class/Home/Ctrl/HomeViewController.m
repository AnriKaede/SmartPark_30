//
//  HomeViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/10/22.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "HomeViewController.h"
#import "LogViewCtrl.h"
#import "UITabBar+CustomBadge.h"
#import "YQVideoPlayer.h"
#import "GraphListTableViewController.h"

#import "EnergyTabbarController.h"
#import "ParkCountViewController.h"
#import "WarnTabbarController.h"

#import "HomeBgMusicTabViewController.h"
#import "VisitorTabbarController.h"
#import "MealTabBarController.h"

#import "LoginViewController.h"
#import "BgMusicViewController.h"

#import "MusicGroupModel.h"

#import "PublicModel.h"
#import "EnvInfoModel.h"
#import "WifiInfoCountModel.h"

#import "SCLAlertView.h"
#import "YQAutoScrolLab.h"

#import "BgMusicTaskCenterViewController.h"

#import "MonitorLoginInfoModel.h"

//#import "WeatherViewController.h"
#import "WeatherDetailController.h"
#import "ScanViewController.h"

#import "YQDownloadButton.h"

#import "MonitorLogin.h"
#import "YQRemindUpdatedView.h"

#import "ResetPswTableViewController.h"

#import "WifiShareCountViewController.h"

#import "Utils.h"

#import "ParkOverViewController.h"

//#import "ARSViewController.h"

#import "AESUtil.h"

//#import "HomeViewController+IMChatManager.h"
#import <Hyphenate/Hyphenate.h>
#import <UserNotifications/UserNotifications.h>
#import "EaseSDKHelper.h"
#import "DemoCallManager.h"
#import "EMGlobalVariables.h"
#import "IMUserQuery.h"

//BOOL gIsCalling = NO;

@interface HomeViewController ()<todayClickDelegate, YQRemindUpdatedViewDelegate, TZImagePickerControllerDelegate, EMChatManagerDelegate, EMClientDelegate>
{
    UIScrollView *bottomBgView;
    
    YQAutoScrolLab *autoLabel;
    
    //天气底部视图
    UIView *_WeatherBgView;
    //地点
    UILabel *_cityLab;
    //分割线
    UIImageView *_sepVLineView;
    //天气
    UIImageView *_weatherView;
    UILabel *_weaDataLab;
    //湿度
    UIImageView *_humidityView;
    UILabel *_humDataLab;
    //PM2.5
    UIImageView *_pmView;
    UILabel *_pmDataLab;
    UILabel *_pmStandLab;
    
    //电耗背景视图
    UIView *_rtimeEnConsumBgView;
    //电耗数据
    UILabel *_elecLab;
    //电耗数据单位
    UILabel *_elecUnitLab;
    //电耗标志图
    UIImageView *_elecIcon;
    
    //水耗背景视图
    UIView *_waterConsumBgView;
    //水耗数据
    UILabel *_waterLab;
    //水耗数据单位
    UILabel *_waterUnitLab;
    //水耗标志图
    UIImageView *_waterIcon;
    //中部灰色分割线视图
    UIView *_midGrayView;
    //剩余车位背景视图
    UIView *_overagePsBgView;
    //剩余车位数量
    UILabel *_overageNumLab;
    //个
    UILabel *_geLab;
    //车位icon
    UIImageView *_parkSpaceView;
    //剩余车位lab
    UILabel *_overageLab;
    //今日访客
    UIView *_todayVisitorsView;
    //今日访客数量
    UILabel *_visNumLab;
    //个
    UILabel *_visGeLab;
    //车位icon
    UIImageView *_visView;
    //剩余车位lab
    UILabel *_visLab;
    
    //背景音乐
    UIView *_bgMusicView;
    //音乐图标
    UIImageView *_musicView;
    //音乐lab
    UILabel *_musicLab;
    
    // wifi
    UIView *_wifiBgView;
    //wifi用户数量
    UILabel *_wifiNumLabel;
    //条
    UILabel *_stripeLab;
    //wifi icon
    UIImageView *_wifiIconImgView;
    //wifi title lab
    UILabel *_wifiTitleLab;
    
    // 就餐热度
    UIView *_eatHotBgView;
    //wifi用户数量
    UILabel *_eatNumLabel;
    //条
    UILabel *_eatStripeLab;
    //就餐 icon
    UIImageView *_eatIconImgView;
    //就餐 title lab
    UILabel *_eatTitleLab;
    
    NSString *_indoorMusic;
    NSString *_outDoorMusic;
    
    // 中间今日园区
    UIView *_todayCountView;
    
    NSTimer *_timer;
    
    // 大华平台登录标示
    BOOL _isLogin;

    PublicModel *_model;
    // 更新提醒view是否显示
    YQRemindUpdatedView *_updatedView;
    BOOL _isShowingAlert;
    NSInteger _alertNum;
    
    NSInteger _appCodeDifVersion;

    BOOL gIsCalling;
}

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _alertNum = 0;
    //导航栏
    [self _initNavItems];
    //界面
    [self _initView];
    
    [self _loadData];
    
    [self showVersionAlert];
    
    // 初始化环信
    [self IMLogin];
    
    /* 17版本强制重新登录获取公司角色信息 */
    [self _reloadLoginInfo];
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:KLoginUserName];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:KLoginPasword];
    if(username != nil && username.length > 0 && password != nil && password.length > 0){
        // 已重新登录验证，本地保存用户名密码。调用接口判断是否正确
        [self liginVer:username withPassword:password];
    }else {
        // 未重新登录验证，退出登录
        [[NSNotificationCenter defaultCenter] postNotificationName:@"logoutNotion" object:nil];
//        [kUserDefaults removeObjectForKey:];
        [self logoutAction];
    }
    
    // 从后台进入前台的提醒
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showVersionAlert) name:@"EnterForegroundAlert" object:nil];
    // 恢复网络通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeNetworkSel) name:@"ResumeNetworkNotification" object:nil];
}


#pragma mark 从无网络恢复网络通知
- (void)resumeNetworkSel {
    [self _loadData];
}

#pragma mark /* 17版本强制重新登录获取公司角色信息 */
- (void)_reloadLoginInfo {
    if(![[NSUserDefaults standardUserDefaults] boolForKey:KNewLoginFlag]){
        // 未重新登录，强制退出
        [self logoutAction];
    }
}

#pragma mark 退出登录清除本地数据
- (void)logoutAction {
    [Utils logoutRemoveDefInfo];
}

#pragma mark 验证登录
- (void)liginVer:(NSString *)userName withPassword:(NSString *)password {
    NSString *pwd = [password md5String];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/common/checkLogin",Main_Url];
    
    NSMutableDictionary *params = @{}.mutableCopy;
    [params setObject:userName forKey:@"loginName"];
    [params setObject:pwd forKey:@"userpasswd"];
    
    NSString *jsonStr = [Utils convertToJsonData:params];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            // 验证成功
        }else {
            // 验证失败，和服务器密码对应不上
            [[NSNotificationCenter defaultCenter] postNotificationName:@"logoutNotion" object:nil];
            [self logoutAction];
        }
    } failure:^(NSError *error) {
    }];
}

#pragma mark 加载更新信息
- (void)showVersionAlert {
    if(_isShowingAlert){
        return;
    }
    NSString *appVersionPath = [[NSBundle mainBundle] pathForResource:@"appVersion" ofType:@"plist"];
    NSDictionary *appVersionDic = [NSDictionary dictionaryWithContentsOfFile:appVersionPath];
    NSString *appVersion = appVersionDic[@"appVersion"];
    
    NSString *loginName = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:KLoginUserName]];
    
    NSString *versionUrl = [NSString stringWithFormat:@"%@/public/getVersion?appType=admin&osType=ios&versionCust=%@&version=%@", Main_Url, loginName, appVersion];
    [[NetworkClient sharedInstance] GET:versionUrl dict:nil progressFloat:nil succeed:^(id responseObject) {
        if([responseObject[@"code"] isEqualToString:@"1"]){
            NSDictionary *responseData = responseObject[@"responseData"];
            if(responseData == nil || [responseData isKindOfClass:[NSNull class]]){
                return ;
            }
            PublicModel *model = [[PublicModel alloc] initWithDataDic:responseData];
            _model = model;
            if(model.appCode != nil && ![model.appCode isKindOfClass:[NSNull class]] && model.appCode.integerValue > appVersion.integerValue){
                [self showVisionAlert:model withDifferVersion:model.appCode.integerValue - appVersion.integerValue];
            }else {
                // 版本相同，同步当前时间为版本更新时间(作用：更新完成重置提醒时间)，并将版本相差数设置为0
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:KAlertTime];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:KDifferVersion];
                
                [kNotificationCenter postNotificationName:@"isNeedRemaindNotification" object:@{@"isNeedRemaind":@"0"}];
                [kUserDefaults setBool:NO forKey:KNeedRemain];
            }
            
        }
    } failure:^(NSError *error) {
        
    }];
    
}

- (void)showVisionAlert:(PublicModel *)model withDifferVersion:(NSInteger)appCodeDifferVersion{
    _isShowingAlert = YES;
    _appCodeDifVersion = appCodeDifferVersion;
    
    NSDate *alertTime = [[NSUserDefaults standardUserDefaults] objectForKey:KAlertTime];
    NSNumber *differVersion = [[NSUserDefaults standardUserDefaults] objectForKey:KDifferVersion];
    NSNumber *alertNum = [[NSUserDefaults standardUserDefaults] objectForKey:KAlertNum];
    
    if ([model.isMust isEqualToString:@"1"]) {
        _updatedView = [[YQRemindUpdatedView alloc] initWithTitle:[NSString stringWithFormat:@"V%@新版本更新", model.versionNum] message:model.versionInfo delegate:self leftButtonTitle:@"暂不更新" rightButtonTitle:@"立即更新"];
        _updatedView.delegate = self;
        _updatedView.isMust = @"1";
        [_updatedView show];
    }else {
        // 非必须更新，判断提醒次数和 上次更新提醒时间和相差版本
        if(differVersion == nil || appCodeDifferVersion > differVersion.integerValue){
            [self showNoMustAlert:model];
            _alertNum = 1;
            
            [kNotificationCenter postNotificationName:@"isNeedRemaindNotification" object:@{@"isNeedRemaind":@"1"}];
            [kUserDefaults setBool:YES forKey:KNeedRemain];
        }else if(alertNum == nil || alertNum.integerValue == 0){
            // 第一次提醒
            [self showNoMustAlert:model];
            _alertNum = 1;
            
        }else if (alertNum.integerValue == 1 && (alertTime == nil || [self getDifferenceByDate:alertTime] >= 7)) {
            [self showNoMustAlert:model];
            _alertNum = 2;
            
        }else {
            // 不提醒
            _isShowingAlert = NO;
        }
    }
}
- (void)showNoMustAlert:(PublicModel *)model {
    _updatedView = [[YQRemindUpdatedView alloc] initWithTitle:[NSString stringWithFormat:@"V%@新版本更新", model.versionNum] message:model.versionInfo delegate:self leftButtonTitle:@"暂不更新" rightButtonTitle:@"立即更新"];
    _updatedView.delegate = self;
    _updatedView.isMust = @"0";
    [_updatedView show];
}

#pragma mark YQRemindUpdatedView Delegate
-(void)remaindViewBtnClick:(buttonType)btn
{
    if(btn == cancleButton){
        _isShowingAlert = NO;
        // 保存提示信息
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:KAlertTime];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_alertNum] forKey:KAlertNum];
        
        // 更新本地版本相差数
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_appCodeDifVersion] forKey:KDifferVersion];
    }
    if (btn == sureButton) {
        // 判断是否是wifi网络
        if([YYReachability reachability].status == YYReachabilityStatusWWAN){
            // 手机流量
            UIAlertController *cerAlertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"您正在使用移动流量，是否确认下载" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [_updatedView show];
            }];
            UIAlertAction *downAction = [UIAlertAction actionWithTitle:@"确认下载" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self openDownUrl];
            }];
            [cerAlertCon addAction:cancelAction];
            [cerAlertCon addAction:downAction];
            [self presentViewController:cerAlertCon animated:YES completion:nil];
            [_updatedView dismiss];
        }else {
            [self openDownUrl];
        }
        
    }
}
// 跳转浏览器下载
- (void)openDownUrl {
    [_updatedView show];
    
    if (_model.appUrl != nil && ![_model.appUrl isKindOfClass:[NSNull class]]) {
        NSString *appUrl = _model.appUrl;   // 改为plist
        
        NSString * urlStr = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", appUrl];    // @"https://dn-transfar.qbox.me/zhihui_admin.plist"
        [self openScheme:urlStr];
        
    }else{
        [self showHint:@"更新失败!"];
    }
}

- (void)openScheme:(NSString *)scheme {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:scheme];
    if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [application openURL:URL options:@{} completionHandler:^(BOOL success) {
            NSLog(@"Open %@: %d",scheme,success);
            //退出应用程序
            exit(0);
        }];
        
    } else {
        BOOL success = [application openURL:URL];
        NSLog(@"Open %@: %d",scheme,success);
    }
}

-(void)_loadData
{
    // 判断密码是否过期(一个月)
    [self verLoginOverdue];
    
    //加载天气数据
    [self _loadWeatherData];
    //加载实时能耗数据
    [self _loadRtimeEnergyConsumData];
    //获取当前剩余车位数
    [self _loadOverParkSpaceData];
    //获取今日访客数
    [self _loadVistorData];
    //获取背景音乐数据
    [self _loadBgMusicData];
    
    //获取wifi数据
    [self _loadWifiData];
    //获取就餐热度数据
    [self _loadEatHotData];
    
    // 加载大华sdk平台 登录信息
    [self _loadMonitorLoginInfo];
    
    // 加载停车接口ip
    [self _loadParkIp];
    
    // 加载地图默认定位经纬度
    [self _loadLocationInfo];
    
    // 获取环信对应服务器哟用户数据
    [[IMUserQuery shaerInstance] loadServerUserData];
}
#pragma mark 加载大华sdk平台 登录信息
- (void)_loadMonitorLoginInfo {
    NSString *urlStr = [NSString stringWithFormat:@"%@/public/getPublicConfig",Main_Url];
    
    NSMutableDictionary *pubParam = @{}.mutableCopy;
    [pubParam setObject:@"DSS" forKey:@"configCode"];
    NSString *jsonStr = [Utils convertToJsonData:pubParam];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        NSDictionary *data = responseObject;
        if ([data[@"code"] isEqualToString:@"1"]) {
            NSDictionary *responseData = responseObject[@"responseData"];
            if(responseData != nil && ![responseData isKindOfClass:[NSNull class]]){
                [[NSUserDefaults standardUserDefaults] setObject:responseData forKey:KMonitorInfo];
            }
        }
        
    } failure:^(NSError *error) {
    }];
}

- (void)_loadParkIp {
    NSString *urlStr = [NSString stringWithFormat:@"%@/public/getPublicConfig",Main_Url];
    
    NSMutableDictionary *pubParam = @{}.mutableCopy;
    [pubParam setObject:@"PARKING" forKey:@"configCode"];
    NSString *jsonStr = [Utils convertToJsonData:pubParam];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        NSDictionary *data = responseObject;
        if ([data[@"code"] isEqualToString:@"1"]) {
            NSDictionary *responseData = responseObject[@"responseData"];
            if(responseData != nil && ![responseData isKindOfClass:[NSNull class]]){
                NSString *parkIp = responseData[@"parking"];
//                NSString *parkUrl = [AESUtil decryptAES:parkIp key:AESKey];
                [[NSUserDefaults standardUserDefaults] setObject:parkIp forKey:KParkResquestIp];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        
    } failure:^(NSError *error) {
    }];
}

#pragma mark 加载地图默认定位经纬度
- (void)_loadLocationInfo {
    NSString *urlStr = [NSString stringWithFormat:@"%@/public/getPublicConfig",Main_Url];
    
    NSMutableDictionary *pubParam = @{}.mutableCopy;
    [pubParam setObject:@"MAPPOSTION" forKey:@"configCode"];
    NSString *jsonStr = [Utils convertToJsonData:pubParam];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        NSDictionary *data = responseObject;
        if ([data[@"code"] isEqualToString:@"1"]) {
            NSDictionary *responseData = responseObject[@"responseData"];
            if(responseData != nil && ![responseData isKindOfClass:[NSNull class]]){
                NSString *locationStr = responseData[@"mapPosition"];
                if(locationStr != nil && ![locationStr isKindOfClass:[NSNull class]]){
                    [[NSUserDefaults standardUserDefaults] setObject:locationStr forKey:KMapLocationCoord];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
        }
        
    } failure:^(NSError *error) {
    }];
}

#pragma mark 加载未读消息
- (void)_loadMsgData {
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:KLoginUserName];
    NSString *urlStr = [NSString stringWithFormat:@"%@/public/getUnreadMessage?appType=%@&loginName=%@",Main_Url, @"admin", username];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        NSDictionary *data = responseObject;
        if ([data[@"code"] isEqualToString:@"1"]) {
            NSNumber *msgNum = responseObject[@"responseData"];
            if(msgNum != nil && ![msgNum isKindOfClass:[NSNull class]] && msgNum.integerValue > 0){
                [self.tabBarController.tabBar setBadgeStyle:kCustomBadgeStyleRedDot value:0 atIndex:2];
            }else {
                [self.tabBarController.tabBar setBadgeStyle:kCustomBadgeStyleNone value:0 atIndex:2];
            }
        }
        
    } failure:^(NSError *error) {
    }];
}

#pragma mark 判断密码是否过期
- (void)verLoginOverdue {
    NSString *urlStr = [NSString stringWithFormat:@"%@/common/isManegePwdOverdue",Main_Url];
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:KLoginUserName];
    
    NSMutableDictionary *param = @{}.mutableCopy;
    if(username != nil && username.length){
        [param setObject:username forKey:@"loginName"];
    }else {
        return;
    }
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"密码修改" message:@"登录密码长时间未修改,为保证账户安全性，建议进行密码修改。" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *canncel = [UIAlertAction actionWithTitle:@"暂不修改" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self dontChange];
            }];
            [canncel setValue:[UIColor grayColor] forKey:@"titleTextColor"];
            UIAlertAction *channge = [UIAlertAction actionWithTitle:@"立即修改" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self presentResetPassword];
            }];
            [alertCon addAction:canncel];
            [alertCon addAction:channge];
            [self presentViewController:alertCon animated:YES completion:nil];
        }
    } failure:^(NSError *error) {
    }];
}
- (void)dontChange {
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:KAdminUserId];
    NSString *urlStr = [NSString stringWithFormat:@"%@/public/upManegePwdTime?userId=%@", Main_Url, userId];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(NSError *error) {
    }];
}
- (void)presentResetPassword {
    // 已过期 跳转修改密码页面
    ResetPswTableViewController *resetPswVC = [[UIStoryboard storyboardWithName:@"Personal" bundle:nil] instantiateViewControllerWithIdentifier:@"ResetPswTableViewController"];
    resetPswVC.isOverdue = YES;
    resetPswVC.hidesBottomBarWhenPushed = YES;
    [self presentViewController:[[RootNavigationController alloc] initWithRootViewController:resetPswVC] animated:YES completion:nil];
}

#pragma mark 加载天气数据
-(void)_loadWeatherData
{
    NSString *urkStr = [NSString stringWithFormat:@"%@/roadLamp/sensorNew",Main_Url];
    
    NSMutableDictionary *param = @{}.mutableCopy;
//    [param setObject:@"" forKey:@"uid"];
    
    NSDictionary *paramDic =@{@"param":[Utils convertToJsonData:param]};
    
    [[NetworkClient sharedInstance] POST:urkStr dict:paramDic progressFloat:nil succeed:^(id responseObject) {
        [bottomBgView.mj_header endRefreshing];
        NSDictionary *data = responseObject;
        if ([data[@"code"] isEqualToString:@"1"]) {
            NSDictionary *weatherDic = data[@"responseData"];
            if(weatherDic == nil || ![weatherDic isKindOfClass:[NSDictionary class]]){
                return ;
            }
            EnvInfoModel *model = [[EnvInfoModel alloc] initWithDataDic:weatherDic];
            
            _cityLab.text = model.adv_name;
            if(model.smallWhite != nil && ![model.smallWhite isKindOfClass:[NSNull class]]){
                [_weatherView sd_setImageWithURL:[NSURL URLWithString:[model.smallWhite stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"未知"]];
            }
            _weaDataLab.text = [NSString stringWithFormat:@"%.1f℃",model.temperature.floatValue];
            _humDataLab.text = [NSString stringWithFormat:@"%.1f%%",model.humidity.floatValue];
            _pmDataLab.text = [NSString stringWithFormat:@"%.0f",model.pm2_5.floatValue];
            
            [self changeValueColor:[NSString stringWithFormat:@"%@", model.pm2_5]];
        }
        
    } failure:^(NSError *error) {
        [bottomBgView.mj_header endRefreshing];
    }];
}

// 根据pm值改变数值颜色
- (void)changeValueColor:(NSString *)pm25 {
    if(pm25 != nil && ![pm25 isKindOfClass:[NSNull class]]){
        if(pm25.integerValue <= 35){
            // 优
            _pmDataLab.textColor = [UIColor colorWithHexString:@"#03ff01"];
            _pmStandLab.text = @"优";
        }else if(pm25.integerValue <= 75){
            // 良
            _pmDataLab.textColor = [UIColor colorWithHexString:@"#ffffff"];
            _pmStandLab.text = @"良";
        }else if(pm25.integerValue <= 115){
            // 轻
            _pmDataLab.textColor = [UIColor colorWithHexString:@"#ffc600"];
            _pmStandLab.text = @"轻度";
        }else if(pm25.integerValue <= 150){
            // 中
            _pmDataLab.textColor = [UIColor colorWithHexString:@"#ffff01"];
            _pmStandLab.text = @"中度";
        }else if(pm25.integerValue <= 250){
            // 重
            _pmDataLab.textColor = [UIColor colorWithHexString:@"#fe9900"];
            _pmStandLab.text = @"重度";
        }else {
            // 严重
            _pmDataLab.textColor = [UIColor colorWithHexString:@"#ff0e00"];
            _pmStandLab.text = @"严重";
        }
        _pmStandLab.textColor = _pmDataLab.textColor;
    }
}

#pragma mark 加载实时能耗数据
-(void)_loadRtimeEnergyConsumData
{
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *statDate = [dateFormat stringFromDate:nowDate];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/energy/status",Main_Url];
    
    NSMutableDictionary *searchParam = @{}.mutableCopy;
    [searchParam setObject:statDate forKey:@"statDate"];
    
    NSString *jsonStr = [Utils convertToJsonData:searchParam];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *dic = responseObject[@"responseData"];
            // 水耗
            NSString *waterValue = dic[@"waterTotal"];
            _waterLab.text = [NSString stringWithFormat:@"%.2f", waterValue.floatValue];
            // 电耗
            NSString *elecValue = dic[@"electricityTotal"];
            _elecLab.text = [NSString stringWithFormat:@"%.2f", elecValue.floatValue];
        }
        
    } failure:^(NSError *error) {
    }];
}

#pragma mark 加载剩余车位数
-(void)_loadOverParkSpaceData
{
    /*
     NSString *urlStr = [NSString stringWithFormat:@"%@/parking/status/0",Main_Url];
     
     [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
     NSDictionary *dataDic = responseObject;
     if ([dataDic[@"code"] isEqualToString:@"1"]) {
     NSDictionary *dic = dataDic[@"responseData"];
     _overageNumLab.text = dic[@"available"];
     }
     } failure:^(NSError *error) {
     
     }];
     */
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/status",ParkMain_Url];
    
    NSMutableDictionary *params = @{}.mutableCopy;
    [params setObject:KParkId forKey:@"parkId"];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        //        DLog(@"%@",responseObject);
        if([responseObject[@"success"] boolValue]){
            NSDictionary *dic = responseObject[@"data"];
            NSDictionary *parkDic = dic[@"park"];
            _overageNumLab.text = [NSString stringWithFormat:@"%@",parkDic[@"parkIdle"]];
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark 获取访客人数
-(void)_loadVistorData
{
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *statDate = [dateFormat stringFromDate:nowDate];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/visitor/dayStat",Main_Url];
    
    NSMutableDictionary *searchParam = @{}.mutableCopy;
    [searchParam setObject:statDate forKey:@"statDate"];
    
    NSString *jsonStr = [Utils convertToJsonData:searchParam];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            // 总数
            _visNumLab.text = [NSString stringWithFormat:@"%@", responseObject[@"responseData"][@"total"]];
        }
        
    } failure:^(NSError *error) {
    }];
}

#pragma mark 获取背景音乐数据
-(void)_loadBgMusicData
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/music/getIndexipcast",Main_Url];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        
        NSDictionary *dataDic = responseObject;
        if ([dataDic[@"code"] isKindOfClass:[NSNull class]]) {
            //            [self showHint:@"暂无数据"];
            [_timer invalidate];
            _timer = nil;
            return ;
        }
        if ([dataDic[@"code"] isEqualToString:@"1"]) {
            
            //            autoLabel.text = @"空闲";
            //            autoLabel.speed = 0;
            //            autoLabel.labelBetweenGap = 0;
            
            NSArray *groups = dataDic[@"responseData"];
            
            if(groups == nil || [groups isKindOfClass:[NSNull class]] || ![groups isKindOfClass:[NSArray class]] || groups.count <= 0){
                [_timer invalidate];
                _timer = nil;
                
                if (autoLabel!=nil) {
                    [autoLabel removeFromSuperview];
                    autoLabel = nil;
                    [self addAtuoLab];
                }
                return ;
            }
            NSString *musciNameStr = @"";
            for (int i = 0; i < groups.count; i++) {
                NSDictionary *musicNameDic = groups[i];
                musciNameStr = [musciNameStr stringByAppendingString:[NSString stringWithFormat:@"  %@",musicNameDic[@"musicname"]]];
            }
            
            autoLabel.text = musciNameStr;
            autoLabel.speed = 20;
            autoLabel.labelBetweenGap = 10;
            
            if(_timer == nil){
                _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 block:^(NSTimer * _Nonnull timer) {
                    _musicView.transform = CGAffineTransformRotate(_musicView.transform, M_PI_4/50);
                } repeats:YES];
            }
            
        }else {
            [_timer invalidate];
            _timer = nil;
        }
    } failure:^(NSError *error) {
    }];
}

/*
#pragma mark 获取报警数据
-(void)_loadAlarmData
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/alarm/status/0",Main_Url];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        NSDictionary *dataDic = responseObject;
        if ([dataDic[@"code"] isEqualToString:@"1"]) {
            NSDictionary *responseData = dataDic[@"responseData"];
            _wifiNumLabel.text = responseData[@"total"];
        }
    } failure:^(NSError *error) {
        
    }];
}
 */

#pragma mark wifi 数据接口
- (void)_loadWifiData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/wifi/getWifiUserDetail?getDetail=%@&layerId=%@&getAns=%@&start=&limit=",Main_Url, @"ALL", @"", @""];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            NSString *allUserCount = [NSString stringWithFormat:@"%@", responseObject[@"responseData"][@"total"]];
            _wifiNumLabel.text = [NSString stringWithFormat:@"%@", allUserCount];
        }
        
    } failure:^(NSError *error) {
        [self showHint:KRequestFailMsg];
    }];
}

#pragma mark 就餐热度接口
- (void)_loadEatHotData {
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *statDate = [dateFormat stringFromDate:nowDate];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/parkCard/dayStat",Main_Url];
    
    NSMutableDictionary *searchParam = @{}.mutableCopy;
    [searchParam setObject:statDate forKey:@"statDate"];
    
    NSString *jsonStr = [Utils convertToJsonData:searchParam];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            // 总数
            _eatNumLabel.text = [NSString stringWithFormat:@"%@", responseObject[@"responseData"][@"chargeCount"]];
        }
        
    } failure:^(NSError *error) {
    }];
}

#pragma mark nav
-(void)_initNavItems
{
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImage:[UIImage imageNamed:@"switchmap"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *rightBtn = [[UIButton alloc] init];
    rightBtn.frame = CGRectMake(0, 0, 40, 40);
    [rightBtn setImage:[UIImage imageNamed:@"scan"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(_rightBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    //titleView
    UIImageView *titleImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    titleImgView.frame = CGRectMake(0, 0, 80*1.5, 17*1.5);
    self.navigationItem.titleView = titleImgView;
}

#pragma mark View
-(void)_initView
{
    //底部scrollview
    bottomBgView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, self.view.frame.size.height)];
    bottomBgView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    bottomBgView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headRefresh)];
    [self.view addSubview:bottomBgView];
    
    //顶部天气视图
    [self _initWeatherView];
    //背景音乐
    [self _initBgMusicView];
    //实时能耗视图
    [self _initRTimeEnergyConsum];
    //中间灰色视图
    [self _initMidGrayView];
    
    //今日访客
    [self _initTodayVisitorsView];
    // wifi
    [self _initEquipmentAlarmView];
    // 就餐热度
    [self _initEatHotView];
    //剩余车位数
    [self _initOverageParkSpaceView];
    
    // 中间进入园区
    [self _initCountView];
}

-(void)headRefresh
{
    [self _loadData];
}

#pragma mark 顶部天气视图
-(void)_initWeatherView
{
    _WeatherBgView = [[UIView alloc] init];
    _WeatherBgView.frame = CGRectMake(0,0,KScreenWidth,84.5*hScale);
    _WeatherBgView.backgroundColor = CNavBgColor;
    [bottomBgView addSubview:_WeatherBgView];
    // 添加渐变色
    [NavGradient viewAddGradient:_WeatherBgView];
    
    UITapGestureRecognizer *weatherTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(weatherAction)];
    [_WeatherBgView addGestureRecognizer:weatherTap];
    
    _cityLab = [[UILabel alloc] init];
    _cityLab.frame = CGRectMake(14*wScale, 0, 79.5*wScale, 25);
    _cityLab.textAlignment = NSTextAlignmentCenter;
    _cityLab.font = [UIFont systemFontOfSize:22];
    _cityLab.centerY = _WeatherBgView.centerY;
    _cityLab.text = @"-";
    _cityLab.textColor = [UIColor whiteColor];
    [_WeatherBgView addSubview:_cityLab];
    
    _sepVLineView = [[UIImageView alloc] init];
    _sepVLineView.frame = CGRectMake(CGRectGetMaxX(_cityLab.frame), (CGRectGetHeight(_WeatherBgView.frame)-32.5*hScale)/2, 0.5*wScale, 32.5*hScale);
    _sepVLineView.image = [UIImage imageNamed:@"weather_sep"];
    [_WeatherBgView addSubview:_sepVLineView];
    
    _weatherView = [[UIImageView alloc] init];
    _weatherView.frame = CGRectMake(94.0*wScale + 50.0*wScale, 22.0*hScale, 24.0*hScale, 24.0*hScale);
    _weatherView.image = [UIImage imageNamed:@"cloud"];
    [_WeatherBgView addSubview:_weatherView];
    
    _humidityView = [[UIImageView alloc] init];
    _humidityView.frame = CGRectMake(94.0*wScale + 50.0*wScale + 85.0*wScale , 22.0*hScale, 24.0*hScale, 20.0*hScale);
    _humidityView.image = [UIImage imageNamed:@"hum"];
    [_WeatherBgView addSubview:_humidityView];
    
    _pmView = [[UIImageView alloc] init];
    _pmView.frame = CGRectMake(94.0*wScale + 50.0*wScale + 85.0*wScale + 85.0*wScale, 22.0*hScale, 24.0*hScale, 20.0*hScale);
    _pmView.image = [UIImage imageNamed:@"PM2.5"];
    [_WeatherBgView addSubview:_pmView];
    
    _weaDataLab = [[UILabel alloc] init];
    _weaDataLab.frame = CGRectMake(0, CGRectGetMaxY(_weatherView.frame)+4.5*hScale, 95.0*hScale, 20.0*hScale);
    _weaDataLab.centerX = _weatherView.centerX;
    _weaDataLab.textAlignment = NSTextAlignmentCenter;
    _weaDataLab.textColor = [UIColor whiteColor];
    _weaDataLab.text = @"-";
    _weaDataLab.font = [UIFont systemFontOfSize:17];
    [_WeatherBgView addSubview:_weaDataLab];
    
    _humDataLab = [[UILabel alloc] init];
    _humDataLab.frame = CGRectMake(0, CGRectGetMaxY(_weatherView.frame)+4.5*hScale, 95.0*hScale, 20.0*hScale);
    _humDataLab.centerX = _humidityView.centerX;
    _humDataLab.textAlignment = NSTextAlignmentCenter;
    _humDataLab.textColor = [UIColor whiteColor];
    _humDataLab.text = @"-";
    _humDataLab.font = [UIFont systemFontOfSize:17];
    [_WeatherBgView addSubview:_humDataLab];
    
    _pmDataLab = [[UILabel alloc] init];
    _pmDataLab.frame = CGRectMake(0, CGRectGetMaxY(_weatherView.frame)+4.5*hScale, 40.0*wScale, 20.0*hScale);
    _pmDataLab.centerX = _pmView.centerX;
    _pmDataLab.textAlignment = NSTextAlignmentCenter;
    _pmDataLab.textColor = [UIColor whiteColor];
    _pmDataLab.text = @"-";
    _pmDataLab.font = [UIFont systemFontOfSize:17];
    [_WeatherBgView addSubview:_pmDataLab];
    
    _pmStandLab = [[UILabel alloc] init];
    _pmStandLab.frame = CGRectMake(_pmDataLab.right + 1, _pmDataLab.top + 2, 24, 12);
    _pmStandLab.textAlignment = NSTextAlignmentCenter;
    _pmStandLab.textColor = [UIColor whiteColor];
    _pmStandLab.text = @"";
    _pmStandLab.font = [UIFont systemFontOfSize:10];
    [_WeatherBgView addSubview:_pmStandLab];
}

// 天气
- (void)weatherAction {
//    WeatherViewController *weatherVC = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"WeatherViewController"];
//    [self.navigationController pushViewController:weatherVC animated:YES];
    
    WeatherDetailController *weatherVC = [[WeatherDetailController alloc] init];
    [self.navigationController pushViewController:weatherVC animated:YES];
}

#pragma mark 背景音乐
-(void)_initBgMusicView
{
    _bgMusicView = [[UIView alloc] init];
    
    _bgMusicView.frame = CGRectMake(-2.5, CGRectGetMaxY(_WeatherBgView.frame) + 5, KScreenWidth*2/5, 180*hScale);
    _bgMusicView.backgroundColor = [UIColor whiteColor];
    _bgMusicView.layer.cornerRadius = 4;
    [bottomBgView addSubview:_bgMusicView];

    _musicView = [[UIImageView alloc] init];
    _musicView.image = [UIImage imageNamed:@"home_bg_music_icon"];
    _musicView.frame = CGRectMake((_bgMusicView.width - 65.0*wScale)/2, 13*hScale, 65.0*wScale, 65.0*wScale);
    [_bgMusicView addSubview:_musicView];
    
//    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 block:^(NSTimer * _Nonnull timer) {
//        _musicView.transform = CGAffineTransformRotate(_musicView.transform, M_PI_4/50);
//    } repeats:YES];
    
    UILabel *musicLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _musicView.bottom + 9.5*hScale, _bgMusicView.width, 17)];
    musicLabel.text = @"背景音乐";
    musicLabel.textColor = [UIColor blackColor];
    musicLabel.font = [UIFont systemFontOfSize:17];
    musicLabel.textAlignment = NSTextAlignmentCenter;
    [_bgMusicView addSubview:musicLabel];
    
    [self addAtuoLab];
    
    //速度  间距
    autoLabel.speed = 0;
    autoLabel.labelBetweenGap = 15;
    
    _bgMusicView.userInteractionEnabled = YES;
    
    //添加背景音乐跳转事件
    UITapGestureRecognizer *bgMusicTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgMusicTap:)];
    [_bgMusicView addGestureRecognizer:bgMusicTap];
}

#pragma mark 实时能耗视图
-(void)_initRTimeEnergyConsum
{
    // 今日电耗
    _rtimeEnConsumBgView = [[UIView alloc] init];
    _rtimeEnConsumBgView.backgroundColor = [UIColor whiteColor];
    _rtimeEnConsumBgView.layer.cornerRadius = 4;
    _rtimeEnConsumBgView.frame = CGRectMake(_bgMusicView.right + 5, CGRectGetMaxY(_WeatherBgView.frame) + 5, KScreenWidth*3/5, 87.5*hScale);
    [bottomBgView addSubview:_rtimeEnConsumBgView];
    
    _elecIcon = [[UIImageView alloc] init];
    _elecIcon.frame = CGRectMake(39*wScale, 26*hScale, 20.0*wScale, 33.0*wScale);
    _elecIcon.image = [UIImage imageNamed:@"elec_power"];
    [_rtimeEnConsumBgView addSubview:_elecIcon];
    
    _elecLab = [[UILabel alloc] init];
    _elecLab.frame = CGRectMake(_elecIcon.right + 2, _elecIcon.top, _rtimeEnConsumBgView.width - _elecIcon.right - 20, 20);
    _elecLab.textAlignment = NSTextAlignmentCenter;
    _elecLab.font = [UIFont systemFontOfSize:20.0*hScale];
    _elecLab.backgroundColor = [UIColor clearColor];
    _elecLab.text = @"-";
    _elecLab.textColor = [UIColor colorWithHexString:@"#FF254E"];
    [_rtimeEnConsumBgView addSubview:_elecLab];
    
    _elecUnitLab = [[UILabel alloc] init];
    _elecUnitLab.frame = CGRectMake(_elecLab.left, _elecLab.bottom + 8*hScale, _elecLab.width, 17);
    _elecUnitLab.textAlignment = NSTextAlignmentCenter;
    _elecUnitLab.font = [UIFont systemFontOfSize:17.0*hScale];
    _elecUnitLab.backgroundColor = [UIColor clearColor];
    _elecUnitLab.text = @"kwh";
    _elecUnitLab.textColor = [UIColor colorWithHexString:@"#FF254E"];
    [_rtimeEnConsumBgView addSubview:_elecUnitLab];
    
    // 水耗
    _waterConsumBgView = [[UIView alloc] init];
    _waterConsumBgView.backgroundColor = [UIColor whiteColor];
    _waterConsumBgView.layer.cornerRadius = 4;
    _waterConsumBgView.frame = CGRectMake(_rtimeEnConsumBgView.left, _rtimeEnConsumBgView.bottom + 5, KScreenWidth*3/5, 87.5*hScale);
    [bottomBgView addSubview:_waterConsumBgView];
    
    _waterIcon = [[UIImageView alloc] init];
    _waterIcon.frame = CGRectMake(39*wScale, 26*hScale, 20.0*wScale, 28.0*wScale);
    _waterIcon.image = [UIImage imageNamed:@"water"];
    [_waterConsumBgView addSubview:_waterIcon];
    
    _waterLab = [[UILabel alloc] init];
    _waterLab.frame = CGRectMake(_waterIcon.right + 2, _waterIcon.top, _waterConsumBgView.width - _waterIcon.right - 20, 20);
    _waterLab.textAlignment = NSTextAlignmentCenter;
    _waterLab.font = [UIFont systemFontOfSize:20.0*hScale];
    _waterLab.backgroundColor = [UIColor clearColor];
    _waterLab.text = @"-";
    _waterLab.textColor = [UIColor colorWithHexString:@"00ABA9"];
    [_waterConsumBgView addSubview:_waterLab];
    
    _waterUnitLab = [[UILabel alloc] init];
    _waterUnitLab.frame = CGRectMake(_waterLab.left, _waterLab.bottom + 8*hScale, _waterLab.width, 17);
    _waterUnitLab.textAlignment = NSTextAlignmentCenter;
    _waterUnitLab.font = [UIFont systemFontOfSize:17.0*hScale];
    _waterUnitLab.backgroundColor = [UIColor clearColor];
    _waterUnitLab.text = @"吨";
    _waterUnitLab.textColor = [UIColor colorWithHexString:@"00ABA9"];
    [_waterConsumBgView addSubview:_waterUnitLab];
    
    _waterConsumBgView.userInteractionEnabled = YES;
    
    //添加能耗跳转事件
    UITapGestureRecognizer *enegryTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enegryTap:)];
    [_rtimeEnConsumBgView addGestureRecognizer:enegryTap];
    UITapGestureRecognizer *waterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enegryTap:)];
    [_waterConsumBgView addGestureRecognizer:waterTap];
}

#pragma mark 中间灰色视图

-(void)_initMidGrayView
{
    _midGrayView = [[UIView alloc] init];
    _midGrayView.frame = CGRectMake(0, 269.0*hScale, KScreenWidth, 5.5*hScale);
    _midGrayView.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    [bottomBgView addSubview:_midGrayView];
}

#pragma mark 剩余车位数

-(void)_initOverageParkSpaceView
{
    
    _overagePsBgView = [[UIView alloc] init];
    _overagePsBgView.frame = CGRectMake(_eatHotBgView.left, _wifiBgView.top, _todayVisitorsView.width, _todayVisitorsView.height);
    _overagePsBgView.backgroundColor = [UIColor whiteColor];
    _overagePsBgView.layer.cornerRadius = 4;
    [bottomBgView addSubview:_overagePsBgView];
    
    _geLab = [[UILabel alloc] init];
    _geLab.font = [UIFont systemFontOfSize:16];
    _geLab.textAlignment = NSTextAlignmentLeft;
    _geLab.textColor = [UIColor colorWithHexString:@"1B82D1"];
    _geLab.text = @"个";
    _geLab.frame = CGRectMake(KScreenWidth/2 - 45*wScale, _overagePsBgView.height/2 - 33, 25*wScale, 25*hScale);
    [_overagePsBgView addSubview:_geLab];
    
    _overageNumLab = [[UILabel alloc] init];
    _overageNumLab.font = [UIFont systemFontOfSize:22];
    _overageNumLab.textAlignment = NSTextAlignmentRight;
    _overageNumLab.textColor = [UIColor colorWithHexString:@"FF0000"];
    _overageNumLab.text = @"-";
    _overageNumLab.frame = CGRectMake(10, _geLab.top, _geLab.left - 25, 25);
    [_overagePsBgView addSubview:_overageNumLab];
    
    _overageLab = [[UILabel alloc] init];
    _overageLab.font = [UIFont systemFontOfSize:17];
    _overageLab.textAlignment = NSTextAlignmentLeft;
    _overageLab.backgroundColor = [UIColor clearColor];
    _overageLab.textColor = [UIColor colorWithHexString:@"1B82D1"];
    _overageLab.text = @"剩余车位";
    _overageLab.frame = CGRectMake(_geLab.right - 70, _overageNumLab.bottom +(30.0*hScale-15), 70, 17);
    [_overagePsBgView addSubview:_overageLab];
    
    _parkSpaceView = [[UIImageView alloc] init];
    _parkSpaceView.image = [UIImage imageNamed:@"overagePark"];
    _parkSpaceView.backgroundColor = [UIColor clearColor];
    _parkSpaceView.frame = CGRectMake(_overageLab.left - 25*hScale - 15, _overageNumLab.bottom+5.0*hScale, 25.0*hScale, 25.0*hScale);
    [_overagePsBgView addSubview:_parkSpaceView];
    
    _overagePsBgView.userInteractionEnabled = YES;
    
    //添加剩余车位跳转事件
    UITapGestureRecognizer *overageParkTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(overageParkTap:)];
    [_overagePsBgView addGestureRecognizer:overageParkTap];
    
}

#pragma mark 今日访客
-(void)_initTodayVisitorsView
{
    _todayVisitorsView = [[UIView alloc] init];
    if (kDevice_Is_iPhoneX) {
        _todayVisitorsView.frame = CGRectMake(-2.5, _bgMusicView.bottom + 5, KScreenWidth/2, (KScreenHeight - 88 - 83 - _bgMusicView.bottom - 10)/2);
    }else{
        _todayVisitorsView.frame = CGRectMake(-2.5, _bgMusicView.bottom + 5, KScreenWidth/2, (KScreenHeight - 49 - 64 - _bgMusicView.bottom - 10)/2);
    }
    _todayVisitorsView.backgroundColor = [UIColor whiteColor];
    _todayVisitorsView.layer.cornerRadius = 4;
    [bottomBgView addSubview:_todayVisitorsView];
    
    _visNumLab = [[UILabel alloc] init];
    _visNumLab.font = [UIFont systemFontOfSize:22];
    _visNumLab.textAlignment = NSTextAlignmentRight;
    _visNumLab.textColor = [UIColor colorWithHexString:@"FF0000"];
    _visNumLab.text = @"-";
    _visNumLab.frame = CGRectMake(10, _todayVisitorsView.height/2 - 33, KScreenWidth/2*0.4, 25);
    [_todayVisitorsView addSubview:_visNumLab];
    
    _visGeLab = [[UILabel alloc] init];
    _visGeLab.font = [UIFont systemFontOfSize:16];
    _visGeLab.textAlignment = NSTextAlignmentLeft;
    _visGeLab.textColor = [UIColor colorWithHexString:@"1B82D1"];
    _visGeLab.text = @"人";
    _visGeLab.frame = CGRectMake(_visNumLab.right+15, _visNumLab.top, 30, 25);;
    [_todayVisitorsView addSubview:_visGeLab];
    
    _visView = [[UIImageView alloc] init];
    _visView.image = [UIImage imageNamed:@"visitor"];
    _visView.backgroundColor = [UIColor clearColor];
    _visView.frame = CGRectMake(17.0*wScale, _visNumLab.bottom+5.0*hScale, 25.0*hScale, 25.0*hScale);
    [_todayVisitorsView addSubview:_visView];
    
    _visLab = [[UILabel alloc] init];
    _visLab.font = [UIFont systemFontOfSize:17];
    _visLab.textAlignment = NSTextAlignmentLeft;
    _visLab.textColor = [UIColor colorWithHexString:@"1B82D1"];
    _visLab.backgroundColor = [UIColor clearColor];
    _visLab.text = @"访客";
    _visLab.frame = CGRectMake(_visView.right+15, _visNumLab.bottom +(30.0*hScale-15), KScreenWidth/2*0.7, 15);
    [_todayVisitorsView addSubview:_visLab];
    
    _todayVisitorsView.userInteractionEnabled = YES;
    
    //添加今日园区跳转事件
    UITapGestureRecognizer *todayVisTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(todayVisTap:)];
    [_todayVisitorsView addGestureRecognizer:todayVisTap];
}

-(void)addAtuoLab
{
#pragma mark 跑马灯
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, _bgMusicView.height - 52*hScale, _bgMusicView.width, 0.3)];
//    bgImgView.image = [UIImage imageNamed:@"home_music_name_bg"];
    bgImgView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    [_bgMusicView addSubview:bgImgView];
    
    autoLabel = [[YQAutoScrolLab alloc] initWithFrame:CGRectMake(10, bgImgView.top + 20*hScale, _bgMusicView.width-20, 17)];
    autoLabel.text = @"空闲";
    autoLabel.dirtionType = DirtionTypeLeft;
    autoLabel.textColor = [UIColor blackColor];
//    autoLabel.textColor = [UIColor colorWithHexString:@"#F1FF7D"];
    autoLabel.backgroundColor = [UIColor clearColor];
    [_bgMusicView addSubview:autoLabel];
}

#pragma mark wifi
-(void)_initEquipmentAlarmView
{
    _wifiBgView = [[UIView alloc] init];
    
    _wifiBgView.frame = CGRectMake(-2.5, _todayVisitorsView.bottom + 5, _todayVisitorsView.width, _todayVisitorsView.height);
    _wifiBgView.backgroundColor = [UIColor whiteColor];
    _wifiBgView.layer.cornerRadius = 4;
    [bottomBgView addSubview:_wifiBgView];
    
    _wifiNumLabel = [[UILabel alloc] init];
    _wifiNumLabel.font = [UIFont systemFontOfSize:22];
    _wifiNumLabel.textAlignment = NSTextAlignmentRight;
    _wifiNumLabel.textColor = [UIColor colorWithHexString:@"FF0000"];
    _wifiNumLabel.text = @"-";
    _wifiNumLabel.frame = CGRectMake(10, _todayVisitorsView.height/2 - 33, KScreenWidth/2*0.4, 25);
    [_wifiBgView addSubview:_wifiNumLabel];
    
    _stripeLab = [[UILabel alloc] init];
    _stripeLab.font = [UIFont systemFontOfSize:17];
    _stripeLab.textAlignment = NSTextAlignmentLeft;
    _stripeLab.textColor = [UIColor colorWithHexString:@"1B82D1"];
    _stripeLab.text = @"人";
    _stripeLab.frame = _visGeLab.frame;
    [_wifiBgView addSubview:_stripeLab];
    
    _wifiIconImgView = [[UIImageView alloc] init];
    _wifiIconImgView.image = [UIImage imageNamed:@"home_wifi"];
    _wifiIconImgView.backgroundColor = [UIColor clearColor];
    _wifiIconImgView.frame = _visView.frame;
    [_wifiBgView addSubview:_wifiIconImgView];
    
    _wifiTitleLab = [[UILabel alloc] init];
    _wifiTitleLab.font = [UIFont systemFontOfSize:17];
    _wifiTitleLab.textAlignment = NSTextAlignmentLeft;
    _wifiTitleLab.textColor = [UIColor colorWithHexString:@"1B82D1"];
    _wifiTitleLab.text = @"在线";
    _wifiTitleLab.backgroundColor = [UIColor clearColor];
    _wifiTitleLab.frame = _visLab.frame;
    [_wifiBgView addSubview:_wifiTitleLab];
    
    _wifiBgView.userInteractionEnabled = YES;
    
    //添加wifi跳转事件
    UITapGestureRecognizer *equipMentAlarmTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(equipMentAlarmTap:)];
    [_wifiBgView addGestureRecognizer:equipMentAlarmTap];
}
// 就餐热度
- (void)_initEatHotView {
    _eatHotBgView = [[UIView alloc] init];
    
    _eatHotBgView.frame = CGRectMake(_todayVisitorsView.right + 5, _todayVisitorsView.top, _todayVisitorsView.width, _todayVisitorsView.height);
    _eatHotBgView.backgroundColor = [UIColor whiteColor];
    _eatHotBgView.layer.cornerRadius = 4;
    [bottomBgView addSubview:_eatHotBgView];
    
    _eatStripeLab = [[UILabel alloc] init];
    _eatStripeLab.font = [UIFont systemFontOfSize:17];
    _eatStripeLab.textAlignment = NSTextAlignmentLeft;
    _eatStripeLab.textColor = [UIColor colorWithHexString:@"1B82D1"];
    _eatStripeLab.text = @"人次";
    _eatStripeLab.frame = CGRectMake(KScreenWidth/2 - 55*wScale, _todayVisitorsView.height/2 - 33, 35*wScale, 25*hScale);
    [_eatHotBgView addSubview:_eatStripeLab];
    
    _eatNumLabel = [[UILabel alloc] init];
    _eatNumLabel.font = [UIFont systemFontOfSize:22];
    _eatNumLabel.textAlignment = NSTextAlignmentRight;
    _eatNumLabel.textColor = [UIColor colorWithHexString:@"FF0000"];
    _eatNumLabel.text = @"-";
    _eatNumLabel.frame = CGRectMake(10, _eatStripeLab.top, _eatStripeLab.left - 25, 25);
    [_eatHotBgView addSubview:_eatNumLabel];
    
    _eatTitleLab = [[UILabel alloc] init];
    _eatTitleLab.font = [UIFont systemFontOfSize:17];
    _eatTitleLab.textAlignment = NSTextAlignmentLeft;
    _eatTitleLab.textColor = [UIColor colorWithHexString:@"1B82D1"];
    _eatTitleLab.text = @"就餐热度";
    _eatTitleLab.backgroundColor = [UIColor clearColor];
    _eatTitleLab.frame = CGRectMake(_eatStripeLab.right - 70, _eatNumLabel.bottom +(30.0*hScale-15), 70, 17);
    [_eatHotBgView addSubview:_eatTitleLab];
    
    _eatIconImgView = [[UIImageView alloc] init];
    _eatIconImgView.image = [UIImage imageNamed:@"home_food"];
    _eatIconImgView.backgroundColor = [UIColor clearColor];
    _eatIconImgView.frame = CGRectMake(_eatTitleLab.left - 25*hScale - 15, _eatNumLabel.bottom+5.0*hScale, 25.0*hScale, 25.0*hScale);
    [_eatHotBgView addSubview:_eatIconImgView];
    
    _eatHotBgView.userInteractionEnabled = YES;
    
    //添加就餐热度跳转事件
    UITapGestureRecognizer *eatHotTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eatHotAction:)];
    [_eatHotBgView addGestureRecognizer:eatHotTap];
}

#pragma mark 今日园区
- (void)_initCountView {
    _todayCountView = [[UIView alloc] initWithFrame:CGRectMake((KScreenWidth - 125*wScale)/2, _eatHotBgView.bottom - 125*wScale/2 + 2.5, 125*wScale, 125*wScale)];
    _todayCountView.layer.cornerRadius = _todayCountView.width/2;
    _todayCountView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    [bottomBgView addSubview:_todayCountView];
    
//    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, _todayCountView.width - 10, _todayCountView.width - 10)];
//    imgView.image = [UIImage imageNamed:@"home_today_count"];
//    [_todayCountView addSubview:imgView];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(5, 5, _todayCountView.width - 10, _todayCountView.width - 10)];
    bgView.layer.cornerRadius = _todayCountView.width/2;
    bgView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    [_todayCountView addSubview:bgView];
    
    YQDownloadButton *button = [[YQDownloadButton alloc] initWithFrame:CGRectMake(0, 0, bgView.width, bgView.width)];
    button.layer.cornerRadius = bgView.width/2;
    button.wave_scale = 0.4;
    [button startDownload];
    button.todayClickDelegate = self;
    [bgView addSubview:button];
}

- (void)todayClick {
    NSLog(@"%@", [self getNowTimeTimestamp]);
    ParkOverViewController *parkOverVC = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"ParkOverViewController"];
    [self.navigationController pushViewController:parkOverVC animated:YES];
}
- (NSString *)getNowTimeTimestamp{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    
    return timeSp;
    
}

#pragma mark 扫一扫
- (void)_rightBarBtnItemClick:(id)sender {
    ScanViewController *scanVC = [[ScanViewController alloc] init];
    [self.navigationController pushViewController:scanVC animated:YES];
}

-(void)_leftBarBtnItemClick:(id)sender
{
    //这里的话是通过遍历循环拿到之前在AppDelegate中声明的那个MMDrawerController属性，然后判断是否为打开状态，如果是就关闭，否就是打开(里面还有一些条件)
    
    if ([kUserDefaults boolForKey:KLoginState]) {
        [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }else{
        //        LogViewCtrl *logCtrl = [[LogViewCtrl alloc] init];
        //        logCtrl.hidesBottomBarWhenPushed = YES;
        //        [self.navigationController pushViewController:logCtrl animated:YES];
        if (self.mm_drawerController.openSide == MMDrawerSideLeft) {
            [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
            return;
        }
        RootNavigationController *loginVC = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginNavViewController"];
        
        [self presentViewController:loginVC animated:YES completion:nil];
    }
}

#pragma mark 能耗点击事件
-(void)enegryTap:(id)tap
{
    if ([kUserDefaults boolForKey:KLoginState]) {
        EnergyTabbarController *energyTC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"EnergyTabbarController"];
        [self.navigationController pushViewController:energyTC animated:YES];
    }else{
        RootNavigationController *loginVC = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginNavViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
    }
}

#pragma mark 剩余车位点击事件
-(void)overageParkTap:(id)tap
{
    if ([kUserDefaults boolForKey:KLoginState]) {
        ParkCountViewController *parkCountTC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"ParkCountViewController"];
        [self.navigationController pushViewController:parkCountTC animated:YES];
    }else{
        RootNavigationController *loginVC = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginNavViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
    }
}

#pragma mark 今日访客点击事件
-(void)todayVisTap:(id)tap
{
    if ([kUserDefaults boolForKey:KLoginState]) {
        VisitorTabbarController *visitorVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"VisitorTabbarController"];
        [self.navigationController pushViewController:visitorVC animated:YES];
    }else{
        RootNavigationController *loginVC = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginNavViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
    }
}

#pragma mark 背景音乐点击事件
-(void)bgMusicTap:(id)tap
{
    if ([kUserDefaults boolForKey:KLoginState]) {
        /*
         HomeBgMusicTabViewController *bgMusicVC = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"HomeBgMusicTabViewController"];
         bgMusicVC.indoorMusic = _indoorMusic;
         bgMusicVC.outdoorMusic = _outDoorMusic;
         [self.navigationController pushViewController:bgMusicVC animated:YES];
         */
        //        BgMusicViewController *bgMusicVC = [[BgMusicViewController alloc] init];
        //        bgMusicVC.menuID = @"13";
        //        [self.navigationController pushViewController:bgMusicVC animated:YES];
        
        BgMusicTaskCenterViewController *taskCenterVC = [[BgMusicTaskCenterViewController alloc] init];
        [self.navigationController pushViewController:taskCenterVC animated:YES];
        
        
    }else{
        RootNavigationController *loginVC = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginNavViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
    }
}

#pragma mark wifi点击事件
-(void)equipMentAlarmTap:(id)tap
{
    if ([kUserDefaults boolForKey:KLoginState]) {
        /*
         WarnTabbarController *WarnTC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"WarnTabbarController"];
         [self.navigationController pushViewController:WarnTC animated:YES];
         */
//        [self showHint:@"敬请期待"];
         WifiShareCountViewController *wifiShareVC = [[WifiShareCountViewController alloc] init];
         [self.navigationController pushViewController:wifiShareVC animated:YES];
    }else{
        RootNavigationController *loginVC = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginNavViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
    }
}
#pragma mark 就餐热度
- (void)eatHotAction:(UITapGestureRecognizer *)tap {
    if ([kUserDefaults boolForKey:KLoginState]) {
        MealTabBarController *mealVC = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"MealTabBarController"];
        [self.navigationController pushViewController:mealVC animated:YES];
    }else{
        RootNavigationController *loginVC = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginNavViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    autoLabel.speed = 15;
    autoLabel.labelBetweenGap = 15;
    
    // 加载未读消息
    [self _loadMsgData];
    
    // 登录大华平台
    if(!_isLogin){
        NSDictionary *monitorInfo = [[NSUserDefaults standardUserDefaults] objectForKey:KMonitorInfo];
        if(monitorInfo != nil){
            MonitorLoginInfoModel *model = [[MonitorLoginInfoModel alloc] initWithDataDic:monitorInfo];
            if(model.dssAddr != nil && ![model.dssAddr isKindOfClass:[NSNull class]] &&
               model.dssPort != nil && ![model.dssPort isKindOfClass:[NSNull class]] &&
               model.dssAdmin != nil && ![model.dssAdmin isKindOfClass:[NSNull class]] &&
               model.dssPasswd != nil && ![model.dssPasswd isKindOfClass:[NSNull class]]
               ){
                // 登录视频监控账号
                [MonitorLogin loginWithAddress:model.dssAddr withPort:model.dssPort withName:model.dssAdmin withPsw:model.dssPasswd withResule:^(BOOL isSuc) {
                    if(isSuc){
                        // 登录成功
                        _isLogin = YES;
                    }else {
                    }
                }];
                
            }
        }
    }
}

#pragma mark 判断相差时间天数
- (NSInteger)getDifferenceByDate:(NSDate *)oldDate {
    NSDate *now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    unsigned int unitFlags = NSCalendarUnitDay;
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:oldDate  toDate:now  options:0];
    return [comps day];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"EnterForegroundAlert" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ResumeNetworkNotification" object:nil];
    
    [[EMClient sharedClient].chatManager removeDelegate:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNOTIFICATION_MAKE1V1CALL object:nil];
}

#pragma mark 环信
- (void)IMLogin {
    if(![EMClient sharedClient].isLoggedIn){
        NSString *loginName = [[NSUserDefaults standardUserDefaults] objectForKey:KLoginUserName];
        [[EMClient sharedClient] loginWithUsername:loginName password:[NSString stringWithFormat:@"%@%@", loginName, IMPasswordRule] completion:^(NSString *aUsername, EMError *aError) {
            if (!aError) {
                NSLog(@"登录成功");
            } else {
                NSLog(@"登录失败");
                //                [self showHint:KRequestFailMsg];
            }
        }];
    }
    
    // 代理环信协议(本地通知)
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    
    [DemoCallManager sharedManager];
    
    if (gMainController == nil) {
        [EMGlobalVariables setGlobalMainController:self];
    }
    
}
#pragma mark 接收消息
- (void)messagesDidReceive:(NSArray *)aMessages {
    for (EMMessage *msg in aMessages) {
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        // App在后台
        if (state == UIApplicationStateBackground) {
            //发送本地推送
            if (NSClassFromString(@"UNUserNotificationCenter")) { // ios 10
                if (@available(iOS 10.0, *)) {
                    // 设置触发时间
                    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.01 repeats:NO];
                    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                    content.sound = [UNNotificationSound defaultSound];
                    
                    EMMessageBody *body = msg.body;
                    content.body = [self bodyMsg:body];
                    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:msg.messageId content:content trigger:trigger];
                    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
                }
            }else {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.fireDate = [NSDate date]; //触发通知的时间
                notification.alertBody = [self bodyMsg:msg.body];
                notification.alertAction = @"Open";
                notification.timeZone = [NSTimeZone defaultTimeZone];
                notification.soundName = UILocalNotificationDefaultSoundName;
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            }
        }else {
            /*
            // 设置触发时间
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.fireDate = [NSDate date]; //触发通知的时间
            notification.alertBody = [self bodyMsg:msg.body];
            notification.alertAction = @"Open";
            notification.timeZone = [NSTimeZone defaultTimeZone];
            notification.soundName = UILocalNotificationDefaultSoundName;
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
             */
            [self playSound];
        }
    }
}

- (NSString *)bodyMsg:(EMMessageBody *)body {
    NSString *bodyStr = @"您有一条新消息";
    if(body.type == EMMessageBodyTypeText){
        EMTextMessageBody *textMsg =  (EMTextMessageBody *)body;
        bodyStr = [NSString stringWithFormat:@"%@", textMsg.text];
    }else if (body.type == EMMessageBodyTypeImage) {
        bodyStr = @"[图片]";
    }else if (body.type == EMMessageBodyTypeVideo) {
        bodyStr = @"[视频]";
    }else if (body.type == EMMessageBodyTypeLocation) {
        bodyStr = @"[位置信息]";
    }else if (body.type == EMMessageBodyTypeVoice) {
        bodyStr = @"[语音]";
    }else if (body.type == EMMessageBodyTypeFile) {
        bodyStr = @"[文件]";
    }
    
    return bodyStr;
}
static SystemSoundID shake_sound_male_id = 0;
-(void) playSound {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"in" ofType:@"caf"];
    if (path) {
        //注册声音到系统
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&shake_sound_male_id);
        AudioServicesPlaySystemSound(shake_sound_male_id);
        //        AudioServicesPlaySystemSound(shake_sound_male_id);//如果无法再下面播放，可以尝试在此播放
    }
    AudioServicesPlaySystemSound(shake_sound_male_id);   //播放注册的声音，（此句代码，可以在本类中的任意位置调用，不限于本方法中）
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);   //让手机震动
}

/*!
 *  当前登录账号在其它设备登录时会接收到该回调
 */
- (void)userAccountDidLoginFromOtherDevice {
    [Utils logoutRemoveDefInfo];
}

/*!
 *  当前登录账号已经被从服务器端删除时会收到该回调
 */
- (void)userAccountDidRemoveFromServer {
    [Utils logoutRemoveDefInfo];
}

@end

