//
//  FountainViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/7.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "FountainViewController.h"
#import "FountainTableViewCell.h"
#import "YQHeaderView.h"

#import "FountainModel.h"
#import "MeetRoomStateModel.h"

#import <SCLAlertView.h>

@interface FountainViewController ()<UITableViewDelegate,UITableViewDataSource,ConSwitchDelegate, CYLTableViewPlaceHolderDelegate>
{
    YQHeaderView *headerView;
    NSString *_leftNum;
    NSString *_centerNum;
    NSString *_rightNum;
    
    UIView *_bottomView;
    UIButton *_allCloseButton;
    UIButton *_allOpenButton;
}
@property (nonatomic,assign) NSInteger stateType;   // 0: 全关; 1: 全开; 2: 未控制

@property (nonatomic,strong) NSMutableArray *dataArr;

@end

@implementation FountainViewController

-(NSMutableArray *)dataArr
{
    if (_dataArr == nil) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _stateType = 2; // 未控制
    
    [self _initView];
    
    [self _initNavItems];
    
    [self _loadData];
}

-(void)_initView
{
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[FountainTableViewCell class] forCellReuseIdentifier:@"FountainTableViewCellID"];
    self.tableView.mj_footer.hidden = YES;
    self.tableView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight-64 - 60);
    
    // 下方全关/开控制
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, KScreenHeight - kTopHeight - 60, KScreenWidth, 60)];
    [self.view addSubview:_bottomView];
    
    _allCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _allCloseButton.frame = CGRectMake(0, 0, KScreenWidth/2, 60);
    [_allCloseButton setImage:[UIImage imageNamed:@"scene_all_close"] forState:UIControlStateNormal];
    [_allCloseButton setTitle:@" 批量模式" forState:UIControlStateNormal];
    [_allCloseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_allCloseButton setBackgroundImage:[UIImage imageNamed:@"scene_all_close_bg"] forState:UIControlStateNormal];
    [_allCloseButton addTarget:self action:@selector(allConModel) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_allCloseButton];
    
    _allOpenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _allOpenButton.backgroundColor = [UIColor colorWithHexString:@"#1B82D1 "];
    _allOpenButton.frame = CGRectMake(KScreenWidth/2, 0, KScreenWidth/2, 60);
    [_allOpenButton setImage:[UIImage imageNamed:@"view_show"] forState:UIControlStateNormal];
    [_allOpenButton setTitle:@" 观赏模式" forState:UIControlStateNormal];
    [_allOpenButton setTitleColor:[UIColor colorWithHexString:@"#CCFF00"] forState:UIControlStateNormal];
    [_allOpenButton addTarget:self action:@selector(viewModel) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_allOpenButton];
}

-(void)_initNavItems
{
//    self.title = @"音乐喷泉";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
}

-(void)headerRereshing
{
    [self _loadData];
}

#pragma mark 批量模式
- (void)allConModel {
    if(KScreenWidth > 440){
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        
        __weak typeof(alert) weakAlert = alert;
        [alert addButton:@"设备全开" actionBlock:^(void) {
            _stateType = 1;
            [self allConScene:@"pquan_on"];
            [weakAlert hideView];
        }];
        
        [alert addButton:@"设备全关" actionBlock:^(void) {
            _stateType = 0;
            [self allConScene:@"pquan_off"];
            // 关闭音乐
            if(_dataArr.count > 0){
                FountainModel *model = _dataArr.firstObject;
                [self colseFountainMusic:model];
            }
            [weakAlert hideView];
        }];
        
        UIColor *edtionColor = [UIColor colorWithHexString:@"#218ee6"];
        [alert showCustom:[UIApplication sharedApplication].delegate.window.rootViewController image:[UIImage imageNamed:@"fountain_logo"] color:edtionColor title:@"请选择批量模式" subTitle:@"" closeButtonTitle:@"取消" duration:0.0f];
        
        return;
    }
    
    // iPhone
    UIAlertController *sheetCon = [UIAlertController alertControllerWithTitle:@"" message:@"请选择批量模式" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    UIAlertAction *openModel = [UIAlertAction actionWithTitle:@"设备全开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _stateType = 1;
        [self allConScene:@"pquan_on"];
    }];
    
    UIAlertAction *closeModel = [UIAlertAction actionWithTitle:@"设备全关" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        _stateType = 0;
        [self allConScene:@"pquan_off"];
        // 关闭音乐
        if(_dataArr.count > 0){
            FountainModel *model = _dataArr.firstObject;
            [self colseFountainMusic:model];
        }
    }];
    
    [sheetCon addAction:cancel];
    [sheetCon addAction:openModel];
    [sheetCon addAction:closeModel];
    
    [self presentViewController:sheetCon animated:YES completion:nil];
}
#pragma mark 喷泉 全开/关模式
- (void)allConScene:(NSString *)modelId {
    NSString *urlStr = [NSString stringWithFormat:@"%@/lighting/model/%@",Main_Url, modelId];
    [self showHudInView:self.view hint:@""];
    [[NetworkClient sharedInstance] POST:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *resDic = responseObject[@"responseData"];
            if(resDic != nil && ![resDic isKindOfClass:[NSNull class]]){
                NSString *result = resDic[@"result"];
                if(result != nil && ![result isKindOfClass:[NSNull class]] && [result isEqualToString:@"success"]){
                    // 重新加载数据
                    [self _loadData];
                    // 记录日志
                    NSString *operate;
                    if([modelId isEqualToString:@"pquan_on"]){
                        operate = @"音乐喷泉全开";
                    }else {
                        operate = @"音乐喷泉全关";
                    }
                    [self logRecordModelId:modelId withOperate:operate];
                }
            }
        }else {
            if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
                [self showHint:responseObject[@"message"]];
            }
        }
        
    } failure:^(NSError *error) {
        [self hideHud];
    }];
    
}
- (void)logRecordModelId:(NSString *)modelId withOperate:(NSString *)operate{
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:operate forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:operate forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"lighting/model" forKey:@"operateUrl"];//操作url
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:modelId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"音乐喷泉" forKey:@"operateDeviceName"];//操作设备名  模块
//    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}
// 关闭喷泉对应音乐设备
- (void)colseFountainMusic:(FountainModel *)fountainModel {
    if(fountainModel.LAYER_A == nil || [fountainModel.LAYER_A isKindOfClass:[NSNull class]]){
        return;
    }
    
    NSArray *musicIdAry = [fountainModel.LAYER_A componentsSeparatedByString:@","];
    [musicIdAry enumerateObjectsUsingBlock:^(NSString *musicId, NSUInteger idx, BOOL * _Nonnull stop) {
        [self getSessionIdByTagId:musicId];
    }];
}
// 根据音箱tagid 获取sessionID
- (void)getSessionIdByTagId:(NSString *)musicTagId {
    NSString *volumStr = [NSString stringWithFormat:@"%@/music/getipcastsometermstatus/%@",Main_Url,musicTagId];
    [[NetworkClient sharedInstance] GET:volumStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSArray *arr = responseObject[@"responseData"];
            if(arr == nil || [arr isKindOfClass:[NSNull class]]){
                return ;
            }
            if(arr != nil && arr.count > 0){
                NSDictionary *volumDic = arr.firstObject;
                NSString *sessionID = volumDic[@"a_sid"];
                if(sessionID != nil && ![sessionID isKindOfClass:[NSNull class]]){
                    [self closeMusicBySeeionID:sessionID withTagId:musicTagId];
                }
            }
        }
    } failure:^(NSError *error) {
    }];
}
// 根据回话id sessionID 关闭音乐
- (void)closeMusicBySeeionID:(NSString *)sessionID withTagId:(NSString *)tagId {
    NSString *urlStr = [NSString stringWithFormat:@"%@/music/playipcastfilectrl/%@/1/0", Main_Url, sessionID];
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        NSDictionary *resDic = responseObject[@"responseData"];
        if(resDic == nil || [resDic isKindOfClass:[NSNull class]]){
            return ;
        }
        if ([resDic[@"result"] isEqualToString:@"success"]) {
            NSLog(@"++++++++喷泉音乐停止成功");
            // 记录日志
            [self logRecordOperate:@"关闭喷泉音柱" withGroupId:tagId withUrl:@"music/playipcastfilectrl"];
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

#pragma 观赏模式
- (void)viewModel {
    UIAlertController *sheetCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确认打开观赏模式" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    UIAlertAction *openModel = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 喷泉全开
        _stateType = 1;
        [self allConScene:@"pquan_on"];
        
        // 打开音乐设备 播放音乐
        [self openMusic];
        
    }];
    
    [sheetCon addAction:cancel];
    [sheetCon addAction:openModel];
    
    [self presentViewController:sheetCon animated:YES completion:nil];
    
}
// 打开音乐设备 播放音乐
- (void)openMusic {
    FountainModel *fountainModel;
    if(_dataArr.count > 0){
        fountainModel = _dataArr.firstObject;
    }else {
        return;
    }
    
    if(!(fountainModel.LAYER_A != nil && ![fountainModel.LAYER_A isKindOfClass:[NSNull class]] &&
         fountainModel.LAYER_B != nil && ![fountainModel.LAYER_B isKindOfClass:[NSNull class]] &&
         fountainModel.LAYER_C != nil && ![fountainModel.LAYER_C isKindOfClass:[NSNull class]]
         )){
        return ;
    }
    
    NSString *playModel = @"4"; // 循环播放
    NSString *volume = [NSString stringWithFormat:@"%ld", fountainModel.LAYER_C.integerValue]; // 音量0~56,0最小,56最大, 整数
    NSString *urlStr = [NSString stringWithFormat:@"%@/music/playipcastfilelist/%@/%@/%@/%@/%@/0/%@", Main_Url, fountainModel.LAYER_B, fountainModel.LAYER_A, @"100", playModel, @"1", volume];
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        if([responseObject[@"responseData"] isKindOfClass:[NSDictionary class]]){
            NSDictionary *resDic = responseObject[@"responseData"];
            if(resDic == nil || [resDic isKindOfClass:[NSNull class]]){
                return ;
            }
            if (resDic[@"sessionID"] != nil && ![resDic[@"sessionID"] isKindOfClass:[NSNull class]]) {
                NSLog(@"===== 音乐播放成功");
                // 记录日志
                [self logRecordOperate:@"播放喷泉音柱" withGroupId:fountainModel.LAYER_B withUrl:@"music/playipcastfilelist"];
            }
        }
    } failure:^(NSError *error) {
    }];
}

#pragma mark 加载喷泉数据
-(void)_loadData
{
    [self showHudInView:self.view hint:@""];
    NSString *urlStr = [NSString stringWithFormat:@"%@/equipment/getLightingList?lightingType=fountain",Main_Url];
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        [self hideHud];
        [self.dataArr removeAllObjects];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *dic = responseObject[@"responseData"];
            _leftNum = [NSString stringWithFormat:@"%@",dic[@"okEquipmentCount"]];
            _centerNum = [NSString stringWithFormat:@"%@",dic[@"outEquipmentCount"]];
            _rightNum = [NSString stringWithFormat:@"%@",dic[@"errorEquipmentCount"]];
            
            NSArray *arr = dic[@"equipmentList"];
            
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FountainModel *model = [[FountainModel alloc] initWithDataDic:obj];
                if(_stateType == 0){
                    model.isOpen = NO;
                }else if(_stateType == 1){
                    model.isOpen = YES;
                }
                [self.dataArr addObject:model];
            }];
            
            [self loadEquipmentState];
        }else {
            [self.tableView.mj_header endRefreshing];
        }
        
        [self.tableView cyl_reloadData];
        _stateType = 2; // 改为未定义
    } failure:^(NSError *error) {
        [self hideHud];
        [self.tableView.mj_header endRefreshing];
        if(self.dataArr.count <= 0){
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

#pragma mark 获取喷泉设备状态
- (void)loadEquipmentState {
    NSMutableString *tagids = @"".mutableCopy;
    [self.dataArr enumerateObjectsUsingBlock:^(FountainModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        if(model.TAGID != nil && ![model.TAGID isKindOfClass:[NSNull class]]){
            if(idx >= self.dataArr.count - 1){
                [tagids appendFormat:@"%@", model.TAGID];
            }else {
                [tagids appendFormat:@"%@,", model.TAGID];
            }
        }
    }];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/lighting/getIbmsTagValue/%@",Main_Url, tagids];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self.tableView.mj_header endRefreshing];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSString *responseData = responseObject[@"responseData"];
            NSData *jsonData = [responseData dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            
            if(jsonDic[@"result"] != nil && ![jsonDic[@"result"] isKindOfClass:[NSNull class]] && [jsonDic[@"result"] isEqualToString:@"success"]){
                // 成功
                [self.dataArr enumerateObjectsUsingBlock:^(FountainModel *fountainModel, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSArray *tagArray = jsonDic[@"tagArray"];
                    [tagArray enumerateObjectsUsingBlock:^(NSDictionary *stateDic, NSUInteger idx, BOOL * _Nonnull stop) {
                        MeetRoomStateModel *stateModel = [[MeetRoomStateModel alloc] initWithDataDic:stateDic];
                        if([stateModel.state_id isEqualToString:fountainModel.TAGID]){
                            if([stateModel.value isEqualToString:@"0"]){
                                fountainModel.isOpen = NO;
                            }else {
                                fountainModel.isOpen = YES;
                            }
                        }
                    }];
                }];
            }
            [self.tableView cyl_reloadData];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
        [self.tableView.mj_header endRefreshing];
    }];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight)];
    return noDataView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark UITableVIew 协议
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
    FountainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FountainTableViewCellID" forIndexPath:indexPath];
    cell.model = self.dataArr[indexPath.row];
    cell.conSwitchDelegate = self;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    /*
    headerView = [[YQHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 85)];
    headerView.leftNumLab.text = _leftNum;
    headerView.centerNumLab.text = _centerNum;
    headerView.rightNumLab.text = _rightNum;
     return headerView;
     */
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    return 85;
    return 0;
}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 单个开关喷泉协议
- (void)conSwitch:(BOOL)on withModel:(FountainModel *)fountainModel {
    NSString *operateType;
    if(on){
        operateType = @"ON";
    }else {
        operateType = @"OFF";
    }
    
    // 设备开关
    NSString *urlStr = [NSString stringWithFormat:@"%@/lighting/%@",Main_Url, fountainModel.TAGID];
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:operateType forKey:@"operateType"];
    [param setObject:@"1" forKey:@"tagValue"];
    
    [self showHudInView:self.view hint:@""];
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            // 记录日志
            NSString *operate;
            if(on){
                operate = [NSString stringWithFormat:@"喷泉\"%@\"打开", fountainModel.DEVICE_NAME];
            }else {
                operate = [NSString stringWithFormat:@"喷泉\"%@\"关闭", fountainModel.DEVICE_NAME];
            }
            [self logRecordFountainOperate:operate withTagId:fountainModel.TAGID];
            
            NSDictionary *resDic = responseObject[@"responseData"];
            if(resDic != nil && ![resDic isKindOfClass:[NSNull class]]){
                NSString *result = resDic[@"result"];
                if(result != nil && ![result isKindOfClass:[NSNull class]] && [result isEqualToString:@"success"]){
                    fountainModel.isOpen = on;  // 状态成功改变
                }
            }
        }else {
            if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
                [self showHint:responseObject[@"message"]];
            }
        }
        // 刷新tableView 对应的开关状态
        NSInteger index = [_dataArr indexOfObject:fountainModel];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    } failure:^(NSError *error) {
        [self hideHud];
    }];
}

- (void)logRecordFountainOperate:(NSString *)operate withTagId:(NSString *)tagId {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:operate forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:operate forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:[NSString stringWithFormat:@"lighting/%@", tagId] forKey:@"operateUrl"];//操作url
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:tagId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"音乐喷泉" forKey:@"operateDeviceName"];//操作设备名  模块
//    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

@end
