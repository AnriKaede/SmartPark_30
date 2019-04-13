//
//  StreetLightsViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/6.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "StreetLightsViewController.h"
#import "TimeSetTableViewController.h"
#import "YQSecondHeaderView.h"
#import "MsgPostViewController.h"

#import "EveMenuView.h"
#import "LightVMenuView.h"
#import "MonitorMenuView.h"
#import "WifiMenuView.h"
#import "AdcMenuView.h"
#import "MusicMenuView.h"
#import "CallMenuView.h"
#import "PowerMenuView.h"

#import "StreetLightModel.h"

#import "YQInDoorPointMapView.h"

#import "NoDataView.h"
#import "StreetLCollectionViewCell.h"

#import "StreLigAllConViewController.h"

#import "SubDeviceModel.h"

#import "PlayVideoViewController.h"
#import "PlaybackViewController.h"
//#import "DHDataCenter.h"

@interface StreetLightsViewController ()<UIScrollViewDelegate,DidSelInMapPopDelegate,reloadDelegate,UICollectionViewDelegate,UICollectionViewDataSource, StreetSelDeviceDelegate, PlayMonitorDelegate>
{
    EveMenuView *_eveMenuView;
    LightVMenuView *_lightVMenuView;
    MonitorMenuView *_monitorMenuView;
    WifiMenuView *_wifiMenuView;
    AdcMenuView *_adcMenuView;
    MusicMenuView *_musicMenuView;
    CallMenuView *_callMenuView;
    PowerMenuView *_powerMenuView;
    
    NSInteger _currentPage;
    YQInDoorPointMapView *_indoorView;
    
    NSMutableArray *_parkLightArr;
    NoDataView *nodataView;
    NSMutableArray *_grapDataArr;
    dispatch_group_t dispatchGroup;
}

@property (nonatomic,strong) YQSecondHeaderView *headerView;

// 头视图下路灯背景视图
@property (nonatomic, strong) UIScrollView *stScrollView;

// page分页控制器
@property (nonatomic, strong) UIPageControl *pageCon;

@end

@implementation StreetLightsViewController

-(YQSecondHeaderView *)headerView
{
    if (_headerView == nil) {
        _headerView = [[YQSecondHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 85)];
        _headerView.backgroundColor = [UIColor colorWithHexString:@"1B82D1"];
    }
    return _headerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentPage = 0;
    _parkLightArr = @[].mutableCopy;
    _grapDataArr = @[].mutableCopy;
    
    
    [self initNavItems];
    
    [self _initView];
    
    [self _initCollectionView];
    
    [self _loadData];
}

-(void)_initCollectionView
{
    //1.初始化layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //设置collectionView滚动方向
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    //设置headerView的尺寸大小
    layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 100);
    //该方法也可以设置itemSize
    
    layout.itemSize = CGSizeMake(110, 60);
    
    //2.初始化collectionView
    //    mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView setCollectionViewLayout:layout];
    
    self.collectionView.frame = CGRectMake(0, 44, KScreenWidth, KScreenHeight-kTopHeight-44*hScale);
    
    //4.设置代理
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.bounces = NO;
    self.collectionView.mj_header.hidden = YES;
    self.collectionView.mj_footer.hidden = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.enablePlaceHolderView = YES;
    nodataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 44, KScreenWidth, KScreenHeight-kTopHeight-44*hScale)];
//    nodataView.delegate = self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.yh_PlaceHolderView = nodataView;
    self.collectionView.yh_PlaceHolderView.hidden = YES;
    nodataView.hidden = YES;
    
    //3.注册collectionViewCell
    //注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
    [self.collectionView registerClass:[StreetLCollectionViewCell class] forCellWithReuseIdentifier:@"StreetLCollectionViewCellID"];
    
    [self.view addSubview:self.collectionView];
}

-(void)initNavItems
{
    self.title = @"路灯";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"indoorWifi_graphic"] style:UIBarButtonItemStyleDone target:self action:@selector(allConAction)];
    
}

- (void)allConAction {
    StreLigAllConViewController *allConVC = [[StreLigAllConViewController alloc] init];
    [self.navigationController pushViewController:allConVC animated:YES];
}

-(void)_initView
{
//    [self.view addSubview:self.headerView];
    
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
    
    _pageCon = [[UIPageControl alloc] initWithFrame:CGRectMake(0, KScreenHeight - 20 - 64, KScreenWidth, 20)];
    _pageCon.backgroundColor = [UIColor clearColor];
    _pageCon.pageIndicatorTintColor = [UIColor grayColor];
    _pageCon.currentPageIndicatorTintColor = [UIColor colorWithHexString:@"1B82D1"];
    _pageCon.currentPage = _currentPage;
    [_pageCon addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_pageCon];
    
}

-(void)_loadData
{
    [_parkLightArr removeAllObjects];
    dispatchGroup = dispatch_group_create();
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/roadLamp/info/",Main_Url];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *dic = responseObject[@"responseData"];
            
            _headerView.openNumLab.text = [NSString stringWithFormat:@"%@",dic[@"on"]];
            _headerView.brokenNumLab.text = [NSString stringWithFormat:@"%@",dic[@"fault"]];
            
            NSArray *arr = dic[@"items"];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                StreetLightModel *model = [[StreetLightModel alloc] initWithDataDic:obj];
                
                NSInteger tag = 6000 + idx;
                NSInteger bgViewTag = 5000 + idx;
                UIView *bgView = [_stScrollView viewWithTag:bgViewTag];
                UILabel *lab = [bgView viewWithTag:tag];
                lab.text = [NSString stringWithFormat:@"%@",model.DEVICE_NAME];
                
                dispatch_group_enter(dispatchGroup);
                
                [self _loadSonEquip:model.DEVICE_ID model:model];
                
            }];
            
        }
        
        dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^(){
            _pageCon.numberOfPages = _parkLightArr.count;
            
            NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"DEVICE_ID" ascending:YES];
            NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sorter count:1];
            NSArray *sortedArray = [_parkLightArr sortedArrayUsingDescriptors:sortDescriptors];
            
            _parkLightArr = sortedArray.mutableCopy;
            [self.collectionView reloadData];
        });
        
        
    } failure:^(NSError *error) {
        
    }];
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
            
            //            DLog(@"%@",responseObject);
            NSArray *arr = responseObject[@"responseData"];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                SubDeviceModel *model1 = [[SubDeviceModel alloc] initWithDataDic:obj];
                [graphData addObject:[NSString stringWithFormat:@"%@,%@,%@",model1.LAYER_A,model1.LAYER_B,model1.LAYER_C]];
                [grapArr addObject:model1];
            }];
            
            model.grapArr = grapArr;
            model.graphData = graphData;
            
            [_parkLightArr addObject:model];
            dispatch_group_leave(dispatchGroup);
        }
        
    } failure:^(NSError *error) {
        DLog(@"%@",error);
    }];
}


//-(void)_loadSonEquip:(NSString *)deviceId
//{
//    NSString *urlStr = [NSString stringWithFormat:@"%@/common/getSubDeviceList?deviceId=%@",Main_Url,deviceId];
//    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
//        NSMutableArray *tempArr = @[].mutableCopy;
//        if ([responseObject[@"code"] isEqualToString:@"1"]) {
////            DLog(@"%@",responseObject);
//            NSArray *arr = responseObject[@"responseData"];
//            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                SubDeviceModel *model = [[SubDeviceModel alloc] initWithDataDic:obj];
//                [tempArr addObject:model];
//            }];
//
//            [_grapDataArr addObject:tempArr];
//        }
//        [self.collectionView reloadData];
//    } failure:^(NSError *error) {
//        DLog(@"%@",error);
//    }];
//}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)_rightBarBtnItemClick:(id)sender
{
    TimeSetTableViewController *timeSetVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"TimeSetTableViewController"];
    [self.navigationController pushViewController:timeSetVC animated:YES];
}

- (void)changePage:(UIPageControl *)pageCon {
    _currentPage = pageCon.currentPage;
    [_stScrollView setContentOffset:CGPointMake(_currentPage*KScreenWidth, 0) animated:YES];
}

#pragma mark ScrollView 协议
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _currentPage = scrollView.contentOffset.x/KScreenWidth;
    _pageCon.currentPage = _currentPage;
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

- (void)selInMapWithId:(NSString *)identity
{
    
}

#pragma mark collectionView代理方法
//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _parkLightArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    StreetLCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"StreetLCollectionViewCellID" forIndexPath:indexPath];

    cell.backgroundColor = [UIColor clearColor];
    cell.model = _parkLightArr[indexPath.row];
    cell.streetDeviceDelegate = self;
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(KScreenWidth, KScreenHeight-kTopHeight-44*hScale);
}

//footer的size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(10, 0);
}

//header的size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize size;
    
    size = CGSizeMake(10, 0);
    
    return size;
}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}


//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}


#pragma mark 播放视频menu协议
- (void)playMonitorDelegate:(SubDeviceModel *)subDeviceModel {
    if(subDeviceModel.TAGID == nil || [subDeviceModel.TAGID isKindOfClass:[NSNull class]]){
        [self showHint:@"相机无参数"];
        return;
    }
    
    [MonitorLogin selectNodeWithChanneId:subDeviceModel.TAGID withNode:^(TreeNode *node) {
    }];
    
    PlayVideoViewController *playVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"PlayVideoViewController"];
    playVC.deviceType = subDeviceModel.DEVICE_TYPE;
    [self.navigationController pushViewController:playVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
