//
//  OutDoorBgMusicViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/13.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "OutDoorBgMusicViewController.h"
#import "YQHeaderView.h"
#import "BgMusicMapModel.h"
#import "YQPointAnnotation.h"
#import "WifiAnnotationView.h"
#import "ChooseMusicViewController.h"
#import "YQSlider.h"
#import "ShowMenuView.h"
#import "BgMusicListTabViewCell.h"

#import "CRSearchBar.h"
#import <UITableView+PlaceHolderView.h>
#import "NoDataView.h"

@interface OutDoorBgMusicViewController ()<MAMapViewDelegate, MenuControlDelegate,UITableViewDelegate,UITableViewDataSource, CellPlayMusicDelegate, ChangeMusicSuccessDelegate,UISearchBarDelegate>
{

    // 弹窗
    ShowMenuView *_showMenuView;
    NSString *_menuTitle;   // 菜单标题
    NSString *_stateStr;    // 设备状态
    UIColor *_stateColor;   // 设备状态颜色
    //    NSString *_currentMusic; // 当前音乐
    CGFloat _volume; // 音量

    BOOL _hasCurrLoc;
    BOOL isOpen;
    
    SoundModel *_selectSoundModel;
    BgMusicMapModel *_selMusicmodel;
    
    //    当前选择的标注index
    NSInteger _selectIndex;
    
    CRSearchBar *searchBar;
    UITableView *tabView;
    NSMutableArray *_failtArr;
    NSMutableArray *_nameArr;
    NSMutableArray *_dataArr;
    
    BOOL _isShowMenu;
    
    CLLocationCoordinate2D _coordinate;
}

@property (nonatomic,strong) MAMapView *mapView;
@property (nonatomic,strong) YQHeaderView *headerView;
@property (nonatomic,strong) NSMutableArray *coordinatesArr;
@property (nonatomic,strong) NSIndexPath *selectedIndex;

@end

@implementation OutDoorBgMusicViewController

-(MAMapView *)mapView
{
    if (_mapView == nil) {
        _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 85, KScreenWidth, KScreenHeight-85)];
        [self.view addSubview:_mapView];
        _mapView.userTrackingMode = MAUserTrackingModeFollow;
        _mapView.hidden = NO;
    }
    return _mapView;
}

- (void)viewWillAppear:(BOOL)animated {
    self.mapView.delegate = self;
    //进入地图就显示定位小蓝点
    self.mapView.showsUserLocation = YES;
}

-(NSMutableArray *)coordinatesArr
{
    if (_coordinatesArr == nil) {
        _coordinatesArr = [NSMutableArray array];
    }
    return _coordinatesArr;
}

-(YQHeaderView *)headerView
{
    if (_headerView == nil) {
        _headerView = [[YQHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 85)];
        _headerView.backgroundColor = [UIColor colorWithHexString:@"1B82D1"];
    }
    return _headerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isOpen = YES;
    _volume = 0.5;
    
    _failtArr = @[].mutableCopy;
    _nameArr = @[].mutableCopy;

    [self initNavItems];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self _initMapView];
    
    [self _initView];
    
    [self _initTableView];
    
    [self _loadData];
}

-(void)_initView
{
    [self.view addSubview:self.headerView];
    
    // 创建点击菜单视图
    _showMenuView = [[ShowMenuView alloc] init];
    _showMenuView.hidden = YES;
    _showMenuView.menuDelegate = self;
    [[UIApplication sharedApplication].delegate.window addSubview:_showMenuView];
    
    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    locationButton.frame = CGRectMake(KScreenWidth - 50, KScreenHeight - 64 - 50, 40, 40);
    locationButton.backgroundColor = [UIColor clearColor];
    [locationButton setBackgroundImage:[UIImage imageNamed:@"current_location"] forState:UIControlStateNormal];
    [locationButton addTarget:self action:@selector(currentLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:locationButton];
}

- (void)currentLocation {
    [_mapView setCenterCoordinate:_coordinate animated:YES];
}

-(void)_initMapView
{
    [self.view addSubview:self.mapView];
}

-(void)_initTableView
{
    tabView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tabView.frame = CGRectMake(0, CGRectGetMaxY(_headerView.frame), KScreenWidth, KScreenHeight-CGRectGetMaxY(_headerView.frame)-64);
    tabView.delegate = self;
    tabView.dataSource = self;
    tabView.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    [tabView registerNib:[UINib nibWithNibName:@"BgMusicListTabViewCell" bundle:nil] forCellReuseIdentifier:@"BgMusicListTabViewCell"];
    tabView.hidden = YES;
    tabView.enablePlaceHolderView = YES;
    tabView.yh_PlaceHolderView = [self makePlaceHolderView];
    [self.view addSubview:tabView];
}

-(void)_loadData
{
    //获取室外音乐点位信息
    [self _loadWifiLocationData];
}

-(void)_loadWifiLocationData
{
    [self showHudInView:self.view hint:@""];
    NSString *urlStr = [NSString stringWithFormat:@"%@/music/getOutMusicList",Main_Url];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *responseDataDic = responseObject[@"responseData"];
            if(responseDataDic == nil || [responseDataDic isKindOfClass:[NSNull class]]){
                return ;
            }
            _headerView.leftNumLab.text = [NSString stringWithFormat:@"%@",responseDataDic[@"okMusicCount"]];
            _headerView.centerNumLab.text = [NSString stringWithFormat:@"%@",responseDataDic[@"outMusicCount"]];
            _headerView.rightNumLab.text = [NSString stringWithFormat:@"%@",responseDataDic[@"errorMusicCount"]];
            
            NSArray *arr = responseDataDic[@"musicList"];
            if(arr == nil || [arr isKindOfClass:[NSNull class]]){
                return ;
            }
            
            for (int i = 0; i < arr.count; i++) {
                BgMusicMapModel *model = [[BgMusicMapModel alloc] initWithDataDic:arr[i]];
                model.isOpen = NO;
                YQPointAnnotation *a1 = [[YQPointAnnotation alloc] init];
                a1.status = model.MUSIC_STATUS;
                a1.number = [NSString stringWithFormat:@"%d",i];
                a1.coordinate = CLLocationCoordinate2DMake([model.LATITUDE doubleValue],[model.LONGITUDE doubleValue]);
                a1.bgMusicMapModel = model;
                [self.coordinatesArr addObject:a1];
            }
        }
        [_mapView addAnnotations:_coordinatesArr];
        
        _dataArr = [NSMutableArray arrayWithArray:self.coordinatesArr];
        
        [tabView reloadData];
    } failure:^(NSError *error) {
        [self hideHud];
    }];
}

#pragma mark delegate
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    /*这里根据不同类型的大头针，生成不同的大头针视图
     为了方便起见我们继承MAPointAnnotation创建了自己的DDAnnotation，用来扩展更多属性，给大头针视图提供更多数据等
     */
    if ([annotation isKindOfClass:[YQPointAnnotation class]])
    {
        static NSString *reusedID = @"DDPointAnnotation_reusedID";
        WifiAnnotationView *annotationView = (WifiAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reusedID];
        
        if (!annotationView) {
            annotationView = [[WifiAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reusedID];
            annotationView.canShowCallout = NO;//设置此属性为NO，防止点击的时候高德自带的气泡弹出
        }
        
        //给气泡赋值
        YQPointAnnotation *ddAnnotation = (YQPointAnnotation *)annotation;
        if ([ddAnnotation.bgMusicMapModel.MUSIC_STATUS isEqualToString:@"5"]) {
            //设置大头针图片
            if([ddAnnotation.bgMusicMapModel.DEVICE_TYPE isEqualToString:@"3"]){
                // 音柱
                annotationView.image = [UIImage imageNamed:@"map_music_icon_error_3"];
            }else if ([ddAnnotation.bgMusicMapModel.DEVICE_TYPE isEqualToString:@"3-3"]) {
                // 蘑菇头
                annotationView.image = [UIImage imageNamed:@"map_music_icon_error_3-3"];
            }else if ([ddAnnotation.bgMusicMapModel.DEVICE_TYPE isEqualToString:@"3-5"]) {
                // 蘑菇头
                annotationView.image = [UIImage imageNamed:@"map_music_icon_error_3-5"];
            }
        }else{
            if([ddAnnotation.bgMusicMapModel.DEVICE_TYPE isEqualToString:@"3"]){
                // 音柱
                annotationView.image = [UIImage imageNamed:@"map_music_icon_normal_3"];
            }else if ([ddAnnotation.bgMusicMapModel.DEVICE_TYPE isEqualToString:@"3-3"]) {
                // 蘑菇头
                annotationView.image = [UIImage imageNamed:@"map_music_icon_normal_3-3"];
            }else if ([ddAnnotation.bgMusicMapModel.DEVICE_TYPE isEqualToString:@"3-5"]) {
                // 蘑菇头
                annotationView.image = [UIImage imageNamed:@"map_music_icon_normal_3-5"];
            }
        }
        
        annotationView.centerOffset = CGPointMake(0, -0.5*ddAnnotation.image.size.height);
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    YQPointAnnotation *anntion = (YQPointAnnotation *)view.annotation;
    
    if ([anntion.bgMusicMapModel.MUSIC_STATUS isEqualToString:@"5"]) {
        if([anntion.bgMusicMapModel.DEVICE_TYPE isEqualToString:@"3"]){
            // 音柱
            view.image = [UIImage imageNamed:@"map_music_icon_error_3"];
        }else if ([anntion.bgMusicMapModel.DEVICE_TYPE isEqualToString:@"3-3"]) {
            // 蘑菇头
            view.image = [UIImage imageNamed:@"map_music_icon_error_3-3"];
        }else if ([anntion.bgMusicMapModel.DEVICE_TYPE isEqualToString:@"3-5"]) {
            // 蘑菇头
            view.image = [UIImage imageNamed:@"map_music_icon_error_3-5"];
        }
    }else {
        if([anntion.bgMusicMapModel.DEVICE_TYPE isEqualToString:@"3"]){
            // 音柱
            view.image = [UIImage imageNamed:@"map_music_icon_normal_3"];
        }else if ([anntion.bgMusicMapModel.DEVICE_TYPE isEqualToString:@"3-3"]) {
            // 蘑菇头
            view.image = [UIImage imageNamed:@"map_music_icon_normal_3-3"];
        }else if ([anntion.bgMusicMapModel.DEVICE_TYPE isEqualToString:@"3-5"]) {
            // 蘑菇头
            view.image = [UIImage imageNamed:@"map_music_icon_normal_3-5"];
        }
    }

    [PointViewSelect pointImageSelect:view];
    
    if ([anntion isKindOfClass:[YQPointAnnotation class]]) {
        BgMusicMapModel *model = anntion.bgMusicMapModel;
        _selMusicmodel = model;
        _showMenuView.hidden = NO;
        if([model.MUSIC_STATUS isEqualToString:@"1"]){
            // 正常
            _stateStr = @"正常开启中";
            _stateColor = [UIColor colorWithHexString:@"#189517"];
        }else if([model.MUSIC_STATUS isEqualToString:@"0"]){
            // 停止
            _stateStr = @"停止";
            _stateColor = [UIColor grayColor];
        }else if([model.MUSIC_STATUS isEqualToString:@"2"]){
            // 暂停
            _stateStr = @"暂停";
            _stateColor = [UIColor blackColor];
        }else if([model.MUSIC_STATUS isEqualToString:@"5"]){
            // 故障
            _stateStr = @"故障";
            _stateColor = [UIColor grayColor];
        }else {
            _stateStr = @"离线";
            _stateColor = [UIColor grayColor];
        }
        
        _menuTitle = model.DEVICE_NAME;
        _selMusicmodel.currentMusic = @"";
        
        [_showMenuView reloadMenuData]; //  刷新菜单
        
        _showMenuView.hidden = NO;
        
        _selectIndex = [anntion.number integerValue];
        
        //    DLog(@"%@",anntion.number);
        [self _loadTargetID:model.TAGID];
    }

}

#pragma mark 选择音乐歌曲播放完成协议
- (void)changeMusicSuc:(NSString *)seccionId {
    [self _loadTargetID:_selMusicmodel.TAGID];
}

#pragma mark 指定IP音箱设备当前播放音频名称
-(void)_loadTargetID:(NSString *)targetID
{
    [self showHudInView:_showMenuView hint:@""];
    NSString *urlStr = [NSString stringWithFormat:@"%@/music/getipcasttermsessionstatus/%@",Main_Url,targetID];
    
    // GCD创建组
    dispatch_group_t group = dispatch_group_create();
    
    // 查询当前播放音乐
    dispatch_group_enter(group);
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        dispatch_group_leave(group);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideHud];
        });
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSArray *arr = responseObject[@"responseData"];
            if(arr == nil || [arr isKindOfClass:[NSNull class]]){
                return ;
            }
            if(arr != nil && arr.count > 0){
                SoundModel *model = [[SoundModel alloc] initWithDataDic:arr.firstObject];
                _selectSoundModel = model;
                _selMusicmodel.currentMusic = model.name;
                
                _selMusicmodel.MUSIC_STATUS = [NSString stringWithFormat:@"%@", model.status];
                if([_selMusicmodel.MUSIC_STATUS isEqualToString:@"1"]){
                    // 正常
                    _stateStr = @"正常开启中";
                    _stateColor = [UIColor colorWithHexString:@"#189517"];
                }else if([_selMusicmodel.MUSIC_STATUS isEqualToString:@"0"]){
                    // 停止
                    _stateStr = @"停止";
                    _stateColor = [UIColor grayColor];
                }else if([_selMusicmodel.MUSIC_STATUS isEqualToString:@"2"]){
                    // 暂停
                    _stateStr = @"暂停";
                    _stateColor = [UIColor blackColor];
                }else if([_selMusicmodel.MUSIC_STATUS isEqualToString:@"5"]){
                    // 故障
                    _stateStr = @"故障";
                    _stateColor = [UIColor grayColor];
                }else {
                    _stateStr = @"离线";
                    _stateColor = [UIColor grayColor];
                }
                 
                /*
                if(model.status.integerValue == 1){
                    // 正常
                    _stateStr = @"正常开启中";
                    _stateColor = [UIColor colorWithHexString:@"#189517"];
                }else if(model.status.integerValue == 0){
                    // 停止
                    _stateStr = @"停止";
                    _stateColor = [UIColor grayColor];
                }else if(model.status.integerValue == 2){
                    // 暂停
                    _stateStr = @"暂停";
                    _stateColor = [UIColor blackColor];
                }else if(model.status.integerValue == 5){
                    // 故障
                    _stateStr = @"故障";
                    _stateColor = [UIColor grayColor];
                }else {
                    _stateStr = @"离线";
                    _stateColor = [UIColor grayColor];
                }
                 */
                
                [_showMenuView reloadMenuData];
                
                if(self.selectedIndex){
                    [tabView reloadRowsAtIndexPaths:@[self.selectedIndex] withRowAnimation:UITableViewRowAnimationFade];
                }
            }else {
                _selectSoundModel = nil;
                _selMusicmodel.currentMusic = @"";
                _selMusicmodel.MUSIC_STATUS = @"4";
                _stateStr = @"离线";
                _stateColor = [UIColor grayColor];
                [_showMenuView reloadMenuData];
                
                if(self.selectedIndex){
                    [tabView reloadRowsAtIndexPaths:@[self.selectedIndex] withRowAnimation:UITableViewRowAnimationFade];
                }
            }
        }
    } failure:^(NSError *error) {
        dispatch_group_leave(group);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideHud];
        });
    }];
    
    /*
    // 查询当前音量
    NSString *volumStr = [NSString stringWithFormat:@"%@/music/getipcastsometermstatus/%@",Main_Url,targetID];
    [[NetworkClient sharedInstance] GET:volumStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSArray *arr = responseObject[@"responseData"];
            if(arr == nil || [arr isKindOfClass:[NSNull class]]){
                return ;
            }
            if(arr != nil && arr.count > 0){
                NSDictionary *volumDic = arr.firstObject;
                _volume = [volumDic[@"vol"] floatValue]/56;
                
                if(self.selectedIndex){
                    [tabView reloadRowsAtIndexPaths:@[self.selectedIndex] withRowAnimation:UITableViewRowAnimationFade];
                }
            }else {
                _volume = 0;
            }
            [_showMenuView reloadMenuData];
        }
    } failure:^(NSError *error) {
    }];
     */
    
    // 查询音箱设备音量
    dispatch_group_enter(group);
    NSString *volumStr = [NSString stringWithFormat:@"%@/music/getTermVolume?tId=%@",Main_Url,targetID];
    [[NetworkClient sharedInstance] GET:volumStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        dispatch_group_leave(group);
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *responseData = responseObject[@"responseData"];
            if(responseData == nil || [responseData isKindOfClass:[NSNull class]]){
                return ;
            }
            NSNumber *vol = responseData[@"vol"];
            if(vol != nil && ![vol isKindOfClass:[NSNull class]]){
                _volume = [vol floatValue]/56;
                if(self.selectedIndex){
                    [tabView reloadRowsAtIndexPaths:@[self.selectedIndex] withRowAnimation:UITableViewRowAnimationFade];
                }
            }else {
                _volume = 0;
            }
            //                [_showMenuView reloadMenuData];
        }
    } failure:^(NSError *error) {
        dispatch_group_leave(group);
    }];
    
    //监视函数
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [_showMenuView reloadMenuData];
    });
}

-(void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view
{
    YQPointAnnotation *anntion = (YQPointAnnotation *)view.annotation;
    if ([anntion isKindOfClass:[YQPointAnnotation class]])
    {
#warning 查询一致
        if ([anntion.bgMusicMapModel.MUSIC_STATUS isEqualToString:@"5"]) {
//        if ([anntion.status isEqualToString:@"5"]) {
            if([anntion.bgMusicMapModel.DEVICE_TYPE isEqualToString:@"3"]){
                // 音柱
                view.image = [UIImage imageNamed:@"map_music_icon_error_3"];
            }else if ([anntion.bgMusicMapModel.DEVICE_TYPE isEqualToString:@"3-3"]) {
                // 蘑菇头
                view.image = [UIImage imageNamed:@"map_music_icon_error_3-3"];
            }else if ([anntion.bgMusicMapModel.DEVICE_TYPE isEqualToString:@"3-5"]) {
                // 蘑菇头
                view.image = [UIImage imageNamed:@"map_music_icon_error_3-5"];
            }
        }else{
            if([anntion.bgMusicMapModel.DEVICE_TYPE isEqualToString:@"3"]){
                // 音柱
                view.image = [UIImage imageNamed:@"map_music_icon_normal_3"];
            }else if ([anntion.bgMusicMapModel.DEVICE_TYPE isEqualToString:@"3-3"]) {
                // 蘑菇头
                view.image = [UIImage imageNamed:@"map_music_icon_normal_3-3"];
            }else if ([anntion.bgMusicMapModel.DEVICE_TYPE isEqualToString:@"3-5"]) {
                // 蘑菇头
                view.image = [UIImage imageNamed:@"map_music_icon_normal_3-5"];
            }
        }
        // 复原之前选中图片效果
        if(view != nil){
            [PointViewSelect recoverSelImgView:view];
        }
    }
}

-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (!_hasCurrLoc)
    {
        _hasCurrLoc = YES;
        _coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
        
        // 必须在定位完成后改变
        NSString *locationStr = [[NSUserDefaults standardUserDefaults] objectForKey:KMapLocationCoord];
        if(locationStr != nil && ![locationStr isKindOfClass:[NSNull class]]){
            NSArray *coordAry = [locationStr componentsSeparatedByString:@","];
            if(coordAry != nil && coordAry.count >= 2){
                NSString *longt = coordAry.firstObject;
                NSString *lat = coordAry.lastObject;
                [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(lat.floatValue, longt.floatValue) animated:YES];
            }
        }
        [_mapView setZoomLevel:18 animated:YES];
    }
}

#pragma mark tableview delegate and datasource

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 49;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 49)];
    headerView.backgroundColor = [UIColor whiteColor];
    searchBar = [[CRSearchBar alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 44) leftImage:[UIImage imageNamed:@"icon_search"] placeholderColor:[UIColor colorWithHexString:@"#E2E2E2"]];
    searchBar.placeholder = @"请输入搜索内容";
    [headerView addSubview:searchBar];
    searchBar.delegate = self;
    searchBar.backgroundColor = [UIColor clearColor];
    searchBar.backgroundImage = [UIImage imageWithColor:[UIColor clearColor]];
    searchBar.searchTextPositionAdjustment = UIOffsetMake(0, 2);
    return headerView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.coordinatesArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BgMusicListTabViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BgMusicListTabViewCell" forIndexPath:indexPath];
    cell.cellPlayMusicDelegate = self;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    YQPointAnnotation *annition = self.coordinatesArr[indexPath.row];
    BgMusicMapModel *model = (BgMusicMapModel *)annition.bgMusicMapModel;
    if (!model.isOpen) {
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.selectView.hidden = YES;
        cell.currentMusicLab.hidden = YES;
        cell.currentMusicDetailLab.hidden = YES;
        cell.changeMusicBtn.hidden = YES;
        cell.volumeAdjustLab.hidden = YES;
        cell.volumeAdjustSlider.hidden = YES;
        cell.musicMenuView.hidden = YES;
    }else{
        cell.contentView.backgroundColor = [UIColor colorWithHexString:@"F8FCFF"];
        cell.selectView.hidden = NO;
        cell.currentMusicLab.hidden = NO;
        cell.currentMusicDetailLab.hidden = NO;
        cell.changeMusicBtn.hidden = NO;
        cell.volumeAdjustLab.hidden = NO;
        cell.volumeAdjustSlider.hidden = NO;
        cell.musicMenuView.hidden = NO;
    }
    
    cell.model = (BgMusicMapModel *)annition.bgMusicMapModel;
    cell.volum = _volume;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    YQPointAnnotation *annition = self.coordinatesArr[indexPath.row];
    BgMusicMapModel *model = (BgMusicMapModel *)annition.bgMusicMapModel;
    if (model.isOpen) {
        return 225;
    }else{
        return 60;
    }
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [searchBar resignFirstResponder];
    
    NSMutableArray *indexPaths = @[].mutableCopy;
    if(indexPath.row < self.coordinatesArr.count){
        [indexPaths addObject:indexPath];
    }
    YQPointAnnotation *annition = self.coordinatesArr[indexPath.row];
    BgMusicMapModel *model = (BgMusicMapModel *)annition.bgMusicMapModel;
    _selMusicmodel = model;
    //判断选中不同row状态时候
    //    if (self.selectedIndex != nil && indexPath.row != selectedIndex.row) {
    if (self.selectedIndex != nil && indexPath.row == _selectedIndex.row) {
        //将选中的和所有索引都加进数组中
        //        indexPaths = [NSArray arrayWithObjects:indexPath,selectedIndex, nil];
        if (model.isOpen) {
            model.isOpen = NO;
        }else{
            model.isOpen = YES;
        }
    }else if (self.selectedIndex != nil && indexPath.row != _selectedIndex.row) {
        if(_selectedIndex.row < self.coordinatesArr.count){
            [indexPaths addObject:_selectedIndex];
            YQPointAnnotation *annition1 = self.coordinatesArr[_selectedIndex.row];
            BgMusicMapModel *model1 = (BgMusicMapModel *)annition1.bgMusicMapModel;
            model1.isOpen = NO;
        }
        if (model.isOpen) {
            model.isOpen = NO;
        }else{
            model.isOpen = YES;
        }
    }else{
        if (model.isOpen) {
            model.isOpen = NO;
        }else{
            model.isOpen = YES;
        }
    }
    
    //记下选中的索引
    self.selectedIndex = indexPath;
    
    [self _loadTargetID:model.TAGID];
    
    //刷新
    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    
    self.mapView.showsUserLocation = NO;
    self.mapView.delegate = nil;
    
    [super viewWillDisappear:animated];
}

#pragma mark 菜单协议
#pragma mark menuDelegate and datasource
#pragma mark 菜单协议
- (CGFloat)menuHeightInView:(NSInteger)index {
    if(index == 0){
        return 60;
    }else if(index == 1){
        return 40;
    }else{
        return 50;
    }
}

- (NSInteger)menuNumInView {
    return 3;
}

- (NSString *)menuTitle:(NSInteger)index {
    switch (index) {
        case 0:
            return @"设备状态";
            break;
        case 1:
            return @"当前音乐";
            break;
        case 2:
            return @"音量调节";
            break;
            
        default:
            return @"";
            break;
    }
}

- (UIColor *)menuTitleColor:(NSInteger)index {
    return [UIColor blackColor];
}
- (NSString *)menuTitleViewText {
    return _menuTitle;
}

- (ShowMenuStyle)menuViewStyle:(NSInteger)index {
    switch (index) {
        case 0:
            return DefaultConMenu;
            break;
        case 1:
            return TextAndImgConMenu;
            break;
        case 2:
            return SliderConMenu;
            break;
            
        default:
            return DefaultConMenu;
            break;
    }
}

- (NSString *)menuMessage:(NSInteger)index {
    if(index == 0){
        return _stateStr;
    }else if(index == 1){
        return _selMusicmodel.currentMusic;
    }else {
        return @"";
    }
}

- (UIColor *)menuMessageColor:(NSInteger)index {
    if(index == 0){
        return _stateColor;
    }else {
        return [UIColor blackColor];
    }
}

// 为SliderConMenu时实现，默认开关状态
- (CGFloat)sliderDefValue:(NSInteger)index {
    return _volume;
}

- (NSArray *)sliderImgs:(NSInteger)index {
    return @[@"_volume_redecing", @"_volume_addition"];
}

-(void)closeMenu {
    if(self.coordinatesArr.count > _selectIndex){
        YQPointAnnotation *anntion = self.coordinatesArr[_selectIndex];
        [self.mapView deselectAnnotation:anntion animated:YES];
    }
}

#pragma mark 滑动slider时调用
- (void)sliderChangeValue:(CGFloat)value {
    // 设置音箱设备音量
    NSString *urlStr = [NSString stringWithFormat:@"%@/music/setTermVolume?tId=%@&vol=%.0f", Main_Url, _selMusicmodel.TAGID,value*56];
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *responseData = responseObject[@"responseData"];
            if(responseData != nil && ![responseData isKindOfClass:[NSNull class]]){
                NSString *result = responseData[@"result"];
                if(result != nil && ![result isKindOfClass:[NSNull class]] && [result isEqualToString:@"success"]){
                    // 记录日志
                    [self logRecordTagId:_selMusicmodel.TAGID withOldVolume:_volume*56 withNewVolume:value*56];
                    // 设置成功
                    _volume = value;
                }
            }
        }
        [_showMenuView reloadMenuData];
    } failure:^(NSError *error) {
        
    }];
}
#pragma mark 单个音箱设置音量
- (void)logRecordTagId:(NSString *)tagId withOldVolume:(CGFloat)OldVolume withNewVolume:(CGFloat)newVolume {
    NSString *volumeStr = [NSString stringWithFormat:@"设置\"%@\"音量", _selMusicmodel.DEVICE_NAME];
    
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:volumeStr forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:[NSString stringWithFormat:@"%@%.0f至%.0f", volumeStr, OldVolume, newVolume] forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"music/setTermVolume" forKey:@"operateUrl"];//操作url
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
    [logDic setObject:[NSString stringWithFormat:@"%.0f", newVolume] forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:tagId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"背景音乐" forKey:@"operateDeviceName"];//操作设备名  模块
    [logDic setObject:[NSString stringWithFormat:@"%.0f", OldVolume] forKey:@"expand1"];// 操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

- (CGFloat)sliderMaxValue:(NSInteger)index {
    if(index == 2){
        return 56;
    }
    return 1;
}

- (NSString *)silderUnit:(NSInteger)index {
    return @"";
}

// 右侧有图片时实现
- (NSString *)imageName:(NSInteger)index {
    if(index == 1){
        return @"music_refresh_icon";
    }
    
    return @"";
}

- (void)didSelectMenu:(NSInteger)index {
    if(index == 1){
        [self chooseMusicList];
    }
}

// 是背景音乐播放时实现
- (BOOL)isPlayMusicMenu {
    return YES;
}
#pragma mark 菜单协议/tableview cell菜单协议
- (void)sliderVolumValue:(CGFloat)volum {
    _volume = volum;
    
    [self sliderChangeValue:volum];
}
- (void)chooseMusicList {
    if(tabView.hidden){
        _isShowMenu = YES;
    }
    // 更换背景音乐
    ChooseMusicViewController *chooseMusicVC = [[ChooseMusicViewController alloc] init];
    chooseMusicVC.changeMusicDelegate = self;
    chooseMusicVC.soundModel = _selectSoundModel;
    chooseMusicVC.outMusicMapModel = _selMusicmodel;
    chooseMusicVC.volume = [NSString stringWithFormat:@"%f", _volume*56];
    [self.navigationController pushViewController:chooseMusicVC animated:YES];
}
- (void)playMusic {
    if(_selectSoundModel == nil){
        _showMenuView.hidden = YES;
        // 当前无播放，跳转选取歌曲播放
        [self chooseMusicList];
    }else {
        // 恢复播放
        NSString *urlStr = [NSString stringWithFormat:@"%@/music/playipcastfilectrl/%@/6/0", Main_Url, _selectSoundModel.sid];
        [self reloadSendRequest:urlStr withOperate:[NSString stringWithFormat:@"背景音乐\"%@\"恢复播放", _selMusicmodel.DEVICE_NAME] withTagId:_selMusicmodel.TAGID];
    }
}
- (void)pauseMusic {
    if(_selectSoundModel != nil){
        // 暂停播放
        NSString *urlStr = [NSString stringWithFormat:@"%@/music/playipcastfilectrl/%@/5/0", Main_Url, _selectSoundModel.sid];
        [self reloadSendRequest:urlStr withOperate:[NSString stringWithFormat:@"背景音乐\"%@\"暂停", _selMusicmodel.DEVICE_NAME] withTagId:_selMusicmodel.TAGID];
    }else {
        [self showHint:@"当前无播放音乐"];
    }
}
- (void)stopMusic {
    if(_selectSoundModel != nil){
        // 停止播放
        NSString *urlStr = [NSString stringWithFormat:@"%@/music/playipcastfilectrl/%@/1/0", Main_Url, _selectSoundModel.sid];
        [self reloadSendRequest:urlStr withOperate:[NSString stringWithFormat:@"背景音乐\"%@\"停止", _selMusicmodel.DEVICE_NAME] withTagId:_selMusicmodel.TAGID];
    }else {
        [self showHint:@"当前无播放音乐"];
    }
}
- (void)upMusic {
    if(_selectSoundModel != nil){
        // 上一曲
        NSString *urlStr = [NSString stringWithFormat:@"%@/music/playipcastfilectrl/%@/4/0", Main_Url, _selectSoundModel.sid];
        [self reloadSendRequest:urlStr withOperate:[NSString stringWithFormat:@"背景音乐\"%@\"上一曲", _selMusicmodel.DEVICE_NAME] withTagId:_selMusicmodel.TAGID];
    }else {
        [self showHint:@"当前无播放音乐"];
    }
}
- (void)downMusic {
    if(_selectSoundModel != nil){
        // 下一曲
        NSString *urlStr = [NSString stringWithFormat:@"%@/music/playipcastfilectrl/%@/3/0", Main_Url, _selectSoundModel.sid];
        [self reloadSendRequest:urlStr withOperate:[NSString stringWithFormat:@"背景音乐\"%@\"下一曲", _selMusicmodel.DEVICE_NAME] withTagId:_selMusicmodel.TAGID];
    }else {
        [self showHint:@"当前无播放音乐"];
    }
}

- (void)reloadSendRequest:(NSString *)urlStr withOperate:(NSString *)operate withTagId:(NSString *)tagId {
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        NSDictionary *resDic = responseObject[@"responseData"];
        if(resDic == nil || [resDic isKindOfClass:[NSNull class]]){
            return ;
        }
        if ([resDic[@"result"] isEqualToString:@"success"]) {
            NSLog(@"++++++++音乐操作成功 刷新");
            [self _loadTargetID:_selMusicmodel.TAGID];
            // 记录日志
            [self logRecordOperate:operate withGroupId:tagId];
        }
    } failure:^(NSError *error) {
    }];
}

#pragma mark uisearchBar delegate

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [_nameArr removeAllObjects];
    
    [_dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YQPointAnnotation *pointAnnition = (YQPointAnnotation *)obj;
        BgMusicMapModel *model = pointAnnition.bgMusicMapModel;
        [_nameArr addObject:model.DEVICE_NAME];
    }];
    
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    [_failtArr removeAllObjects];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@",searchBar.text];
    
    [_nameArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = (NSString *)obj;
        BOOL isContain = [pred evaluateWithObject:name];
        if (isContain) {
            [_failtArr addObject:_dataArr[idx]];
        }
    }];
    
    [self.coordinatesArr removeAllObjects];
    if (searchBar.text.length == 0) {
        [self.coordinatesArr addObjectsFromArray:_dataArr];
    }else{
        [self.coordinatesArr addObjectsFromArray:_failtArr];
    }
    
    [tabView reloadData];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [_failtArr removeAllObjects];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@",searchBar.text];
    
    [_nameArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = (NSString *)obj;
        BOOL isContain = [pred evaluateWithObject:name];
        if (isContain) {
            [_failtArr addObject:_dataArr[idx]];
        }
    }];
    
    [self.coordinatesArr removeAllObjects];
    if (searchText.length == 0) {
        [self.coordinatesArr addObjectsFromArray:_dataArr];
    }else{
        [self.coordinatesArr addObjectsFromArray:_failtArr];
    }
    
    [tabView reloadData];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDateView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 49, KScreenWidth, tabView.height-49)];
    noDateView.label.text = @"无结果";
    return noDateView;
}

-(void)initNavItems
{
    self.title = @"室外音乐";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *rightBtn = [[UIButton alloc] init];
    rightBtn.frame = CGRectMake(0, 0, 40, 40);
    [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [rightBtn setImage:[UIImage imageNamed:@"switchmap"] forState:UIControlStateNormal];    // switchmap
    [rightBtn addTarget:self action:@selector(_rightBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)_rightBarBtnItemClick:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    [UIView animateWithDuration:0.5 animations:^{
        if (_mapView.hidden) {
            [searchBar resignFirstResponder];
            [btn setImage:[UIImage imageNamed:@"switchmap"] forState:UIControlStateNormal];
            _mapView.hidden = NO;
            tabView.hidden = YES;
            [tabView reloadData];
        }else
        {
            [btn setImage:[UIImage imageNamed:@"slideMenu"] forState:UIControlStateNormal];
            _mapView.hidden = YES;
            tabView.hidden = NO;
            
            [self.coordinatesArr removeAllObjects];
            [self.coordinatesArr addObjectsFromArray:_dataArr];
            
            [tabView reloadData];
        }
    }];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(_isShowMenu){
        _showMenuView.alpha = 0;
        _showMenuView.hidden = NO;
        [UIView animateWithDuration:0.1 animations:^{
            _showMenuView.alpha = 1;
        }];
        _isShowMenu = NO;
    }
}
 */

- (void)logRecordOperate:(NSString *)operate withGroupId:(NSString *)groupId {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:operate forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:operate forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"music/playipcastfilectrl" forKey:@"operateUrl"];//操作url
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:groupId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"背景音乐" forKey:@"operateDeviceName"];//操作设备名  模块
    //    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

@end
