//
//  DefineTimeTaskViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/12/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "DefineTimeTaskViewController.h"
#import "TimeTaskCell.h"
#import "MusicTimeModel.h"
#import "NoDataView.h"

@interface DefineTimeTaskViewController ()<UITableViewDelegate,UITableViewDataSource, CYLTableViewPlaceHolderDelegate, PlayStopMusicDelegate>
{
    NSMutableArray *_taskData;
}
@end

@implementation DefineTimeTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _taskData = @[].mutableCopy;
    
    [self _initView];
    
    [self _loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadData) name:@"StopAllMusic" object:nil];
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
    [self.tableView registerNib:[UINib nibWithNibName:@"TimeTaskCell" bundle:nil] forCellReuseIdentifier:@"TimeTaskCell"];
    
}

-(void)headerRereshing{
    [self _loadData];
}

- (void)_loadData {
    NSString *stopUrl = [NSString stringWithFormat:@"%@/music/getSchedTaskList", Main_Url];
    [[NetworkClient sharedInstance] GET:stopUrl dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        [self.tableView.mj_header endRefreshing];
        if(responseObject[@"code"] != nil && ![responseObject[@"code"] isKindOfClass:[NSNull class]] &&  [responseObject[@"code"] isEqualToString:@"1"]){
            NSArray *responseData = responseObject[@"responseData"];
            if(responseData != nil && ![responseData isKindOfClass:[NSNull class]]){
                [_taskData removeAllObjects];
                [responseData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    MusicTimeModel *timeModel = [[MusicTimeModel alloc] initWithDataDic:obj];
                    [_taskData addObject:timeModel];
                }];
                
                [self.tableView cyl_reloadData];
            }
        }
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
        if(_taskData.count <= 0){
            [self showNoDataImage];
        }else {
            [self showHint:KRequestFailMsg];
        }
    }];
}
// 无网络重载
- (void)reloadTableData {
    [self _loadData];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDateView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64-49)];
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
    return _taskData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    TimeTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimeTaskCell" forIndexPath:indexPath];
    cell.musicTimeModel = _taskData[indexPath.row];
    cell.musicDelegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MusicTimeModel *musicTimeModel = _taskData[indexPath.row];
    if(musicTimeModel.isSelect){
        return 120;
    }else {
        return 75;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_taskData enumerateObjectsUsingBlock:^(MusicTimeModel *musicTimeModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if(idx == indexPath.row){
            musicTimeModel.isSelect = !musicTimeModel.isSelect;
        }else {
            musicTimeModel.isSelect = NO;
        }
    }];
    
    [tableView reloadData];
}

#pragma mark 播放/停止
- (void)playStopMusic:(MusicTimeModel *)musicTimeModel {
    if(musicTimeModel.status.integerValue == 0){
        // 未启动状态， 调用播放
        [self playTask:musicTimeModel];
    }else if(musicTimeModel.status.integerValue == 1){
        // 启动状态， 调用停止
        [self stopTask:musicTimeModel];
    }
}

- (void)playTask:(MusicTimeModel *)musicTimeModel {
    NSString *playUrl = [NSString stringWithFormat:@"%@/music/startSchedTask/%@", Main_Url, musicTimeModel.musicTimeId];
    [[NetworkClient sharedInstance] GET:playUrl dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self.tableView.mj_header endRefreshing];
        if(responseObject[@"code"] != nil && ![responseObject[@"code"] isKindOfClass:[NSNull class]] &&  [responseObject[@"code"] isEqualToString:@"1"]){
            NSDictionary *responseData = responseObject[@"responseData"];
            if(responseData != nil && ![responseData isKindOfClass:[NSNull class]]){
                NSString *result = responseData[@"result"];
                if(result != nil && ![result isKindOfClass:[NSNull class]] && [result isEqualToString:@"success"]){
                    musicTimeModel.status = [NSNumber numberWithInteger:1];
                    NSInteger index = [_taskData indexOfObject:musicTimeModel];
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                    // 记录日志
                    [self logRecordOpreate:[NSString stringWithFormat:@"播放定时任务%@",  musicTimeModel.name] withTaskId:[NSString stringWithFormat:@"%@", musicTimeModel.musicTimeId] withUrl:@"music/startSchedTask"];
                }
            }
        }else {
            if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
                [self showHint:responseObject[@"message"]];
            }
        }
        
    } failure:^(NSError *error) {
    }];
}

- (void)stopTask:(MusicTimeModel *)musicTimeModel {
    NSString *playUrl = [NSString stringWithFormat:@"%@/music/stopSchedTask/%@", Main_Url, musicTimeModel.musicTimeId];
    [[NetworkClient sharedInstance] GET:playUrl dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self.tableView.mj_header endRefreshing];
        if(responseObject[@"code"] != nil && ![responseObject[@"code"] isKindOfClass:[NSNull class]] &&  [responseObject[@"code"] isEqualToString:@"1"]){
            NSDictionary *responseData = responseObject[@"responseData"];
            if(responseData != nil && ![responseData isKindOfClass:[NSNull class]]){
                NSString *result = responseData[@"result"];
                if(result != nil && ![result isKindOfClass:[NSNull class]] && [result isEqualToString:@"success"]){
                    musicTimeModel.status = [NSNumber numberWithInteger:0];
                    NSInteger index = [_taskData indexOfObject:musicTimeModel];
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                    // 记录日志
                    [self logRecordOpreate:[NSString stringWithFormat:@"停止定时任务%@",  musicTimeModel.name] withTaskId:[NSString stringWithFormat:@"%@", musicTimeModel.musicTimeId] withUrl:@"music/stopSchedTask"];
                }
            }
        }else {
            if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
                [self showHint:responseObject[@"message"]];
            }
        }
    } failure:^(NSError *error) {
    }];
}

#pragma mark 调节音量协议
- (void)sliderModel:(MusicTimeModel *)musicTimeModel withVol:(CGFloat)vol {
    NSLog(@"====== %f", vol*56);
//    musicTimeModel.vol = [NSNumber numberWithFloat:vol*56];
    
    NSString *playUrl = [NSString stringWithFormat:@"%@/music/modifySchedTaskVoice/%@/%.0f", Main_Url, musicTimeModel.musicTimeId, vol*56];
    [[NetworkClient sharedInstance] GET:playUrl dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self.tableView.mj_header endRefreshing];
        if(responseObject[@"code"] != nil && ![responseObject[@"code"] isKindOfClass:[NSNull class]] &&  [responseObject[@"code"] isEqualToString:@"1"]){
            NSDictionary *responseData = responseObject[@"responseData"];
            if(responseData != nil && ![responseData isKindOfClass:[NSNull class]]){
                NSString *result = responseData[@"result"];
                if(result != nil && ![result isKindOfClass:[NSNull class]] && [result isEqualToString:@"success"]){
                    
                    // 记录日志
                    [self logRecordVolOpreate:[NSString stringWithFormat:@"定时任务%@修改音量",  musicTimeModel.name] withTaskId:[NSString stringWithFormat:@"%@", musicTimeModel.musicTimeId] withUrl:@"music/modifySchedTaskVoice" withOldVol:musicTimeModel.vol.floatValue withNowVol:vol*56];
                    
                    musicTimeModel.vol = [NSNumber numberWithFloat:vol*56];
                }
            }
        }else {
            NSString *message = responseObject[@"message"];
            if(message != nil && ![message isKindOfClass:[NSNull class]]){
                [self showHint:message];
            }
        }
        
        NSInteger modelRow = [_taskData indexOfObject:musicTimeModel];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:modelRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
    } failure:^(NSError *error) {
    }];
}

#pragma mark 记录日志
- (void)logRecordOpreate:(NSString *)opreate withTaskId:(NSString *)taskId withUrl:(NSString *)url {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:opreate forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:opreate forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:url forKey:@"operateUrl"];//操作url
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:taskId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"背景音乐" forKey:@"operateDeviceName"];//操作设备名  模块
//    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

#pragma mark 记录音量调节日志
- (void)logRecordVolOpreate:(NSString *)opreate withTaskId:(NSString *)taskId withUrl:(NSString *)url withOldVol:(CGFloat)oldVol withNowVol:(CGFloat)nowVol {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:opreate forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:[NSString stringWithFormat:@"%@ %.0f至%.0f", opreate, oldVol, nowVol] forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:url forKey:@"operateUrl"];//操作url
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:taskId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"背景音乐" forKey:@"operateDeviceName"];//操作设备名  模块
    [logDic setObject:[NSString stringWithFormat:@"%.0f", nowVol] forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:[NSString stringWithFormat:@"%.0f", oldVol] forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"StopAllMusic" object:nil];
}

@end
