//
//  WaterViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/6.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "WaterViewController.h"
#import "WaterTableViewCell.h"
#import "YQHeaderView.h"

#import "WaterModel.h"
#import <SCLAlertView.h>

#import "UIViewController+WLAlert.h"

#import "WaterMonitorViewController.h"

@interface WaterViewController ()<UITableViewDelegate,UITableViewDataSource, WaterSwitchDelegate>
{
    YQHeaderView *headerView;
    NSString *_openStr;
    NSString *_closeStr;
    NSString *_brokenStr;
    
    UIView *_bottomView;
    UIButton *_allCloseButton;
    UIButton *_allOpenButton;
}

@property (nonatomic,strong) NSMutableArray *dataArr;

@end

@implementation WaterViewController

-(NSMutableArray *)dataArr{
    if (_dataArr == nil) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self _initView];
    
    [self _initNavItems];
    
    [self _loadData];
}

-(void)_initView
{
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[WaterTableViewCell class] forCellReuseIdentifier:@"WaterTableViewCellID"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.mj_header.hidden = NO;
    self.tableView.mj_footer.hidden = YES;
    self.tableView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight-64 - 60);
    
    // 下方全关/开控制
    CGFloat bottomHeight = 0;
    if(kDevice_Is_iPhoneX){
        bottomHeight = 34;
    }
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, KScreenHeight - kTopHeight - 60  - bottomHeight, KScreenWidth, 60)];
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
    _allOpenButton.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    _allOpenButton.frame = CGRectMake(KScreenWidth/2, 0, KScreenWidth/2, 60);
    [_allOpenButton setImage:[UIImage imageNamed:@"panorama_video"] forState:UIControlStateNormal];
    [_allOpenButton setTitle:@" 实景视频" forState:UIControlStateNormal];
    [_allOpenButton setTitleColor:[UIColor colorWithHexString:@"#CCFF00"] forState:UIControlStateNormal];
    [_allOpenButton addTarget:self action:@selector(viewModel) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_allOpenButton];
}

-(void)_initNavItems
{
//    self.title = @"浇灌";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

#pragma mark 批量操作
- (void)allConModel {
    if(KScreenWidth > 440){
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        
        __weak typeof(alert) weakAlert = alert;
        [alert addButton:@"设备全开" actionBlock:^(void) {
            [self switchWater:nil withOpen:YES withAllCon:YES];
            [weakAlert hideView];
        }];
        
        [alert addButton:@"设备全关" actionBlock:^(void) {
            [self switchWater:nil withOpen:NO withAllCon:YES];
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
        [self switchWater:nil withOpen:YES withAllCon:YES];
    }];
    
    UIAlertAction *closeModel = [UIAlertAction actionWithTitle:@"设备全关" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self switchWater:nil withOpen:NO withAllCon:YES];
    }];
    
    [sheetCon addAction:cancel];
    [sheetCon addAction:openModel];
    [sheetCon addAction:closeModel];
    
    [self presentViewController:sheetCon animated:YES completion:nil];
}

#pragma mark 实景视频
- (void)viewModel {
//    [DHDataCenter sharedInstance].channelID = @"1000243$1$0$0";
    [MonitorLogin selectNodeWithChanneId:@"1000243$1$0$0" withNode:^(TreeNode *node) {
    }];
    
    WaterMonitorViewController *waterMonVC = [[WaterMonitorViewController alloc] init];
    [self.navigationController pushViewController:waterMonVC animated:YES];
}

#pragma mark 刷新
-(void)headerRereshing{
    [self _loadData];
}

#pragma mark 加载数据
-(void)_loadData
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/irrigation/controller",Main_Url];
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        [self.tableView.mj_header endRefreshing];
//        DLog(@"%@",responseObject);
        [self.dataArr removeAllObjects];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSArray *responseData = responseObject[@"responseData"];
            
            [responseData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                WaterModel *model = [[WaterModel alloc] initWithDataDic:obj];
                [self.dataArr addObject:model];
            }];
            
            [self calulateCount];
            
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
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

- (void)calulateCount {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.ctrl_status.integerValue = 3"];
    NSArray *stopAry = [self.dataArr filteredArrayUsingPredicate:predicate];
    
    _openStr = [NSString stringWithFormat:@"%lu", self.dataArr.count - stopAry.count];
    _closeStr = [NSString stringWithFormat:@"%ld", stopAry.count];
    _brokenStr = @"0";
}

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
    WaterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WaterTableViewCellID" forIndexPath:indexPath];
    cell.model = self.dataArr[indexPath.row];
    cell.switchDelegate = self;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    headerView = [[YQHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 85)];
    headerView.leftNumLab.text = _openStr;
    headerView.centerNumLab.text = _closeStr;
    headerView.rightNumLab.text = _brokenStr;
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 85;
}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 开关协议
- (void)switchWater:(WaterModel *)waterModel withOpen:(BOOL)isOpen withAllCon:(BOOL)isAllCon {
    if(isOpen){
        [self showTextFieldAlert:@"开启时长设置" withCarnoPlaceholder:nil withInfoPlaceholder:@"请输入浇灌时长(分)" withCancelMsg:@"取消" withCancelBlock:^{
            
            NSInteger index = [_dataArr indexOfObject:waterModel];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            
        } withCertainMsg:@"确定" withCertainBlock:^(NSString *carno, NSString *info) {
            if(isAllCon){
                [self allControl:isOpen withTime:info];
            }else {
                [self switchTimeWater:waterModel withOpen:isOpen withTime:info];
            }
        } isMsgAlert:YES];
    }else {
        if(isAllCon){
            [self allControl:isOpen withTime:@"0"];
        }else {
            [self switchTimeWater:waterModel withOpen:isOpen withTime:@"0"];
        }
    }
}

#pragma mark 设置时间后 单独控制调用接口
- (void)switchTimeWater:(WaterModel *)waterModel withOpen:(BOOL)isOpen withTime:(NSString *)time{
    if(![self validateNumber:time]){
        [self showHint:@"时长只能包含数字"];
        NSInteger index = [_dataArr indexOfObject:waterModel];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        return;
    }
    
    NSString *onStr;
    if(isOpen){
        onStr = @"1";
    }else {
        onStr = @"3";
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/irrigation/setEquipmentStatus", Main_Url];
    NSDictionary *paramDic = @{@"device_id":waterModel.device_id,
                               @"ctrl_status":onStr,
                               @"terminal_type":waterModel.terminal_type,
                               @"serial_num":waterModel.serial_num,
                               @"run_time":time
                               };
    
    NSString *paramStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param =@{@"param" : paramStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [self.tableView.mj_header endRefreshing];
        if([responseObject[@"code"] isEqualToString:@"1"]){
            if(isOpen){
                waterModel.ctrl_status = @1;
            }else {
                waterModel.ctrl_status = @3;
            }
            
            // 记录日志
            [self logRecordOperateDeviceID:[NSString stringWithFormat:@"%@", waterModel.device_id] withDeviceName:waterModel.device_name isOpen:isOpen];
            
        }else {
        }
        if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
            [self showHint:responseObject[@"message"]];
        }
        
//        NSInteger index = [_dataArr indexOfObject:waterModel];
//        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self calulateCount];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
    }];
}

#pragma mark 批量控制
- (void)allControl:(BOOL)isOpen withTime:(NSString *)time {
    if(![self validateNumber:time]){
        [self showHint:@"时长只能包含数字"];
        return;
    }
    
    NSString *onStr;
    if(isOpen){
        onStr = @"1";
    }else {
        onStr = @"3";
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/irrigation/setEquipmentStatusBatch", Main_Url];
    NSMutableArray *paramAry = @[].mutableCopy;
    [self.dataArr enumerateObjectsUsingBlock:^(WaterModel *waterModel, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *paramDic = @{@"device_id":waterModel.device_id,
                                   @"ctrl_status":onStr,
                                   @"terminal_type":waterModel.terminal_type,
                                   @"serial_num":waterModel.serial_num,
                                   @"run_time":time
                                   };
        [paramAry addObject:paramDic];
    }];
    
    NSDictionary *deviceList = @{@"deviceList":paramAry};
    
    NSString *paramStr = [Utils convertToJsonData:deviceList];
    NSDictionary *param =@{@"param" : paramStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [self.tableView.mj_header endRefreshing];
        if([responseObject[@"code"] isEqualToString:@"1"]){
            [self.dataArr enumerateObjectsUsingBlock:^(WaterModel *waterModel, NSUInteger idx, BOOL * _Nonnull stop) {
                if(isOpen){
                    waterModel.ctrl_status = @1;
                }else {
                    waterModel.ctrl_status = @3;
                }
            }];
            
            // 记录日志
            [self logRecordOperateAllCon:isOpen];
            
        }else {
        }
        if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
            [self showHint:responseObject[@"message"]];
        }
        
        [self calulateCount];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
    }];
}

#pragma mark 开关定时任务日志
- (void)logRecordOperateDeviceID:(NSString *)deviceId withDeviceName:(NSString *)deviceName isOpen:(BOOL)isOpen {
    
    NSString *operateStr;
    if(isOpen){
        operateStr = [NSString stringWithFormat:@"开启\"%@\"", deviceName];
    }else {
        operateStr = [NSString stringWithFormat:@"关闭\"%@\"", deviceName];
    }
    
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:operateStr forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:operateStr forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"irrigation/setEquipmentStatus" forKey:@"operateUrl"];//操作url
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:deviceId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"智能浇灌" forKey:@"operateDeviceName"];//操作设备名  模块
    //    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

#pragma mark 开关定时任务日志
- (void)logRecordOperateAllCon:(BOOL)isOpen {
    
    NSString *operateStr;
    if(isOpen){
        operateStr = [NSString stringWithFormat:@"浇灌批量模式全开"];
    }else {
        operateStr = [NSString stringWithFormat:@"浇灌批量模式全关"];
    }
    
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:operateStr forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:operateStr forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"irrigation/setEquipmentStatus" forKey:@"operateUrl"];//操作url
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:@"" forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"智能浇灌" forKey:@"operateDeviceName"];//操作设备名  模块
    //    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)validateNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}

@end
