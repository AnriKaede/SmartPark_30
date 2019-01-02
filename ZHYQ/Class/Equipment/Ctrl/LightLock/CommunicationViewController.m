//
//  CommunicationViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/21.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "CommunicationViewController.h"
#import "YQInDoorPointMapView.h"
#import "CRSearchBar.h"
#import "YQHeaderView.h"
#import <UITableView+PlaceHolderView.h>
#import "CommunLockCell.h"

#import "LockWranViewController.h"

#import "LockMenuView.h"
#import "CoverMenuView.h"

#import "CommnncLockModel.h"
#import "CommnncCoverModel.h"

@interface CommunicationViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate, LockMenuDelegate, CoverMenuDelegate, DidSelInMapPopDelegate>
{
    YQInDoorPointMapView *indoorView;
    UIView *bottomView;
    NSMutableArray *mapArr;
    UIImageView *_selectImageView;
    
    BOOL _isShowMenu;
    UIButton *rightBtn;
    CRSearchBar *searchBar;
    UITableView *_commncTableView;
    
    NSMutableArray *_dataArr;
    
    LockMenuView *_lockMenuView;
    CoverMenuView *_coverMenuView;
    
    NSInteger _page;
    NSInteger _length;
    
    NSString *_searchText;
}

@property (strong, nonatomic) YQHeaderView *headerView;
@property (nonatomic,strong) NSIndexPath * selectedIndex;

@property (nonatomic,strong) NSMutableArray *pointMapDataArr;   // 点位数据，井盖第一组，光交锁第二组。   分组数据
@property (nonatomic,strong) NSMutableArray *mapCoordinateData; // 未分组数据
@property (nonatomic,strong) NSMutableArray *graphData;

@end

@implementation CommunicationViewController

-(NSMutableArray *)pointMapDataArr {
    if (_pointMapDataArr == nil) {
        _pointMapDataArr = [NSMutableArray array];
    }
    return _pointMapDataArr;
}

-(NSMutableArray *)graphData {
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
        _commncTableView.frame = CGRectMake(0, 0, KScreenWidth, bottomView.height);
        indoorView.frame = CGRectMake(0, 0, KScreenWidth, bottomView.height);
        _lockMenuView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
        [_lockMenuView reloadMenu];
        _coverMenuView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
        [_coverMenuView reloadMenu];
        _headerView.hidden = YES;
    }else{
        // 屏幕从横屏变为竖屏时执行
        NSLog(@"屏幕从横屏变为竖屏时执行");
        bottomView.frame = CGRectMake(0, _headerView.bottom, KScreenWidth, KScreenHeight - kTopHeight - 20 - _headerView.bottom);
        _commncTableView.frame = CGRectMake(0, 0, KScreenWidth, bottomView.height);
        indoorView.frame = CGRectMake(0, 0, KScreenWidth, bottomView.height);
        _lockMenuView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
        [_lockMenuView reloadMenu];
        _coverMenuView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
        [_coverMenuView reloadMenu];
        _headerView.hidden = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _mapCoordinateData = @[].mutableCopy;
    
    _page = 1;
    _length = 3;
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    
    //初始化子视图
    [self _initNavItems];
    
    [self _initView];
    
    [self _initTableView];
    
    [self _loadCoordinateData];
    
    [_commncTableView.mj_header beginRefreshing];
    
}

-(void)_initTableView
{
    _commncTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _commncTableView.frame = CGRectMake(0, 0, KScreenWidth, bottomView.height);
    _commncTableView.delegate = self;
    _commncTableView.dataSource = self;
    _commncTableView.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    [_commncTableView registerNib:[UINib nibWithNibName:@"CommunLockCell" bundle:nil] forCellReuseIdentifier:@"CommunLockCell"];
    _commncTableView.hidden = YES;
    _commncTableView.showsVerticalScrollIndicator = NO;
    _commncTableView.showsHorizontalScrollIndicator = NO;
    _commncTableView.enablePlaceHolderView = YES;
    _commncTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _commncTableView.yh_PlaceHolderView = [self makePlaceHolderView];
    [bottomView addSubview:_commncTableView];
    
    _commncTableView.estimatedRowHeight = 0;
    _commncTableView.estimatedSectionHeaderHeight = 0;
    _commncTableView.estimatedSectionFooterHeight = 0;
}

#pragma mark 加载设备 地图点位数据
- (void)_loadCoordinateData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/iot/list",Main_Url];
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self.graphData removeAllObjects];
        [self.pointMapDataArr removeAllObjects];
        [self.mapCoordinateData removeAllObjects];
        
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *dic = responseObject[@"responseData"];
            
            NSArray *coverData = dic[@"ManholeCover"];
            NSMutableArray *covers = @[].mutableCopy;
            [coverData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CommnncCoverModel *model = [[CommnncCoverModel alloc] initWithDataDic:obj];
                //                NSString *graphStr = [NSString stringWithFormat:@"%@,%@",model.longitude, model.latitude];
                NSString *graphStr = [NSString stringWithFormat:@"%@,%@",@400, @500];
                [self.graphData addObject:graphStr];
                [covers addObject:model];
            }];
            [self.pointMapDataArr addObject:covers];
            [self.mapCoordinateData addObjectsFromArray:covers];
            
            NSArray *lockData = dic[@"InterBoxLock"];
            NSMutableArray *locks = @[].mutableCopy;
            [lockData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CommnncLockModel *model = [[CommnncLockModel alloc] initWithDataDic:obj];
//                NSString *graphStr = [NSString stringWithFormat:@"%@,%@",model.longitude, model.latitude];
                NSString *graphStr = [NSString stringWithFormat:@"%@,%@",@600, @500];
                [self.graphData addObject:graphStr];
                [locks addObject:model];
            }];
            [self.pointMapDataArr addObject:locks];
            [self.mapCoordinateData addObjectsFromArray:locks];
            
            // 顶部统计
            _headerView.leftNumLab.text = [NSString stringWithFormat:@"%@",dic[@"ok"]];
            _headerView.centerNumLab.text = [NSString stringWithFormat:@"%@",dic[@"error"]];
            _headerView.rightNumLab.text = [NSString stringWithFormat:@"%@",dic[@"fault"]];
            
        }
        
        indoorView.graphData = self.graphData;
        indoorView.commncArr = self.mapCoordinateData;
        [_commncTableView cyl_reloadData];
    } failure:^(NSError *error) {
        NSLog(@"光交锁错误 %@", error);
    }];
    
}

-(void)_initView
{
    // 创建点击菜单视图
    _lockMenuView = [[NSBundle mainBundle] loadNibNamed:@"LockMenuView" owner:self options:nil].lastObject;
    _lockMenuView.hidden = YES;
    _lockMenuView.lockMenuDelegate = self;
    [[UIApplication sharedApplication].delegate.window addSubview:_lockMenuView];
    
    _coverMenuView = [[NSBundle mainBundle] loadNibNamed:@"CoverMenuView" owner:self options:nil].lastObject;
    _coverMenuView.hidden = YES;
    _coverMenuView.coverMenuDelegate = self;
    [[UIApplication sharedApplication].delegate.window addSubview:_coverMenuView];
    
    _headerView = [[YQHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 85)];
    _headerView.backgroundColor = [UIColor colorWithHexString:@"1B82D1"];
    _headerView.leftLab.text = @"正常";
    _headerView.centerLab.text = @"异常";
    _headerView.centerLab.textColor = [UIColor colorWithHexString:@"#FF2A2A"];
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
    [sendBtn setImage:[UIImage imageNamed:@"nav_lock_wran"] forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(_rightBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *sendItem = [[UIBarButtonItem alloc] initWithCustomView:sendBtn];
    
    self.navigationItem.rightBarButtonItems = @[rightItem, sendItem];
}
- (void)_rightBarBtnItemClick {
    LockWranViewController *lockWranVC = [[LockWranViewController alloc] init];
    [self.navigationController pushViewController:lockWranVC animated:YES];
}

#pragma mark UITableView协议
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.pointMapDataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *eqData = self.pointMapDataArr[section];
    return eqData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *eqData = self.pointMapDataArr[indexPath.section];
    if(indexPath.section == 0){
        CommnncCoverModel *coverModel = eqData[indexPath.row];
        if(coverModel.isSelect){
            return 295;
        }
    }else if(indexPath.section == 1){
        CommnncLockModel *lockModel = eqData[indexPath.row];
        if(lockModel.isSelect){
            return 295;
        }
    }
    return 54;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommunLockCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommunLockCell" forIndexPath:indexPath];
    if(indexPath.section == 0){
        cell.coverModel = self.pointMapDataArr[indexPath.section][indexPath.row];
    }else {
        cell.lockModel = self.pointMapDataArr[indexPath.section][indexPath.row];
    }
//    cell.delegate = self;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 42;
//    if(section == 0){
//        return 49;
//    }else {
//        return 0.1;
//    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    /*
    if(section != 0){
        return [UIView new];
    }
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
     */
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 42)];
    headerView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 11, 100, 20)];
    if(section == 0){
        label.text = @"井盖设备";
    }else {
        label.text = @"光交锁设备";
    }
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentLeft;
    [headerView addSubview:label];
    
    return headerView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [searchBar resignFirstResponder];
    
    [self.pointMapDataArr enumerateObjectsUsingBlock:^(NSArray *eqData, NSUInteger eqIdx, BOOL * _Nonnull stop) {
        if(eqIdx == 0){
            [eqData enumerateObjectsUsingBlock:^(CommnncCoverModel *coverModel, NSUInteger idx, BOOL * _Nonnull stop) {
                if(eqIdx == indexPath.section && idx == indexPath.row){
                    coverModel.isSelect = !coverModel.isSelect;
                }else {
                    coverModel.isSelect = NO;
                }
            }];
        }else if(eqIdx == 1){
            [eqData enumerateObjectsUsingBlock:^(CommnncLockModel *lockModel, NSUInteger idx, BOOL * _Nonnull stop) {
                if(eqIdx == indexPath.section && idx == indexPath.row){
                    lockModel.isSelect = !lockModel.isSelect;
                }else {
                    lockModel.isSelect = NO;
                }
            }];
        }
    }];
    
    [tableView cyl_reloadData];
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
        /*
        [_mapCoordinateData enumerateObjectsUsingBlock:^(LedListModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            BOOL isContain = [pred evaluateWithObject:model.deviceName];
            if (isContain) {
                [self.pointMapDataArr addObject:_dataArr[idx]];
            }
        }];
         */
    }
    _searchText = searchBar.text;
    [_commncTableView reloadData];
}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 选中点位
- (void)selInMapWithId:(NSString *)identity {
    NSInteger selectIndex = [identity integerValue]-100;
    if(self.mapCoordinateData.count <= selectIndex){
        return;
    }
    
    id model = _mapCoordinateData[selectIndex];
    if([model isKindOfClass:[CommnncCoverModel class]]){
        // 井盖
        _coverMenuView.hidden = NO;
        
        CommnncCoverModel *model = _mapCoordinateData[selectIndex];
        _coverMenuView.coverModel = model;
    }else if([model isKindOfClass:[CommnncLockModel class]]){
        // 光交锁
        _lockMenuView.hidden = NO;
        
        CommnncLockModel *model = _mapCoordinateData[selectIndex];
    }
    
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
}

-(void)_rightBarBtnItemClick:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (_commncTableView.hidden) {
        _commncTableView.hidden = NO;
        indoorView.hidden = YES;
        [_commncTableView reloadData];
    }else{
        _commncTableView.hidden = YES;
        indoorView.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDateView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 49, KScreenWidth, _commncTableView.height-49)];
    noDateView.label.text = @"无结果";
    return noDateView;
}
@end
