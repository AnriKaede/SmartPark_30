//
//  ChooseMusicViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/7.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ChooseMusicViewController.h"
#import "ShowMenuView.h"
#import "ChooseMusicTabCell.h"

#import "MusicListModel.h"
#import "NoDataView.h"

@interface ChooseMusicViewController ()<UITableViewDataSource,UITableViewDelegate, PlayMusicDelegate, CYLTableViewPlaceHolderDelegate>

@property (nonatomic,strong) NSMutableArray *dataArr;

@end

@implementation ChooseMusicViewController

-(NSMutableArray *)dataArr{
    if (_dataArr == nil) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _initNavItems];
    
    [self _initView];
    
    [self _loadData];
}

-(void)_initView
{
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"ChooseMusicTabCell" bundle:nil] forCellReuseIdentifier:@"ChooseMusicTabCell"];
    self.tableView.mj_footer.hidden = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight-64);
}

-(void)headerRereshing{
    [self _loadData];
}

#pragma mark 获取背景音乐平台已有的音频文件列表
-(void)_loadData
{
    [self showHudInView:self.view hint:@""];
    NSString *urlStr = [NSString stringWithFormat:@"%@/music/getipcastfilelist",Main_Url];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        [self.tableView.mj_header endRefreshing];
        if (self.dataArr.count != 0) {
            [self.dataArr removeAllObjects];
        }
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSArray *arr = responseObject[@"responseData"];
            if(arr != nil && ![arr isKindOfClass:[NSNull class]]){
                [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    MusicListModel *model = [[MusicListModel alloc] initWithDataDic:obj];
                    //                if ([model.name isEqualToString:_soundModel.name]) {
                    //                    model.isPlay = YES;
                    //                }
                    [self.dataArr addObject:model];
                }];
            }
        }
        [self.tableView cyl_reloadData];
    } failure:^(NSError *error) {
        [self hideHud];
        [self.tableView.mj_header endRefreshing];
    }];
}

-(void)_initNavItems
{
    self.title = @"选择音乐";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDateView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64-49)];
    noDateView.delegate = self;
    return noDateView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark UItableView协议
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
    ChooseMusicTabCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChooseMusicTabCell" forIndexPath:indexPath];
    cell.model = self.dataArr[indexPath.row];
    cell.playMusicDelegate = self;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 播放歌曲协议
- (void)playMusicWithFile:(MusicListModel *)musicListModel {
    
    if(_musicGroupModel != nil){
        // 分组播放
        [self playGroupMusic:musicListModel];
        return;
    }
    
    /*
     播放指定歌曲
     1、当前无正在播放歌曲时，直接调用接口播放
     2、当前有播放歌曲时需要先停止当前播放歌曲playipcastfilectrl(Param2:控制命令 1:停止), 再调用播放接口
     */
    
    
    if(_soundModel != nil && _soundModel.sid != nil && ![_soundModel.sid isKindOfClass:[NSNull class]]){
        // 当前有播放歌曲
        // 停止当前歌曲
        NSString *urlStr = [NSString stringWithFormat:@"%@/music/playipcastfilectrl/%@/1/0", Main_Url, _soundModel.sid];
        [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
            NSDictionary *resDic = responseObject[@"responseData"];
            if(resDic == nil || [resDic isKindOfClass:[NSNull class]]){
                return ;
            }
            if ([resDic[@"result"] isEqualToString:@"success"]) {
                NSLog(@"停止成功");
                [self playMusicWithModel:musicListModel];
                // 记录日志
                [self logRecordOperate:[NSString stringWithFormat:@"背景音乐\"%@\"停止", _musicMapModel.DEVICE_NAME] withGroupId:[NSString stringWithFormat:@"%@", _soundModel.sid] withUrl:@"music/playipcastfilectrl"];
            }
        } failure:^(NSError *error) {
        }];
    }else {
        [self playMusicWithModel:musicListModel];
    }
    
}
- (void)playMusicWithModel:(MusicListModel *)musicListModel {
    
    NSMutableString *fidStr = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@", musicListModel.fid]];
    [_dataArr enumerateObjectsUsingBlock:^(MusicListModel *musicModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if(![musicModel.fid isEqual:musicListModel.fid]){
            [fidStr appendFormat:@",%@", musicModel.fid];
        }
    }];
    
    NSString *tagId = @""; // 终端id 测试设定设备1
    if(_musicMapModel != nil && ![_musicMapModel.TAGID isKindOfClass:[NSNull class]]){
        tagId = _musicMapModel.TAGID;
    }else if (_outMusicMapModel != nil && ![_outMusicMapModel.TAGID isKindOfClass:[NSNull class]]) {
        tagId = _outMusicMapModel.TAGID;
    }
//    else if (_musicGroupModel != nil && ![_musicGroupModel.tids isKindOfClass:[NSNull class]]) {
//        NSMutableString *tids = @"".mutableCopy;
//        [_musicGroupModel.tids enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if(idx == _musicGroupModel.tids.count - 1){
//                [tids appendFormat:@"%@", obj];
//            }else {
//                [tids appendFormat:@"%@,", obj];
//            }
//        }];
//        tagId = tids;
//    }
    
    /*
     1;单曲播放（即只播放一次）
     2;单曲循环播放（循环播放一个曲目）
     3;顺序播放（按序播放全部歌曲一次）
     4;循环播放（循环播放所有歌曲）
     */
    NSString *playModel = @"4"; // 循环播放
    NSString *volume = [NSString stringWithFormat:@"%ld", _volume.integerValue]; // 音量0~56,0最小,56最大, 整数
    NSString *urlStr = [NSString stringWithFormat:@"%@/music/playipcastfilelist/%@/%@/%@/%@/%@/0/%@", Main_Url, fidStr, tagId, @"100", playModel, @"1", volume];
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        if([responseObject[@"responseData"] isKindOfClass:[NSDictionary class]]){
            NSDictionary *resDic = responseObject[@"responseData"];
            if(resDic == nil || [resDic isKindOfClass:[NSNull class]]){
                return ;
            }
            if (resDic[@"sessionID"] != nil && ![resDic[@"sessionID"] isKindOfClass:[NSNull class]]) {
                [self showHint:@"播放成功"];
                if(_changeMusicDelegate){
                    [_changeMusicDelegate changeMusicSuc:resDic[@"sessionID"]];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                // 记录日志
                [self logRecordOperate:[NSString stringWithFormat:@"背景音乐\"%@\"播放", _musicMapModel.DEVICE_NAME] withGroupId:[NSString stringWithFormat:@"%@", tagId] withUrl:@"music/playipcastfilelist"];
            }
        }
    } failure:^(NSError *error) {
    }];
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

#pragma mark 分组播放
- (void)playGroupMusic:(MusicListModel *)musicListModel {
    NSMutableString *fidStr = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@", musicListModel.fid]];
    [_dataArr enumerateObjectsUsingBlock:^(MusicListModel *musicModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if(![musicModel.fid isEqual:musicListModel.fid]){
            [fidStr appendFormat:@",%@", musicModel.fid];
        }
    }];
    NSString *volume = [NSString stringWithFormat:@"%ld", _volume.integerValue]; // 音量0~56,0最小,56最大, 整数
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/music/getgroupinfobygroupid/%@/0/%@/%@/%@", Main_Url, _musicGroupModel.gid, musicListModel.fid, volume, fidStr];
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        if([responseObject[@"responseData"] isKindOfClass:[NSDictionary class]]){
            NSDictionary *resDic = responseObject[@"responseData"];
            if(resDic == nil || [resDic isKindOfClass:[NSNull class]]){
                return ;
            }
            if (resDic[@"sessionID"] != nil && ![resDic[@"sessionID"] isKindOfClass:[NSNull class]]) {
                [self showHint:@"播放成功"];
                if(_changeMusicDelegate){
                    [_changeMusicDelegate changeGroupMusicSuc:resDic[@"sessionID"] withVolum:_volume];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                // 记录日志
                [self logRecordOperate:@"背景音乐区域分组播放" withGroupId:[NSString stringWithFormat:@"%@", _musicGroupModel.gid] withUrl:@"music/getgroupinfobygroupid"];
            }
        }
    } failure:^(NSError *error) {
    }];
}

- (void)logRecordOperate:(NSString *)operate withGroupId:(NSString *)groupId withUrl:(NSString *)url {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:operate forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:operate forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:url forKey:@"operateUrl"];//操作url
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:groupId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"背景音乐" forKey:@"operateDeviceName"];//操作设备名  模块
    //    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

- (SwitchBlock)isSwitchBlock:(NSInteger)index {
    SwitchBlock switchBlockOne = ^(BOOL isOn) {
        
    };
    return switchBlockOne;
}

@end
