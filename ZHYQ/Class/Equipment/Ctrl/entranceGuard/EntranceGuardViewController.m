//
//  EntranceGuardViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/11.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "EntranceGuardViewController.h"
#import "RecordViewController.h"
#import "AuthorityViewController.h"

#import "OpenDoorAreaViewController.h"
#import "FloorModel.h"
#import "DoorModel.h"
#import "EntranceCell.h"

#import "CRSearchBar.h"

#import "EntranceGroupView.h"
#import "NoDataView.h"

@interface EntranceGuardViewController ()<UITableViewDelegate, UITableViewDataSource,SGPageTitleViewDelegate, UISearchBarDelegate, EntranceDelegate, GroupConDelegate, CYLTableViewPlaceHolderDelegate>
{
    __weak IBOutlet UILabel *_openNumLabel;
    __weak IBOutlet UILabel *_closeNumLabel;
    __weak IBOutlet UIView *_doorBgView;
    
    DoorModel *_selModel;
    
    UITableView *_entranceTableView;
    
    CRSearchBar *searchBar;
    NSMutableArray *_failtArr;
    NSMutableArray *_nameArr;
    NSMutableArray *_dataArr;
    
    EntranceGroupView *_groupView;
    
    UIButton *rightBtn;
    
}

@property (nonatomic, strong) YQSegmentView *pageTitleView;
@property (nonatomic, strong) NSMutableArray *doorData;
@property (nonatomic,strong) NSMutableArray *titleArr;
@property (nonatomic,strong) NSMutableArray *mapNameArr;
@property (nonatomic,strong) NSMutableArray *layerIdArr;

@end

@implementation EntranceGuardViewController

-(NSMutableArray *)doorData
{
    if (_doorData == nil) {
        _doorData = [NSMutableArray array];
    }
    return _doorData;
}

-(NSMutableArray *)layerIdArr
{
    if (_layerIdArr == nil) {
        _layerIdArr = [NSMutableArray array];
    }
    return _layerIdArr;
}

-(NSMutableArray *)titleArr
{
    if (_titleArr == nil) {
        _titleArr = [NSMutableArray array];
    }
    return _titleArr;
}

-(NSMutableArray *)mapNameArr
{
    if (_mapNameArr == nil) {
        _mapNameArr = [NSMutableArray array];
    }
    return _mapNameArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initNavView];
    
    _failtArr = @[].mutableCopy;
    _nameArr = @[].mutableCopy;
    _dataArr = @[].mutableCopy;
    
    [self _loadRDFloorData];
    
    [self _initGroupView];
    
    [self groupAction];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadRDFloorData) name:@"NetworkReconvert" object:nil];
}

- (void)_initNavView {
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    rightBtn = [[UIButton alloc] init];
    rightBtn.frame = CGRectMake(0, 0, 40, 40);
    [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [rightBtn setImage:[UIImage imageNamed:@"switchmap"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(groupAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

// 分组切换视图
- (void)_initGroupView {
    _groupView = [[EntranceGroupView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64)];
    _groupView.backgroundColor = [UIColor whiteColor];
    _groupView.hidden = YES;
    _groupView.groupConDelegate = self;
    [self.view addSubview:_groupView];
}

- (void)groupAction {
    _groupView.hidden = !_groupView.hidden;
    if(_groupView.hidden){
        [rightBtn setImage:[UIImage imageNamed:@"switchmap"] forState:UIControlStateNormal];
    }else {
        [rightBtn setImage:[UIImage imageNamed:@"switch_list_icon"] forState:UIControlStateNormal];
    }
}

-(void)_loadRDFloorData
{
    [self showHudInView:self.view hint:@""];
//    NSString *urlStr = [NSString stringWithFormat:@"%@/public/getChildBulidingList?bulidId=1",Main_Url];
    NSString *urlStr = [NSString stringWithFormat:@"%@/public/getChildBulidingList?bulidId=-11",Main_Url];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        rightBtn.enabled = NO;
        
        [self hideHud];
        [self.mapNameArr removeAllObjects];
        [self.layerIdArr removeAllObjects];
        [self.titleArr removeAllObjects];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            
            NSArray *dataArr = responseObject[@"responseData"];
            if(dataArr.count > 0){
                rightBtn.enabled = YES;
            }
            
            [dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FloorModel *model = [[FloorModel alloc] initWithDataDic:obj];
                [self.mapNameArr addObject:model.LAYER_MAP];
                [self.titleArr addObject:model.LAYER_NAME];
                [self.layerIdArr addObject:model.LAYER_ID];
            }];
            
            if (_titleArr.count != 0) {
                [self _initTabView];
                
                [self _initTitleView];
            }
        }
    } failure:^(NSError *error) {
        [self hideHud];
        rightBtn.enabled = NO;
    }];
}

- (void)_initTabView {
    //    self.title = @"门禁";
    
    _entranceTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 61, KScreenWidth, KScreenHeight - 61 - kTopHeight) style:UITableViewStyleGrouped];
    _entranceTableView.delegate = self;
    _entranceTableView.dataSource = self;
    _entranceTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _entranceTableView.tableFooterView = [UIView new];
    [self.view insertSubview:_entranceTableView belowSubview:_groupView];
    
    [_entranceTableView registerNib:[UINib nibWithNibName:@"EntranceCell" bundle:nil] forCellReuseIdentifier:@"EntranceCell"];
}

-(void)_initTitleView
{
    YQSegmentConfigure *configure = [YQSegmentConfigure pageTitleViewConfigure];
    configure.titleSelectedColor = [UIColor whiteColor];
    configure.indicatorStyle = SGIndicatorStyleCover;
    configure.indicatorColor = [UIColor colorWithHexString:@"1B82D1"];
    configure.indicatorAdditionalWidth = 100; // 说明：指示器额外增加的宽度，不设置，指示器宽度为标题文字宽度；若设置无限大，则指示器宽度为按钮宽度
    configure.indicatorHeight = 122; // 说明：不设置，遮盖样式下，默认高度为文字高度 + 5；若设置无限大，则高度为 PageTitleView 高度
    
    self.pageTitleView = [YQSegmentView pageTitleViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 61) delegate:self titleNames:_titleArr configure:configure];
    _pageTitleView.selectedIndex = 0;
    [self.view insertSubview:_pageTitleView belowSubview:_groupView];
}

-(void)_loadFloorData:(NSInteger)index
{
    [self showHudInView:self.view hint:@""];
    NSString *layerID = [NSString stringWithFormat:@"%@",self.layerIdArr[index]];
    NSString *urlStr = [NSString stringWithFormat:@"%@/visitor/getInDoorGuardList?layerId=%@",Main_Url,layerID];
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        
        [self.doorData removeAllObjects];
        
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *respData = responseObject[@"responseData"];
            _openNumLabel.text = [NSString stringWithFormat:@"%@",respData[@"outDoorCount"]];
            _closeNumLabel.text = [NSString stringWithFormat:@"%@",respData[@"okDoorCount"]];
            NSArray *arr = respData[@"DoorList"];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DoorModel *model = [[DoorModel alloc] initWithDataDic:obj];
                [self.doorData addObject:model];
            }];
        }
        
        _dataArr = [NSMutableArray arrayWithArray:self.doorData];
        
        [_entranceTableView cyl_reloadData];
    } failure:^(NSError *error) {
        [self hideHud];
    }];
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_rightBarBtnItemClick {
    OpenDoorAreaViewController *openDoorVC = [[OpenDoorAreaViewController alloc] init];
    [self.navigationController pushViewController:openDoorVC animated:YES];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDateView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 49, KScreenWidth, KScreenHeight - 64 - 49)];
    noDateView.label.text = @"无结果";
    return noDateView;
}

#pragma mark UITableView 协议
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.doorData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DoorModel *model = self.doorData[indexPath.row];
    if(model.isSpread){
        return 226;
    }
    return 60;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
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
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 , KScreenWidth, 0.5)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    [headerView addSubview:lineView];
    
    return headerView;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EntranceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EntranceCell" forIndexPath:indexPath];
    cell.model = self.doorData[indexPath.row];
    cell.entranceDelegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DoorModel *model = self.doorData[indexPath.row];
    
    if(_selModel == model){
        model.isSpread = !model.isSpread;
    }else {
        model.isSpread = YES;
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    if(_selModel != nil && _selModel != model){
        _selModel.isSpread = NO;
        NSInteger index = [self.doorData indexOfObject:_selModel];
        NSIndexPath *selIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [tableView reloadRowsAtIndexPaths:@[selIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    _selModel = model;
    
}

#pragma mark page 切换
- (void)pageTitleView:(YQSegmentView *)pageTitleView selectedIndex:(NSInteger)selectedIndex {
    DLog(@"%ld",selectedIndex);
    [self _loadFloorData:selectedIndex];
    
}

#pragma mark 远程开门
-(void)_unLockTheDoor:(DoorModel *)doorModel {
    
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
        [self confinOpen:doorModel];
    }];
    [alertCon addAction:cancel];
    [alertCon addAction:open];
    
    [self presentViewController:alertCon animated:YES completion:nil];
}
- (void)confinOpen:(DoorModel *)doorModel {
    NSString *urlStr = [NSString stringWithFormat:@"%@/visitor/openDoor",Main_Url];
    NSMutableDictionary *param =@{}.mutableCopy;
    if(doorModel.LAYER_C != nil && ![doorModel.LAYER_C isKindOfClass:[NSNull class]]){
        [param setObject:doorModel.LAYER_C forKey:@"doorDeviceId"];
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

#pragma mark Cell操作协议
- (void)unLockDoor:(DoorModel *)doorModel {
    [self _unLockTheDoor:doorModel];
}

- (void)viewAuthorityList:(DoorModel *)doorModel {
    AuthorityViewController *authorityVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"AuthorityViewController"];
    authorityVC.deivedID = doorModel.TAGID;
    authorityVC.doorName = doorModel.DEVICE_NAME;
    [self.navigationController pushViewController:authorityVC animated:YES];
}

- (void)openRecord:(DoorModel *)doorModel {
    RecordViewController * openRecVC = [[RecordViewController alloc] init];
    openRecVC.deivedID = doorModel.TAGID;
    openRecVC.doorName = doorModel.DEVICE_NAME;
    [self.navigationController pushViewController:openRecVC animated:YES];
}

#pragma mark uisearchBar 协议
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
    
    [self.doorData removeAllObjects];
    if (searchBar.text.length == 0) {
        [self.doorData addObjectsFromArray:_dataArr];
    }else{
        [self.doorData addObjectsFromArray:_failtArr];
    }
    
    [_entranceTableView cyl_reloadData];
    
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
    
    [self.doorData removeAllObjects];
    if (searchText.length == 0) {
        [self.doorData addObjectsFromArray:_dataArr];
    }else{
        [self.doorData addObjectsFromArray:_failtArr];
    }
    
    [_entranceTableView cyl_reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NetworkReconvert" object:nil];
}

@end

