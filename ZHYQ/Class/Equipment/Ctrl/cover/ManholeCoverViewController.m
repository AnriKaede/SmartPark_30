//
//  ManholeCoverViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/6.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ManholeCoverViewController.h"
#import "YQSecondHeaderView.h"

//#import "NewCoverModel.h"
#import "NewCoverModel.h"

#import "YQPointAnnotation.h"
#import "WifiAnnotationView.h"
#import "ShowMenuView.h"

//#import "ManholeListViewController.h"
#import "ManholeListTableViewCell.h"

#import "CRSearchBar.h"
#import "NoDataView.h"
#import <UITableView+PlaceHolderView.h>

@interface ManholeCoverViewController ()<MAMapViewDelegate,MenuControlDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate, UnLockDelegate>
{
    BOOL _hasCurrLoc;
    // 弹窗
    ShowMenuView *_showMenuView;
    
    //弹窗标题
    NSString *_title;
    //开启关闭图片名称
    NSString *_imageName;
    //井盖状态
    NSString *_holeStatusStr;
    //井盖地点
    NSString *_holeAreaStr;
    //井盖编号
    NSString *_holeNum;
    
//    当前选择的标注index
    NSInteger _selectIndex;
    
    BOOL isOpen;
    CRSearchBar *searchBar;
    UITableView *tabView;
    NSMutableArray *_failtArr;
    NSMutableArray *_nameArr;
    NSMutableArray *_failtDataArr;
    
    CLLocationCoordinate2D _coordinate;
}

@property (nonatomic,strong) MAMapView *mapView;
@property (nonatomic,strong) YQSecondHeaderView *headerView;
@property (nonatomic,retain) NSMutableArray *coordinatesArr;
@property (nonatomic,retain) NSMutableArray *dataArr;
@property (nonatomic, strong)NSIndexPath * selectedIndex;

@end

@implementation ManholeCoverViewController

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

-(NSMutableArray *)dataArr
{
    if (_dataArr == nil) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
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
    // Do any additional setup after loading the view
    
    isOpen = YES;
    
    _failtArr = @[].mutableCopy;
    _nameArr = @[].mutableCopy;
    
    [self _initNavItems];
    
    [self _initMapView];
    
    [self _initView];
    
    [self _loadData];
}

-(void)_loadData
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/manhole/allCovers",Main_Url];
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
//        DLog(@"%@",responseObject);
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *dataDic = responseObject[@"responseData"];
            
            NSArray *dataArr1 = dataDic[@"items"];
            [dataArr1 enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NewCoverModel *model = [[NewCoverModel alloc] initWithDataDic:obj];
                YQPointAnnotation *a1 = [[YQPointAnnotation alloc] init];
                if (model.IS_ALARM != nil && ![model.IS_ALARM isKindOfClass:[NSNull class]] && [model.IS_ALARM isEqualToString:@"1"]) {
                    a1.status = @"0";
                }else{
                    a1.status = @"1";
                }
//                a1.status = model.man;
                a1.number = [NSString stringWithFormat:@"%ld",idx];
                a1.coordinate = CLLocationCoordinate2DMake([model.LATITUDE doubleValue],[model.LONGITUDE doubleValue]);
                [self.coordinatesArr addObject:a1];
                [self.dataArr addObject:model];
            }];
            
            [_mapView addAnnotations:self.coordinatesArr];
            
            _headerView.openLab.text = @"正常";
            _headerView.openNumLab.text = [NSString stringWithFormat:@"%@",dataDic[@"nomal_count"]];
            _headerView.brokenLab.text = @"故障";
            _headerView.brokenNumLab.text = [NSString stringWithFormat:@"%@",dataDic[@"unnomal_count"]];
            
        }
        
        _failtDataArr = [NSMutableArray arrayWithArray:self.dataArr];
        
        [tabView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

-(void)_initNavItems
{
//    self.title = @"井盖";
    
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
    [rightBtn setImage:[UIImage imageNamed:@"switchmap"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"slideMenu"] forState:UIControlStateSelected];
    [rightBtn addTarget:self action:@selector(_rightBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)_initView
{
    [self.view addSubview:self.headerView];
    
    _showMenuView = [[ShowMenuView alloc] init];
    _showMenuView.menuDelegate = self;
    _showMenuView.hidden = YES;
    [[UIApplication sharedApplication].delegate.window addSubview:_showMenuView];
    
    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    locationButton.frame = CGRectMake(KScreenWidth - 50, KScreenHeight - 64 - 50, 40, 40);
    locationButton.backgroundColor = [UIColor clearColor];
    [locationButton setBackgroundImage:[UIImage imageNamed:@"current_location"] forState:UIControlStateNormal];
    [locationButton addTarget:self action:@selector(currentLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:locationButton];
    
    tabView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tabView.delegate = self;
    tabView.dataSource = self;
    tabView.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    [tabView registerNib:[UINib nibWithNibName:@"ManholeListTableViewCell" bundle:nil] forCellReuseIdentifier:@"ManholeListTableViewCell"];
    tabView.frame = CGRectMake(0, CGRectGetMaxY(_headerView.frame), KScreenWidth, KScreenHeight-CGRectGetMaxY(_headerView.frame)-64);
    tabView.hidden = YES;
    tabView.enablePlaceHolderView = YES;
    tabView.yh_PlaceHolderView = [self makePlaceHolderView];
    [self.view addSubview:tabView];

}

- (void)currentLocation {
    [_mapView setCenterCoordinate:_coordinate animated:YES];
}

#pragma mark MenuControlDelegate
- (CGFloat)menuHeightInView:(NSInteger)index {
    switch (index) {
        case 0:
            return 50;
            break;
        case 1:
            return 50;
            break;
        case 2:
            return 50;
            break;
        default:
            return 100;
            break;
    }
}

- (NSInteger)menuNumInView {
    return 4;
}

- (NSString *)menuTitle:(NSInteger)index {
    switch (index) {
        case 0:
            return @"井盖状态";
            break;
        case 1:
            return @"井盖地点";
            break;
        case 2:
            return @"井盖编号";
            break;
        default:
            return @"井盖开锁";
            break;
    }
}

- (UIColor *)menuTitleColor:(NSInteger)index {
    switch (index) {
        case 0:
            return [UIColor blackColor];
            break;
        case 1:
            return [UIColor blackColor];
            break;
        case 2:
            return [UIColor blackColor];
            break;
        default:
            return [UIColor colorWithHexString:@"FF4359"];
            break;
    }
}

- (NSString *)menuTitleViewText {
    return _title;
}

- (ShowMenuStyle)menuViewStyle:(NSInteger)index {
    switch (index) {
        case 0:
            return DefaultConMenu;
            break;
        case 1:
            return DefaultConMenu;
            break;
        case 2:
            return DefaultConMenu;
            break;
        default:
            return ImgConMenu;
            break;
    }
}

- (NSString *)menuMessage:(NSInteger)index {
    switch (index) {
        case 0:
            return _holeStatusStr;
            break;
        case 1:
            return _holeAreaStr;
            break;
        case 2:
            return _holeNum;
            break;
        default:
            return @"";
            break;
    }

}

- (NSString *)imageName:(NSInteger)index {
    switch (index) {
        case 0:
            return @"";
            break;
        case 1:
            return @"";
            break;
        case 2:
            return @"";
            break;
        default:
            return _imageName;
            break;
    }
}

-(void)closeMenu
{
    YQPointAnnotation *anntion = self.coordinatesArr[_selectIndex];
    [self.mapView deselectAnnotation:anntion animated:YES];
}

-(void)didSelectMenu:(NSInteger)index
{
    
    NewCoverModel *coverModel = (NewCoverModel *)self.dataArr[_selectIndex];
    if(coverModel.DEVICE_TYPE != nil && ![coverModel.DEVICE_TYPE isKindOfClass:[NSNull class]] && [coverModel.DEVICE_TYPE isEqualToString:@"30-1"]){
        // 30-1 可开锁 需要coverid
        NSString *urlStr = [NSString stringWithFormat:@"%@/manhole/covers/%@/commands?command=%@",Main_Url,coverModel.platItem.iot_cover,@"unlock"];
        
        [[NetworkClient sharedInstance] POST:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
            DLog(@"%@",responseObject);
            if ([responseObject[@"code"] isEqualToString:@"1"]) {
                // 成功
                // 记录日志
                [self logRecordTagId:[NSString stringWithFormat:@"%@", coverModel.platItem.iot_cover]];
            }
        } failure:^(NSError *error) {
            
        }];
    }
    
}

-(void)_initMapView
{
    [self.view addSubview:self.mapView];
}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 切换列表界面
-(void)_rightBarBtnItemClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    
    [searchBar resignFirstResponder];
//    ManholeListViewController *holeListVC = [[ManholeListViewController alloc] init];
//    holeListVC.dataArr = self.dataArr;
//    [self.navigationController pushViewController:holeListVC animated:YES];
    [UIView animateWithDuration:0.5 animations:^{
        if (_mapView.hidden) {
            _mapView.hidden = NO;
            tabView.hidden = YES;
            
            [self.dataArr removeAllObjects];
            [self.dataArr addObjectsFromArray:_failtDataArr];
            
            [tabView reloadData];
        }else
        {
            _mapView.hidden = YES;
            tabView.hidden = NO;
            
            [tabView reloadData];
        }
    }];
}

-(void)handleSwitchEvent:(id)sender
{
    
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
            annotationView.image = [UIImage imageNamed:@"map_holecover_error"];//设置大头针图片
        }else if ([ddAnnotation.status isEqualToString:@"1"])
        {
            annotationView.image = [UIImage imageNamed:@"map_holecover_normal"];//设置大头针图片
        }else{
            annotationView.image = [UIImage imageNamed:@"map_holecover_normal"];//设置大头针图片
        }
        
        annotationView.centerOffset = CGPointMake(0, -0.5*ddAnnotation.image.size.height);
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    YQPointAnnotation *anntion = (YQPointAnnotation *)view.annotation;
    if ([anntion isKindOfClass:[YQPointAnnotation class]])
    {
        NSInteger selectIndex = [anntion.number integerValue];
        _showMenuView.hidden = NO;
        NewCoverModel *model = (NewCoverModel *)self.dataArr[selectIndex];
        
        NewCoverInfoModel *model1 = (NewCoverInfoModel *)model.platItem;
        if (!model1.is_open.boolValue) {
            _holeStatusStr = @"上锁";
            if(model.DEVICE_TYPE != nil && ![model.DEVICE_TYPE isKindOfClass:[NSNull class]] && [model.DEVICE_TYPE isEqualToString:@"30-1"]){
                _imageName = @"_jingai_lock_in";
            }else {
                _imageName = @"cover_lock_unabel";
            }
        }else {
            _holeStatusStr = @"未上锁";
            if(model.DEVICE_TYPE != nil && ![model.DEVICE_TYPE isKindOfClass:[NSNull class]] && [model.DEVICE_TYPE isEqualToString:@"30-1"]){
                _imageName = @"_jingai_lock_off";
            }else {
                _imageName = @"cover_lock_unabel";
            }
        }
        
        _title = [NSString stringWithFormat:@"%@", model.DEVICE_NAME];
        _holeAreaStr = [NSString stringWithFormat:@"%@",model.DEVICE_ADDR];
        _holeNum = [NSString stringWithFormat:@"%@",model1.iot_cover];
        
        [_showMenuView reloadMenuData];
        if ([anntion.status isEqualToString:@"0"]) {
            view.image = [UIImage imageNamed:@"map_holecover_error"];
        }else {
            view.image = [UIImage imageNamed:@"map_holecover_normal"];
        }
        [PointViewSelect pointImageSelect:view];
        
        _selectIndex = [anntion.number integerValue];
    }
}

-(void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view
{
    YQPointAnnotation *anntion = (YQPointAnnotation *)view.annotation;
    if ([anntion isKindOfClass:[YQPointAnnotation class]])
    {
        if ([anntion.status isEqualToString:@"1"]) {
            view.image = [UIImage imageNamed:@"map_holecover_normal"];
        }else{
            view.image = [UIImage imageNamed:@"map_holecover_error"];
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
    return self.dataArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ManholeListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ManholeListTableViewCell" forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.row == _selectedIndex.row && _selectedIndex != nil) {
        //如果是展开
        if (isOpen == YES) {
            //xxxxxx
            NSLog(@"new cell");
            cell.contentView.backgroundColor = [UIColor colorWithHexString:@"F8FCFF"];
            cell.selectView.hidden = NO;
            cell.holeLocationLab.hidden = NO;
            cell.holeAreaLab.hidden = NO;
            cell.holeLockLab.hidden = NO;
            cell.lockBtn.hidden = NO;
            cell.holeNumLab.hidden = NO;
            cell.holeNumDetailLab.hidden = NO;
            
        }else{
            //收起
            NSLog(@"old cell");
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.selectView.hidden = YES;
            cell.holeLocationLab.hidden = YES;
            cell.holeAreaLab.hidden = YES;
            cell.holeLockLab.hidden = YES;
            cell.lockBtn.hidden = YES;
            cell.holeNumLab.hidden = YES;
            cell.holeNumDetailLab.hidden = YES;
        }
        //不是自身
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.selectView.hidden = YES;
        cell.holeLocationLab.hidden = YES;
        cell.holeAreaLab.hidden = YES;
        cell.holeLockLab.hidden = YES;
        cell.lockBtn.hidden = YES;
        cell.holeNumLab.hidden = YES;
        cell.holeNumDetailLab.hidden = YES;
    }
    
    cell.model = self.dataArr[indexPath.row];
    cell.unlockDelegate = self;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _selectedIndex.row && _selectedIndex != nil ) {
        if (isOpen == YES) {
            return 210;
        }else{
            return 60;
        }
    }
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [searchBar resignFirstResponder];
    
    NSMutableArray *indexPaths = @[].mutableCopy;
    if(indexPath.row < self.dataArr.count){
        [indexPaths addObject:indexPath];
    }
    //判断选中不同row状态时候
    //    if (self.selectedIndex != nil && indexPath.row != selectedIndex.row) {
    if (self.selectedIndex != nil && indexPath.row == _selectedIndex.row) {
        //将选中的和所有索引都加进数组中
        //        indexPaths = [NSArray arrayWithObjects:indexPath,selectedIndex, nil];
        isOpen = !isOpen;
        
    }else if (self.selectedIndex != nil && indexPath.row != _selectedIndex.row) {
        if(_selectedIndex.row < self.dataArr.count){
            [indexPaths addObject:_selectedIndex];
        }
        isOpen = YES;
        
    }
    //记下选中的索引
    self.selectedIndex = indexPath;
    //刷新
    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark cell点击解锁
- (void)unLockCover:(NewCoverModel *)model {
    if(model.DEVICE_TYPE != nil && ![model.DEVICE_TYPE isKindOfClass:[NSNull class]] && [model.DEVICE_TYPE isEqualToString:@"30-1"]){
        NSString *urlStr = [NSString stringWithFormat:@"%@/manhole/covers/%@/commands?command=%@",Main_Url,model.platItem.iot_cover,@"unlock"];
        
        [[NetworkClient sharedInstance] POST:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
            DLog(@"%@",responseObject);
            if ([responseObject[@"code"] isEqualToString:@"1"]) {
                // 成功
                // 记录日志
                [self logRecordTagId:[NSString stringWithFormat:@"%@", model.platItem.iot_cover]];
            }
        } failure:^(NSError *error) {
            
        }];
    }else {
//        [self showHint:@"此设备"];
    }
}

#pragma mark uisearchBar delegate

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [_nameArr removeAllObjects];
    
    [_failtDataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NewCoverModel *model = (NewCoverModel *)obj;
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
            [_failtArr addObject:_failtDataArr[idx]];
        }
    }];
    
    [self.dataArr removeAllObjects];
    if (searchBar.text.length == 0) {
        [self.dataArr addObjectsFromArray:_failtDataArr];
    }else{
        [self.dataArr addObjectsFromArray:_failtArr];
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
            [_failtArr addObject:_failtDataArr[idx]];
        }
    }];
    
    [self.dataArr removeAllObjects];
    if (searchText.length == 0) {
        [self.dataArr addObjectsFromArray:_failtDataArr];
    }else{
        [self.dataArr addObjectsFromArray:_failtArr];
    }
    
    [tabView reloadData];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDateView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 49, KScreenWidth, tabView.height-49)];
    noDateView.label.text = @"无结果";
    return noDateView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark 记录日志
- (void)logRecordTagId:(NSString *)tagId {
    NewCoverModel *model;
    if(_mapView.hidden && self.selectedIndex != nil){
        model = (NewCoverModel *)self.dataArr[self.selectedIndex.row];
    }else {
        model = (NewCoverModel *)self.dataArr[_selectIndex];
    }
    NSString *opreateStr = [NSString stringWithFormat:@"井盖\"%@\"开锁", model.DEVICE_NAME];
    
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:opreateStr forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:opreateStr forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"manhole/covers" forKey:@"operateUrl"];//操作url
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:tagId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"智能井盖" forKey:@"operateDeviceName"];//操作设备名  模块
//    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

@end
