//
//  StreetLightPointViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/12.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "StreetLightPointViewController.h"
#import "YQInDoorPointMapView.h"

#import "EveMenuView.h"
#import "LightVMenuView.h"
#import "MonitorMenuView.h"
#import "WifiMenuView.h"
#import "AdcMenuView.h"
#import "MusicMenuView.h"
#import "CallMenuView.h"
#import "PowerMenuView.h"

#import "PlayVideoViewController.h"
#import "PlaybackViewController.h"
#import "DHDataCenter.h"

@interface StreetLightPointViewController ()<DidSelInMapPopDelegate, PlayMonitorDelegate>
{
    YQInDoorPointMapView *_indoorView;
    
    EveMenuView *_eveMenuView;
    LightVMenuView *_lightVMenuView;
    MonitorMenuView *_monitorMenuView;
    WifiMenuView *_wifiMenuView;
    AdcMenuView *_adcMenuView;
    MusicMenuView *_musicMenuView;
    CallMenuView *_callMenuView;
    PowerMenuView *_powerMenuView;
    
    NSMutableArray *_parkLightArr;
}
@end

@implementation StreetLightPointViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _parkLightArr = @[].mutableCopy;
    
    [self initPointMapView];
    
    [self _loadSonEquip:_model.DEVICE_ID model:_model];
}

-(void)_loadSonEquip:(NSString *)deviceId model:(StreetLightModel *)model
{
    
    NSMutableArray *graphData = @[].mutableCopy;
    NSMutableArray *grapArr = [NSMutableArray array];
    NSString *urlStr = [NSString stringWithFormat:@"%@/common/getSubDeviceList?deviceId=%@",Main_Url,deviceId];
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            
            [graphData removeAllObjects];
            [grapArr removeAllObjects];
            
            NSArray *arr = responseObject[@"responseData"];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                SubDeviceModel *model1 = [[SubDeviceModel alloc] initWithDataDic:obj];
                [graphData addObject:[NSString stringWithFormat:@"%@,%@,%@",model1.LAYER_A,model1.LAYER_B,model1.LAYER_C]];
                [grapArr addObject:model1];
            }];
            
            model.grapArr = grapArr;
            model.graphData = graphData;
            
            _indoorView.streetLightGraphData = model.graphData;
            _indoorView.streetLightArr = model.grapArr;
            
            [_parkLightArr addObject:model];
            
        }
        
    } failure:^(NSError *error) {
        DLog(@"%@",error);
    }];
}

-(void)initPointMapView
{
    // 顶部名称
    self.title = _model.DEVICE_NAME;
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _indoorView = [[YQInDoorPointMapView alloc]initWithIndoorMapImageName:@"stLight" Frame:CGRectMake(KScreenWidth/2-(320*hScale/2) + 20, 10, 320*hScale, 550*hScale) withScale:1];
    _indoorView.selInMapDelegate = self;
    [self.view addSubview:_indoorView];

    // 创建点击菜单视图
    _eveMenuView = [[EveMenuView alloc] init];
    _lightVMenuView = [[LightVMenuView alloc] init];
    _monitorMenuView = [[MonitorMenuView alloc] init];
    _monitorMenuView.playMonitorDelegate = self;
    _wifiMenuView = [[WifiMenuView alloc] init];
    _adcMenuView = [[AdcMenuView alloc] init];
    _musicMenuView = [[MusicMenuView alloc] init];
    _callMenuView = [[CallMenuView alloc] init];
    _powerMenuView = [[PowerMenuView alloc] init];
    
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selInMapWithId:(NSString *)identity
{
    NSInteger selIndex = identity.integerValue - 100;
    if(_model.grapArr.count > selIndex){
        SubDeviceModel *deviceModel = _model.grapArr[selIndex];
        [self selDevice:deviceModel];
    }
}

#pragma mark 选择路灯子设备协议
- (void)selDevice:(SubDeviceModel *)deviceModel {
    if([deviceModel.DEVICE_TYPE isEqualToString:@"15"]){
        // 环境监测PM2.5
        _eveMenuView.subDeviceModel = deviceModel;
        [_eveMenuView showMenu];
        
    }else if([deviceModel.DEVICE_TYPE isEqualToString:@"18"]){
        // LED路灯
        _lightVMenuView.subDeviceModel = deviceModel;
        _lightVMenuView.parentDevName = _model.DEVICE_NAME;
        [_lightVMenuView showMenu];
        
    }else if([deviceModel.DEVICE_TYPE isEqualToString:@"2"]){
        // WIFI
        _wifiMenuView.subDeviceModel = deviceModel;
        [_wifiMenuView showMenu];
        
    }else if([deviceModel.DEVICE_TYPE isEqualToString:@"1-1"] ||
             [deviceModel.DEVICE_TYPE isEqualToString:@"1-2"] ||
             [deviceModel.DEVICE_TYPE isEqualToString:@"1-3"]){
        // 球机摄像相机
        _monitorMenuView.subDeviceModel = deviceModel;
        [_monitorMenuView showMenu];
        
    }else if([deviceModel.DEVICE_TYPE isEqualToString:@"14"]){
        // LED广告屏
        _adcMenuView.subDeviceModel = deviceModel;
        _adcMenuView.parentDevName = _model.DEVICE_NAME;
        [_adcMenuView showMenu];
        
    }else if([deviceModel.DEVICE_TYPE isEqualToString:@"3"]){
        // IP音箱
        _musicMenuView.subDeviceModel = deviceModel;
        [_musicMenuView showMenu];
        
    }else if([deviceModel.DEVICE_TYPE isEqualToString:@"16"]){
        // 一键呼叫
        _callMenuView.subDeviceModel = deviceModel;
        [_callMenuView showMenu];
        
    }else if([deviceModel.DEVICE_TYPE isEqualToString:@"17"]){
        // 充电桩
        _powerMenuView.subDeviceModel = deviceModel;
        [_powerMenuView showMenu];
        
    }
}

#pragma mark 播放视频menu协议
- (void)playMonitorDelegate:(SubDeviceModel *)subDeviceModel {
    if(subDeviceModel.TAGID == nil || [subDeviceModel.TAGID isKindOfClass:[NSNull class]]){
        [self showHint:@"相机无参数"];
        return;
    }
    
    [DHDataCenter sharedInstance].channelID = subDeviceModel.TAGID;
    
    PlayVideoViewController *playVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"PlayVideoViewController"];
    playVC.deviceType = subDeviceModel.DEVICE_TYPE;
    [self.navigationController pushViewController:playVC animated:YES];
}
- (void)playBackMonitorDelegate:(SubDeviceModel *)subDeviceModel {
    if(subDeviceModel.TAGID == nil || [subDeviceModel.TAGID isKindOfClass:[NSNull class]]){
        [self showHint:@"相机无参数"];
        return;
    }
    [DHDataCenter sharedInstance].channelID = subDeviceModel.TAGID;
    
    PlaybackViewController *playVC = [[PlaybackViewController alloc] init];
    [self.navigationController pushViewController:playVC animated:YES];
}

@end
