//
//  InDoorMonitorViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/11.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "InDoorMonitorViewController.h"

#import "ShowMenuView.h"
#import "YQSecondHeaderView.h"

#import "YQInDoorPointMapView.h"
#import "InDoorMonitorMapModel.h"

#import "MonitorTableViewCell.h"

#import "CRSearchBar.h"
#import "NoDataView.h"
#import <UITableView+PlaceHolderView.h>

//#import "DHDataCenter.h"
#import "PlayVideoViewController.h"
#import "PlaybackViewController.h"

#import "MonitorLogin.h"

@interface InDoorMonitorViewController ()<UIScrollViewDelegate, MenuControlDelegate,SGPageTitleViewDelegate,DidSelInMapPopDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
{    
    // 弹窗
    ShowMenuView *_showMenuView;
    NSString *_menuTitle;   // 菜单标题
    NSString *_stateStr;    // 设备状态
    UIColor *_stateColor;   // 设备状态颜色
    
    YQInDoorPointMapView *indoorView;
    UIImageView *_selectImageView;
    BOOL isOpen;
    UIView *bottomView;
    
    CRSearchBar *searchBar;
    UITableView *tabView;
    NSMutableArray *_failtArr;
    NSMutableArray *_nameArr;
    NSMutableArray *_dataArr;
    
    InDoorMonitorMapModel *_currentModel;
    BOOL _isShowMenu;
    NSMutableDictionary *_statusDic;
    
    BOOL _isOnline;
}

@property (strong,nonatomic) YQSecondHeaderView *headerView;
@property (nonatomic,strong) NSMutableArray *cameraDataArr;
@property (nonatomic,strong) NSMutableArray *graphData;
@property (nonatomic,strong) NSIndexPath *selectedIndex;

@end

@implementation InDoorMonitorViewController

-(NSMutableArray *)cameraDataArr
{
    if (_cameraDataArr == nil) {
        _cameraDataArr = [NSMutableArray array];
    }
    return _cameraDataArr;
}

-(NSMutableArray *)graphData
{
    if (_graphData == nil) {
        _graphData = [NSMutableArray array];
    }
    return _graphData;
}

-(YQSecondHeaderView *)headerView
{
    if (_headerView == nil) {
        _headerView = [[YQSecondHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 85)];
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
    
    isOpen = YES;
    
    _failtArr = @[].mutableCopy;
    _nameArr = @[].mutableCopy;
    
    _statusDic = @{}.mutableCopy;
    [_statusDic setObject:@"0" forKey:@"areaStatus"];
    
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    
    //初始化子视图
    [self _initView];
    [self _initheaderView];
    [self _initTableView];
    [self _initPointMapView];
    
    [self _loadFloorEquipmentData:[NSString stringWithFormat:@"%@",_floorModel.LAYER_ID]];
}

-(void)_initheaderView
{
    [self.view addSubview:self.headerView];
    
}

-(void)_initTableView
{
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_headerView.frame), KScreenWidth, KScreenHeight-kTopHeight-CGRectGetMaxY(_headerView.frame))];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    tabView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tabView.frame = CGRectMake(0, 0, KScreenWidth, bottomView.height);
    tabView.delegate = self;
    tabView.dataSource = self;
    tabView.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    [tabView registerNib:[UINib nibWithNibName:@"MonitorTableViewCell" bundle:nil] forCellReuseIdentifier:@"MonitorTableViewCell"];
    tabView.hidden = YES;
    tabView.enablePlaceHolderView = YES;
    tabView.yh_PlaceHolderView = [self makePlaceHolderView];
    [bottomView addSubview:tabView];
}

-(void)_loadFloorEquipmentData:(NSString *)layerId
{
    [self showHudInView:self.view hint:@""];
    NSString *urlStr = [NSString stringWithFormat:@"%@/camera/getInCameraList?layerId=%@",Main_Url,layerId];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            
            NSDictionary *dataDic = responseObject[@"responseData"];
//            _headerView.leftNumLab.text = [NSString stringWithFormat:@"%@",dataDic[@"okCameraCount"]];
//            _headerView.centerNumLab.text = [NSString stringWithFormat:@"%@",dataDic[@"outCameraCount"]];
//            _headerView.rightNumLab.text = [NSString stringWithFormat:@"%@",dataDic[@"errorCameraCount"]];

            _headerView.openNumLab.text = [NSString stringWithFormat:@"%@",dataDic[@"okCameraCount"]];
            _headerView.brokenNumLab.text = [NSString stringWithFormat:@"%@",dataDic[@"errorCameraCount"]];
            
            NSArray *arr = dataDic[@"cameraList"];
            if (self.graphData.count != 0) {
                [self.graphData removeAllObjects];
            }
            if (self.cameraDataArr.count != 0) {
                [self.cameraDataArr removeAllObjects];
            }
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                InDoorMonitorMapModel *model = [[InDoorMonitorMapModel alloc] initWithDataDic:arr[idx]];
                
//                if (idx == 1||idx == 2) {
//                    model.CAMERA_STATUS = @"0";
//                }
//                NSString *graphStr = [NSString stringWithFormat:@"%@,%@,%@",model.LAYER_A,model.LAYER_B,model.LAYER_C];
                NSString *graphStr = [NSString stringWithFormat:@"%@,%@",model.LONGITUDE, model.LATITUDE];
                [self.graphData addObject:graphStr];
                [self.cameraDataArr addObject:model];
            }];
            indoorView.graphData = _graphData;
            indoorView.cameraModelArr = _cameraDataArr;
        }
        
        _dataArr = [NSMutableArray arrayWithArray:self.cameraDataArr];
        
        [tabView reloadData];
    } failure:^(NSError *error) {
        [self hideHud];
    }];
}

-(void)_initView
{
    
    _showMenuView = [[ShowMenuView alloc] init];
    _showMenuView.menuDelegate = self;
    _showMenuView.hidden = YES;
    [[UIApplication sharedApplication].delegate.window addSubview:_showMenuView];
    
}

-(void)_initPointMapView
{
    indoorView = [[YQInDoorPointMapView alloc]initWithIndoorMapImageName:[NSString stringWithFormat:@"%@",_floorModel.LAYER_MAP] Frame:CGRectMake(0, 0, self.view.frame.size.width, bottomView.height)];
    indoorView.selInMapDelegate = self;
    [bottomView addSubview:indoorView];
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
    return self.cameraDataArr.count;
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
    cell.indoorModel = self.cameraDataArr[indexPath.row];
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
    if(indexPath.row < self.cameraDataArr.count){
        [indexPaths addObject:indexPath];
    }
    //判断选中不同row状态时候
    //    if (self.selectedIndex != nil && indexPath.row != selectedIndex.row) {
    if (self.selectedIndex != nil && indexPath.row == _selectedIndex.row) {
        //将选中的和所有索引都加进数组中
        //        indexPaths = [NSArray arrayWithObjects:indexPath,selectedIndex, nil];
        isOpen = !isOpen;
        
    }else if (self.selectedIndex != nil && indexPath.row != _selectedIndex.row) {
        if(_selectedIndex.row < self.cameraDataArr.count){
            [indexPaths addObject:_selectedIndex];
        }
        isOpen = YES;
    }
    //记下选中的索引
    self.selectedIndex = indexPath;
    //刷新
    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

-(void)segmentedControlTapped:(id)sender
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [MonitorLogin selectNodeWithChanneId:_currentModel.TAGID];
        
        [self forceOrientationPortrait];
        
        PlayVideoViewController *playVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"PlayVideoViewController"];
        playVC.selChannelId = _currentModel.TAGID;
        playVC.deviceType = _currentModel.DEVICE_TYPE;
        [self.navigationController pushViewController:playVC animated:YES];
         
    }else if(index == 2) {
        if(_currentModel.TAGID == nil || [_currentModel.TAGID isKindOfClass:[NSNull class]]){
            [self showHint:@"相机无参数"];
            return;
        }
        #warning 大华SDK旧版本
//        [DHDataCenter sharedInstance].channelID = _currentModel.TAGID;
        [MonitorLogin selectNodeWithChanneId:_currentModel.TAGID];
        
        [self forceOrientationPortrait];
        
        PlaybackViewController *playVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"PlaybackViewController"];
        playVC.selChannelId = _currentModel.TAGID;
        [self.navigationController pushViewController:playVC animated:YES];

    }
}

- (void)selInMapWithId:(NSString *)identity {
    
    NSInteger selectIndex = [identity integerValue]-100;
    if(self.cameraDataArr.count <= selectIndex){
        return;
    }
    InDoorMonitorMapModel *model = self.cameraDataArr[selectIndex];
    _currentModel = model;
    
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
    
    
    _showMenuView.hidden = NO;
    /*
    if([model.CAMERA_STATUS isEqualToString:@"1"]){
        // 正常
        _stateStr = @"正常开启中";
        _stateColor = [UIColor colorWithHexString:@"#189517"];
    }else if([model.CAMERA_STATUS isEqualToString:@"0"]){
        // 故障
        _stateStr = @"设备故障";
        _stateColor = [UIColor colorWithHexString:@"#FF4359"];
    }if([model.CAMERA_STATUS isEqualToString:@"2"]){
        // 离线
        _stateStr = @"离线";
        _stateColor = [UIColor grayColor];
    }
     */
    
    _menuTitle = model.DEVICE_NAME;
    
    [_showMenuView reloadMenuData]; //  刷新菜单
    
    if (_selectImageView) {
        _selectImageView.contentMode = UIViewContentModeScaleToFill;
        NSInteger selIndex = _selectImageView.tag-100;
        if(self.cameraDataArr.count <= selIndex){
            return;
        }
        InDoorMonitorMapModel *selectModel = self.cameraDataArr[_selectImageView.tag-100];
        
        if ([selectModel.CAMERA_STATUS isEqualToString:@"1"]||[selectModel.CAMERA_STATUS isEqualToString:@"2"]) {
            if ([selectModel.DEVICE_TYPE isEqualToString:@"1-1"]) {
                _selectImageView.image = [UIImage imageNamed:@"map_gunshot_icon_normal"];
            }else if ([selectModel.DEVICE_TYPE isEqualToString:@"1-2"])
            {
                _selectImageView.image = [UIImage imageNamed:@"map_ball_icon_normal"];
            }else{
                _selectImageView.image = [UIImage imageNamed:@"map_halfball_icon_normal"];
            }
        }else{
            if ([selectModel.DEVICE_TYPE isEqualToString:@"1-1"]) {
                _selectImageView.image = [UIImage imageNamed:@"map_gunshot_icon_error"];
            }else if ([selectModel.DEVICE_TYPE isEqualToString:@"1-2"])
            {
                _selectImageView.image = [UIImage imageNamed:@"map_ball_icon_error"];
            }else{
                _selectImageView.image = [UIImage imageNamed:@"map_halfball_icon_error"];
            }
        }
    }
    
    // 复原之前选中图片效果
    if(_selectImageView != nil){
        [PointViewSelect recoverSelImgView:_selectImageView];
    }
    
    UIImageView *imageView = [indoorView.mapView viewWithTag:[identity integerValue]];
    if ([model.CAMERA_STATUS isEqualToString:@"1"]||[model.CAMERA_STATUS isEqualToString:@"2"]) {
        if ([model.DEVICE_TYPE isEqualToString:@"1-1"]) {
            imageView.image = [UIImage imageNamed:@"map_gunshot_icon_normal"];
        }else if ([model.DEVICE_TYPE isEqualToString:@"1-2"])
        {
            imageView.image = [UIImage imageNamed:@"map_ball_icon_normal"];
        }else{
            imageView.image = [UIImage imageNamed:@"map_halfball_icon_normal"];
        }
    }else {
        if ([model.DEVICE_TYPE isEqualToString:@"1-1"]) {
            imageView.image = [UIImage imageNamed:@"map_gunshot_icon_error"];
        }else if ([model.DEVICE_TYPE isEqualToString:@"1-2"])
        {
            imageView.image = [UIImage imageNamed:@"map_ball_icon_error"];
        }else{
            imageView.image = [UIImage imageNamed:@"map_halfball_icon_error"];
        }
    }
    imageView.contentMode = UIViewContentModeScaleToFill;
    _selectImageView = imageView;
    
    [PointViewSelect pointImageSelect:_selectImageView];
}

#pragma mark 室内点位图与列表的切换
-(void)rightBtnAction:(NSNotification *)notification
{
    [UIView animateWithDuration:0.5 animations:^{
        if (tabView.hidden) {
            tabView.hidden = NO;
            indoorView.hidden = YES;
            [tabView reloadData];
            [_statusDic setObject:@"1" forKey:@"areaStatus"];
        }else{
            tabView.hidden = YES;
            indoorView.hidden = NO;
            [_statusDic setObject:@"0" forKey:@"areaStatus"];
        }
    }];
}

#pragma mark uisearchBar delegate

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [_nameArr removeAllObjects];
    
    [_dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        InDoorMonitorMapModel *model = (InDoorMonitorMapModel *)obj;
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
    
    [self.cameraDataArr removeAllObjects];
    if (searchBar.text.length == 0) {
        [self.cameraDataArr addObjectsFromArray:_dataArr];
    }else{
        [self.cameraDataArr addObjectsFromArray:_failtArr];
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
    
    [self.cameraDataArr removeAllObjects];
    if (searchText.length == 0) {
        [self.cameraDataArr addObjectsFromArray:_dataArr];
    }else{
        [self.cameraDataArr addObjectsFromArray:_failtArr];
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
            
            [self.cameraDataArr removeAllObjects];
            [self.cameraDataArr addObjectsFromArray:_dataArr];
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

#pragma mark 强制变为竖屏
- (void)forceOrientationPortrait {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.allowRotate = NO;
    [delegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
    
    //设置屏幕的转向为竖屏
    [[UIDevice currentDevice] setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
    //刷新
    [UIViewController attemptRotationToDeviceOrientation];
}

@end
