//
//  AirConditionViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "AirConditionViewController.h"
#import "YQHeaderView.h"
#import "AirConditionCollViewCell.h"
#import "TimeSetTableViewController.h"
#import "NoDataView.h"
#import "CRSearchBar.h"
#import "YQInDoorPointMapView.h"
#import "AirConditionModel.h"
#import <UITableView+PlaceHolderView.h>
#import "AirConTableViewCell.h"

#import "AirMenuView.h"

#import "MeetRoomStateModel.h"

typedef enum {
    AirSwitch = 0,
    AirModel,
    AirWindSpeed,
    AirTemp
}AirOperate;

@interface AirConditionViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,DidSelInMapPopDelegate,UISearchBarDelegate, AirMenuDelegate, AirCellSwitchDelegate>
{
    YQInDoorPointMapView *indoorView;
    UIView *bottomView;
    NSMutableArray *mapArr;
    UIImageView *_selectImageView;
    
    AirConditionModel *_selectModel;
    
    BOOL _isShowMenu;
    UIButton *rightBtn;
    CRSearchBar *searchBar;
    UITableView *tabView;
    BOOL isOpen;
    
    NSMutableArray *_failtArr;
    NSMutableArray *_nameArr;
    NSMutableArray *_dataArr;
    
    AirMenuView *_airMenuView;
}

@property (strong, nonatomic) YQHeaderView *headerView;
@property (nonatomic, strong) UICollectionView *mainCollectionView;
@property (nonatomic,strong) NSIndexPath * selectedIndex;
@property (nonatomic,strong) NSMutableArray *pointMapDataArr;
@property (nonatomic,strong) NSMutableArray *graphData;

@end

@implementation AirConditionViewController

-(NSMutableArray *)pointMapDataArr
{
    if (_pointMapDataArr == nil) {
    _pointMapDataArr = [NSMutableArray array];
}
    return _pointMapDataArr;
}

-(NSMutableArray *)graphData
{
    if (_graphData == nil) {
        _graphData = [NSMutableArray array];
    }
    return _graphData;
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
        _airMenuView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
        [_airMenuView reloadMenu];
        _headerView.hidden = YES;
        // 请求点位状态数据
        if(_selectModel != nil && _selectModel.TAGID != nil){
            [self loadAirStateData:_selectModel.TAGID withBlock:^(BOOL success) {
            }];
        }
    }else{
        // 屏幕从横屏变为竖屏时执行
        NSLog(@"屏幕从横屏变为竖屏时执行");
        bottomView.frame = CGRectMake(0, _headerView.bottom, KScreenWidth, KScreenHeight - kTopHeight - 20 - _headerView.bottom);
        tabView.frame = CGRectMake(0, 0, KScreenWidth, bottomView.height);
        indoorView.frame = CGRectMake(0, 0, KScreenWidth, bottomView.height);
        _airMenuView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
        [_airMenuView reloadMenu];
        _headerView.hidden = NO;
        // 请求点位状态数据
        if(_selectModel != nil && _selectModel.TAGID != nil){
            [self loadAirStateData:_selectModel.TAGID withBlock:^(BOOL success) {
            }];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isOpen = YES;
    
    _failtArr = @[].mutableCopy;
    _nameArr = @[].mutableCopy;
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    
    //初始化子视图
    [self _initNavItems];
    
    [self _initView];
    
    [self _initTableView];
    
    [self _loadPointMapData:[NSString stringWithFormat:@"%@",_floorModel.LAYER_ID]];
}

-(void)_initTableView
{
    tabView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tabView.frame = CGRectMake(0, 0, KScreenWidth, bottomView.height);
    tabView.delegate = self;
    tabView.dataSource = self;
    tabView.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    [tabView registerNib:[UINib nibWithNibName:@"AirConTableViewCell" bundle:nil] forCellReuseIdentifier:@"AirConTableViewCell"];
    tabView.hidden = YES;
    tabView.showsVerticalScrollIndicator = NO;
    tabView.showsHorizontalScrollIndicator = NO;
    tabView.enablePlaceHolderView = YES;
    tabView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tabView.yh_PlaceHolderView = [self makePlaceHolderView];
    [bottomView addSubview:tabView];
}

#pragma mark 加载空调点位图数据
-(void)_loadPointMapData:(NSString *)layerId
{
    [self showHudInView:self.view hint:@""];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/equipment/getEquipmentList?deviceType=6&layerId=%@",Main_Url,layerId];
    NSLog(@"空调--- %@", urlStr);
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        [self.graphData removeAllObjects];
        [self.pointMapDataArr removeAllObjects];
        
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *dic = responseObject[@"responseData"];
            NSArray *arr = dic[@"equipmentList"];
            
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                AirConditionModel *model = [[AirConditionModel alloc] initWithDataDic:obj];
                NSString *graphStr = [NSString stringWithFormat:@"%@,%@",model.LONGITUDE, model.LATITUDE];
                [self.graphData addObject:graphStr];
                [self.pointMapDataArr addObject:model];
            }];
            
            [self _loadCountData];
        }
        
        [tabView reloadData];
    } failure:^(NSError *error) {
        [self hideHud];
        NSLog(@"空调错误 %@", error);
    }];
}

#pragma mark 加载空调顶部统计数据
- (void)_loadCountData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/airConditioner/layerStatus",Main_Url];
    
    NSDictionary *paramDic = @{@"layerId":_floorModel.LAYER_ID};
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *dic = responseObject[@"responseData"];
            _headerView.leftNumLab.text = [NSString stringWithFormat:@"%@",dic[@"openCount"]];
            _headerView.centerNumLab.text = [NSString stringWithFormat:@"%@",dic[@"closeCount"]];
            _headerView.rightNumLab.text = [NSString stringWithFormat:@"%@",dic[@"errorCount"]];
            
            NSArray *deviceList = dic[@"deviceList"];
            [self dealCountData:deviceList];
        }
    } failure:^(NSError *error) {
    }];
}
- (void)dealCountData:(NSArray *)deviceList {
    NSMutableDictionary *deviceDic = @{}.mutableCopy;
    [deviceList enumerateObjectsUsingBlock:^(NSDictionary *objDic, NSUInteger idx, BOOL * _Nonnull stop) {
        if(objDic[@"DEVICE_ID"] != nil && objDic[@"VALUE"]){
            [deviceDic setObject:objDic[@"VALUE"] forKey:objDic[@"DEVICE_ID"]];
        }
    }];
    
    [self.pointMapDataArr enumerateObjectsUsingBlock:^(AirConditionModel *airModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if([deviceDic containsObjectForKey:airModel.DEVICE_ID]){
            NSString *value = deviceDic[airModel.DEVICE_ID];    // 1开 2关
            if(airModel.stateModel == nil){
                airModel.stateModel = [[MeetRoomStateModel alloc] init];
            }
            if([value isEqualToString:@"1"]){
                airModel.stateModel.value = @"1";
            }else {
                airModel.stateModel.value = @"0";
            }
        }
    }];
    
    indoorView.graphData = self.graphData;
    indoorView.airConArr = self.pointMapDataArr;
    
    _dataArr = [NSMutableArray arrayWithArray:self.pointMapDataArr];
}

-(void)_initView
{
    // 创建点击菜单视图
    _airMenuView = [[AirMenuView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    _airMenuView.hidden = YES;
    _airMenuView.airMenuDelegate = self;
    [[UIApplication sharedApplication].delegate.window addSubview:_airMenuView];
    
    _headerView = [[YQHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 85)];
    _headerView.backgroundColor = [UIColor colorWithHexString:@"1B82D1"];
    [self.view addSubview:_headerView];
    UITapGestureRecognizer *hidKeybTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidKeyB)];
    _headerView.userInteractionEnabled = YES;
    [_headerView addGestureRecognizer:hidKeybTap];
    
    [self _initPointMapView:[NSString stringWithFormat:@"%@",_floorModel.LAYER_MAP]];
}
- (void)hidKeyB {
    [self.view endEditing:YES];
}

-(void)_initPointMapView:(NSString *)layerMap
{
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 85, KScreenWidth, KScreenHeight-kTopHeight-85)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    indoorView = [[YQInDoorPointMapView alloc]initWithIndoorMapImageName:layerMap Frame:CGRectMake(0, 0, KScreenWidth, bottomView.height)];
    indoorView.selInMapDelegate = self;
    [bottomView addSubview:indoorView];
}

-(void)_initNavItems
{
    self.title = _floorModel.LAYER_NAME;
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    rightBtn = [[UIButton alloc] init];
    rightBtn.frame = CGRectMake(0, 0, 40, 40);
    rightBtn.selected = NO;
    [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];

    [rightBtn setImage:[UIImage imageNamed:@"slideMenu"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"switchmap"] forState:UIControlStateSelected];
    rightBtn.selected = YES;

    [rightBtn addTarget:self action:@selector(_rightBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

#pragma mark tableview delegate and datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _pointMapDataArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AirConTableViewCell *cell = [tabView dequeueReusableCellWithIdentifier:@"AirConTableViewCell" forIndexPath:indexPath];
    AirConditionModel *model = _pointMapDataArr[indexPath.row];
//    if(self.selectedIndex != nil && self.selectedIndex.row == indexPath.row){
//        cell.stateDic = _stateDic;
//    }
    cell.model = model;
    cell.switchDelegate = self;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AirConditionModel *model = self.pointMapDataArr[indexPath.row];
    if(model.isSeparate){
        if(model.stateModel.value != nil && ![model.stateModel.value isKindOfClass:[NSNull class]] && ![model.stateModel.value isEqualToString:@"0"]){
            if((model.modelModel.actionType != nil && ![model.modelModel.actionType isKindOfClass:[NSNull class]] && [model.modelModel.actionType isEqualToString:@"1"]) ||
               (model.tempModel.actionType != nil && ![model.tempModel.actionType isKindOfClass:[NSNull class]] && [model.tempModel.actionType isEqualToString:@"1"]) ||
               (model.windModel.actionType != nil && ![model.windModel.actionType isKindOfClass:[NSNull class]] && [model.windModel.actionType isEqualToString:@"1"])){
                // 有操作权限
                return 285;
            }else {
                // 无操作权限
                return 175;
            }
        }else {
            return 135;
        }
    }else{
        return 60;
    }
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
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 48.5, KScreenWidth, 0.5)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    [headerView addSubview:lineView];
    
    return headerView;
}

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [searchBar resignFirstResponder];
    
    NSMutableArray *indexPaths = @[].mutableCopy;
    if(indexPath.row < self.pointMapDataArr.count){
        [indexPaths addObject:indexPath];
    }
    //判断选中不同row状态时候
    if (self.selectedIndex != nil && indexPath.row == _selectedIndex.row) {
        //将选中的和所有索引都加进数组中
    }else if (self.selectedIndex != nil && indexPath.row != _selectedIndex.row) {
        if(_selectedIndex.row < self.pointMapDataArr.count){
            [indexPaths addObject:_selectedIndex];
        }
    }
    //记下选中的索引
    self.selectedIndex = indexPath;
    //刷新
    //    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
    AirConditionModel *model = self.pointMapDataArr[indexPath.row];
    if(_selectModel != nil){
        NSInteger index = [self.pointMapDataArr indexOfObject:_selectModel];
        if(_selectModel == model){
            _selectModel.isSeparate = !_selectModel.isSeparate;
        }else {
            _selectModel.isSeparate = NO;
            model.isSeparate = YES;
        }
        
        _selectModel = model;
        [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:indexPath.section], indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }else {
        _selectModel = model;
        model.isSeparate = YES;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    // 根据选中请求空调状态
    [self loadAirStateData:model.DEVICE_ID withBlock:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        });
    }];
}
#pragma mark 加载空调状态数据
- (void)loadAirStateData:(NSString *)deviceId withBlock:(void (^)(BOOL success))block{
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/airConditioner/deviceStatus",Main_Url];
    
    NSDictionary *paramDic = @{@"deviceId":deviceId};
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *responseData = responseObject[@"responseData"];
            NSDictionary *infos = responseData[@"infos"];
            // 处理数据赋值给选中model
            [self dealModelData:infos];
            // 成功
            if(tabView.hidden){
                NSArray *devices = responseData[@"devices"];
                NSMutableArray *titles = @[].mutableCopy;
                [devices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    AirConditionModel *model = [[AirConditionModel alloc] initWithDataDic:obj];
                    [titles addObject:model];
                }];
                
                _airMenuView.deviceId = deviceId;
                _airMenuView.devices = titles;
                _airMenuView.airConditionModel = _selectModel;
            }else {
                block(YES);
            }
        }else {
            NSString *message = responseObject[@"message"];
            if(message != nil && ![message isKindOfClass:[NSNull class]]){
                [self showHint:message];
            }
        }
    } failure:^(NSError *error) {
        [self showHint:KRequestFailMsg];
    }];
    
}
// 处理状态数据
- (void)dealModelData:(NSDictionary *)stateDic {
    NSDictionary *AIRSTATUS = stateDic[@"AIRSTATUS"];
    if(AIRSTATUS != nil && ![AIRSTATUS isKindOfClass:[NSNull class]]){
        // 开关状态
        MeetRoomStateModel *stateModel = [[MeetRoomStateModel alloc] initWithDataDic:AIRSTATUS];
        _selectModel.stateModel = stateModel;
    }
    
    NSDictionary *WINDSPEED = stateDic[@"WINDSPEED"];
    if(WINDSPEED != nil && ![WINDSPEED isKindOfClass:[NSNull class]]){
        // 风速
        MeetRoomStateModel *stateModel = [[MeetRoomStateModel alloc] initWithDataDic:WINDSPEED];
        _selectModel.windModel = stateModel;
    }
    
    NSDictionary *WORKMODE = stateDic[@"WORKMODE"];
    if(WORKMODE != nil && ![WORKMODE isKindOfClass:[NSNull class]]){
        // 模式
        MeetRoomStateModel *stateModel = [[MeetRoomStateModel alloc] initWithDataDic:WORKMODE];
        _selectModel.modelModel = stateModel;
    }
    
    NSDictionary *TEMPERATUR = stateDic[@"TEMPERATUR"];
    if(TEMPERATUR != nil && ![TEMPERATUR isKindOfClass:[NSNull class]]){
        // 温度
        MeetRoomStateModel *stateModel = [[MeetRoomStateModel alloc] initWithDataDic:TEMPERATUR];
        _selectModel.tempModel = stateModel;
    }
    
    NSDictionary *FAILURE = stateDic[@"FAILURE"];
    if(FAILURE != nil && ![FAILURE isKindOfClass:[NSNull class]]){
        // 是否故障
        MeetRoomStateModel *stateModel = [[MeetRoomStateModel alloc] initWithDataDic:FAILURE];
        _selectModel.failureModel = stateModel;
    }
}

#pragma mark uisearchBar delegate

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [_nameArr removeAllObjects];
    
    [_dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AirConditionModel *model = (AirConditionModel *)obj;
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
    
    [self.pointMapDataArr removeAllObjects];
    if (searchBar.text.length == 0) {
        [self.pointMapDataArr addObjectsFromArray:_dataArr];
    }else{
        [self.pointMapDataArr addObjectsFromArray:_failtArr];
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
    
    [self.pointMapDataArr removeAllObjects];
    if (searchText.length == 0) {
        [self.pointMapDataArr addObjectsFromArray:_dataArr];
    }else{
        [self.pointMapDataArr addObjectsFromArray:_failtArr];
    }
    
    [tabView reloadData];
}



-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark AirMenuDelegate/AirCellSwitchDelegate 菜单协议
#pragma mark 切换选择空调
- (void)cutAirControl:(AirConditionModel *)model {
    NSLog(@"%@", model.DEVICE_NAME);
    [self loadAirStateData:model.DEVICE_ID withBlock:^(BOOL success) {
    }];
}
#pragma mark 空调开关协议
- (void)siwtchAir:(NSString *)writeId withDeviceId:(NSString *)deviceId withOn:(BOOL)on withModel:(AirConditionModel *)airModel{
    NSString *operateValue;
    if(on){
        operateValue = @"1";
    }else {
        operateValue = @"0";
    }
    [self modelCutData:writeId withDeviceId:deviceId withTagName:@"AIRSTATUS" withValue:operateValue withAirOperate:AirSwitch withAirModel:airModel];
}
#pragma mark 空调模式切换
- (void)modelCut:(NSString *)writeId withDeviceId:(NSString *)deviceId withModel:(AirConditionModel *)airModel{
    _airMenuView.hidden = YES;
    // 接口可使用上面开关，传值不同
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"请选择空调模式" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if(tabView.hidden){
            _airMenuView.hidden = NO;
        }
    }];
    UIAlertAction *coldAction = [UIAlertAction actionWithTitle:@"制冷模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(tabView.hidden){
            _airMenuView.hidden = NO;
        }
        [self modelCutData:writeId withDeviceId:deviceId withTagName:@"WORKMODE" withValue:@"2" withAirOperate:AirModel withAirModel:airModel];
    }];
    UIAlertAction *hotAction = [UIAlertAction actionWithTitle:@"制热模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(tabView.hidden){
            _airMenuView.hidden = NO;
        }
        [self modelCutData:writeId withDeviceId:deviceId withTagName:@"WORKMODE" withValue:@"1" withAirOperate:AirModel withAirModel:airModel];
    }];
    UIAlertAction *wetAction = [UIAlertAction actionWithTitle:@"除湿模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(tabView.hidden){
            _airMenuView.hidden = NO;
        }
        [self modelCutData:writeId withDeviceId:deviceId withTagName:@"WORKMODE" withValue:@"4" withAirOperate:AirModel withAirModel:airModel];
    }];
    UIAlertAction *windAction = [UIAlertAction actionWithTitle:@"通风模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(tabView.hidden){
            _airMenuView.hidden = NO;
        }
        [self modelCutData:writeId withDeviceId:deviceId withTagName:@"WORKMODE" withValue:@"3" withAirOperate:AirModel withAirModel:airModel];
    }];
    
    [alertCon addAction:coldAction];
    [alertCon addAction:hotAction];
    [alertCon addAction:cancelAction];
    
    [alertCon addAction:wetAction];
    [alertCon addAction:windAction];
    
    if (alertCon.popoverPresentationController != nil) {
        alertCon.popoverPresentationController.sourceView = _headerView;
        alertCon.popoverPresentationController.sourceRect = _headerView.bounds;
    }
    
    [self presentViewController:alertCon animated:YES completion:nil];
}
#pragma mark 温度控制
- (void)tempCut:(NSString *)tepm withWriteId:(NSString *)writeId withDeviceId:(NSString *)deviceId withModel:(AirConditionModel *)airModel{
    if(tepm.integerValue >= AirMinTemp && tepm.integerValue <= AirMaxTemp){
        [self modelCutData:writeId withDeviceId:deviceId withTagName:@"TEMPERATUR" withValue:tepm withAirOperate:AirTemp withAirModel:airModel];
    }else {
        [self showHint:@"超出可控温度"];
    }
}
#pragma mark 风速控制
- (void)speedCut:(NSString *)writeId withDeviceId:(NSString *)deviceId withModel:(AirConditionModel *)airModel{
    _airMenuView.hidden = YES;
    
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"请选择风速" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if(tabView.hidden){
            _airMenuView.hidden = NO;
        }
    }];
    UIAlertAction *lowAction = [UIAlertAction actionWithTitle:@"低风速" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(tabView.hidden){
            _airMenuView.hidden = NO;
        }
        [self modelCutData:writeId withDeviceId:deviceId withTagName:@"WINDSPEED" withValue:@"3" withAirOperate:AirWindSpeed withAirModel:airModel];
    }];
    UIAlertAction *midstAction = [UIAlertAction actionWithTitle:@"中风速" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(tabView.hidden){
            _airMenuView.hidden = NO;
        }
        [self modelCutData:writeId withDeviceId:deviceId withTagName:@"WINDSPEED" withValue:@"2" withAirOperate:AirWindSpeed withAirModel:airModel];
    }];
    UIAlertAction *heightAction = [UIAlertAction actionWithTitle:@"高风速" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(tabView.hidden){
            _airMenuView.hidden = NO;
        }
        [self modelCutData:writeId withDeviceId:deviceId withTagName:@"WINDSPEED" withValue:@"1" withAirOperate:AirWindSpeed withAirModel:airModel];
    }];
    UIAlertAction *autoAction = [UIAlertAction actionWithTitle:@"自动风速" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(tabView.hidden){
            _airMenuView.hidden = NO;
        }
        [self modelCutData:writeId withDeviceId:deviceId withTagName:@"WINDSPEED" withValue:@"0" withAirOperate:AirWindSpeed withAirModel:airModel];
    }];
    [alertCon addAction:cancelAction];
    [alertCon addAction:lowAction];
    [alertCon addAction:midstAction];
    [alertCon addAction:heightAction];
    [alertCon addAction:autoAction];
    
    if (alertCon.popoverPresentationController != nil) {
        alertCon.popoverPresentationController.sourceView = _headerView;
        alertCon.popoverPresentationController.sourceRect = _headerView.bounds;
    }
    
    [self presentViewController:alertCon animated:YES completion:nil];
}
#pragma mark 调用接口设置空调数值
- (void)modelCutData:(NSString *)writeId withDeviceId:(NSString *)deviceId withTagName:(NSString *)tagName withValue:(NSString *)operateValue withAirOperate:(AirOperate)airOperate withAirModel:(AirConditionModel *)airModel{
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/airConditioner/operateConditioner",Main_Url];
    
    NSDictionary *paramDic = @{@"deviceId":deviceId,
                               @"tagId":writeId,
                               @"operateValue":operateValue,
                               @"tagName":tagName
                               };
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [self showHudInView:self.view hint:@""];
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *resDic = responseObject[@"responseData"];
            if(resDic != nil && ![resDic isKindOfClass:[NSNull class]]){
                NSString *result = resDic[@"result"];
                if(result != nil && ![result isKindOfClass:[NSNull class]] && [result isEqualToString:@"success"]){
                    // 开关 刷新开关数量、关变为开，请求状态数据
                    if(airOperate == AirSwitch){
//                        [self _loadCountData];
                        
                        /*
                        if(operateValue.boolValue){
                            // 成功
                            NSInteger index = [_dataArr indexOfObject:_selectModel];
                            // 查询状态
                            [self loadAirStateData:_selectModel.DEVICE_ID withBlock:^(BOOL success) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [tabView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                                });
                            }];
                        }
                         */
                    }
                    // 成功刷新本地数据
                    [self refreshLocationData:operateValue withAirOperate:airOperate withAirModel:airModel];
                    
                    // 记录日志
                    [self opeatreLog:airOperate withOperateValue:operateValue withTagId:deviceId];
                    
                }
            }
        }else {
            NSString *message = responseObject[@"message"];
            [self showHint:message];
            
            NSInteger index = [_dataArr indexOfObject:_selectModel];
            [tabView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }failure:^(NSError *error) {
        [self hideHud];
        [self showHint:KRequestFailMsg];
    }];
}
// 刷新本地数据，解决接口延迟问题
- (void)refreshLocationData:(NSString *)operateValue withAirOperate:(AirOperate)airOperate withAirModel:(AirConditionModel *)airModel {
    switch (airOperate) {
        case AirSwitch:
            {
                airModel.stateModel.value = operateValue;
                // 顶部统计
                if([operateValue isEqualToString:@"0"]){
                    _headerView.leftNumLab.text = [NSString stringWithFormat:@"%ld",_headerView.leftNumLab.text.integerValue - 1];
                    _headerView.centerNumLab.text = [NSString stringWithFormat:@"%ld",_headerView.centerNumLab.text.integerValue + 1];
                }else {
                    _headerView.leftNumLab.text = [NSString stringWithFormat:@"%ld",_headerView.leftNumLab.text.integerValue + 1];
                    _headerView.centerNumLab.text = [NSString stringWithFormat:@"%ld",_headerView.centerNumLab.text.integerValue - 1];
                }
                indoorView.airConArr = self.pointMapDataArr;
                break;
            }
        case AirTemp:
        {
            airModel.tempModel.value = operateValue;
            break;
        }
        case AirModel:
        {
            airModel.modelModel.value = operateValue;
            break;
        }
        case AirWindSpeed:
        {
            airModel.windModel.value = operateValue;
            break;
        }
    }
    
    // tableView
    NSInteger index = [_pointMapDataArr indexOfObject:airModel];
    if(index < _pointMapDataArr.count){
        [tabView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        // AirMenuView
        _airMenuView.airConditionModel = airModel;
        //    [_airMenuView reloadMenu];
    }
}

- (void)opeatreLog:(AirOperate)airOperate withOperateValue:(NSString *)operateValue withTagId:(NSString *)tagId {
    NSString *operate;
    NSString *oldValue = @"";
    NSString *newValue = @"";
    
    switch (airOperate) {
        case AirSwitch:
        {
            if(![operateValue isEqualToString:@"0"]){
                operate = [NSString stringWithFormat:@"开启%@空调", _selectModel.DEVICE_NAME];
            }else {
                operate = [NSString stringWithFormat:@"关闭%@空调", _selectModel.DEVICE_NAME];
            }
            break;
        }
        case AirTemp:
        {
            newValue = operateValue;
            operate = [NSString stringWithFormat:@"%@空调调节温度至%@℃", _selectModel.DEVICE_NAME,operateValue];
            break;
        }
        case AirModel:
        {
            if([operateValue isEqualToString:@"1"]){
                operate = [NSString stringWithFormat:@"%@空调设置制热模式", _selectModel.DEVICE_NAME];
            }else if([operateValue isEqualToString:@"2"]){
                operate = [NSString stringWithFormat:@"%@空调设置制冷模式", _selectModel.DEVICE_NAME];
            }else if([operateValue isEqualToString:@"3"]){
                operate = [NSString stringWithFormat:@"%@空调设置通风模式", _selectModel.DEVICE_NAME];
            }else if([operateValue isEqualToString:@"4"]){
                operate = [NSString stringWithFormat:@"%@空调设置除湿模式", _selectModel.DEVICE_NAME];
            }
            break;
        }
        case AirWindSpeed:
        {
            if([operateValue isEqualToString:@"0"]){
                operate = [NSString stringWithFormat:@"%@空调设置自动风速", _selectModel.DEVICE_NAME];
            }else if([operateValue isEqualToString:@"1"]){
                operate = [NSString stringWithFormat:@"%@空调设置高风速", _selectModel.DEVICE_NAME];
            }else if([operateValue isEqualToString:@"2"]){
                operate = [NSString stringWithFormat:@"%@空调设置中风速", _selectModel.DEVICE_NAME];
            }else if([operateValue isEqualToString:@"3"]){
                operate = [NSString stringWithFormat:@"%@空调设置低风速", _selectModel.DEVICE_NAME];
            }
            break;
        }
            
    }
    
    [self logRecordOperate:operate withTagId:tagId withOldValue:oldValue withNewValue:newValue];
}

#pragma mark 选中点位
- (void)selInMapWithId:(NSString *)identity {
    NSInteger selectIndex = [identity integerValue]-100;
    if(self.pointMapDataArr.count <= selectIndex){
        return;
    }
    AirConditionModel *model = self.pointMapDataArr[selectIndex];
    
    if (_selectImageView) {
        _selectImageView.contentMode = UIViewContentModeScaleToFill;
        if ([_selectModel.EQUIP_STATUS isEqualToString:@"0"]) {
            _selectImageView.image = [UIImage imageNamed:@"mapairconditionerror"];
        }else{
            if(_selectModel.stateModel.value != nil && ![_selectModel.stateModel.value isKindOfClass:[NSNull class]] && [_selectModel.stateModel.value isEqualToString:@"0"]) {
                _selectImageView.image = [UIImage imageNamed:@"mapaircondition_close"];
            }else {
                _selectImageView.image = [UIImage imageNamed:@"mapairconditionnormal"];
            }
        }
    }
    
    _selectModel = model;
    
    // 复原之前选中图片效果
    if(_selectImageView != nil){
        [PointViewSelect recoverSelImgView:_selectImageView];
    }
    
    UIImageView *imageView = [indoorView.mapView viewWithTag:[identity integerValue]];
    if ([model.EQUIP_STATUS isEqualToString:@"0"]) {
        imageView.image = [UIImage imageNamed:@"mapairconditionerror"];
    }else {
        if(model.stateModel.value != nil && ![model.stateModel.value isKindOfClass:[NSNull class]] && [model.stateModel.value isEqualToString:@"0"]) {
            imageView.image = [UIImage imageNamed:@"mapaircondition_close"];
        }else {
            imageView.image = [UIImage imageNamed:@"mapairconditionnormal"];
        }
    }
    imageView.contentMode = UIViewContentModeScaleToFill;
    _selectImageView = imageView;
    
    [PointViewSelect pointImageSelect:_selectImageView];
    
    _airMenuView.hidden = NO;
    
    // 请求点位状态数据
    [self loadAirStateData:model.DEVICE_ID withBlock:^(BOOL success) {
    }];
    
}
/*
#pragma mark 空调状态数据
- (void)loadAirStateData:(NSString *)deviceId {
    NSString *urlStr = [NSString stringWithFormat:@"%@/airConditioner/deviceStatus",Main_Url];
    
    NSDictionary *paramDic = @{@"deviceId":deviceId};
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *responseData = responseObject[@"responseData"];
            NSArray *devices = responseData[@"devices"];
            
            NSMutableArray *titles = @[].mutableCopy;
            [devices enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                AirConditionModel *model = [[AirConditionModel alloc] initWithDataDic:obj];
                [titles addObject:model];
            }];
            
            NSDictionary *infos = responseData[@"infos"];
            
            // 成功
            _airMenuView.deviceId = deviceId;
            _airMenuView.devices = titles;
            _airMenuView.stateDic = infos;
//                [_airMenuView reloadMenu]; //  刷新菜单
        }
    } failure:^(NSError *error) {
        [self showHint:KRequestFailMsg];
    }];
    
}
 */

-(void)_rightBarBtnItemClick:(id)sender
{
    
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (tabView.hidden) {
        tabView.hidden = NO;
        indoorView.hidden = YES;
        [tabView reloadData];
    }else{
        tabView.hidden = YES;
        indoorView.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDateView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 49, KScreenWidth, tabView.height-49)];
    noDateView.label.text = @"无结果";
    return noDateView;
}

#pragma mark 单个开关日志
- (void)logRecordOperate:(NSString *)operate withTagId:(NSString *)tagId withOldValue:(NSString *)oldValue withNewValue:(NSString *)newValue {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:operate forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:operate forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:[NSString stringWithFormat:@"airConditioner/operateConditioner"] forKey:@"operateUrl"];//操作url
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
    [logDic setObject:newValue forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:tagId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"空调" forKey:@"operateDeviceName"];//操作设备名  模块
    [logDic setObject:oldValue forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

@end
