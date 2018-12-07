//
//  StreetMapViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/4.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "StreetMapViewController.h"
#import "ShowMenuView.h"
#import "YQSecondHeaderView.h"

#import "YQInDoorPointMapView.h"

#import "MonitorTableViewCell.h"

#import "CRSearchBar.h"
#import "NoDataView.h"
#import <UITableView+PlaceHolderView.h>

#import "DHDataCenter.h"
#import "PlayVideoViewController.h"
#import "PlaybackViewController.h"

#import "StreetLightModel.h"
#import "LightGroupCell.h"

#import "StreetLightPointViewController.h"
#import "StreLigAllConViewController.h"

@interface StreetMapViewController ()<UIScrollViewDelegate,DidSelInMapPopDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
{
    YQInDoorPointMapView *indoorView;
    UIImageView *_selectImageView;
    UIImageView *_selectBottomImageView;
    BOOL isOpen;
    UIView *bottomView;
    
    CRSearchBar *searchBar;
    UITableView *tabView;
    NSMutableArray *_failtArr;
    NSMutableArray *_nameArr;
    NSMutableArray *_dataArr;
    
    StreetLightModel *_currentModel;
    BOOL _isShowMenu;
    NSMutableDictionary *_statusDic;
    
    BOOL _isOnline;
    
    UIView *_bottomView;
}

@property (strong,nonatomic) YQSecondHeaderView *headerView;
@property (nonatomic,strong) NSMutableArray *cameraDataArr;
@property (nonatomic,strong) NSMutableArray *graphData;
@property (nonatomic,strong) NSIndexPath *selectedIndex;

@end

@implementation StreetMapViewController

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
//        _bottomView.frame = 
        _headerView.hidden = YES;
    }else{
        // 屏幕从横屏变为竖屏时执行
        NSLog(@"屏幕从横屏变为竖屏时执行");
        bottomView.frame = CGRectMake(0, _headerView.bottom, KScreenWidth, KScreenHeight - kTopHeight - 20 - _headerView.bottom);
        tabView.frame = CGRectMake(0, 0, KScreenWidth, bottomView.height);
        indoorView.frame = CGRectMake(0, 0, KScreenWidth, bottomView.height);
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
    [self _initheaderView];
    [self _initTableView];
    [self _initPointMapView];
    
    [self _createBottomView];
    
    [self _loadFloorEquipmentData];
}

-(void)_initheaderView
{
    self.headerView.openLab.text = @"在线";
    self.headerView.brokenLab.text = @"离线";
    [self.view addSubview:self.headerView];
    
}
- (void)_createBottomView {
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, KScreenHeight - kTopHeight - 60, KScreenWidth, 60)];
    _bottomView.hidden = YES;
    _bottomView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:_bottomView];
    
    NSString *leftTitle = @"";
    leftTitle = @"取消";
    UIButton *bottomLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    bottomLeftButton.tag = 2001;
    bottomLeftButton.frame = CGRectMake((KScreenWidth - 267)/2, 10, 267, 40);
    bottomLeftButton.layer.cornerRadius = 20;
    bottomLeftButton.backgroundColor = CNavBgColor;
    [bottomLeftButton setTitle:@"批量开关" forState:UIControlStateNormal];
    [bottomLeftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bottomLeftButton addTarget:self action:@selector(bottomLeftAction) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:bottomLeftButton];
}
- (void)bottomLeftAction {
    StreLigAllConViewController *allConVC = [[StreLigAllConViewController alloc] init];
    [self.navigationController pushViewController:allConVC animated:YES];
}

-(void)_initTableView
{
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_headerView.frame), KScreenWidth, KScreenHeight-kTopHeight-CGRectGetMaxY(_headerView.frame))];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    tabView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tabView.frame = CGRectMake(0, 0, KScreenWidth, bottomView.height);
    tabView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
    tabView.delegate = self;
    tabView.dataSource = self;
    tabView.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    [tabView registerNib:[UINib nibWithNibName:@"LightGroupCell" bundle:nil] forCellReuseIdentifier:@"LightGroupCell"];
    tabView.hidden = YES;
    tabView.enablePlaceHolderView = YES;
    tabView.yh_PlaceHolderView = [self makePlaceHolderView];
    [bottomView addSubview:tabView];
}

-(void)_loadFloorEquipmentData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/roadLamp/info/",Main_Url];
    [self showHudInView:self.view hint:@""];
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *dic = responseObject[@"responseData"];
            NSNumber *onNum = dic[@"on"];
            NSNumber *offNum = dic[@"off"];
            _headerView.openNumLab.text = [NSString stringWithFormat:@"%ld",onNum.integerValue + offNum.integerValue];
            _headerView.brokenNumLab.text = [NSString stringWithFormat:@"%@",dic[@"fault"]];
            
            if (self.graphData.count != 0) {
                [self.graphData removeAllObjects];
            }
            if (self.cameraDataArr.count != 0) {
                [self.cameraDataArr removeAllObjects];
            }
            NSArray *arr = dic[@"items"];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                StreetLightModel *model = [[StreetLightModel alloc] initWithDataDic:obj];
                
                NSString *graphStr = [NSString stringWithFormat:@"%@,%@",model.LONGITUDE, model.LATITUDE];
                [self.graphData addObject:graphStr];
                [self.cameraDataArr addObject:model];
            }];
            indoorView.graphData = _graphData;
            indoorView.streetLightMapArr = _cameraDataArr;
        }
        
        _dataArr = [NSMutableArray arrayWithArray:self.cameraDataArr];
        
        [tabView reloadData];
    } failure:^(NSError *error) {
        [self hideHud];
    }];
}

-(void)_initPointMapView {
    // 地图
    indoorView = [[YQInDoorPointMapView alloc]initWithIndoorMapImageName:[NSString stringWithFormat:@"%@",@"smart_park_bg"] Frame:CGRectMake(0, 0, self.view.frame.size.width, bottomView.height)];
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
    LightGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LightGroupCell" forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    StreetLightModel *model = self.cameraDataArr[indexPath.row];
    cell.nameLabel.text = model.DEVICE_NAME;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    if (indexPath.row == _selectedIndex.row && _selectedIndex != nil ) {
        if (isOpen == YES) {
            return 180;
        }else{
            return 60;
        }
    }
     */
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self forceOrientationPortrait];
    
    [searchBar resignFirstResponder];
    
    /*
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
     //刷新
     [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
     */
    //记下选中的索引
    self.selectedIndex = indexPath;
    
    StreetLightModel *model = self.cameraDataArr[indexPath.row];
    
    [self presentPointVC:model];
}
- (void)presentPointVC:(StreetLightModel *)model {
    // 到路灯挂载子设备页面
    // 跳转点位图
    StreetLightPointViewController *streetVC = [[StreetLightPointViewController alloc] init];
    streetVC.model = model;
    //    [self.navigationController pushViewController:streetVC animated:YES];
    streetVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    streetVC.isHidenNaviBar = YES;
    streetVC.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    
    RootNavigationController *navVC = [[RootNavigationController alloc] initWithRootViewController:streetVC];
    
    navVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    [self presentViewController:navVC animated:YES completion:^{
    }];
}

-(void)segmentedControlTapped:(id)sender
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)selInMapWithId:(NSString *)identity {
    
    NSInteger selectIndex = [identity integerValue]-100;
    if(self.cameraDataArr.count <= selectIndex){
        return;
    }
    StreetLightModel *model = self.cameraDataArr[selectIndex];
    _currentModel = model;
    
    // 复原之前选中图片效果
    if(_selectImageView != nil && _selectBottomImageView != nil){
        [PointViewSelect recoverSelImgView:_selectImageView];
        [PointViewSelect recoverSelImgView:_selectBottomImageView];
        StreetLightModel *selectModel = self.cameraDataArr[_selectImageView.tag-100];
        _selectImageView.contentMode = UIViewContentModeScaleToFill;
        // 区分莲花灯和路灯
        if ([selectModel.DEVICE_TYPE isEqualToString:@"55-2"]) {
            _selectImageView.image = [UIImage imageNamed:@"street_lamp_map_flower"];
            _selectBottomImageView.image = [UIImage imageNamed:@"street_lamp_light_01"];
        }else {
            _selectImageView.image = [UIImage imageNamed:@"street_lamp_map_nor"];
            _selectBottomImageView.image = [UIImage imageNamed:@"street_lamp_light_01"];
        }
    }
    
    UIImageView *imageView = [indoorView.mapView viewWithTag:[identity integerValue]];
    UIImageView *bottomImageView = [indoorView.mapView viewWithTag:[identity integerValue]+100];
    // 区分莲花灯和路灯
    if ([model.DEVICE_TYPE isEqualToString:@"55-2"]) {
        imageView.image = [UIImage imageNamed:@"street_lamp_map_flower"];
        bottomImageView.image = [UIImage imageNamed:@"street_lamp_light_sel_01"];
    }else {
        imageView.image = [UIImage imageNamed:@"street_lamp_map_nor"];
        bottomImageView.image = [UIImage imageNamed:@"street_lamp_light_sel_01"];
    }
    imageView.contentMode = UIViewContentModeScaleToFill;
    _selectImageView = imageView;
    _selectBottomImageView = bottomImageView;
    
    [PointViewSelect pointImageSelect:_selectImageView];
    [PointViewSelect pointImageSelect:_selectBottomImageView];
    
    [self presentPointVC:model];
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
            _bottomView.hidden = NO;
        }else{
            tabView.hidden = YES;
            indoorView.hidden = NO;
            [_statusDic setObject:@"0" forKey:@"areaStatus"];
            _bottomView.hidden = YES;
        }
    }];
}

#pragma mark uisearchBar delegate

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [_nameArr removeAllObjects];
    
    [_dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        StreetLightModel *model = (StreetLightModel *)obj;
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
    
//    self.title = @"智能路灯";
    
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
            _bottomView.hidden = NO;
            [tabView reloadData];
            [btn setImage:[UIImage imageNamed:@"slideMenu"] forState:UIControlStateNormal];
        }else{
            [searchBar resignFirstResponder];
            [_statusDic setObject:@"0" forKey:@"areaStatus"];
            tabView.hidden = YES;
            indoorView.hidden = NO;
            _bottomView.hidden = YES;
            [btn setImage:[UIImage imageNamed:@"switchmap"] forState:UIControlStateNormal];
            
            [self.cameraDataArr removeAllObjects];
            [self.cameraDataArr addObjectsFromArray:_dataArr];
        }
    }];
}

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
