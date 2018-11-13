//
//  InDoorBgMusicViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/13.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "InDoorBgMusicViewController.h"
#import "YQHeaderView.h"
#import "YQInDoorPointMapView.h"
#import "InDoorBgMusicMapModel.h"
#import "ShowMenuView.h"
#import "ChooseMusicViewController.h"

#import "BgMusicListTabViewCell.h"
#import "YQSlider.h"
#import "TopMenuModel.h"
#import "ShowMenuView.h"
#import "SoundModel.h"

#import "CRSearchBar.h"
#import "NoDataView.h"
#import <UITableView+PlaceHolderView.h>

@interface InDoorBgMusicViewController ()<UIScrollViewDelegate,DidSelInMapPopDelegate,UITableViewDelegate,UITableViewDataSource,MenuControlDelegate, CellPlayMusicDelegate, ChangeMusicSuccessDelegate,UISearchBarDelegate>

{

    // 弹窗
    ShowMenuView *_showMenuView;
    NSString *_menuTitle;   // 菜单标题
    NSString *_stateStr;    // 设备状态
    UIColor *_stateColor;   // 设备状态颜色
//    NSString *_currentMusic; // 当前音乐
    CGFloat _volume; // 音量
    
    YQInDoorPointMapView *indoorView;
    UIImageView *_selectImageView;
    UIView *bottomView;
    BOOL isOpen;
    NSInteger titleSelectIndex;
    
    SoundModel *_selectSoundModel;
    InDoorBgMusicMapModel *_selMusicmodel;
    
    CRSearchBar *searchBar;
    UITableView *tabView;
    NSMutableArray *_failtArr;
    NSMutableArray *_nameArr;
    NSMutableArray *_dataArr;
    
    BOOL _isShowMenu;
    NSMutableDictionary *_statusDic;
}

@property (nonatomic, strong) NSIndexPath * selectedIndex;
@property (strong, nonatomic) YQHeaderView *headerView;

@property (nonatomic,strong) NSMutableArray *bgMusicArr;
@property (nonatomic,strong) NSMutableArray *graphData;

@end

@implementation InDoorBgMusicViewController

-(NSMutableArray *)graphData
{
    if (_graphData == nil) {
        _graphData = [NSMutableArray array];
    }
    return _graphData;
}

-(NSMutableArray *)bgMusicArr
{
    if (_bgMusicArr == nil) {
        _bgMusicArr = [NSMutableArray array];
    }
    return _bgMusicArr;
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
    
    _volume = 0.5;
    
    _failtArr = @[].mutableCopy;
    _nameArr = @[].mutableCopy;
    
    _statusDic = @{}.mutableCopy;
    [_statusDic setObject:@"0" forKey:@"areaStatus"];
    
    isOpen = YES;
    titleSelectIndex = 0;
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];

    //初始化子视图
    [self _initView];
    [self _initheaderView];
    [self _initTableView];
    [self _initPointMapView];
    
    [self _loadFloorEquipmentData:[NSString stringWithFormat:@"%@",_floorModel.LAYER_ID]];
    
}

-(void)_loadFloorEquipmentData:(NSString *)layerId
{
    [self showHudInView:self.view hint:@""];
    NSString *urlStr = [NSString stringWithFormat:@"%@/music/getInMusicList?layerId=%@",Main_Url,layerId];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            
            NSDictionary *dataDic = responseObject[@"responseData"];
            if(dataDic == nil || [dataDic isKindOfClass:[NSNull class]]){
                return ;
            }
            _headerView.leftNumLab.text = [NSString stringWithFormat:@"%@",dataDic[@"okMusicCount"]];
            _headerView.centerNumLab.text = [NSString stringWithFormat:@"%@",dataDic[@"outMusicCount"]];
            _headerView.rightNumLab.text = [NSString stringWithFormat:@"%@",dataDic[@"errorMusicCount"]];
            
            NSArray *arr = dataDic[@"musicList"];
            
            if (self.graphData.count != 0) {
                [self.graphData removeAllObjects];
            }
            if (self.bgMusicArr.count != 0) {
                [self.bgMusicArr removeAllObjects];
            }
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                InDoorBgMusicMapModel *model = [[InDoorBgMusicMapModel alloc] initWithDataDic:arr[idx]];
                model.currentMusic = @"";
                
//                if (idx == 1||idx == 3) {
//                    model.MUSIC_STATUS = @"0";
//                }
                if (_selectedIndex != nil) {
                    
                }
                model.isOpen = NO;
//                NSString *graphStr = [NSString stringWithFormat:@"%@,%@,%@",model.LAYER_A,model.LAYER_B,model.LAYER_C];
                NSString *graphStr = [NSString stringWithFormat:@"%@,%@",model.LONGITUDE, model.LATITUDE];
                [self.graphData addObject:graphStr];
                [self.bgMusicArr addObject:model];
            }];
            
            
            indoorView.graphData = _graphData;
            indoorView.bgMusicArr = _bgMusicArr;
            
            _dataArr = [NSMutableArray arrayWithArray:self.bgMusicArr];
            
            [tabView reloadData];
        }
    } failure:^(NSError *error) {
        [self hideHud];
    }];
}

-(void)_initView
{
    // 创建点击菜单视图
    _showMenuView = [[ShowMenuView alloc] init];
    _showMenuView.hidden = YES;
    _showMenuView.menuDelegate = self;
    [[UIApplication sharedApplication].delegate.window addSubview:_showMenuView];
    
}

-(void)_initTableView
{
    tabView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tabView.frame = CGRectMake(0, 0, KScreenWidth, bottomView.height);
    tabView.delegate = self;
    tabView.dataSource = self;
    tabView.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    [tabView registerNib:[UINib nibWithNibName:@"BgMusicListTabViewCell" bundle:nil] forCellReuseIdentifier:@"BgMusicListTabViewCell"];
    tabView.hidden = YES;
//    tabView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tabView.enablePlaceHolderView = YES;
    tabView.yh_PlaceHolderView = [self makePlaceHolderView];
    [bottomView addSubview:tabView];
}

-(void)_initheaderView
{
    [self.view addSubview:self.headerView];
    
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_headerView.frame), KScreenWidth, KScreenHeight-kTopHeight-CGRectGetMaxY(_headerView.frame))];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
}

-(void)_initPointMapView
{
    indoorView = [[YQInDoorPointMapView alloc]initWithIndoorMapImageName:[NSString stringWithFormat:@"%@",_floorModel.LAYER_MAP] Frame:CGRectMake(0, 0, KScreenWidth, bottomView.height)];
    indoorView.selInMapDelegate = self;
    [bottomView addSubview:indoorView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.bgMusicArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BgMusicListTabViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BgMusicListTabViewCell" forIndexPath:indexPath];
    cell.cellPlayMusicDelegate = self;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    InDoorBgMusicMapModel *model = self.bgMusicArr[indexPath.row];
    if (!model.isOpen) {
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.selectView.hidden = YES;
        cell.currentMusicLab.hidden = YES;
        cell.currentMusicDetailLab.hidden = YES;
        cell.changeMusicBtn.hidden = YES;
        cell.volumeAdjustLab.hidden = YES;
        cell.volumeAdjustSlider.hidden = YES;
        cell.musicMenuView.hidden = YES;
    }else{
        cell.contentView.backgroundColor = [UIColor colorWithHexString:@"F8FCFF"];
        cell.selectView.hidden = NO;
        cell.currentMusicLab.hidden = NO;
        cell.currentMusicDetailLab.hidden = NO;
        cell.changeMusicBtn.hidden = NO;
        cell.volumeAdjustLab.hidden = NO;
        cell.volumeAdjustSlider.hidden = NO;
        cell.musicMenuView.hidden = NO;
    }
//    cell.model = self.bgMusicArr[indexPath.row];
    cell.inDoorModel = self.bgMusicArr[indexPath.row];
    cell.volum = _volume;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row == _selectedIndex.row && _selectedIndex != nil ) {
//        if (isOpen == YES) {
//            return 225;
//        }else{
//            return 60;
//        }
//    }
    InDoorBgMusicMapModel *model = self.bgMusicArr[indexPath.row];
    if (model.isOpen) {
        return 225;
    }else{
        return 60;
    }
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [searchBar resignFirstResponder];
    
    NSMutableArray *indexPaths = @[].mutableCopy;
    if(indexPath.row < self.bgMusicArr.count){
        [indexPaths addObject:indexPath];
    }
    InDoorBgMusicMapModel *model = self.bgMusicArr[indexPath.row];
    _selMusicmodel = model;
    //判断选中不同row状态时候
    //    if (self.selectedIndex != nil && indexPath.row != selectedIndex.row) {
    if (self.selectedIndex != nil && indexPath.row == _selectedIndex.row) {
        //将选中的和所有索引都加进数组中
        //        indexPaths = [NSArray arrayWithObjects:indexPath,selectedIndex, nil];
        if (model.isOpen) {
            model.isOpen = NO;
        }else{
            model.isOpen = YES;
        }
    }else if (self.selectedIndex != nil && indexPath.row != _selectedIndex.row) {
        if(_selectedIndex.row < self.bgMusicArr.count){
            [indexPaths addObject:_selectedIndex];
            InDoorBgMusicMapModel *model1 = self.bgMusicArr[_selectedIndex.row];
            model1.isOpen = NO;
        }
        if (model.isOpen) {
            model.isOpen = NO;
        }else{
            model.isOpen = YES;
        }
    }else{
        if (model.isOpen) {
            model.isOpen = NO;
        }else{
            model.isOpen = YES;
        }
    }
    
    //记下选中的索引
    self.selectedIndex = indexPath;
    
    [self _loadTargetID:model.TAGID];
    
    //刷新
    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark menuDelegate and datasource
#pragma mark 菜单协议
- (CGFloat)menuHeightInView:(NSInteger)index {
    if(index == 0){
        return 60;
    }else if(index == 1){
        return 40;
    }else{
        return 50;
    }
}

- (NSInteger)menuNumInView {
    return 3;
}

- (NSString *)menuTitle:(NSInteger)index {
    switch (index) {
        case 0:
            return @"设备状态";
            break;
        case 1:
            return @"当前音乐";
            break;
        case 2:
            return @"音量调节";
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
            return TextAndImgConMenu;
            break;
        case 2:
            return SliderConMenu;
            break;
            
        default:
            return DefaultConMenu;
            break;
    }
}

- (NSString *)menuMessage:(NSInteger)index {
    if(index == 0){
        return _stateStr;
    }else if(index == 1){
        return _selMusicmodel.currentMusic;
    }else {
        return @"";
    }
}

- (UIColor *)menuMessageColor:(NSInteger)index {
    if(index == 0){
        return _stateColor;
    }else {
        return [UIColor blackColor];
    }
}

- (CGFloat)sliderMaxValue:(NSInteger)index {
    if(index == 2){
        return 56;
    }
    return 1;
}

- (NSString *)silderUnit:(NSInteger)index {
    return @"";
}

// 为SliderConMenu时实现，默认开关状态
- (CGFloat)sliderDefValue:(NSInteger)index {
    return _volume;
}

- (NSArray *)sliderImgs:(NSInteger)index {
    return @[@"_volume_redecing", @"_volume_addition"];
}

#pragma mark 滑动slider时调用
- (void)sliderChangeValue:(CGFloat)value {
    
    // 设置音箱设备音量
    NSString *urlStr = [NSString stringWithFormat:@"%@/music/setTermVolume?tId=%@&vol=%.0f", Main_Url, _selMusicmodel.TAGID,value*56];
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *responseData = responseObject[@"responseData"];
            if(responseData != nil && ![responseData isKindOfClass:[NSNull class]]){
                NSString *result = responseData[@"result"];
                if(result != nil && ![result isKindOfClass:[NSNull class]] && [result isEqualToString:@"success"]){
                    // 记录日志
                    [self logRecordTagId:_selMusicmodel.TAGID withOldVolume:_volume*56 withNewVolume:value*56];
                    // 设置成功
                    _volume = value;
                }
            }
        }else {
            NSString *message = responseObject[@"message"];
            if(message != nil && ![message isKindOfClass:[NSNull class]]){
                [self showHint:message];
            }
        }
        [_showMenuView reloadMenuData];
    } failure:^(NSError *error) {
        
    }];
}
#pragma mark 单个音箱设置音量
- (void)logRecordTagId:(NSString *)tagId withOldVolume:(CGFloat)OldVolume withNewVolume:(CGFloat)newVolume {
    NSString *volumeStr = [NSString stringWithFormat:@"设置\"%@\"音量", _selMusicmodel.DEVICE_NAME];
    
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:volumeStr forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:[NSString stringWithFormat:@"%@%.0f至%.0f", volumeStr, OldVolume, newVolume] forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"music/setTermVolume" forKey:@"operateUrl"];//操作url
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
    [logDic setObject:[NSString stringWithFormat:@"%.0f", newVolume] forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:tagId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"背景音乐" forKey:@"operateDeviceName"];//操作设备名  模块
    [logDic setObject:[NSString stringWithFormat:@"%.0f", OldVolume] forKey:@"expand1"];// 操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

// 右侧有图片时实现
- (NSString *)imageName:(NSInteger)index {
    if(index == 1){
        return @"music_refresh_icon";
    }
    
    return @"";
}

- (void)didSelectMenu:(NSInteger)index {
    if(index == 1){
        [self chooseMusicList];
    }
}

// 是背景音乐播放时实现
- (BOOL)isPlayMusicMenu {
    return YES;
}
#pragma mark 菜单协议/tableview cell菜单协议
- (void)sliderVolumValue:(CGFloat)volum {
    _volume = volum;
    
    [self sliderChangeValue:volum];
}
- (void)chooseMusicList {
    if(tabView.hidden){
        _isShowMenu = YES;
    }
    
    [self forceOrientationPortrait];
    
    // 更换背景音乐
    ChooseMusicViewController *chooseMusicVC = [[ChooseMusicViewController alloc] init];
    chooseMusicVC.changeMusicDelegate = self;
    chooseMusicVC.soundModel = _selectSoundModel;
    chooseMusicVC.musicMapModel = _selMusicmodel;
    chooseMusicVC.volume = [NSString stringWithFormat:@"%f", _volume*56];
    [self.navigationController pushViewController:chooseMusicVC animated:YES];
}
- (void)playMusic {
    if(_selectSoundModel == nil){
        _showMenuView.hidden = YES;
        // 当前无播放，跳转选取歌曲播放
        [self chooseMusicList];
    }else {
        // 恢复播放
        NSString *urlStr = [NSString stringWithFormat:@"%@/music/playipcastfilectrl/%@/6/0", Main_Url, _selectSoundModel.sid];
        [self reloadSendRequest:urlStr withOperate:[NSString stringWithFormat:@"背景音乐\"%@\"恢复播放", _selMusicmodel.DEVICE_NAME] withTagId:_selMusicmodel.TAGID];
    }
}
- (void)pauseMusic {
    if(_selectSoundModel != nil){
        // 暂停播放
        NSString *urlStr = [NSString stringWithFormat:@"%@/music/playipcastfilectrl/%@/5/0", Main_Url, _selectSoundModel.sid];
        [self reloadSendRequest:urlStr withOperate:[NSString stringWithFormat:@"背景音乐\"%@\"暂停", _selMusicmodel.DEVICE_NAME] withTagId:_selMusicmodel.TAGID];
    }else {
        [self showHint:@"当前无播放音乐"];
    }
}
- (void)stopMusic {
    if(_selectSoundModel != nil){
        // 停止播放
        NSString *urlStr = [NSString stringWithFormat:@"%@/music/playipcastfilectrl/%@/1/0", Main_Url, _selectSoundModel.sid];
        [self reloadSendRequest:urlStr withOperate:[NSString stringWithFormat:@"背景音乐\"%@\"停止", _selMusicmodel.DEVICE_NAME] withTagId:_selMusicmodel.TAGID];
    }else {
        [self showHint:@"当前无播放音乐"];
    }
}
- (void)upMusic {
    if(_selectSoundModel != nil){
        // 上一曲
        NSString *urlStr = [NSString stringWithFormat:@"%@/music/playipcastfilectrl/%@/4/0", Main_Url, _selectSoundModel.sid];
        [self reloadSendRequest:urlStr withOperate:[NSString stringWithFormat:@"背景音乐\"%@\"上一曲", _selMusicmodel.DEVICE_NAME] withTagId:_selMusicmodel.TAGID];
    }else {
        [self showHint:@"当前无播放音乐"];
    }
}
- (void)downMusic {
    if(_selectSoundModel != nil){
        // 下一曲
        NSString *urlStr = [NSString stringWithFormat:@"%@/music/playipcastfilectrl/%@/3/0", Main_Url, _selectSoundModel.sid];
        [self reloadSendRequest:urlStr withOperate:[NSString stringWithFormat:@"背景音乐\"%@\"下一曲", _selMusicmodel.DEVICE_NAME] withTagId:_selMusicmodel.TAGID];
    }else {
        [self showHint:@"当前无播放音乐"];
    }
}
- (void)reloadSendRequest:(NSString *)urlStr withOperate:(NSString *)operate withTagId:(NSString *)tagId {
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        NSDictionary *resDic = responseObject[@"responseData"];
        if(resDic == nil || [resDic isKindOfClass:[NSNull class]]){
            return ;
        }
        if ([resDic[@"result"] isEqualToString:@"success"]) {
            NSLog(@"++++++++音乐操作成功 刷新");
            [self _loadTargetID:_selMusicmodel.TAGID];
            // 记录日志
            [self logRecordOperate:operate withGroupId:tagId];
        }
    } failure:^(NSError *error) {
    }];
}

- (void)selInMapWithId:(NSString *)identity {
    
    NSInteger selectIndex = [identity integerValue]-100;
    if(self.bgMusicArr.count <= selectIndex){
        return;
    }
    InDoorBgMusicMapModel *model = self.bgMusicArr[selectIndex];
    _selMusicmodel = model;
    
    _showMenuView.hidden = NO;
    if([model.MUSIC_STATUS isEqualToString:@"1"]){
        // 正常
        _stateStr = @"正常开启中";
        _stateColor = [UIColor colorWithHexString:@"#189517"];
    }else if([model.MUSIC_STATUS isEqualToString:@"0"]){
        // 停止
        _stateStr = @"停止";
        _stateColor = [UIColor grayColor];
    }if([model.MUSIC_STATUS isEqualToString:@"2"]){
        // 暂停
        _stateStr = @"暂停";
        _stateColor = [UIColor blackColor];
    }else if([model.MUSIC_STATUS isEqualToString:@"5"]){
        _stateStr = @"故障";
        _stateColor = [UIColor grayColor];
    }else{
        _stateStr = @"离线";
        _stateColor = [UIColor grayColor];
    }
    
    _menuTitle = model.DEVICE_NAME;
    _selMusicmodel.currentMusic = @"";
    
//    [_showMenuView reloadMenuData]; //  刷新菜单
    
    if (_selectImageView) {
        _selectImageView.contentMode = UIViewContentModeScaleToFill;
        if(self.bgMusicArr.count <= _selectImageView.tag-100){
            return;
        }
        InDoorBgMusicMapModel *selectModel = self.bgMusicArr[_selectImageView.tag-100];
        // 开启 (0-停止, 1-播放, 2-暂停)  4-关闭 5 故障
        if (![selectModel.MUSIC_STATUS isEqualToString:@"5"]) {
            if([selectModel.DEVICE_TYPE isEqualToString:@"3"]){
                // 音柱
                _selectImageView.image = [UIImage imageNamed:@"map_music_icon_normal_3"];
            }else if ([selectModel.DEVICE_TYPE isEqualToString:@"3-3"]) {
                // 蘑菇头
                _selectImageView.image = [UIImage imageNamed:@"map_music_icon_normal_3-3"];
            }else if ([selectModel.DEVICE_TYPE isEqualToString:@"3-5"]) {
                // 蘑菇头
                _selectImageView.image = [UIImage imageNamed:@"map_music_icon_normal_3-5"];
            }
        }else{
            if([selectModel.DEVICE_TYPE isEqualToString:@"3"]){
                // 音柱
                _selectImageView.image = [UIImage imageNamed:@"map_music_icon_error_3"];
            }else if ([selectModel.DEVICE_TYPE isEqualToString:@"3-3"]) {
                // 蘑菇头
                _selectImageView.image = [UIImage imageNamed:@"map_music_icon_error_3-3"];
            }else if ([selectModel.DEVICE_TYPE isEqualToString:@"3-5"]) {
                // 吸顶式
                _selectImageView.image = [UIImage imageNamed:@"map_music_icon_error_3-5"];
            }
        }
    }
    
    // 复原之前选中图片效果
    if(_selectImageView != nil){
        [PointViewSelect recoverSelImgView:_selectImageView];
    }
    
    UIImageView *imageView = [indoorView.mapView viewWithTag:[identity integerValue]];
    if (![model.MUSIC_STATUS isEqualToString:@"5"]) {
        if([model.DEVICE_TYPE isEqualToString:@"3"]){
            // 音柱
            imageView.image = [UIImage imageNamed:@"map_music_icon_normal_3"];
        }else if ([model.DEVICE_TYPE isEqualToString:@"3-3"]) {
            // 蘑菇头
            imageView.image = [UIImage imageNamed:@"map_music_icon_normal_3-3"];
        }else if ([model.DEVICE_TYPE isEqualToString:@"3-5"]) {
            // 蘑菇头
            imageView.image = [UIImage imageNamed:@"map_music_icon_normal_3-5"];
        }
    }else{
        if([model.DEVICE_TYPE isEqualToString:@"3"]){
            // 音柱
            imageView.image = [UIImage imageNamed:@"map_music_icon_error_3"];
        }else if ([model.DEVICE_TYPE isEqualToString:@"3-3"]) {
            // 蘑菇头
            imageView.image = [UIImage imageNamed:@"map_music_icon_error_3-3"];
        }else if ([model.DEVICE_TYPE isEqualToString:@"3-5"]) {
            // 吸顶式
            imageView.image = [UIImage imageNamed:@"map_music_icon_error_3-5"];
        }
    }
    imageView.contentMode = UIViewContentModeScaleToFill;
    _selectImageView = imageView;
    
    [PointViewSelect pointImageSelect:_selectImageView];
    
    [self _loadTargetID:model.TAGID];
}

#pragma mark 选择音乐歌曲播放完成协议
- (void)changeMusicSuc:(NSString *)seccionId {
    [self _loadTargetID:_selMusicmodel.TAGID];
    if(tabView.hidden){
        _showMenuView.hidden = NO;
    }
}

#pragma mark 指定IP音箱设备当前播放音频名称
-(void)_loadTargetID:(NSString *)targetID
{
    [self showHudInView:_showMenuView hint:@""];
    NSString *urlStr = [NSString stringWithFormat:@"%@/music/getipcasttermsessionstatus/%@",Main_Url,targetID];
    
    // GCD创建组
    dispatch_group_t group = dispatch_group_create();

    // 查询当前播放音乐
    dispatch_group_enter(group);
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        dispatch_group_leave(group);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideHud];
        });
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSArray *arr = responseObject[@"responseData"];
            if(arr == nil || [arr isKindOfClass:[NSNull class]]){
                return ;
            }
            if(arr != nil && arr.count > 0){
                SoundModel *model = [[SoundModel alloc] initWithDataDic:arr.firstObject];
                _selectSoundModel = model;
                _selMusicmodel.currentMusic = model.name;
                _selMusicmodel.MUSIC_STATUS = [NSString stringWithFormat:@"%@", model.status];
                if([_selMusicmodel.MUSIC_STATUS isEqualToString:@"1"]){
                    // 正常
                    _stateStr = @"正常开启中";
                    _stateColor = [UIColor colorWithHexString:@"#189517"];
                }else if([_selMusicmodel.MUSIC_STATUS isEqualToString:@"0"]){
                    // 停止
                    _stateStr = @"停止";
                    _stateColor = [UIColor grayColor];
                }else if([_selMusicmodel.MUSIC_STATUS isEqualToString:@"2"]){
                    // 暂停
                    _stateStr = @"暂停";
                    _stateColor = [UIColor blackColor];
                }else if([_selMusicmodel.MUSIC_STATUS isEqualToString:@"5"]){
                    // 故障
                    _stateStr = @"故障";
                    _stateColor = [UIColor grayColor];
                }else {
                    _stateStr = @"离线";
                    _stateColor = [UIColor grayColor];
                }
                
//                [_showMenuView reloadMenuData];
                
                if(self.selectedIndex){
                    [tabView reloadRowsAtIndexPaths:@[self.selectedIndex] withRowAnimation:UITableViewRowAnimationFade];
                }
            }else {
                _selectSoundModel = nil;
                _selMusicmodel.currentMusic = @"";
                _selMusicmodel.MUSIC_STATUS = @"4";
                _stateStr = @"离线";
                _stateColor = [UIColor grayColor];
                
//                    [_showMenuView reloadMenuData];
                
                if(self.selectedIndex){
                    [tabView reloadRowsAtIndexPaths:@[self.selectedIndex] withRowAnimation:UITableViewRowAnimationFade];
                }
            }
        }
    } failure:^(NSError *error) {
        dispatch_group_leave(group);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideHud];
        });
    }];
    
    /*
    // 查询当前音量
    dispatch_group_enter(group);
    NSString *volumStr = [NSString stringWithFormat:@"%@/music/getipcastsometermstatus/%@",Main_Url,targetID];
    [[NetworkClient sharedInstance] GET:volumStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        dispatch_group_leave(group);
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSArray *arr = responseObject[@"responseData"];
            if(arr == nil || [arr isKindOfClass:[NSNull class]]){
                return ;
            }
            if(arr != nil && arr.count > 0){
                NSDictionary *volumDic = arr.firstObject;
                _volume = [volumDic[@"vol"] floatValue]/56;
                if(self.selectedIndex){
                    [tabView reloadRowsAtIndexPaths:@[self.selectedIndex] withRowAnimation:UITableViewRowAnimationFade];
                }
            }else {
                _volume = 0;
            }
//                [_showMenuView reloadMenuData];
        }
    } failure:^(NSError *error) {
        dispatch_group_leave(group);
    }];
     */
    
    // 查询音箱设备音量
    dispatch_group_enter(group);
    NSString *volumStr = [NSString stringWithFormat:@"%@/music/getTermVolume?tId=%@",Main_Url,targetID];
    [[NetworkClient sharedInstance] GET:volumStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        dispatch_group_leave(group);
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *responseData = responseObject[@"responseData"];
            if(responseData == nil || [responseData isKindOfClass:[NSNull class]]){
                return ;
            }
            NSNumber *vol = responseData[@"vol"];
            if(vol != nil && ![vol isKindOfClass:[NSNull class]]){
                _volume = [vol floatValue]/56;
                if(self.selectedIndex){
                    [tabView reloadRowsAtIndexPaths:@[self.selectedIndex] withRowAnimation:UITableViewRowAnimationFade];
                }
            }else {
                _volume = 0;
            }
            //                [_showMenuView reloadMenuData];
        }
    } failure:^(NSError *error) {
        dispatch_group_leave(group);
    }];
    
    //监视函数
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [_showMenuView reloadMenuData];
    });
}

#pragma mark uisearchBar delegate

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [_nameArr removeAllObjects];
    
    [_dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        InDoorBgMusicMapModel *model = (InDoorBgMusicMapModel *)obj;
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
    
    [self.bgMusicArr removeAllObjects];
    if (searchBar.text.length == 0) {
        [self.bgMusicArr addObjectsFromArray:_dataArr];
    }else{
        [self.bgMusicArr addObjectsFromArray:_failtArr];
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
    
    [self.bgMusicArr removeAllObjects];
    if (searchText.length == 0) {
        [self.bgMusicArr addObjectsFromArray:_dataArr];
    }else{
        [self.bgMusicArr addObjectsFromArray:_failtArr];
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
            
            [self.bgMusicArr removeAllObjects];
            [self.bgMusicArr addObjectsFromArray:_dataArr];
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

- (void)logRecordOperate:(NSString *)operate withGroupId:(NSString *)groupId {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:operate forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:operate forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"music/playipcastfilectrl" forKey:@"operateUrl"];//操作url
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:groupId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"背景音乐" forKey:@"operateDeviceName"];//操作设备名  模块
    //    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
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
