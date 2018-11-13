//
//  SingleControlViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/15.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "SingleControlViewController.h"

#import "MeetRoomModel.h"
#import "MeetRoomStateModel.h"
#import "SceneEquipmentModel.h"

#import "SingleCtrlTableViewCell.h"
//#import "AloneConCell.h"    // 不带silder

@interface SingleControlViewController ()<UITableViewDelegate,UITableViewDataSource, SliderLightDelegate, CYLTableViewPlaceHolderDelegate>
{
    UIView *_bottomView;
    UIButton *_allCloseButton;
    UIButton *_allOpenButton;
    
    NSMutableArray *_sceneData;
    BOOL _isSceneModel; // 是否是场景模式变换
}

@property (nonatomic,strong) NSMutableArray *dataArr;

@end

@implementation SingleControlViewController

-(NSMutableArray *)dataArr{
    if (_dataArr == nil) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _sceneData = @[].mutableCopy;
    
    [self configTableView];
    
    [self _initView];
    
    [self _loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadData) name:@"changeSceneModel" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSceneModel:) name:@"changeSceneModel" object:nil];
}

/*
#pragma mark 更换场景模式
- (void)changeSceneModel:(NSNotification *)notification {
    NSString *modelId = notification.userInfo[@"modelId"];
    
    [self changeModel:modelId];
}
 */

- (void)changeModel:(NSString *)modelId {
    NSString *urlStr = [NSString stringWithFormat:@"%@/lighting/model/%@",Main_Url, modelId];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            [_sceneData removeAllObjects];
            NSArray *responseData = responseObject[@"responseData"];
            [responseData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                SceneEquipmentModel *model = [[SceneEquipmentModel alloc] initWithDataDic:obj];
                [_sceneData addObject:model];
            }];
            _isSceneModel = YES;
            [self.tableView cyl_reloadData];
            
            // 记录日志
        }
    } failure:^(NSError *error) {
        DLog(@"%@",error);
    }];
}

-(void)configTableView
{
    [self.view addSubview:self.tableView];
    
    if (kDevice_Is_iPhoneX) {
        self.tableView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight-88-34 - 60 - 60);
    }else{
        self.tableView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight-64 - 60 - 60);
        
    }
    self.tableView.contentInset =UIEdgeInsetsMake(0, 0, 6, 0);
    self.tableView.showsVerticalScrollIndicator = YES;
    self.tableView.showsHorizontalScrollIndicator = YES;
//    self.tableView.mj_header.hidden = YES;
    self.tableView.mj_footer.hidden = YES;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SingleCtrlTableViewCell" bundle:nil] forCellReuseIdentifier:@"SingleCtrlTableViewCell"];
//    [self.tableView registerNib:[UINib nibWithNibName:@"AloneConCell" bundle:nil] forCellReuseIdentifier:@"AloneConCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, KScreenHeight - kTopHeight - 60 - 60, KScreenWidth, 60)];
    [self.view addSubview:_bottomView];
    
    _allCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _allCloseButton.frame = CGRectMake(0, 0, KScreenWidth/2, 60);
    [_allCloseButton setImage:[UIImage imageNamed:@"scene_all_close"] forState:UIControlStateNormal];
    [_allCloseButton setTitle:@" 设备全关" forState:UIControlStateNormal];
    [_allCloseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_allCloseButton setBackgroundImage:[UIImage imageNamed:@"scene_all_close_bg"] forState:UIControlStateNormal];
    [_allCloseButton addTarget:self action:@selector(allClose) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_allCloseButton];
    
    _allOpenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _allOpenButton.backgroundColor = [UIColor colorWithHexString:@"#1B82D1 "];
    _allOpenButton.frame = CGRectMake(KScreenWidth/2, 0, KScreenWidth/2, 60);
    [_allOpenButton setImage:[UIImage imageNamed:@"scene_all_open"] forState:UIControlStateNormal];
    [_allOpenButton setTitle:@" 设备全开" forState:UIControlStateNormal];
    [_allOpenButton setTitleColor:[UIColor colorWithHexString:@"#CCFF00"] forState:UIControlStateNormal];
    [_allOpenButton addTarget:self action:@selector(allOpen) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_allOpenButton];
}
// 下拉刷新
-(void)headerRereshing{
    [self _loadData];
}

- (void)_initView {
    
    self.title = @"单独控制";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
    
}

-(void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/equipment/getLightingListByRoomId?roomId=%@",Main_Url, _model.ROOM_ID];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            [_dataArr removeAllObjects];
            NSDictionary *resDic = responseObject[@"responseData"];
            NSArray *equipmentList = resDic[@"equipmentList"];
            [equipmentList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                MeetRoomModel *model = [[MeetRoomModel alloc] initWithDataDic:obj];
                model.LightValue = @100;
                [self.dataArr addObject:model];
            }];
            
            _isSceneModel = NO;
            [self loadEquipmentState];
        }else {
            [self.tableView.mj_header endRefreshing];
        }
        [self.tableView cyl_reloadData];
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
        
        BOOL isEmpty = NO;
        if(_isSceneModel){
            if(_sceneData.count <= 0){
                isEmpty = YES;
            }
        }else {
            if(_dataArr.count <= 0){
                isEmpty = YES;
            }
        }
        if(isEmpty){
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

#pragma mark 获取会议室设备状态
- (void)loadEquipmentState {
    NSMutableString *tagids = @"".mutableCopy;
    NSMutableString *airTagids = @"".mutableCopy;
    [self.dataArr enumerateObjectsUsingBlock:^(MeetRoomModel *meetRoomModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if([meetRoomModel.DEVICE_TYPE isEqualToString:@"6"]){
            [meetRoomModel.airList enumerateObjectsUsingBlock:^(MeetRoomDeviceModel *deviceModel, NSUInteger idx, BOOL * _Nonnull stop) {
                if(deviceModel.READ_ID != nil && ![deviceModel.READ_ID isKindOfClass:[NSNull class]]){
                    [airTagids appendFormat:@"%@,", deviceModel.READ_ID];
                }
            }];
        }else {
            if(meetRoomModel.TAGID != nil && ![meetRoomModel.TAGID isKindOfClass:[NSNull class]]){
                [tagids appendFormat:@"%@,", meetRoomModel.TAGID];
            }
        }
    }];
    
    [tagids appendString:airTagids];
    if(tagids != nil && tagids.length > 0){
        [tagids deleteCharactersInRange:NSMakeRange(tagids.length - 1, 1)];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/lighting/getIbmsTagValue/%@",Main_Url, tagids];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self.tableView.mj_header endRefreshing];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSString *responseData = responseObject[@"responseData"];
            NSData *jsonData = [responseData dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            
            if(jsonDic[@"result"] != nil && ![jsonDic[@"result"] isKindOfClass:[NSNull class]] && [jsonDic[@"result"] isEqualToString:@"success"]){
                // 成功
                [self.dataArr enumerateObjectsUsingBlock:^(MeetRoomModel *meetRoomModel, NSUInteger idx, BOOL * _Nonnull stop) {
                    // 空调特殊处理
                    if([meetRoomModel.DEVICE_TYPE isEqualToString:@"6"]){
                        [meetRoomModel.airList enumerateObjectsUsingBlock:^(MeetRoomDeviceModel *meetRoomDeviceModel, NSUInteger idx, BOOL * _Nonnull stop) {
                            NSArray *tagArray = jsonDic[@"tagArray"];
                            [tagArray enumerateObjectsUsingBlock:^(NSDictionary *stateDic, NSUInteger idx, BOOL * _Nonnull stop) {
                                MeetRoomStateModel *stateModel = [[MeetRoomStateModel alloc] initWithDataDic:stateDic];
                                if([stateModel.state_id isEqualToString:meetRoomDeviceModel.READ_ID]){
                                    meetRoomDeviceModel.current_state = stateModel.value;
                                }
                            }];
                        }];
                    }else {
                        NSArray *tagArray = jsonDic[@"tagArray"];
                        [tagArray enumerateObjectsUsingBlock:^(NSDictionary *stateDic, NSUInteger idx, BOOL * _Nonnull stop) {
                            MeetRoomStateModel *stateModel = [[MeetRoomStateModel alloc] initWithDataDic:stateDic];
                            if([stateModel.state_id isEqualToString:meetRoomModel.TAGID]){
                                meetRoomModel.current_state = stateModel.value;
                            }
                        }];
                    }
                }];
            }
            [self.tableView cyl_reloadData];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
        [self.tableView.mj_header endRefreshing];
    }];
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 保存
- (void)saveAction {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 60, KScreenWidth, KScreenHeight - kTopHeight - 120)];
    return noDataView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark - Table view 协议
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_isSceneModel){
        return _sceneData.count;
    }else {
        return self.dataArr.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SingleCtrlTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SingleCtrlTableViewCell" forIndexPath:indexPath];
    cell.lightDelegare = self;
    if(_isSceneModel){
        SceneEquipmentModel *model = _sceneData[indexPath.row];
            // 灯筒
        cell.sceneModel = model;
    }else {
        MeetRoomModel *model = _dataArr[indexPath.row];
        cell.model = model;
    }
    cell.isScene = _isSceneModel;
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_isSceneModel){
        SceneEquipmentModel *model = _sceneData[indexPath.row];
        if([model.deviceType isEqualToString:@"18-1"] && [model.tagStatus isEqualToString:@"ON"]){
            // 灯筒
            return 120;
        }
        
    }else {
        MeetRoomModel *model = _dataArr[indexPath.row];
        if([model.DEVICE_TYPE isEqualToString:@"18-1"] && model.current_state != nil &&  ![model.current_state isKindOfClass:[NSNull class]] && ![model.current_state isEqualToString:@"0"]){
            // 灯筒
            return 120;
        }
        if([model.DEVICE_TYPE isEqualToString:@"6"]){
            // 空调
            __block BOOL isOpen = NO;
            [model.airList enumerateObjectsUsingBlock:^(MeetRoomDeviceModel *deviceModel, NSUInteger idx, BOOL * _Nonnull stop) {
                if([deviceModel.TAGNAME isEqualToString:@"AIRSTATUS"] && deviceModel.current_state!= nil && ![deviceModel.current_state isKindOfClass:[NSNull class]] && ![deviceModel.current_state isEqualToString:@"0"]){
                    isOpen = YES;
                }
            }];
            if(isOpen){
                return 120 + 80;
            }else {
                return 75;
            }
        }
    }
    return 75;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

#pragma mark 设备全关
- (void)allClose {
    [self allConScene:@"off"];
}

#pragma mark 设备全开
- (void)allOpen {
    [self allConScene:@"on"];
}

#pragma mark 灯桶协议(可调节亮度)
- (void)switchOnOff:(MeetRoomModel *)meetRoomModel withOpen:(BOOL)open {
    [self aloneCon:meetRoomModel.TAGID withOpen:open withMeetModel:meetRoomModel withSceneModel:nil withIsScene:NO withDeviceName:meetRoomModel.DEVICE_NAME];
}
- (void)sliderValue:(MeetRoomModel *)meetRoomModel withValue:(CGFloat)slider {
    [self aloneSliderValue:meetRoomModel.TAGID withValue:slider withDeviceName:meetRoomModel.DEVICE_NAME withModel:meetRoomModel withSceneEquipmentModel:nil isScene:NO];
}

- (void)switchSceneOnOff:(SceneEquipmentModel *)sceneModel withOpen:(BOOL)open {
    [self aloneCon:sceneModel.tagId withOpen:open withMeetModel:nil withSceneModel:sceneModel withIsScene:YES withDeviceName:sceneModel.tagName];
}
- (void)sliderSceneValue:(SceneEquipmentModel *)sceneModel withValue:(CGFloat)slider {
    [self aloneSliderValue:sceneModel.tagId withValue:slider withDeviceName:sceneModel.tagName withModel:nil withSceneEquipmentModel:sceneModel isScene:YES];
}


#pragma mark 单独控制协议
- (void)aloneCon:(NSString *)tagId withOpen:(BOOL)open withMeetModel:(MeetRoomModel *)meetModel withSceneModel:(SceneEquipmentModel *)sceneModel withIsScene:(BOOL)isScene withDeviceName:(NSString *)deviceName {
    NSString *operateType;
    if(open){
        operateType = @"ON";
    }else {
        operateType = @"OFF";
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/lighting/%@",Main_Url, tagId];
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:operateType forKey:@"operateType"];
    [param setObject:@"1" forKey:@"tagValue"];
    
    [self showHudInView:self.view hint:@""];
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *resDic = responseObject[@"responseData"];
            if(resDic != nil && ![resDic isKindOfClass:[NSNull class]]){
                NSString *result = resDic[@"result"];
                if(result != nil && ![result isKindOfClass:[NSNull class]] && [result isEqualToString:@"success"]){
                    // 成功
                    if(open){
                        if(isScene){
                            sceneModel.tagStatus = @"ON";
                        }else {
                            meetModel.current_state = @"1";
                        }
                    }else {
                        if(isScene){
                            sceneModel.tagStatus = @"OFF";
                        }else {
                            meetModel.current_state = @"0";
                        }
                    }
                    // 记录日志
                    NSString *operate;
                    if(open){
                        operate = [NSString stringWithFormat:@"会议室%@开启", deviceName];
                    }else {
                        operate = [NSString stringWithFormat:@"会议室%@关闭", deviceName];
                    }
                    [self logRecordOperate:operate withTagId:tagId withOldValue:@"" withNewValue:@""];
                }
            }
        }else {
            if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
                [self showHint:responseObject[@"message"]];
            }
        }
        
        NSInteger index;
        if(isScene){
            index = [_sceneData indexOfObject:sceneModel];
        }else {
            index = [_dataArr indexOfObject:meetModel];
        }
        
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
    } failure:^(NSError *error) {
        [self hideHud];
        NSInteger index;
        if(isScene){
            index = [_sceneData indexOfObject:sceneModel];
        }else {
            index = [_dataArr indexOfObject:meetModel];
        }
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }];
}
#pragma mark 空调操作协议
- (void)modelCutData:(NSString *)writeId withDeviceId:(NSString *)deviceId withTagName:(NSString *)tagName withValue:(NSString *)operateValue withMeetModel:(MeetRoomModel *)meetModel {
    
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
                    // 成功
                    [meetModel.airList enumerateObjectsUsingBlock:^(MeetRoomDeviceModel *deviceModel, NSUInteger idx, BOOL * _Nonnull stop) {
                        if([deviceModel.TAGNAME isEqualToString:tagName]) {
                            deviceModel.current_state = operateValue;
                        }
                    }];

                    // 记录日志
                    [self opeatreLog:tagName withOperateValue:operateValue withTagId:deviceId withName:meetModel.DEVICE_NAME];
                }
            }
        }else {
            if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
                [self showHint:responseObject[@"message"]];
            }
        }
        
        NSInteger index = [_dataArr indexOfObject:meetModel];
        
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }failure:^(NSError *error) {
        [self hideHud];
        [self showHint:KRequestFailMsg];
    }];
}

- (void)opeatreLog:(NSString *)tagName withOperateValue:(NSString *)operateValue withTagId:(NSString *)tagId withName:(NSString *)deviceName {
    NSString *operate;
    NSString *oldValue = @"";
    NSString *newValue = @"";
    
    if([tagName isEqualToString:@"AIRSTATUS"]){
        if(![operateValue isEqualToString:@"0"]){
            operate = [NSString stringWithFormat:@"开启%@空调", deviceName];
        }else {
            operate = [NSString stringWithFormat:@"关闭%@空调", deviceName];
        }
    }else if([tagName isEqualToString:@"TEMPERATUR"]){
        newValue = operateValue;
        operate = [NSString stringWithFormat:@"%@空调调节温度至%@℃", deviceName,operateValue];
    }else if([tagName isEqualToString:@"WORKMODE"]){
        if([operateValue isEqualToString:@"1"]){
            operate = [NSString stringWithFormat:@"%@空调设置制热模式", deviceName];
        }else if([operateValue isEqualToString:@"2"]){
            operate = [NSString stringWithFormat:@"%@空调设置制冷模式", deviceName];
        }else if([operateValue isEqualToString:@"3"]){
            operate = [NSString stringWithFormat:@"%@空调设置通风模式", deviceName];
        }else if([operateValue isEqualToString:@"4"]){
            operate = [NSString stringWithFormat:@"%@空调设置除湿模式", deviceName];
        }
    }else if([tagName isEqualToString:@"WINDSPEED"]){
        if([operateValue isEqualToString:@"0"]){
            operate = [NSString stringWithFormat:@"%@空调设置自动风速", deviceName];
        }else if([operateValue isEqualToString:@"1"]){
            operate = [NSString stringWithFormat:@"%@空调设置高风速", deviceName];
        }else if([operateValue isEqualToString:@"2"]){
            operate = [NSString stringWithFormat:@"%@空调设置中风速", deviceName];
        }else if([operateValue isEqualToString:@"3"]){
            operate = [NSString stringWithFormat:@"%@空调设置低风速", deviceName];
        }
    }
    
    [self logRecordOperate:operate withTagId:tagId withOldValue:oldValue withNewValue:newValue];
}

#pragma mark 单个开关日志
- (void)logRecordOperate:(NSString *)operate withTagId:(NSString *)tagId withOldValue:(NSString *)oldValue withNewValue:(NSString *)newValue {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:operate forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:operate forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:[NSString stringWithFormat:@"lighting/%@", tagId] forKey:@"operateUrl"];//操作url
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
    [logDic setObject:newValue forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:tagId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"会议室" forKey:@"operateDeviceName"];//操作设备名  模块
    [logDic setObject:oldValue forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

- (void)aloneSliderValue:(NSString *)tagId withValue:(CGFloat)slider withDeviceName:(NSString *)deviceName withModel:(MeetRoomModel *)meetRoomModel withSceneEquipmentModel:(SceneEquipmentModel *)sceneModel isScene:(BOOL)isScene {
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/lighting/%@",Main_Url, tagId];
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:@"ADJUST" forKey:@"operateType"];
    [param setObject:[NSNumber numberWithInt:slider*100] forKey:@"tagValue"];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *resDic = responseObject[@"responseData"];
            if(resDic != nil && ![resDic isKindOfClass:[NSNull class]]){
                NSString *result = resDic[@"result"];
                if(result != nil && ![result isKindOfClass:[NSNull class]] && [result isEqualToString:@"success"]){
                    // 成功
                    [self showHint:@"成功"];
                    // 记录日志
                    NSString *operate;
                    if(isScene){
                        operate = [NSString stringWithFormat:@"会议室%@亮度调节%ld至%.0f", deviceName, sceneModel.tagValue.integerValue, slider*100];
                        sceneModel.tagValue = [NSString stringWithFormat:@"%.0f", slider*100];
                    }else {
                        operate = [NSString stringWithFormat:@"会议室%@亮度调节%ld至%.0f", deviceName, meetRoomModel.LightValue.integerValue, slider*100];
                        meetRoomModel.LightValue = [NSNumber numberWithFloat:slider*100];
                    }
                    
                    [self logRecordDriOperate:operate withTagId:tagId withOldValue:0  withNewValue:slider*100];
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
#pragma mark 单个亮度日志
- (void)logRecordDriOperate:(NSString *)operate withTagId:(NSString *)tagId withOldValue:(CGFloat)oldValue withNewValue:(CGFloat)newValue {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:operate forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:operate forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:[NSString stringWithFormat:@"lighting/%@", tagId] forKey:@"operateUrl"];//操作url
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
    [logDic setObject:[NSString stringWithFormat:@"%.0f", newValue] forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:tagId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"会议室" forKey:@"operateDeviceName"];//操作设备名  模块
//    [logDic setObject:[NSString stringWithFormat:@"%.0f", oldValue] forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

#pragma mark 全开 全关模式
- (void)allConScene:(NSString *)modelId {
    NSString *urlStr = [NSString stringWithFormat:@"%@/lighting/model/%@?roomId=%@",Main_Url, modelId, _model.ROOM_ID];
    [self showHudInView:self.view hint:@""];
    [[NetworkClient sharedInstance] POST:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *resDic = responseObject[@"responseData"];
            if(resDic != nil && ![resDic isKindOfClass:[NSNull class]]){
                NSString *result = resDic[@"result"];
                if(result != nil && ![result isKindOfClass:[NSNull class]] && [result isEqualToString:@"success"]){
                    
                    // 记录日志
                    [self logRecordModelId:modelId];
                    
                    [self changeModel:modelId];
                    
                    // 发送全部控制通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AllControlScene" object:nil];
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changeSceneModel" object:nil];
}

#pragma mark 记录日志
- (void)logRecordModelId:(NSString *)modelId {
    NSString *operate = @"";
    if([modelId isEqualToString:@"off"]){
        operate = @"会议室设备全关";
    }else if([modelId isEqualToString:@"on"]){
        operate = @"会议室设备全开";
    }
    
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:operate forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:operate forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"lighting/model" forKey:@"operateUrl"];//操作url
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:modelId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"会议室" forKey:@"operateDeviceName"];//操作设备名  模块
    //    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

@end
