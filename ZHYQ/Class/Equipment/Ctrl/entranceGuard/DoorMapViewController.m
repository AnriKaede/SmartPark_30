//
//  DoorMapViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/28.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "DoorMapViewController.h"

#import "ShowMenuView.h"
#import "YQHeaderView.h"

#import "YQInDoorPointMapView.h"

#import "DoorModel.h"
#import "EntranceCell.h"

#import "CRSearchBar.h"

#import "NoDataView.h"
#import <UITableView+PlaceHolderView.h>

#import "AuthorityViewController.h"
#import "RecordViewController.h"

#define scal 0.3

@interface DoorMapViewController ()<UIScrollViewDelegate, MenuControlDelegate,DidSelInMapPopDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate, EntranceDelegate>
{
    
    // 弹窗
    ShowMenuView *_showMenuView;
    NSString *_menuTitle;   // 菜单标题
    NSString *_stateStr;    // 设备状态
    UIColor *_stateColor;   // 设备状态颜色
    
    YQInDoorPointMapView *indoorView;
    UIImageView *_selectImageView;
    UIView *bottomView;
//    BOOL isOpen;
    
    CRSearchBar *searchBar;
    UITableView *tabView;
    NSMutableArray *_failtArr;
    NSMutableArray *_nameArr;
    NSMutableArray *_dataArr;
    
    NSMutableDictionary *_statusDic;
    
    NSInteger _currentSelectIndex;
    
    DoorModel *_selDoorModel;
}

//@property (strong,nonatomic) YQHeaderView *headerView;
@property (nonatomic,strong) NSMutableArray *wifiDataArr;
@property (nonatomic,strong) NSMutableArray *graphData;
@property (nonatomic,strong) NSIndexPath * selectedIndex;

@end


@implementation DoorMapViewController

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
    }else{
        // 屏幕从横屏变为竖屏时执行
        NSLog(@"屏幕从横屏变为竖屏时执行");
        bottomView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight - 20);
        tabView.frame = CGRectMake(0, 0, KScreenWidth, bottomView.height);
        indoorView.frame = CGRectMake(0, 0, KScreenWidth, bottomView.height);
        _showMenuView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
        [_showMenuView reloadMenuData];
    }
}

//-------

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

/*
-(YQHeaderView *)headerView
{
    if (_headerView == nil) {
        _headerView = [[YQHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 85)];
        _headerView.backgroundColor = [UIColor colorWithHexString:@"1B82D1"];
    }
    return _headerView;
}
 */

-(void)setFloorModel:(FloorModel *)floorModel
{
    _floorModel = floorModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNavItems];
    
    //初始化子视图
    [self _initView];
//    [self _initMsgBgView];
    [self _initTableView];
    [self _initPointMapView];
    
    _failtArr = @[].mutableCopy;
    _nameArr = @[].mutableCopy;
    
    _statusDic = @{}.mutableCopy;
    [_statusDic setObject:@"0" forKey:@"areaStatus"];
    
//    isOpen = YES;
    _currentSelectIndex = 0;
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    
    [self _loadFloorEquipmentData:[NSString stringWithFormat:@"%@",_floorModel.LAYER_ID]];
}

/*
-(void)_initMsgBgView
{
    [self.view addSubview:self.headerView];
}
 */

-(void)_initPointMapView
{
    // 门禁地下车库用特定图片
    if(_floorModel.LAYER_NUM != nil && [_floorModel.LAYER_NUM isEqualToString:@"-1"]){
        indoorView = [[YQInDoorPointMapView alloc]initWithIndoorMapImageName:[NSString stringWithFormat:@"doorPark"] Frame:CGRectMake(0, 0, KScreenWidth, bottomView.height)];
    }else {
        indoorView = [[YQInDoorPointMapView alloc]initWithIndoorMapImageName:[NSString stringWithFormat:@"%@",_floorModel.LAYER_MAP] Frame:CGRectMake(0, 0, KScreenWidth, bottomView.height)];
    }
    indoorView.selInMapDelegate = self;
    [bottomView addSubview:indoorView];
}

-(void)_initTableView
{
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    tabView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tabView.frame = CGRectMake(0, 0, KScreenWidth, bottomView.height);
    //    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    tabView.delegate = self;
    tabView.dataSource = self;
    tabView.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    [tabView registerNib:[UINib nibWithNibName:@"EntranceCell" bundle:nil] forCellReuseIdentifier:@"EntranceCell"];
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

#pragma mark tableview 协议
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 49;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
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

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.wifiDataArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EntranceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EntranceCell" forIndexPath:indexPath];
    cell.model = self.wifiDataArr[indexPath.row];
    cell.entranceDelegate = self;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DoorModel *doorModel = self.wifiDataArr[indexPath.row];
    if(doorModel.isSpread){
        if([doorModel.DEVICE_TYPE isEqualToString:@"4-1"]){
            return 290;
        }else {
            return 226;
        }
    }else{
        return 60;
    }
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [searchBar resignFirstResponder];
    
    NSMutableArray *indexPaths = @[].mutableCopy;
    if(indexPath.row < self.wifiDataArr.count){
        [indexPaths addObject:indexPath];
    }
    //判断选中不同row状态时候
    //    if (self.selectedIndex != nil && indexPath.row != selectedIndex.row) {
    if (self.selectedIndex != nil && indexPath.row == _selectedIndex.row) {
        //将选中的和所有索引都加进数组中
        //        indexPaths = [NSArray arrayWithObjects:indexPath,selectedIndex, nil];
//        isOpen = !isOpen;
        
    }else if (self.selectedIndex != nil && indexPath.row != _selectedIndex.row) {
        if(_selectedIndex.row < self.wifiDataArr.count){
            [indexPaths addObject:_selectedIndex];
        }
//        isOpen = YES;
    }
    //记下选中的索引
    self.selectedIndex = indexPath;
    //刷新
//    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
    DoorModel *model = self.wifiDataArr[indexPath.row];
    if(_selDoorModel != nil){
        NSInteger index = [self.wifiDataArr indexOfObject:_selDoorModel];
        if(_selDoorModel == model){
            _selDoorModel.isSpread = !_selDoorModel.isSpread;
        }else {
            _selDoorModel.isSpread = NO;
            model.isSpread = YES;
        }
        
        _selDoorModel = model;
        [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:indexPath.section], indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }else {
        _selDoorModel = model;
        model.isSpread = YES;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark 请求点位数据
-(void)_loadFloorEquipmentData:(NSString *)layerId
{
    [self showHudInView:self.view hint:@""];
    NSString *urlStr = [NSString stringWithFormat:@"%@/visitor/getInDoorGuardList?layerId=%@",Main_Url,layerId];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        if (responseObject[@"code"] != nil && ![responseObject[@"code"] isKindOfClass:[NSNull class]] && [responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *dataDic = responseObject[@"responseData"];
            /*
            _headerView.leftNumLab.text = [NSString stringWithFormat:@"%@",dataDic[@"okDoorCount"]];
            _headerView.centerNumLab.text = [NSString stringWithFormat:@"%@",dataDic[@"outDoorCount"]];
            _headerView.rightNumLab.text = [NSString stringWithFormat:@"%@",dataDic[@"errorDoorCount"]];
             */
            NSArray *arr = dataDic[@"DoorList"];
            if (self.graphData.count != 0) {
                [self.graphData removeAllObjects];
            }
            if (self.wifiDataArr.count != 0) {
                [self.wifiDataArr removeAllObjects];
            }
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DoorModel *model = [[DoorModel alloc] initWithDataDic:obj];
                NSString *graphStr = [NSString stringWithFormat:@"%@,%@",model.LONGITUDE, model.LATITUDE];
                [self.graphData addObject:graphStr];
                [self.wifiDataArr addObject:model];
            }];
            indoorView.graphData = _graphData;
            indoorView.doorModelArr = _wifiDataArr;
            
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
        return 75;
    }else if(index == 1 && _selDoorModel && [_selDoorModel.DEVICE_TYPE isEqualToString:@"4-1"]){
        return 70;
    }else{
        return 40;
    }
}

- (NSInteger)menuNumInView {
    if(_selDoorModel && [_selDoorModel.DEVICE_TYPE isEqualToString:@"4-1"]){
        return 4;
    }else {
        return 3;
    }
}

- (NSString *)menuTitle:(NSInteger)index {
    switch (index) {
        case 0:
            if(_selDoorModel && [_selDoorModel.DEVICE_TYPE isEqualToString:@"4-1"]){
                if([_selDoorModel.TAGID isEqualToString:@"344"] || [_selDoorModel.TAGID isEqualToString:@"346"]){
                    return @"自东向西进闸机门";
                }else {
                    return @"进闸机门";
                }
            }else {
                return _stateStr;
            }
            break;
        case 1:
            if(_selDoorModel && [_selDoorModel.DEVICE_TYPE isEqualToString:@"4-1"]){
                if([_selDoorModel.TAGID isEqualToString:@"344"] || [_selDoorModel.TAGID isEqualToString:@"346"]){
                    return @"自西向东出闸机门";
                }else {
                    return @"出闸机门";
                }
            }else {
                return @"权限卡";
            }
            break;
        case 2:
            if(_selDoorModel && [_selDoorModel.DEVICE_TYPE isEqualToString:@"4-1"]){
                return @"权限卡";
            }else {
                return @"开门记录";
            }
            break;
        case 3:
            if(_selDoorModel && [_selDoorModel.DEVICE_TYPE isEqualToString:@"4-1"]){
                return @"开门记录";
            }else {
                return @"";
            }
            break;
            
        default:
            return @"";
            break;
    }
}

- (UIColor *)menuTitleColor:(NSInteger)index {
    if(index == 0){
        if(_selDoorModel && [_selDoorModel.DEVICE_TYPE isEqualToString:@"4-1"]){
            return [UIColor blackColor];
        }else {
            return _stateColor;
        }
    }else {
        return [UIColor blackColor];
    }
}

- (NSString *)menuTitleViewText {
    return _menuTitle;
}

- (ShowMenuStyle)menuViewStyle:(NSInteger)index {
    return ImgConMenu;
}

- (NSString *)imageName:(NSInteger)index {
    if(index == 0){
        return @"_jingai_lock_in";
    }else if(index == 1 && _selDoorModel && [_selDoorModel.DEVICE_TYPE isEqualToString:@"4-1"]) {
        return @"_jingai_lock_in";
    }else {
        return @"door_list_right_narrow";
    }
}

- (CGSize)imageSize:(NSInteger)index {
    switch (index) {
        case 0:
            return CGSizeMake(60, 60);
            break;
            
        case 1:
            if(_selDoorModel && [_selDoorModel.DEVICE_TYPE isEqualToString:@"4-1"]) {
                return CGSizeMake(60, 60);
            }else {
                return CGSizeMake(20, 20);
            }
            break;
            
        default:
            return CGSizeMake(20, 20);
            break;
    }
}
- (void)didSelectMenu:(NSInteger)index {
    switch (index) {
        case 0:
            {
                // 开门禁，地图点位点击不需要二次确认
                [self confinOpen:_selDoorModel withOperate:@"2"];
            }
            break;
            
        case 1:
        {
            if(_selDoorModel && [_selDoorModel.DEVICE_TYPE isEqualToString:@"4-1"]) {
                [self confinOpen:_selDoorModel withOperate:@"1"];
            }else {
                // 权限卡
                [self viewAuthorityList:_selDoorModel];
            }
        }
            break;
            
        case 2:
        {
            if(_selDoorModel && [_selDoorModel.DEVICE_TYPE isEqualToString:@"4-1"]) {
                [self viewAuthorityList:_selDoorModel];
            }else {
                // 开门记录
                [self openRecord:_selDoorModel];
            }
            break;
        }
            
        case 3:
        {
            if(_selDoorModel && [_selDoorModel.DEVICE_TYPE isEqualToString:@"4-1"]) {
                [self openRecord:_selDoorModel];
            }else {
                // 无操作 3列
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)selInMapWithId:(NSString *)identity {
    _showMenuView.hidden = NO;
    
    NSInteger selectIndex = [identity integerValue]-100;
    if(self.wifiDataArr.count <= selectIndex){
        return;
    }
    DoorModel *model = self.wifiDataArr[selectIndex];
    
    _selDoorModel = model;
    
    if([model.DOOR_STATUS isEqualToString:@"1"]){
        // 正常
        _stateStr = @"房间锁门中";
        _stateColor = [UIColor colorWithHexString:@"#189517"];
    }else if([model.DOOR_STATUS isEqualToString:@"0"]){
        // 故障
        _stateStr = @"门禁故障";
        _stateColor = [UIColor colorWithHexString:@"#FF4359"];
    }if([model.DOOR_STATUS isEqualToString:@"2"]){
        // 离线
        _stateStr = @"房间开门中";
        _stateColor = [UIColor grayColor];
    }
    
    _menuTitle = model.DEVICE_NAME;
    
    [_showMenuView reloadMenuData]; //  刷新菜单
    
    if (_selectImageView) {
        DoorModel *selectModel = self.wifiDataArr[_selectImageView.tag-100];
        _selectImageView.contentMode = UIViewContentModeScaleToFill;
        // 闸机使用透明图片
        if ([selectModel.DEVICE_TYPE isEqualToString:@"4-1"]) {
        }else {
            if ([selectModel.DOOR_STATUS isEqualToString:@"1"]||[selectModel.DOOR_STATUS isEqualToString:@"2"]) {
                _selectImageView.image = [UIImage imageNamed:@"map_door_normal"];
            }else{
                _selectImageView.image = [UIImage imageNamed:@"map_door_error"];
            }
        }
    }
    
    // 复原之前选中图片效果
    if(_selectImageView != nil){
        // 闸机使用透明图片
        if ([model.DEVICE_TYPE isEqualToString:@"4-1"]) {
        }else {
            [PointViewSelect recoverSelImgView:_selectImageView];
        }
    }
    
    // 闸机使用透明图片
    if ([model.DEVICE_TYPE isEqualToString:@"4-1"]) {
    }else {
        UIImageView *imageView = [indoorView.mapView viewWithTag:[identity integerValue]];
        if ([model.DOOR_STATUS isEqualToString:@"1"]||[model.DOOR_STATUS isEqualToString:@"2"]) {
            imageView.image = [UIImage imageNamed:@"map_door_normal"];
        }else {
            imageView.image = [UIImage imageNamed:@"map_door_error"];
        }
        imageView.contentMode = UIViewContentModeScaleToFill;
        _selectImageView = imageView;
        
        [PointViewSelect pointImageSelect:_selectImageView];
    }
}

#pragma mark uisearchBar delegate

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [_nameArr removeAllObjects];
    
    [_dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DoorModel *model = (DoorModel *)obj;
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

#pragma mark Cell 点击协议
- (void)unLockDoor:(DoorModel *)doorModel withOperate:(NSString *)operate {
    UIAlertControllerStyle alertControllerStyle;
    if(KScreenWidth > 440){
        // ipad
        alertControllerStyle = UIAlertControllerStyleAlert;
    }else {
        alertControllerStyle = UIAlertControllerStyleActionSheet;
    }
    
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"是否开门" message:@"" preferredStyle:alertControllerStyle];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *open = [UIAlertAction actionWithTitle:@"开门" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self confinOpen:doorModel withOperate:operate];
    }];
    [alertCon addAction:cancel];
    [alertCon addAction:open];
    
    [self presentViewController:alertCon animated:YES completion:nil];
}
- (void)confinOpen:(DoorModel *)doorModel withOperate:(NSString *)operate {
    /*
    NSString *urlStr = [NSString stringWithFormat:@"%@/visitor/openDoor",Main_Url];
    NSMutableDictionary *param =@{}.mutableCopy;
    if([doorModel.DEVICE_TYPE isEqualToString:@"4-1"]){
        // 闸机, 进 1  出 2
//        进 出反向
//         东向电梯正门西一  332
//         东向电梯正门西三  336
//         东向电梯右侧南三  342
        
        [param setObject:operate forKey:@"doorDeviceId"];
        if(doorModel.TAGID != nil && ![doorModel.TAGID isKindOfClass:[NSNull class]]){
            if([doorModel.TAGID isEqualToString:@"332"] ||
               [doorModel.TAGID isEqualToString:@"336"] ||
               [doorModel.TAGID isEqualToString:@"342"]){
                operate = [operate isEqualToString:@"1"] ? @"2" : @"1";
                [param setObject:operate forKey:@"doorDeviceId"];
            }
        }
    }else {
        if(doorModel.LAYER_C != nil && ![doorModel.LAYER_C isKindOfClass:[NSNull class]]){
            [param setObject:doorModel.LAYER_C forKey:@"doorDeviceId"];
        }
    }
    if(doorModel.TAGID != nil && ![doorModel.TAGID isKindOfClass:[NSNull class]]){
        [param setObject:doorModel.TAGID forKey:@"tagId"];
    }
    if(doorModel.LAYER_A != nil && ![doorModel.LAYER_A isKindOfClass:[NSNull class]]){
        [param setObject:doorModel.LAYER_A forKey:@"param1"];
    }
    [param setObject:@"5768" forKey:@"param2"];
    if(doorModel.LAYER_B != nil && ![doorModel.LAYER_B isKindOfClass:[NSNull class]]){
        [param setObject:doorModel.LAYER_B forKey:@"param3"];
    }
    [param setObject:@"admin" forKey:@"appType"];
    [param setObject:[[NSUserDefaults standardUserDefaults] objectForKey:KLoginUserName] forKey:@"osUser"];
    [param setObject:@"admin" forKey:@"number"];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        DLog(@"%@",responseObject);
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            [self showHint:responseObject[@"message"]];
            // 成功
            // 记录日志
            [self logRecordTagId:doorModel.TAGID withDoorName:doorModel.DEVICE_NAME];
        }else {
            NSString *message = responseObject[@"message"];
            if(message != nil && ![message isKindOfClass:[NSNull class]]){
                [self showHint:message];
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
     */
    
    NSString *inOutFlag = @"0"; //非必传,闸机进门传2 出传1  其他类型门禁传0(默认)
    if([doorModel.DEVICE_TYPE isEqualToString:@"4-1"]){
        inOutFlag = operate;
    }
    if([doorModel.TAGID isEqualToString:@"332"] ||
       [doorModel.TAGID isEqualToString:@"336"] ||
       [doorModel.TAGID isEqualToString:@"342"]){
        inOutFlag = [operate isEqualToString:@"1"] ? @"2" : @"1";
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/visitor/openDoor?deviceId=%@&inOutFlag=%@",Main_Url, doorModel.DEVICE_ID, inOutFlag];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        DLog(@"%@",responseObject);
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            [self showHint:responseObject[@"message"]];
            // 成功
            // 记录日志
            [self logRecordTagId:doorModel.TAGID withDoorName:doorModel.DEVICE_NAME];
        }else {
            NSString *message = responseObject[@"message"];
            if(message != nil && ![message isKindOfClass:[NSNull class]]){
                [self showHint:message];
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark 记录日志
- (void)logRecordTagId:(NSString *)tagId withDoorName:(NSString *)doorName {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:[NSString stringWithFormat:@"远程开门%@", doorName] forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:[NSString stringWithFormat:@"远程开门%@", doorName] forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"visitor/openDoor" forKey:@"operateUrl"];//操作url
    [logDic setObject:doorName forKey:@"operateLocation"];//操作地点
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:tagId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"门禁" forKey:@"operateDeviceName"];//操作设备名  模块
    //    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

#pragma mark 权限卡
- (void)viewAuthorityList:(DoorModel *)doorModel {
    [self forceOrientationPortrait];
    
    AuthorityViewController *authorityVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"AuthorityViewController"];
    authorityVC.deivedID = doorModel.TAGID;
    authorityVC.doorName = doorModel.DEVICE_NAME;
    [self.navigationController pushViewController:authorityVC animated:YES];
    NSLog(@"%@", [self.navigationController class]);
}


#pragma mark 开门记录
- (void)openRecord:(DoorModel *)doorModel {
    [self forceOrientationPortrait];
    
    RecordViewController * openRecVC = [[RecordViewController alloc] init];
    openRecVC.tagID = doorModel.TAGID;
    openRecVC.deivedID = doorModel.DEVICE_ID;
    openRecVC.doorName = doorModel.DEVICE_NAME;
    [self.navigationController pushViewController:openRecVC animated:YES];
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
