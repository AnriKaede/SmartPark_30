//
//  OutDoorWifiViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/2.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "OutDoorWifiViewController.h"
#import "YQHeaderView.h"
#import "WifiMapModel.h"
#import "YQPointAnnotation.h"
#import "WifiAnnotationView.h"

#import "ShowMenuView.h"
#import "WifiListTableViewCell.h"

#import "CRSearchBar.h"
#import "NoDataView.h"
#import <UITableView+PlaceHolderView.h>
#import "wifiSticalCenterViewController.h"

#import "WifiInfoModel.h"
#import "wifiSticalCenterViewController.h"

@interface OutDoorWifiViewController ()<MAMapViewDelegate, MenuControlDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate, WifiConDelegate>
{
    // 弹窗
    ShowMenuView *_showMenuView;
    NSString *_menuTitle;   // 菜单标题
    NSString *_stateStr;    // 设备状态
    UIColor *_stateColor;   // 设备状态颜色
    BOOL _isRuning; // 是否正常开启
    NSString *_locationStr; // 位置
    NSString *_accessNum; // 接收速率
    NSString *_sendNum; // 发送速率
    NSString *_userNum; // 用户数

    BOOL _hasCurrLoc;
    BOOL isOpen;
    
    //    当前选择的标注index
    NSInteger _selectIndex;
    
    CRSearchBar *searchBar;
    UITableView *tabView;
    NSMutableArray *_failtArr;
    NSMutableArray *_nameArr;
    NSMutableArray *_dataArr;
    
    CLLocationCoordinate2D _coordinate;
    
    WifiInfoModel *_wifiInfoModel;  // 选中当前wifi设备数据详细model
    WifiMapModel *_wifiMapModel;  // 选中当前wifi设备数据model
}

@property (nonatomic,strong) MAMapView *mapView;
@property (nonatomic,strong) YQHeaderView *headerView;
@property (nonatomic,strong) NSMutableArray *coordinatesArr;
@property (nonatomic,strong) NSIndexPath * selectedIndex;

@end

@implementation OutDoorWifiViewController

-(MAMapView *)mapView
{
    if (_mapView == nil) {
        _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 85, KScreenWidth, KScreenHeight-85)];
        [self.view addSubview:_mapView];
        _mapView.delegate = self;
        //进入地图就显示定位小蓝点
        _mapView.zoomLevel = 18;
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
    
    _failtArr = @[].mutableCopy;
    _nameArr = @[].mutableCopy;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self _initMapView];
    
    [self _initView];
    
    [self _initTableView];
    
    [self _loadData];
    
    [self initNavItems];
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
//    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    tabView.delegate = self;
    tabView.dataSource = self;
    tabView.enablePlaceHolderView = YES;
    tabView.yh_PlaceHolderView = [self makePlaceHolderView];
    tabView.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    [tabView registerNib:[UINib nibWithNibName:@"WifiListTableViewCell" bundle:nil] forCellReuseIdentifier:@"WifiListTableViewCell"];
    tabView.hidden = YES;
    [self.view addSubview:tabView];
}

-(void)_loadData
{
    //获取wifi点位信息
    [self _loadWifiLocationData];
}

-(void)_loadWifiLocationData
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/wifi/getOutWifiList",Main_Url];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *responseDataDic = responseObject[@"responseData"];
            NSArray *arr = responseDataDic[@"wifiList"];
            
            _headerView.leftNumLab.text = [NSString stringWithFormat:@"%@",responseDataDic[@"okWifiCount"]];
            _headerView.centerNumLab.text = [NSString stringWithFormat:@"%@",responseDataDic[@"outWifiCount"]];
            _headerView.rightNumLab.text = [NSString stringWithFormat:@"%@",responseDataDic[@"errorWifiCount"]];
            
            for (int i = 0; i < arr.count; i++) {
                WifiMapModel *model = [[WifiMapModel alloc] initWithDataDic:arr[i]];
                YQPointAnnotation *a1 = [[YQPointAnnotation alloc] init];
                a1.status = model.WIFI_STATUS;
                a1.number = [NSString stringWithFormat:@"%d",i];
                a1.coordinate = CLLocationCoordinate2DMake([model.LATITUDE doubleValue],[model.LONGITUDE doubleValue]);
                a1.wifiMapModel = model;
                [self.coordinatesArr addObject:a1];
            }
        }
        [_mapView addAnnotations:_coordinatesArr];
        
        _dataArr = [NSMutableArray arrayWithArray:self.coordinatesArr];
        
        [self.tableView reloadData];
    } failure:^(NSError *error) {
//        DLog(@"%@",error);
    }];
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
    WifiListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WifiListTableViewCell" forIndexPath:indexPath];
    cell.wifiConDelegate = self;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.row == _selectedIndex.row && _selectedIndex != nil) {
        //如果是展开
        if (isOpen == YES) {
            //xxxxxx
            cell.contentView.backgroundColor = [UIColor colorWithHexString:@"F8FCFF"];
            cell.selectView.hidden = NO;
            cell.locationLab.hidden = NO;
            cell.locationNumLab.hidden = NO;
            cell.netSepLab.hidden = NO;
            cell.netSepNumLab.hidden = NO;
            cell.sendLab.hidden = NO;
            cell.sendNumLab.hidden = NO;
            cell.userLab.hidden = NO;
            cell.userNumLab.hidden = NO;
            cell.userNumBt.hidden = NO;
        }else{
            //收起
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.selectView.hidden = YES;
            cell.locationLab.hidden = YES;
            cell.locationNumLab.hidden = YES;
            cell.netSepLab.hidden = YES;
            cell.netSepNumLab.hidden = YES;
            cell.sendLab.hidden = YES;
            cell.sendNumLab.hidden = YES;
            cell.userLab.hidden = YES;
            cell.userNumLab.hidden = YES;
            cell.userNumBt.hidden = YES;
        }
        //不是自身
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.selectView.hidden = YES;
        cell.locationLab.hidden = YES;
        cell.locationNumLab.hidden = YES;
        cell.netSepLab.hidden = YES;
        cell.netSepNumLab.hidden = YES;
        cell.sendLab.hidden = YES;
        cell.sendNumLab.hidden = YES;
        cell.userLab.hidden = YES;
        cell.userNumLab.hidden = YES;
        cell.userNumBt.hidden = YES;
    }
    YQPointAnnotation *anniton = self.coordinatesArr[indexPath.row];
    cell.mapModel = anniton.wifiMapModel;
    cell.wifiInfoModel = _wifiInfoModel;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _selectedIndex.row && _selectedIndex != nil ) {
        if (isOpen == YES) {
            return 230;
        }else{
            return 60;
        }
    }
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [searchBar resignFirstResponder];
    
    YQPointAnnotation *anniton = self.coordinatesArr[indexPath.row];
    WifiMapModel *model = anniton.wifiMapModel;
    _wifiMapModel = model;
    
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
    
    [self loadWifiData:model.DEVICE_ID withLayId:model.LAYER_ID withList:YES];
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
            annotationView.image = [UIImage imageNamed:@"wifi_error"];//设置大头针图片
        }else if ([ddAnnotation.status isEqualToString:@"1"])
        {
            annotationView.image = [UIImage imageNamed:@"wifi_normal"];//设置大头针图片
        }else{
            annotationView.image = [UIImage imageNamed:@"wifi_normal"];//设置大头针图片
        }
        
        annotationView.centerOffset = CGPointMake(0, -0.5*ddAnnotation.image.size.height);
        
//        annotationView.imageView.size = CGSizeMake(30, 30);
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    
    YQPointAnnotation *anntion = (YQPointAnnotation *)view.annotation;
    if ([anntion isKindOfClass:[YQPointAnnotation class]]){
        WifiMapModel *model = anntion.wifiMapModel;
        _wifiMapModel = model;
        
        if ([model.WIFI_STATUS isEqualToString:@"1"]||[model.WIFI_STATUS isEqualToString:@"2"]) {
            view.image = [UIImage imageNamed:@"wifi_normal"];
        }else {
            view.image = [UIImage imageNamed:@"wifi_error"];
        }
        [PointViewSelect pointImageSelect:view];
        
        _showMenuView.hidden = NO;
        
        _menuTitle = model.DEVICE_NAME;
        _locationStr = [NSString stringWithFormat:@"%@", model.DEVICE_ADDR];
        
        _selectIndex = [anntion.number integerValue];
        
        [_showMenuView reloadMenuData]; //  刷新菜单
//        view.imageView.size = CGSizeMake(30, 30);
        
        [self loadWifiData:model.DEVICE_ID withLayId:model.LAYER_ID withList:NO];
    }

}

#pragma mark 加载单个设备数据
- (void)loadWifiData:(NSString *)DEVICE_ID withLayId:(NSNumber *)layId withList:(BOOL)isList {
    _wifiInfoModel = nil;
    NSString *urlStr = [NSString stringWithFormat:@"%@/wifi/getWifiListDetail?layerId=%@&AP=%@",Main_Url, layId, DEVICE_ID];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            NSDictionary *responseData = responseObject[@"responseData"];
            NSArray *wifiList = responseData[@"wifiList"];
            if(wifiList != nil && [wifiList isKindOfClass:[NSArray class]] && wifiList.count > 0){
                _wifiInfoModel = [[WifiInfoModel alloc] initWithDataDic:wifiList.firstObject];
                if(isList){
                    // 刷新列表cell
                    if(_selectedIndex){
                        [tabView reloadRowsAtIndexPaths:@[_selectedIndex] withRowAnimation:UITableViewRowAnimationFade];
                    }
                }else {
                    // 刷新地图菜单
                    [self loadWifiInfo:_wifiInfoModel];
                }
            }
        }
        
    } failure:^(NSError *error) {
        
    }];
}
- (void)loadWifiInfo:(WifiInfoModel *)wifiInfoModel {
    // 更新数据
    if(wifiInfoModel.status.integerValue == 1){
        // 正常
        _isRuning = YES;
        _stateStr = @"正常开启中";
        _stateColor = [UIColor colorWithHexString:@"#189517"];
    }
    else {
        // 离线
        _isRuning = NO;
        _stateStr = @"离线";
        _stateColor = [UIColor grayColor];
    }
    
    _accessNum = [NSString stringWithFormat:@"%@", [self speedValueStr:wifiInfoModel.recv.doubleValue]];
    _sendNum = [NSString stringWithFormat:@"%@", [self speedValueStr:wifiInfoModel.send.doubleValue]];
    _userNum = [NSString stringWithFormat:@"%@", wifiInfoModel.usercount];
    
    [_showMenuView reloadMenuData]; //  刷新菜单
    
}
- (NSString *)speedValueStr:(double)speed {
    NSString *speedStr;
    if(speed < 1024){
        // b
        speedStr = [NSString stringWithFormat:@"%.2f b", speed];
    }else if(speed > 1024 && speed < 1024*1024){
        // kb
        speedStr = [NSString stringWithFormat:@"%.2f kb", speed/1024.00];
    }else {
        // M
        speedStr = [NSString stringWithFormat:@"%.2f M", speed/(1024.00*1024.00)];
    }
    return speedStr;
}

- (void)goWifiUser {
    wifiSticalCenterViewController *wifiStiVc = [[wifiSticalCenterViewController alloc] init];
    wifiStiVc.wifiInfoModel = _wifiInfoModel;
    wifiStiVc.inDoorWifiModel = (InDoorWifiModel *)_wifiMapModel;
    [self.navigationController pushViewController:wifiStiVc animated:YES];
}

-(void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view
{
    YQPointAnnotation *anntion = (YQPointAnnotation *)view.annotation;
    if ([anntion isKindOfClass:[YQPointAnnotation class]])
    {
        if ([anntion.status isEqualToString:@"1"]||[anntion.status isEqualToString:@"2"]) {
            view.image = [UIImage imageNamed:@"wifi_normal"];
        }else{
            view.image = [UIImage imageNamed:@"wifi_error"];
        }
        // 复原之前选中图片效果
        if(view != nil){
            [PointViewSelect recoverSelImgView:view];
        }
//        view.imageView.size = CGSizeMake(30, 30);
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
    if(index == 0 || index == 1 || index == 2){
        return 45;
    }else{
        return 40;
    }
}

- (NSInteger)menuNumInView {
    return 7;
}

- (NSString *)menuTitle:(NSInteger)index {
    switch (index) {
        case 0:
            return @"重启设备";
            break;
        case 1:
            return @"开启射频";
            break;
        case 2:
            return @"关闭射频";
            break;
        case 3:
            return @"位置";
            break;
        case 4:
            return @"接收速率";
            break;
        case 5:
            return @"发送速率";
            break;
        case 6:
            return @"接入用户数";
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
            return ImgConMenu;
            break;
        case 1:
            return ImgConMenu;
            break;
        case 2:
            return ImgConMenu;
            break;
        case 6:
            return TextAndImgConMenu;
            break;
        default:
            return DefaultConMenu;
            break;
    }
}
- (CGSize)imageSize:(NSInteger)index {
    return CGSizeMake(32, 32);
}

- (NSString *)menuMessage:(NSInteger)index {
    switch (index) {
        case 3:
            return _locationStr;
            break;
        case 4:
            return _accessNum;
            break;
        case 5:
            return _sendNum;
            break;
        case 6:
            return _userNum;
            break;
            
        default:
            return @"";
            break;
    }
}
- (NSString *)imageName:(NSInteger)index {
    if(index == 0){
        return @"led_restart_icon";
    }else if(index == 1){
        return @"led_play_icon";
    }else if(index == 2){
        return @"led_close_icon";
    }else if(index == 6){
        return @"wifi_list";
    }
    return @"";
}

#pragma mark 点击开关回调
- (void)didSelectMenu:(NSInteger)index {
    if(index == 0){
        [self wifiControl:0];
    }else if(index == 1){
        [self wifiControl:1];
    }else if(index == 2){
        [self wifiControl:2];
    }else if(index == 6){
        [self goWifiUser];
    }
}

#pragma mark 调用开关wifi接口
- (void)wifiControl:(NSInteger)conType {
    // conType: 0重启，1开射频，2关射频
    NSString *operation;
    if(conType == 0){
        operation = @"reboot";
    }else if(conType == 1){
        operation = @"enable_radio";
    }else if(conType == 2){
        operation = @"disable_radio";
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@/wifi/setWifiState?layerId=%@&operation=%@&mode=%@&deviceId=%@",Main_Url, _wifiMapModel.LAYER_ID, operation, @"all", _wifiMapModel.DEVICE_ID];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        NSNumber *success = responseObject[@"success"];
        if(!success.boolValue){
            if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]] ) {
                [self showHint:responseObject[@"message"]];
            }
        }else {
            [_showMenuView reloadMenuData];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

-(void)closeMenu {
    if(self.coordinatesArr.count > _selectIndex){
        YQPointAnnotation *anntion = self.coordinatesArr[_selectIndex];
        [self.mapView deselectAnnotation:anntion animated:YES];
    }
}

-(void)initNavItems
{
    self.title = @"室外WIFI";
    
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

#pragma mark uisearchBar delegate

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [_nameArr removeAllObjects];
    
    [_dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YQPointAnnotation *pointAnnition = (YQPointAnnotation *)obj;
        WifiMapModel *model = pointAnnition.wifiMapModel;
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

#pragma mark cell控制协议
- (void)wifiConType:(NSInteger)type {
    [self wifiControl:type];
}

@end
