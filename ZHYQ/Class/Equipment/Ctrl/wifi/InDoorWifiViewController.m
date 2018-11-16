//
//  InDoorWifiViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/2.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "InDoorWifiViewController.h"

#import "ShowMenuView.h"
#import "YQHeaderView.h"

#import "YQInDoorPointMapView.h"

#import "InDoorWifiModel.h"
#import "WifiListTableViewCell.h"

#import "CRSearchBar.h"

#import "NoDataView.h"
#import <UITableView+PlaceHolderView.h>
#import "wifiSticalCenterViewController.h"

#import "WifiInfoModel.h"

#define scal 0.3

@interface InDoorWifiViewController ()<UIScrollViewDelegate, MenuControlDelegate,DidSelInMapPopDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
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

    YQInDoorPointMapView *indoorView;
    UIImageView *_selectImageView;
    UIView *bottomView;
    BOOL isOpen;
    
    CRSearchBar *searchBar;
    UITableView *tabView;
    NSMutableArray *_failtArr;
    NSMutableArray *_nameArr;
    NSMutableArray *_dataArr;
    
    NSMutableDictionary *_statusDic;
    
    NSInteger _currentSelectIndex;
    
    WifiInfoModel *_wifiInfoModel;  // 选中当前wifi设备数据详细model
    InDoorWifiModel *_inDoorWifiModel;  // 选中当前wifi设备数据model
}

@property (strong,nonatomic) YQHeaderView *headerView;
@property (nonatomic,strong) NSMutableArray *wifiDataArr;
@property (nonatomic,strong) NSMutableArray *graphData;
@property (nonatomic,strong) NSIndexPath * selectedIndex;

@end

@implementation InDoorWifiViewController

-(NSMutableArray *)wifiDataArr
{
    if (_wifiDataArr == nil) {
        _wifiDataArr = [NSMutableArray array];
    }
    return _wifiDataArr;
}

-(NSMutableArray *)graphData
{
    if (_graphData == nil) {
        _graphData = [NSMutableArray array];
    }
    return _graphData;
}

-(YQHeaderView *)headerView
{
    if (_headerView == nil) {
        _headerView = [[YQHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 85)];
        _headerView.backgroundColor = [UIColor colorWithHexString:@"1B82D1"];
    }
    return _headerView;
}

-(void)setFloorModel:(FloorModel *)floorModel
{
    _floorModel = floorModel;
}

#pragma mark 横屏控制
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.allowRotate = YES;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.allowRotate = NO;
}

//---------
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        // 屏幕从竖屏变为横屏时执行
        NSLog(@"屏幕从竖屏变为横屏时执行");
        bottomView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight - 32);
        tabView.frame = CGRectMake(0, 0, KScreenWidth, bottomView.height);
        indoorView.frame = CGRectMake(0, 0, KScreenWidth, bottomView.height);
        _showMenuView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
        [_showMenuView reloadMenuData];
        _headerView.hidden = YES;
    }else{
        // 屏幕从横屏变为竖屏时执行
        NSLog(@"屏幕从横屏变为竖屏时执行");
        bottomView.frame = CGRectMake(0, _headerView.bottom, KScreenWidth, KScreenHeight - kTopHeight - 20 - _headerView.bottom);
        tabView.frame = CGRectMake(0, 0, KScreenWidth, bottomView.height);
        indoorView.frame = CGRectMake(0, 0, KScreenWidth, bottomView.height);
        _showMenuView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
        [_showMenuView reloadMenuData];
        _headerView.hidden = NO;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNavItems];
    
    //初始化子视图
    [self _initView];
    [self _initMsgBgView];
    [self _initTableView];
    [self _initPointMapView];
    
    _failtArr = @[].mutableCopy;
    _nameArr = @[].mutableCopy;
    
    _statusDic = @{}.mutableCopy;
    [_statusDic setObject:@"0" forKey:@"areaStatus"];
    
    isOpen = YES;
    _currentSelectIndex = 0;
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    
    [self _loadFloorEquipmentData:[NSString stringWithFormat:@"%@",_floorModel.LAYER_ID]];
}

-(void)_initMsgBgView
{
    [self.view addSubview:self.headerView];
}

-(void)_initPointMapView
{
    indoorView = [[YQInDoorPointMapView alloc]initWithIndoorMapImageName:[NSString stringWithFormat:@"%@",_floorModel.LAYER_MAP] Frame:CGRectMake(0, 0, self.view.frame.size.width, bottomView.height)];
    indoorView.selInMapDelegate = self;
    [bottomView addSubview:indoorView];
}

-(void)_initTableView
{
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_headerView.frame), KScreenWidth, KScreenHeight-kTopHeight-CGRectGetMaxY(_headerView.frame))];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    tabView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tabView.frame = CGRectMake(0, 0, KScreenWidth, bottomView.height);
//    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    tabView.delegate = self;
    tabView.dataSource = self;
    tabView.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    [tabView registerNib:[UINib nibWithNibName:@"WifiListTableViewCell" bundle:nil] forCellReuseIdentifier:@"WifiListTableViewCell"];
    tabView.hidden = YES;
    tabView.enablePlaceHolderView = YES;
    tabView.yh_PlaceHolderView = [self makePlaceHolderView];
    [bottomView addSubview:tabView];
}

-(void)_initView
{
    _showMenuView = [[ShowMenuView alloc] init];
    _showMenuView.menuDelegate = self;
    _showMenuView.hidden = YES;
    [[UIApplication sharedApplication].delegate.window addSubview:_showMenuView];
    
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
    return self.wifiDataArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WifiListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WifiListTableViewCell" forIndexPath:indexPath];
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
    cell.model = self.wifiDataArr[indexPath.row];
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
    
    InDoorWifiModel *model = self.wifiDataArr[indexPath.row];
    _inDoorWifiModel = model;
    
    NSMutableArray *indexPaths = @[].mutableCopy;
    if(indexPath.row < self.wifiDataArr.count){
        [indexPaths addObject:indexPath];
    }
    //判断选中不同row状态时候
    //    if (self.selectedIndex != nil && indexPath.row != selectedIndex.row) {
    if (self.selectedIndex != nil && indexPath.row == _selectedIndex.row) {
        //将选中的和所有索引都加进数组中
        //        indexPaths = [NSArray arrayWithObjects:indexPath,selectedIndex, nil];
        isOpen = !isOpen;
        
    }else if (self.selectedIndex != nil && indexPath.row != _selectedIndex.row) {
        if(_selectedIndex.row < self.wifiDataArr.count){
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

#pragma mark 加载地图列表数据
-(void)_loadFloorEquipmentData:(NSString *)layerId
{
    [self showHudInView:self.view hint:@""];
    NSString *urlStr = [NSString stringWithFormat:@"%@/wifi/getInWifiList?layerId=%@",Main_Url,layerId];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *dataDic = responseObject[@"responseData"];
            _headerView.leftNumLab.text = [NSString stringWithFormat:@"%@",dataDic[@"okWifiCount"]];
            _headerView.centerNumLab.text = [NSString stringWithFormat:@"%@",dataDic[@"outWifiCount"]];
            _headerView.rightNumLab.text = [NSString stringWithFormat:@"%@",dataDic[@"errorWifiCount"]];
            NSArray *arr = dataDic[@"wifiList"];
            if (self.graphData.count != 0) {
                [self.graphData removeAllObjects];
            }
            if (self.wifiDataArr.count != 0) {
                [self.wifiDataArr removeAllObjects];
            }
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                InDoorWifiModel *model = [[InDoorWifiModel alloc] initWithDataDic:arr[idx]];
                
//                if (idx == 1||idx == 3) {
//                    model.WIFI_STATUS = @"0";
//                }
//                NSString *graphStr = [NSString stringWithFormat:@"%@,%@,%@",model.LAYER_A,model.LAYER_B,model.LAYER_C];
                NSString *graphStr = [NSString stringWithFormat:@"%@,%@",model.LONGITUDE, model.LATITUDE];
                [self.graphData addObject:graphStr];
                [self.wifiDataArr addObject:model];
            }];
            indoorView.graphData = _graphData;
            indoorView.wifiModelArr = _wifiDataArr;
            
            _dataArr = [NSMutableArray arrayWithArray:self.wifiDataArr];
            
            [tabView reloadData];
        }
    } failure:^(NSError *error) {
        [self hideHud];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 菜单协议
- (CGFloat)menuHeightInView:(NSInteger)index {
    if(index == 0){
        return 60;
    }else{
        return 40;
    }
}

- (NSInteger)menuNumInView {
    return 5;
}

- (NSString *)menuTitle:(NSInteger)index {
    switch (index) {
        case 0:
            return _stateStr;
            break;
        case 1:
            return @"位置";
            break;
        case 2:
            return @"接收速率";
            break;
        case 3:
            return @"发送速率";
            break;
        case 4:
            return @"接入用户数";
            break;
            
        default:
            return @"";
            break;
    }
}

- (UIColor *)menuTitleColor:(NSInteger)index {
    if(index == 0){
        return _stateColor;
    }else {
        return [UIColor blackColor];
    }
}

- (NSString *)menuTitleViewText {
    return _menuTitle;
}

- (ShowMenuStyle)menuViewStyle:(NSInteger)index {
    switch (index) {
        case 0:
            return SwitchConMenu;
            break;
        case 4:
            return TextAndImgConMenu;
            break;
        default:
            return DefaultConMenu;
            break;
    }
}

- (NSString *)menuMessage:(NSInteger)index {
    switch (index) {
        case 1:
            return _locationStr;
            break;
        case 2:
            return _accessNum;
            break;
        case 3:
            return _sendNum;
            break;
        case 4:
            return _userNum;
            break;
            
        default:
            return @"";
            break;
    }
}
- (NSString *)imageName:(NSInteger)index {
    return @"wifi_list";
}

// 为SwitchConMenu时实现，默认开关状态
- (BOOL)isSwitch:(NSInteger)index {
    return _isRuning;
}

#pragma mark 点击开关回调
- (void)switchState:(NSInteger)index withSwitch:(BOOL)isOn {
    if([_stateStr isEqualToString:@"设备故障"]){
        return;
    }
    
    [self wifiControl:isOn];
}
- (void)didSelectMenu:(NSInteger)index {
    if(index == 4){
        [self goWifiUser];
    }
}

#pragma mark 调用开关wifi接口
- (void)wifiControl:(BOOL)on {
    NSString *operation;
    if(on){
        operation = @"enable_radio";
    }else {
        operation = @"disable_radio";
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@/wifi/setWifiState?layerId=%@&operation=%@&mode=%@&deviceId=%@",Main_Url, _inDoorWifiModel.LAYER_ID, operation, @"all", _inDoorWifiModel.DEVICE_ID];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        NSNumber *success = responseObject[@"success"];
        if(!success.boolValue){
            if(responseObject[@"msg"] != nil && ![responseObject[@"msg"] isKindOfClass:[NSNull class]] ) {
                [self showHint:responseObject[@"msg"]];
            }
        }else {
            if(on){
                _stateStr = @"正常开启中";
                _stateColor = [UIColor colorWithHexString:@"#189517"];
            }else {
                _stateStr = @"离线";
                _stateColor = [UIColor blackColor];
            }
            [_showMenuView reloadMenuData];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark 选中地图标注
- (void)selInMapWithId:(NSString *)identity {
    _showMenuView.hidden = NO;
    
    NSInteger selectIndex = [identity integerValue]-100;
    if(self.wifiDataArr.count <= selectIndex){
        return;
    }
    
    InDoorWifiModel *model = self.wifiDataArr[selectIndex];
    _inDoorWifiModel = model;
    
    _menuTitle = model.DEVICE_NAME;
    _locationStr = model.DEVICE_ADDR;
    
    if (_selectImageView) {
        InDoorWifiModel *selectModel = self.wifiDataArr[_selectImageView.tag-100];
        _selectImageView.contentMode = UIViewContentModeScaleToFill;
        if ([selectModel.WIFI_STATUS isEqualToString:@"1"]||[selectModel.WIFI_STATUS isEqualToString:@"2"]) {
            _selectImageView.image = [UIImage imageNamed:@"wifi_normal"];
        }else{
            _selectImageView.image = [UIImage imageNamed:@"wifi_error"];
        }
    }
    
    // 复原之前选中图片效果
    if(_selectImageView != nil){
        [PointViewSelect recoverSelImgView:_selectImageView];
    }
    
    UIImageView *imageView = [indoorView.mapView viewWithTag:[identity integerValue]];
    if ([model.WIFI_STATUS isEqualToString:@"1"]||[model.WIFI_STATUS isEqualToString:@"2"]) {
        imageView.image = [UIImage imageNamed:@"wifi_normal"];
    }else {
        imageView.image = [UIImage imageNamed:@"wifi_error"];
    }
    imageView.contentMode = UIViewContentModeScaleToFill;
    _selectImageView = imageView;
    
    [PointViewSelect pointImageSelect:_selectImageView];
    
    [_showMenuView reloadMenuData]; //  刷新菜单，加载完成在刷新
    
    [self loadWifiData:model.DEVICE_ID withLayId:model.LAYER_ID withList:NO];
    
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
//    else if([model.WIFI_STATUS isEqualToString:@"0"]){
//        // 故障
//        _isRuning = NO;
//        _stateStr = @"设备故障";
//        _stateColor = [UIColor colorWithHexString:@"#FF4359"];
//    }
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
    wifiStiVc.inDoorWifiModel = _inDoorWifiModel;
    [self.navigationController pushViewController:wifiStiVc animated:YES];
}

#pragma mark uisearchBar delegate
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [_nameArr removeAllObjects];
    
    [_dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        InDoorWifiModel *model = (InDoorWifiModel *)obj;
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

    [self.wifiDataArr removeAllObjects];
    if (searchBar.text.length == 0) {
        [self.wifiDataArr addObjectsFromArray:_dataArr];
    }else{
        [self.wifiDataArr addObjectsFromArray:_failtArr];
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
    
    [self.wifiDataArr removeAllObjects];
    if (searchText.length == 0) {
        [self.wifiDataArr addObjectsFromArray:_dataArr];
    }else{
        [self.wifiDataArr addObjectsFromArray:_failtArr];
    }
    
    [tabView reloadData];
}

-(void)initNavItems {
    self.title = _floorModel.LAYER_NAME;
    
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
        if (tabView.hidden) {
            [_statusDic setObject:@"1" forKey:@"areaStatus"];
            tabView.hidden = NO;
            indoorView.hidden = YES;
            [tabView reloadData];
            [btn setImage:[UIImage imageNamed:@"slideMenu"] forState:UIControlStateNormal];
        }else{
            [searchBar resignFirstResponder];
            [_statusDic setObject:@"0" forKey:@"areaStatus"];
            tabView.hidden = YES;
            indoorView.hidden = NO;
            [btn setImage:[UIImage imageNamed:@"switchmap"] forState:UIControlStateNormal];
            
            [self.wifiDataArr removeAllObjects];
            [self.wifiDataArr addObjectsFromArray:_dataArr];
        }
    }];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDateView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 49, KScreenWidth, tabView.height-49)];
    noDateView.label.text = @"无结果";
    return noDateView;
}

@end
