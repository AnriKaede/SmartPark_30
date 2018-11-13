//
//  ParkNightViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/10.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ParkNightViewController.h"
#import "YQSlider.h"
#import "YQSwitch.h"
#import "TimeSetTableViewController.h"

#import "YQInDoorPointMapView.h"
#import "YQHeaderView.h"
#import "ShowMenuView.h"

#import "ParkLightModel.h"

#import "ParkTimeViewController.h"

#import "MeetRoomStateModel.h"

@interface ParkNightViewController ()<DidSelInMapPopDelegate, MenuControlDelegate>
{
    YQSwitch *_yqSwitch;
    
    __weak IBOutlet UIImageView *_stateImgView;
    
    __weak IBOutlet UILabel *_stateLabel;
    
    __weak IBOutlet UIView *_lightView;
    
    YQSlider *_yqSlider;
    
    YQInDoorPointMapView *indoorView;
    UIView *bottomView;
    UIImageView *_selectImageView;
    
    ShowMenuView *_showMenuView;
    BOOL _isRuning;
    NSString *_titleStr;
    NSString *_stateStr;
    UIColor *_stateColor;
    CGFloat _lightValue;
    NSString *_timeStr;
    
    BOOL _isShowMenu;
    
    ParkLightModel *_selModel;
}

@property (nonatomic,strong) YQHeaderView *headerView;
@property (nonatomic,strong) NSMutableArray *pointMapDataArr;
@property (nonatomic,strong) NSMutableArray *graphData;

@end

@implementation ParkNightViewController

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

-(YQHeaderView *)headerView
{
    if (_headerView == nil) {
        _headerView = [[YQHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 85)];
        _headerView.backgroundColor = [UIColor colorWithHexString:@"1B82D1"];
    }
    return _headerView;
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
        indoorView.frame = CGRectMake(0, 0, KScreenWidth, bottomView.height);
        _showMenuView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
        [_showMenuView reloadMenuData];
        _headerView.hidden = YES;
    }else{
        // 屏幕从横屏变为竖屏时执行
        NSLog(@"屏幕从横屏变为竖屏时执行");
        bottomView.frame = CGRectMake(0, _headerView.bottom, KScreenWidth, KScreenHeight - kTopHeight - 20 - _headerView.bottom);
        indoorView.frame = CGRectMake(0, 0, KScreenWidth, bottomView.height);
        _showMenuView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
        [_showMenuView reloadMenuData];
        _headerView.hidden = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
    
    [self _loadData];
}

- (void)_initView {
//    self.title = @"车库照明";
    
    // 创建点击菜单视图
    _showMenuView = [[ShowMenuView alloc] init];
    _showMenuView.hidden = YES;
    _showMenuView.menuDelegate = self;
    [[UIApplication sharedApplication].delegate.window addSubview:_showMenuView];
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [self.view addSubview:self.headerView];
    
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_headerView.frame), KScreenWidth, KScreenHeight-64-CGRectGetMaxY(_headerView.frame))];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    indoorView = [[YQInDoorPointMapView alloc]initWithIndoorMapImageName:@"dxck" Frame:CGRectMake(0, 5, KScreenWidth, bottomView.height-10)];
    indoorView.selInMapDelegate = self;
    [bottomView addSubview:indoorView];
    
    // 定时任务按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"park_light_time"] style:UIBarButtonItemStylePlain target:self action:@selector(timeAction)];
}

- (void)timeAction {
    [self forceOrientationPortrait];
    
    ParkTimeViewController *parkTimeVC = [[ParkTimeViewController alloc] init];
    parkTimeVC.timeTaskType = ParkLightTask;
    parkTimeVC.navTitle = @"定时照明";
    [self.navigationController pushViewController:parkTimeVC animated:YES];
}

#pragma mark 车库照明点位图
-(void)_loadData
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/equipment/getLightingList?lightingType=parking",Main_Url];
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        DLog(@"%@",responseObject);
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *dic = responseObject[@"responseData"];
            _headerView.leftNumLab.text = [NSString stringWithFormat:@"%@",dic[@"okEquipmentCount"]];
            _headerView.centerNumLab.text = [NSString stringWithFormat:@"%@",dic[@"outEquipmentCount"]];
            _headerView.rightNumLab.text = [NSString stringWithFormat:@"%@",dic[@"errorEquipmentCount"]];
            
            NSArray *arr = dic[@"equipmentList"];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ParkLightModel *model = [[ParkLightModel alloc] initWithDataDic:obj];
                
//                NSString *graphStr = [NSString stringWithFormat:@"%@,%@,%@",model.LAYER_A,model.LAYER_B,model.LAYER_C];
                NSString *graphStr = [NSString stringWithFormat:@"%@,%@",model.LONGITUDE, model.LATITUDE];
                [self.graphData addObject:graphStr];
                [self.pointMapDataArr addObject:model];
            }];
            
//            indoorView.isLayCoord = YES;
            indoorView.graphData = self.graphData;
            indoorView.parkLightArr = self.pointMapDataArr;
            
            // 加载开关状态
            [self loadEquipmentState];
        }
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark 点位图协议方法

- (void)selInMapWithId:(NSString *)identity {
    NSInteger selectIndex = [identity integerValue]-100;
    if(self.pointMapDataArr.count <= selectIndex){
        return;
    }
    ParkLightModel *model = self.pointMapDataArr[selectIndex];
    
    if (_selectImageView) {
        ParkLightModel *selectModel = self.pointMapDataArr[_selectImageView.tag-100];
        _selectImageView.contentMode = UIViewContentModeScaleToFill;
        if ([selectModel.EQUIP_STATUS isEqualToString:@"1"]) {
            _selectImageView.image = [UIImage imageNamed:@"park_light_normal"];
        }else if ([selectModel.EQUIP_STATUS isEqualToString:@"2"]) {
            _selectImageView.image = [UIImage imageNamed:@"park_light_normal"];
        }else{
            _selectImageView.image = [UIImage imageNamed:@"park_light_error"];
        }
    }
    
    // 复原之前选中图片效果
    if(_selectImageView != nil){
        [PointViewSelect recoverSelImgView:_selectImageView];
    }
    
    UIImageView *imageView = [indoorView.mapView viewWithTag:[identity integerValue]];
    if ([model.EQUIP_STATUS isEqualToString:@"1"] || [model.EQUIP_STATUS isEqualToString:@"2"]) {
        imageView.image = [UIImage imageNamed:@"park_light_normal"];
    }else {
        imageView.image = [UIImage imageNamed:@"park_light_error"];
    }
    imageView.contentMode = UIViewContentModeScaleToFill;
    _selectImageView = imageView;
    
    [PointViewSelect pointImageSelect:_selectImageView];
    
    _selModel = model;
    
    _showMenuView.hidden = NO;
    _titleStr = model.DEVICE_NAME;
    if([model.current_states isEqualToString:@"0"]){
        // 关闭
        _isRuning = NO;
        _stateStr = @"关闭";
        _stateColor = [UIColor grayColor];
    }else {// 正常
        _isRuning = YES;
        _stateStr = @"正常开启中";
        _stateColor = [UIColor colorWithHexString:@"#189517"];
    }
    
    _lightValue = 0;
    _timeStr = @"无参数";
    
    [_showMenuView reloadMenuData]; //  刷新菜单
}

#pragma mark 获取照明设备状态
- (void)loadEquipmentState {
    NSMutableString *tagids = @"".mutableCopy;
    [self.pointMapDataArr enumerateObjectsUsingBlock:^(ParkLightModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        if(model.TAGID != nil && ![model.TAGID isKindOfClass:[NSNull class]]){
            if(idx >= self.pointMapDataArr.count - 1){
                [tagids appendFormat:@"%@", model.TAGID];
            }else {
                [tagids appendFormat:@"%@,", model.TAGID];
            }
        }
    }];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/lighting/getIbmsTagValue/%@",Main_Url, tagids];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSString *responseData = responseObject[@"responseData"];
            NSData *jsonData = [responseData dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            
            if(jsonDic[@"result"] != nil && ![jsonDic[@"result"] isKindOfClass:[NSNull class]] && [jsonDic[@"result"] isEqualToString:@"success"]){
                // 成功
                __block int openCount = 0;
                __block int closeCount = 0;
                [self.pointMapDataArr enumerateObjectsUsingBlock:^(ParkLightModel *parkLightModel, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSArray *tagArray = jsonDic[@"tagArray"];
                    [tagArray enumerateObjectsUsingBlock:^(NSDictionary *stateDic, NSUInteger idx, BOOL * _Nonnull stop) {
                        MeetRoomStateModel *stateModel = [[MeetRoomStateModel alloc] initWithDataDic:stateDic];
                        if([stateModel.state_id isEqualToString:parkLightModel.TAGID]){
                            parkLightModel.current_states = stateModel.value;
                            
                            if([stateModel.value isEqualToString:@"0"]){
                                closeCount ++;
                            }else {
                                openCount ++;
                            }
                        }
                    }];
                }];
                
                _headerView.leftNumLab.text = [NSString stringWithFormat:@"%d",openCount];
                _headerView.centerNumLab.text = [NSString stringWithFormat:@"%d",closeCount];
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)refreshTopCount {
    __block int openCount = 0;
    __block int closeCount = 0;
    [self.pointMapDataArr enumerateObjectsUsingBlock:^(ParkLightModel *parkLightModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if([parkLightModel.current_states isEqualToString:@"0"]){
            closeCount ++;
        }else {
            openCount ++;
        }
    }];
    
    _headerView.leftNumLab.text = [NSString stringWithFormat:@"%d",openCount];
    _headerView.centerNumLab.text = [NSString stringWithFormat:@"%d",closeCount];
}

#pragma mark MenuControlDelegate
- (CGFloat)menuHeightInView:(NSInteger)index {
    switch (index) {
        case 0:
            return 60;
            break;
            
        default:
            return 0;
            break;
    }
}

- (NSInteger)menuNumInView {
    return 1;
}

- (NSString *)menuTitle:(NSInteger)index {
    switch (index) {
        case 0:
            return _stateStr;
            break;
            
        default:
            return @"";
            break;
    }
}

- (UIColor *)menuTitleColor:(NSInteger)index {
    if(index == 0){
        return _stateColor;
    }else {
        return [UIColor blackColor];
    }
}

- (NSString *)menuTitleViewText {
    return _titleStr;
}

- (ShowMenuStyle)menuViewStyle:(NSInteger)index {
    switch (index) {
        case 0:
            return SwitchConMenu;
            break;
            
        default:
            return DefaultConMenu;
            break;
    }
}

- (BOOL)isSwitch:(NSInteger)index {
    return _isRuning;
}

- (NSString *)menuMessage:(NSInteger)index {
    if(index == 2){
        return _timeStr;
    }else {
        return @"";
    }
}
- (UIColor *)menuMessageColor:(NSInteger)index {
    if(index == 2){
        return [UIColor colorWithHexString:@"#FF3333"];
    }else {
        return [UIColor blackColor];
    }
}

// 开关协议
- (void)switchState:(NSInteger)index withSwitch:(BOOL)isOn {
    if([_stateStr isEqualToString:@"设备故障"]){
        return;
    }
    
    NSString *operateType;
    if(isOn){
        operateType = @"ON";
    }else {
        operateType = @"OFF";
    }
    
    // 设备开关
    NSString *urlStr = [NSString stringWithFormat:@"%@/lighting/%@",Main_Url, _selModel.TAGID];
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
                    _isRuning = isOn;
                    if(isOn){
                        _stateStr = @"正常开启中";
                        _stateColor = [UIColor colorWithHexString:@"#189517"];
                        
                        _selModel.current_states = @"255";
                    }else {
                        _stateStr = @"关闭";
                        _stateColor = [UIColor grayColor];
                        
                        _selModel.current_states = @"0";
                    }
                    
                    [self refreshTopCount];
                    
                    // 记录日志
                    NSString *operate;
                    if(isOn){
                        operate = [NSString stringWithFormat:@"车库照明\"%@\"开启", _selModel.DEVICE_NAME];
                    }else {
                        operate = [NSString stringWithFormat:@"车库照明\"%@\"关闭", _selModel.DEVICE_NAME];
                    }
                    [self logRecordOperate:operate withTagId:_selModel.TAGID];
                }
            }
        }else {
            if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
                [self showHint:responseObject[@"message"]];
            }
        }
        [_showMenuView reloadMenuData];
    } failure:^(NSError *error) {
        [self hideHud];
        [_showMenuView reloadMenuData];
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

- (void)logRecordOperate:(NSString *)operate withTagId:(NSString *)tagId {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:operate forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:operate forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:[NSString stringWithFormat:@"lighting/%@", tagId] forKey:@"operateUrl"];//操作url
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:tagId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"车库照明" forKey:@"operateDeviceName"];//操作设备名  模块
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
