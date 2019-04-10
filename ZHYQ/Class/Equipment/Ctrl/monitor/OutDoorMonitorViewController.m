//
//  OutDoorMonitorViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/11.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "OutDoorMonitorViewController.h"
//#import "YQHeaderView.h"
#import "YQSecondHeaderView.h"

#import "MonitorMapModel.h"
#import "YQPointAnnotation.h"
#import "WifiAnnotationView.h"

#import "ShowMenuView.h"
#import "MonitorTableViewCell.h"

#import "CRSearchBar.h"
#import "NoDataView.h"
#import <UITableView+PlaceHolderView.h>

//#import "DHDataCenter.h"
#import "PlayVideoViewController.h"
#import "PlaybackViewController.h"

@interface OutDoorMonitorViewController ()<MAMapViewDelegate, MenuControlDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{

    // 弹窗
    ShowMenuView *_showMenuView;
    NSString *_menuTitle;   // 菜单标题
    NSString *_stateStr;    // 设备状态
    UIColor *_stateColor;   // 设备状态颜色

    //只有首次定位成功跳到该经纬度位置bool
    BOOL _hasCurrLoc;
    BOOL isOpen;
    UIView *bottomView;
    
    //    当前选择的标注index
    NSInteger _selectIndex;
    
    CRSearchBar *searchBar;
    UITableView *tabView;
    NSMutableArray *_failtArr;
    NSMutableArray *_nameArr;
    NSMutableArray *_dataArr;
    
    MonitorMapModel *_currentModel;
    BOOL _isShowMenu;
    
    BOOL _isOnline;
    CLLocationCoordinate2D _coordinate;
}

@property (nonatomic,strong) MAMapView *mapView;
@property (nonatomic,strong) YQSecondHeaderView *headerView;
@property (nonatomic,strong) NSMutableArray *coordinatesArr;
@property (nonatomic,strong) NSIndexPath * selectedIndex;

@end

@implementation OutDoorMonitorViewController

-(MAMapView *)mapView
{
    if (_mapView == nil) {
        _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 85, KScreenWidth, KScreenHeight-85)];
        [self.view addSubview:_mapView];
        _mapView.delegate = self;
        //进入地图就显示定位小蓝点
        _mapView.showsUserLocation = YES;
        _mapView.userTrackingMode = MAUserTrackingModeFollow;
    }
    return _mapView;
}

-(NSMutableArray *)coordinatesArr
{
    if (_coordinatesArr == nil) {
        _coordinatesArr = [NSMutableArray array];
    }
    return _coordinatesArr;
}

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
    // Do any additional setup after loading the view.
    
    isOpen = YES;
    
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
    [tabView registerNib:[UINib nibWithNibName:@"MonitorTableViewCell" bundle:nil] forCellReuseIdentifier:@"MonitorTableViewCell"];
    tabView.hidden = YES;
    tabView.enablePlaceHolderView = YES;
    tabView.yh_PlaceHolderView = [self makePlaceHolderView];
    [self.view addSubview:tabView];
}

-(void)_loadData
{
    //获取wifi点位信息
    [self _loadWifiLocationData];
}

-(void)_loadWifiLocationData
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/camera/getOutCameraList",Main_Url];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        
//        DLog(@"%@",responseObject);
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *responseDataDic = responseObject[@"responseData"];
            NSArray *arr = responseDataDic[@"cameraList"];
            
//            _headerView.leftNumLab.text = [NSString stringWithFormat:@"%@",responseDataDic[@"okCameraCount"]];
            _headerView.openNumLab.text = [NSString stringWithFormat:@"%@",responseDataDic[@"okCameraCount"]];
            _headerView.brokenNumLab.text = [NSString stringWithFormat:@"%@",responseDataDic[@"errorCameraCount"]];
//            _headerView.centerNumLab.text = [NSString stringWithFormat:@"%@",responseDataDic[@"outCameraCount"]];
//            _headerView.rightNumLab.text = [NSString stringWithFormat:@"%@",responseDataDic[@"errorCameraCount"]];
            
            for (int i = 0; i < arr.count; i++) {
                MonitorMapModel *model = [[MonitorMapModel alloc] initWithDataDic:arr[i]];
                YQPointAnnotation *a1 = [[YQPointAnnotation alloc] init];
                a1.status = model.CAMERA_STATUS;
                a1.number = [NSString stringWithFormat:@"%d",i];
                a1.coordinate = CLLocationCoordinate2DMake([model.LATITUDE doubleValue],[model.LONGITUDE doubleValue]);
                a1.monitorMapModel = model;
                [self.coordinatesArr addObject:a1];
            }
        }
        [_mapView addAnnotations:_coordinatesArr];
        
        _dataArr = [NSMutableArray arrayWithArray:self.coordinatesArr];
        
        [tabView reloadData];
    } failure:^(NSError *error) {
        DLog(@"%@",error);
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
        if ([ddAnnotation.status isEqualToString:@"0"]) {
            if ([ddAnnotation.monitorMapModel.DEVICE_TYPE isEqualToString:@"1-1"]) {
                annotationView.image = [UIImage imageNamed:@"map_gunshot_icon_error"];//设置大头针图片
            }else if ([ddAnnotation.monitorMapModel.DEVICE_TYPE isEqualToString:@"1-2"]){
                annotationView.image = [UIImage imageNamed:@"map_ball_icon_error"];//设置大头针图片
            }else{
                annotationView.image = [UIImage imageNamed:@"map_halfball_icon_error"];//设置大头针图片
            }
        }else if ([ddAnnotation.status isEqualToString:@"1"])
        {
            if ([ddAnnotation.monitorMapModel.DEVICE_TYPE isEqualToString:@"1-1"]) {
                annotationView.image = [UIImage imageNamed:@"map_gunshot_icon_normal"];//设置大头针图片
            }else if ([ddAnnotation.monitorMapModel.DEVICE_TYPE isEqualToString:@"1-2"]){
                annotationView.image = [UIImage imageNamed:@"map_ball_icon_normal"];//设置大头针图片
            }else{
                annotationView.image = [UIImage imageNamed:@"map_halfball_icon_normal"];//设置大头针图片
            }
        }else{
            if ([ddAnnotation.monitorMapModel.DEVICE_TYPE isEqualToString:@"1-1"]) {
                annotationView.image = [UIImage imageNamed:@"map_gunshot_icon_normal"];//设置大头针图片
            }else if ([ddAnnotation.monitorMapModel.DEVICE_TYPE isEqualToString:@"1-2"]){
                annotationView.image = [UIImage imageNamed:@"map_ball_icon_normal"];//设置大头针图片
            }else{
                annotationView.image = [UIImage imageNamed:@"map_halfball_icon_normal"];//设置大头针图片
            }
        }
        
        annotationView.centerOffset = CGPointMake(0, -0.5*ddAnnotation.image.size.height);
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
//    view.image = [UIImage imageNamed:@"camera_select"];
    YQPointAnnotation *anntion = (YQPointAnnotation *)view.annotation;
    [PointViewSelect pointImageSelect:view];
    
    if ([anntion isKindOfClass:[YQPointAnnotation class]]){
        MonitorMapModel *model = anntion.monitorMapModel;
        _currentModel = model;
        
        if ([model.CAMERA_STATUS isEqualToString:@"1"]||[model.CAMERA_STATUS isEqualToString:@"2"]) {
            if ([model.DEVICE_TYPE isEqualToString:@"1-1"]) {
                view.image = [UIImage imageNamed:@"map_gunshot_icon_normal"];
            }else if ([model.DEVICE_TYPE isEqualToString:@"1-2"])
            {
                view.image = [UIImage imageNamed:@"map_ball_icon_normal"];
            }else{
                view.image = [UIImage imageNamed:@"map_halfball_icon_normal"];
            }
        }else {
            if ([model.DEVICE_TYPE isEqualToString:@"1-1"]) {
                view.image = [UIImage imageNamed:@"map_gunshot_icon_error"];
            }else if ([model.DEVICE_TYPE isEqualToString:@"1-2"])
            {
                view.image = [UIImage imageNamed:@"map_ball_icon_error"];
            }else{
                view.image = [UIImage imageNamed:@"map_halfball_icon_error"];
            }
        }
        
        _showMenuView.hidden = NO;
        
        #warning 大华SDK旧版本
        /*
        DeviceTreeNode* tasksGroup =  [DHDataCenter sharedInstance].CamerasGroups;
        
        _stateStr = @"";
        
        if(model.TAGID != nil && model.TAGID.length > 6){
            NSString *careraID = [model.TAGID substringWithRange:NSMakeRange(0, model.TAGID.length - 6)];
            [tasksGroup queryNodeByCareraId:careraID withBlock:^(DeviceTreeNode *node) {
                NSLog(@"在线离线状态：------- %d", node.bOnline);
                if(node.bOnline){
                    // 在线
                    _isOnline = YES;
                    _stateStr = @"正常开启中";
                    _stateColor = [UIColor colorWithHexString:@"#189517"];
                }else {
                    // 离线
                    _isOnline = NO;
                    _stateStr = @"离线";
                    _stateColor = [UIColor grayColor];
                }
            }];
        }
        
         */
        _menuTitle = model.DEVICE_NAME;
        
        [_showMenuView reloadMenuData]; //  刷新菜单
        
        _selectIndex = [anntion.number integerValue];

    }
    
}

-(void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view
{
    YQPointAnnotation *anntion = (YQPointAnnotation *)view.annotation;
    
    if ([anntion isKindOfClass:[YQPointAnnotation class]])
    {
        if ([anntion.status isEqualToString:@"1"] || [anntion.status isEqualToString:@"2"]) {
            if ([anntion.monitorMapModel.DEVICE_TYPE isEqualToString:@"1-1"]) {
                view.image = [UIImage imageNamed:@"map_gunshot_icon_normal"];//设置大头针图片
            }else if ([anntion.monitorMapModel.DEVICE_TYPE isEqualToString:@"1-2"]){
                view.image = [UIImage imageNamed:@"map_ball_icon_normal"];//设置大头针图片
            }else{
                view.image = [UIImage imageNamed:@"map_halfball_icon_normal"];//设置大头针图片
            }
        }else{
            if ([anntion.monitorMapModel.DEVICE_TYPE isEqualToString:@"1-1"]) {
                view.image = [UIImage imageNamed:@"map_gunshot_icon_error"];//设置大头针图片
            }else if ([anntion.monitorMapModel.DEVICE_TYPE isEqualToString:@"1-2"]){
                view.image = [UIImage imageNamed:@"map_ball_icon_error"];//设置大头针图片
            }else{
                view.image = [UIImage imageNamed:@"map_halfball_icon_error"];//设置大头针图片
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    self.mapView.showsUserLocation = NO;
    self.mapView.delegate = nil;
    
    [super viewWillDisappear:animated];
}

#pragma mark 菜单协议
- (CGFloat)menuHeightInView:(NSInteger)index {
    switch (index) {
        case 0:
            return 40;
            break;
        case 1:
            return 80;
            break;
        case 2:
            return 50;
            break;
            
        default:
            return 0;
            break;
    }
}

- (NSInteger)menuNumInView {
    return 3;
}

- (NSString *)menuTitle:(NSInteger)index {
    switch (index) {
        case 0:
            return @"在线状态";
            break;
        case 1:
            return @"实时画面";
            break;
        case 2:
            return @"历史录像";
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
            return ImgConMenu;
            break;
        case 2:
            return ImgConMenu;
            break;
            
        default:
            return DefaultConMenu;
            break;
    }
}

- (NSString *)menuMessage:(NSInteger)index {
    switch (index) {
        case 0:
            return _stateStr;
            break;
            
        default:
            return @"";
            break;
    }
}
- (UIColor *)menuMessageColor:(NSInteger)index {
    if(index == 0){
        return _stateColor;
    }else {
        return [UIColor blackColor];
    }
}

// 右侧有图片时实现
- (NSString *)imageName:(NSInteger)index {
    if(index == 1){
        return @"camera_play";
    }
    if(index == 2){
        return @"door_list_right_narrow";
    }
    return @"";
}
- (CGSize)imageSize:(NSInteger)index {
    if(index == 2){
        return CGSizeMake(30, 30);
    }
    return CGSizeMake(62, 62);
}

- (void)didSelectMenu:(NSInteger)index {
    if(index == 1){
        _isShowMenu = YES;
#pragma mark 播放视频
        // 播放视频
        // 查询固定相机
        //                [DHDataCenter sharedInstance].channelID = @"1000010$1$0$0";
        
//        if(!_isOnline){
//            // 离线
//            [self showHint:@"设备离线"];
//            return;
//        }
        
        if(_currentModel.TAGID == nil || [_currentModel.TAGID isKindOfClass:[NSNull class]]){
            [self showHint:@"相机无参数"];
            return;
        }
        #warning 大华SDK旧版本
//        [DHDataCenter sharedInstance].channelID = _currentModel.TAGID;
        
        PlayVideoViewController *playVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"PlayVideoViewController"];
        playVC.deviceType = _currentModel.DEVICE_TYPE;
        [self.navigationController pushViewController:playVC animated:YES];
        
    }else if(index == 2) {
        if(_currentModel.TAGID == nil || [_currentModel.TAGID isKindOfClass:[NSNull class]]){
            [self showHint:@"相机无参数"];
            return;
        }
        #warning 大华SDK旧版本
//        [DHDataCenter sharedInstance].channelID = _currentModel.TAGID;
        
        PlaybackViewController *playVC = [[PlaybackViewController alloc] init];
        [self.navigationController pushViewController:playVC animated:YES];
    }
}

-(void)closeMenu
{
    if(self.coordinatesArr.count > _selectIndex){
        YQPointAnnotation *anniton = self.coordinatesArr[_selectIndex];
        [self.mapView deselectAnnotation:anniton animated:YES];
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

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.coordinatesArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MonitorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MonitorTableViewCell" forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.row == _selectedIndex.row && _selectedIndex != nil) {
        //如果是展开
        if (isOpen == YES) {
            cell.contentView.backgroundColor = [UIColor colorWithHexString:@"F8FCFF"];
            cell.selectView.hidden = NO;
            cell.playBtn.hidden = NO;
            cell.screen.hidden = NO;
            cell.hisLab.hidden = NO;
            cell.playBackBtn.hidden = NO;
        }else{
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.selectView.hidden = YES;
            cell.playBtn.hidden = YES;
            cell.screen.hidden = YES;
            cell.hisLab.hidden = YES;
            cell.playBackBtn.hidden = YES;
        }
        //不是自身
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.selectView.hidden = YES;
        cell.playBtn.hidden = YES;
        cell.screen.hidden = YES;
        cell.hisLab.hidden = YES;
        cell.playBackBtn.hidden = YES;
    }
    
    if(self.coordinatesArr.count > indexPath.row){
        YQPointAnnotation *anntion = self.coordinatesArr[indexPath.row];
        cell.mapModel = anntion.monitorMapModel;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _selectedIndex.row && _selectedIndex != nil ) {
        if (isOpen == YES) {
            return 180;
        }else{
            return 60;
        }
    }
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [searchBar resignFirstResponder];
    
    NSMutableArray *indexPaths = @[].mutableCopy;
    if(indexPath.row < self.coordinatesArr.count){
        [indexPaths addObject:indexPath];
    }
    //判断选中不同row状态时候
    //    if (self.selectedIndex != nil && indexPath.row != selectedIndex.row) {
    if (self.selectedIndex != nil && indexPath.row == _selectedIndex.row) {
        //将选中的和所有索引都加进数组中
        //        indexPaths = [NSArray arrayWithObjects:indexPath,selectedIndex, nil];
        isOpen = !isOpen;
        
    }else if (self.selectedIndex != nil && indexPath.row != _selectedIndex.row) {
        if(_selectedIndex.row < self.coordinatesArr.count){
            [indexPaths addObject:_selectedIndex];
        }
        isOpen = YES;
    }
    //记下选中的索引
    self.selectedIndex = indexPath;
    //刷新
    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark uisearchBar delegate

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [_nameArr removeAllObjects];
    
    [_dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YQPointAnnotation *pointAnnition = (YQPointAnnotation *)obj;
        MonitorMapModel *model = pointAnnition.monitorMapModel;
        [_nameArr addObject:model.DEVICE_NAME];
    }];
    
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    [_failtArr removeAllObjects];
//    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@",searchBar.text];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF.monitorMapModel.DEVICE_NAME CONTAINS %@",searchBar.text];
    
    _failtArr = [_dataArr filteredArrayUsingPredicate:pred].mutableCopy;
    
//    [_nameArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSString *name = (NSString *)obj;
//        BOOL isContain = [pred evaluateWithObject:name];
//        if (isContain) {
//            [_failtArr addObject:_dataArr[idx]];
//        }
//    }];
    
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
    self.title = @"室外监控";
    
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

@end


