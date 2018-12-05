//
//  LEDMapViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/5.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "LEDMapViewController.h"
#import "YQHeaderView.h"
#import "NewLEDCell.h"
#import "LedListModel.h"
#import "NoDataView.h"
#import "CRSearchBar.h"
#import "YQInDoorPointMapView.h"
#import <UITableView+PlaceHolderView.h>

#import "MsgPostViewController.h"
#import "LEDScreenShotViewController.h"

#import "LEDMenuView.h"

typedef enum {
    OpenLed = 0,
    CloseLed,
    OpenPC,
    RestartPC,
    ClosePC,
    ResumeDefault,
    
    OpenStreetLED,
    CLoseStreetLED,
    RestartStreetPC
}LEDOperateType;

@interface LEDMapViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,DidSelInMapPopDelegate,UISearchBarDelegate, LEDMenuDelegate, LEDListDelegate>
{
    YQInDoorPointMapView *indoorView;
    UIView *bottomView;
    NSMutableArray *mapArr;
    UIImageView *_selectImageView;
    UIImageView *_selectBottomImageView;
    
    LedListModel *_selectModel;
    
    BOOL _isShowMenu;
    UIButton *rightBtn;
    CRSearchBar *searchBar;
    UITableView *tabView;
    BOOL isOpen;
    
    NSMutableArray *_dataArr;
    
    LEDMenuView *_ledMenuView;
    
    NSInteger _page;
    NSInteger _length;
    
    NSString *_searchText;
}

@property (strong, nonatomic) YQHeaderView *headerView;
@property (nonatomic, strong) UICollectionView *mainCollectionView;
@property (nonatomic,strong) NSIndexPath * selectedIndex;
@property (nonatomic,strong) NSMutableArray *pointMapDataArr;
@property (nonatomic,strong) NSMutableArray *graphData;

@end

@implementation LEDMapViewController

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
        _ledMenuView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
        [_ledMenuView reloadMenu];
        _headerView.hidden = YES;
    }else{
        // 屏幕从横屏变为竖屏时执行
        NSLog(@"屏幕从横屏变为竖屏时执行");
        bottomView.frame = CGRectMake(0, _headerView.bottom, KScreenWidth, KScreenHeight - kTopHeight - 20 - _headerView.bottom);
        tabView.frame = CGRectMake(0, 0, KScreenWidth, bottomView.height);
        indoorView.frame = CGRectMake(0, 0, KScreenWidth, bottomView.height);
        _ledMenuView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
        [_ledMenuView reloadMenu];
        _headerView.hidden = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _page = 1;
    _length = 20;
    
    isOpen = YES;
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    
    //初始化子视图
    [self _initNavItems];
    
    [self _initView];
    
    [self _initTableView];
    
    [self _loadPointMapData];
    
    // 加载顶部统计数
    [self _loadCountData];
}

-(void)_initTableView
{
    tabView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tabView.frame = CGRectMake(0, 0, KScreenWidth, bottomView.height);
    tabView.delegate = self;
    tabView.dataSource = self;
    tabView.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    [tabView registerNib:[UINib nibWithNibName:@"NewLEDCell" bundle:nil] forCellReuseIdentifier:@"NewLEDCell"];
    tabView.hidden = YES;
    tabView.showsVerticalScrollIndicator = NO;
    tabView.showsHorizontalScrollIndicator = NO;
    tabView.enablePlaceHolderView = YES;
    tabView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tabView.yh_PlaceHolderView = [self makePlaceHolderView];
    [bottomView addSubview:tabView];
}

#pragma mark 加载LED点位图数据
-(void)_loadPointMapData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/equipment/getLedScreenList",Main_Url];
    
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:@"all" forKey:@"type"];
    [param setObject:[NSNumber numberWithInteger:_page] forKey:@"pageNumber"];
    [param setObject:[NSNumber numberWithInteger:_length] forKey:@"pageSize"];
    NSDictionary *paramDic =@{@"param":[Utils convertToJsonData:param]};
    [self showHudInView:self.view hint:@""];
    [[NetworkClient sharedInstance] POST:urlStr dict:paramDic progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        [self.graphData removeAllObjects];
        [self.pointMapDataArr removeAllObjects];
        
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *dic = responseObject[@"responseData"];
            NSArray *arr = dic[@"ledScreenList"];
            
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                LedListModel *model = [[LedListModel alloc] initWithDataDic:obj];
//                NSString *graphStr = [NSString stringWithFormat:@"%@,%@",model.LONGITUDE, model.LATITUDE];
//                [self.graphData addObject:graphStr];
                [self.graphData addObject:@"543,535,"];
                [self.pointMapDataArr addObject:model];
            }];
        }
        
        indoorView.graphData = self.graphData;
        indoorView.LEDMapArr = self.pointMapDataArr;
        _dataArr = self.pointMapDataArr.mutableCopy;
        [tabView reloadData];
    } failure:^(NSError *error) {
        [self hideHud];
        NSLog(@"LED错误 %@", error);
    }];
}

#pragma mark 加载LED顶部统计数据
- (void)_loadCountData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/equipment/getLedScreenList",Main_Url];
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *dic = responseObject[@"responseData"];
            _headerView.leftNumLab.text = [NSString stringWithFormat:@"%@",dic[@"okCount"]];
            _headerView.centerNumLab.text = [NSString stringWithFormat:@"%@",dic[@"outCount"]];
            _headerView.rightNumLab.text = [NSString stringWithFormat:@"%@",dic[@"errorCount"]];
        }
    } failure:^(NSError *error) {
    }];
}

-(void)_initView
{
    // 创建点击菜单视图
    _ledMenuView = [[NSBundle mainBundle] loadNibNamed:@"LEDMenuView" owner:self options:nil].lastObject;
    _ledMenuView.hidden = YES;
    _ledMenuView.ledMenuDelegate = self;
    [[UIApplication sharedApplication].delegate.window addSubview:_ledMenuView];
    
    _headerView = [[YQHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 85)];
    _headerView.backgroundColor = [UIColor colorWithHexString:@"1B82D1"];
    [self.view addSubview:_headerView];
    UITapGestureRecognizer *hidKeybTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidKeyB)];
    _headerView.userInteractionEnabled = YES;
    [_headerView addGestureRecognizer:hidKeybTap];
    
    [self _initPointMapView];
}
- (void)hidKeyB {
    [self.view endEditing:YES];
}

-(void)_initPointMapView {
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 85, KScreenWidth, KScreenHeight-kTopHeight-85)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    indoorView = [[YQInDoorPointMapView alloc]initWithIndoorMapImageName:@"smart_park_bg" Frame:CGRectMake(0, 0, KScreenWidth, bottomView.height)];
    indoorView.selInMapDelegate = self;
    [bottomView addSubview:indoorView];
}

-(void)_initNavItems {
    
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
    
    // 发送屏幕信息bt
    UIButton *sendBtn = [[UIButton alloc] init];
    sendBtn.frame = CGRectMake(0, 0, 40, 40);
    [sendBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [sendBtn setImage:[UIImage imageNamed:@"LED_publish_icon"] forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(_rightBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *sendItem = [[UIBarButtonItem alloc] initWithCustomView:sendBtn];
    
    self.navigationItem.rightBarButtonItems = @[rightItem, sendItem];
}
- (void)_rightBarBtnItemClick {
    MsgPostViewController *ledPostMsgVC = [[MsgPostViewController alloc] init];
    [self.navigationController pushViewController:ledPostMsgVC animated:YES];
}

#pragma mark UITableView协议
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pointMapDataArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 205;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewLEDCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewLEDCell" forIndexPath:indexPath];
    cell.ledListModel = self.pointMapDataArr[indexPath.row];
    cell.delegate = self;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 49;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 49)];
    headerView.backgroundColor = [UIColor whiteColor];
    searchBar = [[CRSearchBar alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 44) leftImage:[UIImage imageNamed:@"icon_search"] placeholderColor:[UIColor colorWithHexString:@"#E2E2E2"]];
    searchBar.placeholder = @"请输入搜索内容";
    if(_searchText != nil){
        searchBar.text = _searchText;
    }
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [searchBar resignFirstResponder];
}

#pragma mark uisearchBar delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@",searchBar.text];
    
    [self.pointMapDataArr removeAllObjects];
    if (searchBar.text.length == 0) {
        [self.pointMapDataArr addObjectsFromArray:_dataArr];
    }else{
        [_dataArr enumerateObjectsUsingBlock:^(LedListModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            BOOL isContain = [pred evaluateWithObject:model.deviceName];
            if (isContain) {
                [self.pointMapDataArr addObject:_dataArr[idx]];
            }
        }];
    }
    _searchText = searchBar.text;
    [tabView reloadData];
}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 选中点位
- (void)selInMapWithId:(NSString *)identity {
    NSInteger selectIndex = [identity integerValue]-100;
    if(self.pointMapDataArr.count <= selectIndex){
        return;
    }
    LedListModel *model = self.pointMapDataArr[selectIndex];
    
    if (_selectImageView) {
        _selectImageView.contentMode = UIViewContentModeScaleToFill;
        if([_selectModel.mainstatus isEqualToString:@"1"]) {
            _selectImageView.image = [UIImage imageNamed:@"LED_map_icon"];
        }else {
            _selectImageView.image = [UIImage imageNamed:@"LED_map_icon"];
        }
    }
    
    _selectModel = model;
    
    // 复原之前选中图片效果
    if(_selectImageView != nil){
        [PointViewSelect recoverSelImgView:_selectImageView];
        [PointViewSelect recoverSelImgView:_selectBottomImageView];
    }
    
    UIImageView *imageView = [indoorView.mapView viewWithTag:[identity integerValue]];
    UIImageView *bottomImageView = [indoorView.mapView viewWithTag:[identity integerValue] + 100];
    if ([model.mainstatus isEqualToString:@"1"]) {
        imageView.image = [UIImage imageNamed:@"LED_map_icon"];
    }else {
        imageView.image = [UIImage imageNamed:@"LED_map_icon"];
    }
    imageView.contentMode = UIViewContentModeScaleToFill;
    _selectImageView = imageView;
    _selectBottomImageView = bottomImageView;
    
    [PointViewSelect pointImageSelect:_selectImageView];
    [PointViewSelect pointImageSelect:_selectBottomImageView];
    
    _ledMenuView.modelAry = @[model];
    _ledMenuView.hidden = NO;
    
}

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

#pragma mark 新LED操作协议
// 截屏
- (void)lookScreenShotWithModel:(LedListModel*)ledListModel {
    _ledMenuView.hidden = YES;
    LEDScreenShotViewController *ledScreenVc = [[LEDScreenShotViewController alloc] init];
    if([ledListModel.type isEqualToString:@"1"]){
        // 路灯屏
        ledScreenVc.isStreetLight = YES;
    }
    ledScreenVc.ledListModel = ledListModel;
    [self.navigationController pushViewController:ledScreenVc animated:YES];
}
- (void)ledSwitch:(BOOL)on withModel:(LedListModel*)ledListModel {
    if([ledListModel.type isEqualToString:@"1"]){
        // 路灯屏
        [self streetOperate:on withModel:ledListModel];
    }else {
        if(on){
            [self operateLed:OpenLed withModel:ledListModel];
        }else {
            [self operateLed:CloseLed withModel:ledListModel];
        }
    }
    ledListModel.mainstatus = on ? @"1" : @"0";
}
- (void)ledPlay:(LedListModel*)ledListModel {
    _ledMenuView.hidden = YES;
    NSInteger index = [self.pointMapDataArr indexOfObject:ledListModel];
    UITableViewCell *cellView = [tabView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [self alertOperate:@"是否确定开启设备主机" withBolck:^{
        [self operateLed:OpenPC withModel:ledListModel];
    } withShowView:cellView==nil?_headerView:cellView];
}
- (void)ledRestart:(LedListModel*)ledListModel {
    _ledMenuView.hidden = YES;
    NSInteger index = [self.pointMapDataArr indexOfObject:ledListModel];
    UITableViewCell *cellView = [tabView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [self alertOperate:@"是否确定重启设备主机" withBolck:^{
        if([ledListModel.type isEqualToString:@"1"]){
            [self streetRestart:ledListModel];
        }else {
            [self operateLed:RestartPC withModel:ledListModel];
        }
    } withShowView:cellView==nil?_headerView:cellView];
}
- (void)ledClose:(LedListModel*)ledListModel {
    _ledMenuView.hidden = YES;
    NSInteger index = [self.pointMapDataArr indexOfObject:ledListModel];
    UITableViewCell *cellView = [tabView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [self alertOperate:@"是否确定关闭设备主机" withBolck:^{
        [self operateLed:ClosePC withModel:ledListModel];
    } withShowView:cellView==nil?_headerView:cellView];
}
- (void)resumeDefault:(LedListModel*)ledListModel {
    _ledMenuView.hidden = YES;
    NSInteger index = [self.pointMapDataArr indexOfObject:ledListModel];
    UITableViewCell *cellView = [tabView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [self alertOperate:@"是否确定恢复默认节目" withBolck:^{
        [self operateLed:ResumeDefault withModel:ledListModel];
    } withShowView:cellView==nil?_headerView:cellView];
}

- (void)operateLed:(LEDOperateType)operateType withModel:(LedListModel *)ledListModel {
    NSString *urlStr;
    if(operateType == OpenPC){
        urlStr = [NSString stringWithFormat:@"%@/udpController/sendWakeOnlan",Main_Url];
    }else {
        urlStr = [NSString stringWithFormat:@"%@/udpController/sendMsgToUdpSer",Main_Url];
    }
    
    NSMutableDictionary *searchParam = @{}.mutableCopy;
    [searchParam setObject:ledListModel.deviceId forKey:@"deviceId"];
    [searchParam setObject:[self conOperateType:operateType] forKey:@"instructions"];
    
    //    NSString *jsonStr = [Utils convertToJsonData:searchParam];
    //    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:searchParam progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            // 调列表接口刷新
            //            [self _loadData];
            
            // 成功
            // 记录日志
            [self operateLog:operateType withModel:ledListModel];
            
            if(operateType == OpenLed){
                _headerView.leftNumLab.text = [NSString stringWithFormat:@"%ld", _headerView.leftNumLab.text.integerValue + 1];
                _headerView.centerNumLab.text = [NSString stringWithFormat:@"%ld", _headerView.centerNumLab.text.integerValue - 1];
            }else if(operateType == CloseLed){
                _headerView.leftNumLab.text = [NSString stringWithFormat:@"%ld", _headerView.leftNumLab.text.integerValue - 1];
                _headerView.centerNumLab.text = [NSString stringWithFormat:@"%ld", _headerView.centerNumLab.text.integerValue + 1];
            }
        }
        if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
            [self showHint:responseObject[@"message"]];
        }
        
        NSInteger index = [self.pointMapDataArr indexOfObject:ledListModel];
        [tabView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)operateLog:(LEDOperateType)operateType withModel:(LedListModel *)ledListModel {
    NSString *operate;
    switch (operateType) {
        case OpenLed:
        {
            ledListModel.mainstatus = @"1";
            operate = [NSString stringWithFormat:@"LED屏\"%@\"开", ledListModel.deviceName];
            break;
        }
        case CloseLed:
        {
            ledListModel.mainstatus = @"0";
            operate = [NSString stringWithFormat:@"LED屏\"%@\"关", ledListModel.deviceName];
            break;
        }
        case OpenPC:
        {
            operate = [NSString stringWithFormat:@"LED屏电脑\"%@\"开", ledListModel.deviceName];
            break;
        }
        case RestartPC:
        {
            operate = [NSString stringWithFormat:@"LED电脑\"%@\"重启", ledListModel.deviceName];
            break;
        }
        case ClosePC:
        {
            operate = [NSString stringWithFormat:@"LED屏电脑\"%@\"关", ledListModel.deviceName];
            break;
        }
        case OpenStreetLED:
        {
            operate = [NSString stringWithFormat:@"路灯LED屏\"%@\"开", ledListModel.deviceName];
            break;
        }
        case CLoseStreetLED:
        {
            operate = [NSString stringWithFormat:@"路灯LED屏\"%@\"关", ledListModel.deviceName];
            break;
        }
        case RestartStreetPC:
        {
            operate = [NSString stringWithFormat:@"路灯LED主机\"%@\"重启", ledListModel.deviceName];
            break;
        }
            
        default:
            break;
    }
    [self logRecordOperate:operate withTagid:ledListModel.tagid];
}
- (void)logRecordOperate:(NSString *)operate withTagid:(NSString *)tagId {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:operate forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:operate forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"udpController/sendMsgToUdpSer" forKey:@"operateUrl"];//操作url
    [logDic setObject:tagId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"LED屏" forKey:@"operateDeviceName"];//操作设备名  模块
    
    [LogRecordObj recordLog:logDic];
}

- (NSString *)conOperateType:(LEDOperateType)operateType {
    NSString *operate;
    switch (operateType) {
        case OpenLed:
        {
            operate = @"OPENLED";
            break;
        }
        case CloseLed:
        {
            operate = @"CLOSELED";
            break;
        }
        case OpenPC:
        {
            operate = @"START";
            break;
        }
        case RestartPC:
        {
            operate = @"REBOOT";
            break;
        }
        case ClosePC:
        {
            operate = @"SHUTDOWN";
            break;
        }
        case ResumeDefault:
        {
            operate = @"UPDATEPLAY";
            break;
        }
            
        default:
            break;
    }
    
    return operate;
}

- (void)alertOperate:(NSString *)message withBolck:(void(^)(void))certain withShowView:(UIView *)showView {
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        _ledMenuView.hidden = NO;
    }];
    UIAlertAction *removeAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        certain();
    }];
    [alertCon addAction:cancelAction];
    [alertCon addAction:removeAction];
    if (alertCon.popoverPresentationController != nil) {
        alertCon.popoverPresentationController.sourceView = showView;
        alertCon.popoverPresentationController.sourceRect = showView.bounds;
    }
    [self presentViewController:alertCon animated:YES completion:^{
    }];
}

#pragma mark 路灯屏 操作
- (void)streetOperate:(BOOL)onOff withModel:(LedListModel *)ledListModel {
    NSString *urlStr = [NSString stringWithFormat:@"%@/roadLamp/openAndStopScreen",Main_Url];
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:ledListModel.tagid forKey:@"tagId"];
    LEDOperateType operateType;
    if(onOff){
        // 开
        [param setObject:[NSNumber numberWithBool:YES] forKey:@"arg1"];
        operateType = OpenStreetLED;
    }else {
        // 关
        [param setObject:[NSNumber numberWithBool:NO] forKey:@"arg1"];
        operateType = CLoseStreetLED;
    }
    
    NSString *jsonParam = [Utils convertToJsonData:param];
    NSDictionary *params = @{@"param":jsonParam};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            // 调列表接口刷新
            // 成功
            // 记录日志
            [self operateLog:operateType withModel:ledListModel];
            
            ledListModel.mainstatus = [NSString stringWithFormat:@"%d", onOff];
            
            // 本地修改统计
            if(onOff){
                _headerView.leftNumLab.text = [NSString stringWithFormat:@"%ld", _headerView.leftNumLab.text.integerValue + 1];
                _headerView.centerNumLab.text = [NSString stringWithFormat:@"%ld", _headerView.centerNumLab.text.integerValue - 1];
            }else {
                _headerView.leftNumLab.text = [NSString stringWithFormat:@"%ld", _headerView.leftNumLab.text.integerValue - 1];
                _headerView.centerNumLab.text = [NSString stringWithFormat:@"%ld", _headerView.centerNumLab.text.integerValue + 1];
            }
        }
        if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
            [self showHint:responseObject[@"message"]];
        }
        
        NSInteger index = [self.pointMapDataArr indexOfObject:ledListModel];
        [tabView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
    } failure:^(NSError *error) {
        
    }];
}
- (void)streetRestart:(LedListModel *)ledListModel {
    NSString *urlStr = [NSString stringWithFormat:@"%@/roadLamp/restartScreen",Main_Url];
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:ledListModel.tagid forKey:@"tagId"];
    LEDOperateType operateType = RestartStreetPC;
    
    NSString *jsonParam = [Utils convertToJsonData:param];
    NSDictionary *params = @{@"param":jsonParam};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            // 调列表接口刷新
            // 成功
            // 记录日志
            [self operateLog:operateType withModel:ledListModel];
        }
        if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
            [self showHint:responseObject[@"message"]];
        }
        
        NSInteger index = [self.pointMapDataArr indexOfObject:ledListModel];
        [tabView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
    } failure:^(NSError *error) {
        
    }];
}

@end
