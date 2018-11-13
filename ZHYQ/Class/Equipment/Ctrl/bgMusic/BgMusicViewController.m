//
//  BgMusicViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/7.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BgMusicViewController.h"
#import "YQHeaderView.h"
#import "YQSecondHeaderView.h"

#import "inDoorMusicTabCell.h"

#import "ChooseMusicViewController.h"

//#import "BgMusicCenterViewController.h"
#import "MusicGroupViewController.h"

#import "BgMusicModel.h"
#import "MusicGroupModel.h"

#import "NoDataView.h"

@interface BgMusicViewController ()<UITableViewDelegate,UITableViewDataSource,inDoorChooseMusicDelegate, ChangeMusicSuccessDelegate, CYLTableViewPlaceHolderDelegate>
{
//    YQHeaderView *headerView;
    YQSecondHeaderView *headerView;
    
    
    NSString *_openStr;
    NSString *_closeStr;
    NSString *_brokenStr;
    
    NSMutableArray *_groupData;
    
    NSIndexPath *_chooseIndexPath;
}

@property (nonatomic,strong) NSMutableArray *dataArr;

@end

@implementation BgMusicViewController

-(NSMutableArray *)dataArr
{
    if (_dataArr == nil) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _groupData = @[].mutableCopy;
    
    [self _initView];
    
    [self _initNavItems];
    
//    [self _loadBgMusicData];
    
    [self _loadMusicGroup];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadMusicGroup) name:@"StopAllMusic" object:nil];
}

-(void)_initView
{
    [self.view addSubview:self.tableView];
    self.tableView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64-65);
    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    self.tableView.mj_header.hidden = YES;
    self.tableView.mj_footer.hidden = YES;
    [self.tableView registerNib:[UINib nibWithNibName:@"inDoorMusicTabCell" bundle:nil] forCellReuseIdentifier:@"inDoorMusicTabCell"];
}

-(void)_initNavItems
{
    self.title = @"背景音乐";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
}

- (void)headerRereshing {
//    [self _loadBgMusicData];
    [self _loadMusicGroup];
}

/*
#pragma mark 获取背景音乐数据
-(void)_loadBgMusicData
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/music/status/0",Main_Url];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        
        [self.dataArr removeAllObjects];
        NSDictionary *dataDic = responseObject;
        if ([dataDic[@"code"] isEqualToString:@"1"]) {
            
            NSDictionary *responseData = dataDic[@"responseData"];
            _openStr = responseData[@"on"];
            _closeStr = responseData[@"off"];
            _brokenStr = responseData[@"fault"];
            
            NSArray *arr = responseData[@"items"];
            
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                BgMusicModel *model = [[BgMusicModel alloc] initWithDataDic:obj];
                [self.dataArr addObject:model];
            }];
            
        }
        
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}
 */

#pragma mark 获取音乐分组
- (void)_loadMusicGroup {
    NSString *urlStr = [NSString stringWithFormat:@"%@/music/getipcastgrouplist",Main_Url];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        [self.tableView.mj_header endRefreshing];
        [_groupData removeAllObjects];
        NSDictionary *dataDic = responseObject;
        
        if ([dataDic[@"code"] isKindOfClass:[NSNull class]]) {
            [self showHint:@"暂无数据"];
            return;
        }
        
        if ([dataDic[@"code"] isEqualToString:@"1"]) {
            
            NSArray *groups = dataDic[@"responseData"];
            
            [groups enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                MusicGroupModel *model = [[MusicGroupModel alloc] initWithDataDic:obj];
                [_groupData addObject:model];
            }];
            [self.tableView cyl_reloadData];
        }
        
        [self.tableView cyl_reloadData];
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
        if(_groupData.count <= 0){
            [self showNoDataImage];
        }else {
            [self showHint:KRequestFailMsg];
        }
    }];
}
// 无网络重载
- (void)reloadTableData {
    [self _loadMusicGroup];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDateView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 49, KScreenWidth, self.tableView.height-49)];
    noDateView.label.text = @"无结果";
    return noDateView;
}

- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _groupData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    inDoorMusicTabCell *indoorCell = (inDoorMusicTabCell *)[tableView dequeueReusableCellWithIdentifier:@"inDoorMusicTabCell"];
    indoorCell.inDoorDelegate = self;
    indoorCell.musicGroupModel = _groupData[indexPath.row];

    return indoorCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 270;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    headerView = [[YQSecondHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 85)];
    headerView.backgroundColor = [UIColor colorWithHexString:@"1B82D1"];
    headerView.openNumLab.text = _openStr;
    headerView.brokenLab.text = @"故障";
    headerView.brokenNumLab.text = _closeStr;
//    headerView.leftNumLab.text = _openStr;
//    headerView.centerNumLab.text = _closeStr;
//    headerView.rightNumLab.text = _brokenStr;
    
//    return headerView;
    
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    return 85;
    return 0.1;
}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 音乐选择协议
-(void)inDoor_chooseMusicTap:(MusicGroupModel *)groupModel withVolum:(CGFloat)volum {
    [self chooseMusicPlay:groupModel withVolum:volum];
}
- (void)chooseMusicPlay:(MusicGroupModel *)groupModel withVolum:(CGFloat)volum {
    NSInteger index = [_groupData indexOfObject:groupModel];
    _chooseIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    ChooseMusicViewController *chooseMusicVC = [[ChooseMusicViewController alloc] init];
    chooseMusicVC.musicGroupModel = groupModel;
    chooseMusicVC.volume = [NSString stringWithFormat:@"%f", volum*56];
    chooseMusicVC.changeMusicDelegate = self;
    [self.navigationController pushViewController:chooseMusicVC animated:YES];
}

#pragma mark 跳转室内外音乐详情
-(void)inDoor_seeDetailsClick:(MusicGroupModel *)musicGroupModel
{
    /*
    // 根据参数判断跳转室内外
    BgMusicCenterViewController *bgCenterVC = [[BgMusicCenterViewController alloc] init];
    bgCenterVC.index = 0;
//    bgCenterVC.index = 1;   // 室外
    bgCenterVC.menuID = self.menuID;
    [self.navigationController pushViewController:bgCenterVC animated:YES];
     */
    
    MusicGroupViewController *musicVC = [[MusicGroupViewController alloc] init];
    musicVC.menuID = [NSString stringWithFormat:@"%@",self.menuID];
    musicVC.title = @"背景音乐";
    [self.navigationController pushViewController:musicVC animated:YES];
}

// 下一曲
- (void)downMusic:(MusicGroupModel *)musicGroupModel {
    NSString *urlStr = [NSString stringWithFormat:@"%@/music/getgroupinfobygroupid/%@/3/0/0/0", Main_Url, musicGroupModel.gid];
    [self reloadSendRequest:urlStr withModel:musicGroupModel withOperate:[NSString stringWithFormat:@"背景音乐\"%@\"下一曲", musicGroupModel.name]];
}

// 暂停
- (void)pauseMusic:(MusicGroupModel *)musicGroupModel {
    NSString *urlStr = [NSString stringWithFormat:@"%@/music/getgroupinfobygroupid/%@/5/0/0/0", Main_Url, musicGroupModel.gid];
    [self reloadSendRequest:urlStr withModel:musicGroupModel withOperate:[NSString stringWithFormat:@"背景音乐\"%@\"暂停", musicGroupModel.name]];
}

// 恢复播放
- (void)playMusic:(MusicGroupModel *)musicGroupModel withVolum:(CGFloat)volum {
    if(musicGroupModel.status.integerValue == 0){
        // 离线状态 未播放
        [self chooseMusicPlay:musicGroupModel withVolum:volum];
    }else {
        NSString *urlStr = [NSString stringWithFormat:@"%@/music/getgroupinfobygroupid/%@/6/0/0/0", Main_Url, musicGroupModel.gid];
        [self reloadSendRequest:urlStr withModel:musicGroupModel withOperate:[NSString stringWithFormat:@"背景音乐\"%@\"恢复播放", musicGroupModel.name]];
    }
}

// 停止
- (void)stopMusic:(MusicGroupModel *)musicGroupModel {
    NSString *urlStr = [NSString stringWithFormat:@"%@/music/getgroupinfobygroupid/%@/1/0/0/0", Main_Url, musicGroupModel.gid];
    [self reloadSendRequest:urlStr withModel:musicGroupModel withOperate:[NSString stringWithFormat:@"背景音乐\"%@\"停止", musicGroupModel.name]];
}

// 上一曲
- (void)upMusic:(MusicGroupModel *)musicGroupModel {
    NSString *urlStr = [NSString stringWithFormat:@"%@/music/getgroupinfobygroupid/%@/4/0/0/0", Main_Url, musicGroupModel.gid];
    [self reloadSendRequest:urlStr withModel:musicGroupModel withOperate:[NSString stringWithFormat:@"背景音乐\"%@\"上一曲", musicGroupModel.name]];
}

- (void)reloadSendRequest:(NSString *)urlStr withModel:(MusicGroupModel *)musicGroupModel withOperate:(NSString *)operate {
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        NSDictionary *resDic = responseObject[@"responseData"];
        if(resDic != nil && ![resDic isKindOfClass:[NSNull class]]){
            if ([resDic[@"result"] isEqualToString:@"success"]) {
                NSLog(@"++++++++音乐操作成功 刷新");
                
                // 重新查询音箱工作状态
                [self queryIpInfoWithModel:musicGroupModel];
                // 记录日志
                [self logRecordOperate:operate withGroupId:[NSString stringWithFormat:@"%@", musicGroupModel.gid]];
            }
        }else {
            // 重新查询音箱工作状态
            [self queryIpInfoWithModel:musicGroupModel];
        }
    } failure:^(NSError *error) {
    }];
}
- (void)queryIpInfoWithModel:(MusicGroupModel *)musicGroupModel {
    if(musicGroupModel.tids.count <= 0){
        return;
    }
    if(musicGroupModel.tids == nil || [musicGroupModel.tids isKindOfClass:[NSNull class]] || musicGroupModel.tids.count <= 0){
        return;
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@/music/getipcasttermsessionstatus/%@", Main_Url, musicGroupModel.tids.firstObject];
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSArray *arr = responseObject[@"responseData"];
            if(arr != nil && arr.count > 0){
                SoundModel *model = [[SoundModel alloc] initWithDataDic:arr.firstObject];
                musicGroupModel.musicname = model.name;
                musicGroupModel.status = model.status;
                
            }else {
                musicGroupModel.musicname = @"";
                musicGroupModel.status = @0;
            }
            NSInteger index = [_groupData indexOfObject:musicGroupModel];
            _chooseIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView reloadRowAtIndexPath:_chooseIndexPath withRowAnimation:UITableViewRowAnimationFade];
        }
    } failure:^(NSError *error) {
    }];
}
- (void)sendRequestWithUrl:(NSString *)urlStr withModel:(MusicGroupModel *)musicGroupModel {
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        NSDictionary *resDic = responseObject[@"responseData"];
        if ([resDic[@"result"] isEqualToString:@"success"]) {
            NSLog(@"++++++++音乐操作成功");
        }
    } failure:^(NSError *error) {
    }];
}

#pragma mark 分组跟换音乐成功协议
- (void)changeGroupMusicSuc:(NSString *)seccionId withVolum:(NSString *)volum {
    MusicGroupModel *model = _groupData[_chooseIndexPath.row];
    model.vol = [NSNumber numberWithString:volum];
    [self queryIpInfoWithModel:model];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"StopAllMusic" object:nil];
}

- (void)logRecordOperate:(NSString *)operate withGroupId:(NSString *)groupId {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:operate forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:operate forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"music/getgroupinfobygroupid" forKey:@"operateUrl"];//操作url
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:groupId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"背景音乐" forKey:@"operateDeviceName"];//操作设备名  模块
//    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

@end
