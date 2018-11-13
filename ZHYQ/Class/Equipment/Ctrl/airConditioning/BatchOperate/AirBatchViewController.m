//
//  AirBatchViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/7/13.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "AirBatchViewController.h"
#import "AirBatchCell.h"
#import "AirCompanyModel.h"
#import "AirRoomModel.h"
#import "CalculateHeight.h"

@interface AirBatchViewController ()<UITableViewDelegate, UITableViewDataSource, LayerSelDelegate>
{
    UITableView *_aptTableView;
    NSMutableArray *_aptParkData;
    
    UIView *_bottomView;
    NoDataView *_noDataView;
}
@end

@implementation AirBatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initNavView];
    
    [self _initView];
    
    [self _loadData];
    
    _aptParkData = @[].mutableCopy;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allSelAction:) name:@"AirALlSelNotification" object:nil];
}

- (void)_initNavView {
    self.title = @"批量操作车位锁";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

-(void)_leftBarBtnItemClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 批量全选/取消全选
- (void)allSelAction:(NSNotification*) notification {
    NSNumber *isAllSel = [notification object];
    
    [_aptParkData enumerateObjectsUsingBlock:^(AirCompanyModel *companyModel, NSUInteger idx, BOOL * _Nonnull stop) {
        companyModel.isSelect = isAllSel.boolValue;
        if(isAllSel.boolValue){
            companyModel.isDisplay = YES;
        }
        [companyModel.layers enumerateObjectsUsingBlock:^(AirLayerModel *layerModel, NSUInteger idx, BOOL * _Nonnull stop) {
            layerModel.isSelect = isAllSel.boolValue;
        }];
    }];
    [_aptTableView reloadData];
}

- (void)_initView {
    _aptTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64 - 60) style:UITableViewStylePlain];
    _aptTableView.tableFooterView = [UIView new];
    _aptTableView.backgroundColor = [UIColor whiteColor];
    _aptTableView.delegate = self;
    _aptTableView.dataSource = self;
    [self.view addSubview:_aptTableView];
    
    [_aptTableView registerNib:[UINib nibWithNibName:@"AirBatchCell" bundle:nil] forCellReuseIdentifier:@"AirBatchCell"];
    
    [self _createBottomView];
    
    _noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight)];
    _noDataView.hidden = YES;
    [self.view addSubview:_noDataView];
}
- (void)_createBottomView {
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, KScreenHeight - kTopHeight - 60, KScreenWidth, 60)];
    [self.view insertSubview:_bottomView aboveSubview:_aptTableView];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, KScreenWidth/2, 60);
    [leftButton setBackgroundImage:[UIImage imageNamed:@"scene_all_close_bg"] forState:UIControlStateNormal];
    [leftButton setTitle:@"批量关空调" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(batchOpenAction) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:leftButton];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(KScreenWidth/2, 0, KScreenWidth/2, 60);
    rightButton.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    [rightButton setTitle:@"批量开空调" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor colorWithHexString:@"#CCFF00"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(batchProhibitAction) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:rightButton];
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/airConditioner/companyRooms", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:@"" forKey:@"companyId"];
    
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            // 处理数据
            [self dealBatchData:responseObject[@"responseData"]];
            [_aptTableView reloadData];
        }
        if(_aptParkData.count <= 0){
            _noDataView.hidden = NO;
        }else {
            _noDataView.hidden = YES;
        }
        
    }failure:^(NSError *error) {
        if(_aptParkData.count <= 0){
            [self showNoDataImage];
        }else {
            [self showHint:KRequestFailMsg];
        }
    }];
}
- (void)dealBatchData:(NSArray *)batchData {
    [_aptParkData removeAllObjects];
    [batchData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AirCompanyModel *companyModel = [[AirCompanyModel alloc] initWithDataDic:obj];
        [_aptParkData addObject:companyModel];
    }];
}

#pragma mark 无网络重新加载
- (void)reloadTableData {
    [self _loadData];
}

#pragma mark UITableView 协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _aptParkData.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    AirCompanyModel *companyModel = _aptParkData[section];
    if(companyModel.isDisplay){
        return companyModel.layers.count;
    }else {
        return 0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    AirCompanyModel *companyModel = _aptParkData[section];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 50)];
    headerView.tag = 4000+section;
    headerView.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *displayTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayAction:)];
    [headerView addGestureRecognizer:displayTap];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, KScreenWidth - 40, 50)];
    label.text = companyModel.companyName;
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:17];
    label.textAlignment = NSTextAlignmentLeft;
    [headerView addSubview:label];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = section + 2000;
    button.hidden = !companyModel.isDisplay;
    button.frame = CGRectMake(KScreenWidth - 40, 5, 40, 40);
    [button setImage:[UIImage imageNamed:@"park_cancel_apt_normal"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"park_cancel_apt_select"] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(selGroupAction:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:button];
    
    // 选中一组
    button.selected = companyModel.isSelect;
    
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    AirCompanyModel *companyModel = _aptParkData[indexPath.section];
    AirLayerModel *layerModel = companyModel.layers[indexPath.row];
    NSMutableString *roomsStr = @"".mutableCopy;
    __block NSInteger count = 0;
    int item = (KScreenWidth - 159)/70 - 1;
    [layerModel.rooms enumerateObjectsUsingBlock:^(AirRoomModel *roomModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if(count >= item || roomModel.roomName.length > 5){
            [roomsStr appendFormat:@"%@\n", roomModel.roomName];
            count = 0;
        }else {
            [roomsStr appendFormat:@"%@  ", roomModel.roomName];
            count ++;
        }
    }];
//    CGFloat textHeight = [CalculateHeight heightForString:roomsStr fontSize:17 andWidth:(KScreenWidth - 159)];
    CGFloat textHeight = [self getSpaceLabelHeight:roomsStr withFont:[UIFont fontWithName:@"Monaco" size:17] withWidth:(KScreenWidth - 159)];
    return textHeight + 30;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AirBatchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AirBatchCell" forIndexPath:indexPath];
    
    AirCompanyModel *companyModel = _aptParkData[indexPath.section];
    cell.airLayerModel = companyModel.layers[indexPath.row];
    cell.layerSelDelegate = self;
    
    return cell;
}

#pragma mark cell选中一行协议
- (void)selLayer:(AirLayerModel *)airLayerModel withOn:(BOOL)on {
    airLayerModel.isSelect = on;
    __block NSInteger section;
    __block NSInteger index;
    [_aptParkData enumerateObjectsUsingBlock:^(AirCompanyModel *airCompanyModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if([airCompanyModel.layers containsObject:airLayerModel]) {
            section = idx;
            index = [airCompanyModel.layers indexOfObject:airLayerModel];
        }
    }];
    [_aptTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:section]] withRowAnimation:UITableViewRowAnimationFade];
}

// 显示或隐藏一组
- (void)displayAction:(UITapGestureRecognizer *)tap {
    NSInteger index = tap.view.tag - 4000;
    AirCompanyModel *companyModel = _aptParkData[index];
    companyModel.isDisplay = !companyModel.isDisplay;
    
    [_aptTableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark 批量选中某组
- (void)selGroupAction:(UIButton *)selBt {
    AirCompanyModel *companyModel = _aptParkData[selBt.tag - 2000];
    companyModel.isSelect = !companyModel.isSelect;
    
    [companyModel.layers enumerateObjectsUsingBlock:^(AirLayerModel *layerModel, NSUInteger idx, BOOL * _Nonnull stop) {
        layerModel.isSelect = companyModel.isSelect;
    }];
    
    NSInteger section = [_aptParkData indexOfObject:companyModel];
    [_aptTableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark 批量关空调
- (void)batchOpenAction {
    NSString *spaces = [self achieveSelAir];
    if(spaces == nil || spaces.length <= 0){
        [self showHint:@"请先选择"];
        return;
    }
    NSLog(@"%@", spaces);
    
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"确认关闭选中空调设备(%@)", [self achieveSelLayer]] preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        // batchAllow
        [self operationSpace:spaces withOperateValue:@"0"];
    }];
    [alertCon addAction:cancelAction];
    [alertCon addAction:closeAction];
    
    if (alertCon.popoverPresentationController != nil) {
        alertCon.popoverPresentationController.sourceView = _bottomView;
        alertCon.popoverPresentationController.sourceRect = _bottomView.bounds;
    }
    
    [self presentViewController:alertCon animated:YES completion:nil];
    
}

#pragma mark 批量开空调
- (void)batchProhibitAction {
    NSString *spaces = [self achieveSelAir];
    if(spaces == nil || spaces.length <= 0){
        [self showHint:@"请先选择"];
        return;
    }
    
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"确认开启选中空调设备(%@)", [self achieveSelLayer]] preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *openAction = [UIAlertAction actionWithTitle:@"开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // batchAllow
        [self operationSpace:spaces withOperateValue:@"1"];
    }];
    [alertCon addAction:cancelAction];
    [alertCon addAction:openAction];
    
    if (alertCon.popoverPresentationController != nil) {
        alertCon.popoverPresentationController.sourceView = _bottomView;
        alertCon.popoverPresentationController.sourceRect = _bottomView.bounds;
    }
    
    [self presentViewController:alertCon animated:YES completion:nil];
}

- (void)operationSpace:(NSString *)rangeIds withOperateValue:(NSString *)operateValue {
    NSString *urlStr = [NSString stringWithFormat:@"%@/airConditioner/batchOperate", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:@"rooms" forKey:@"rangeType"];
    [paramDic setObject:rangeIds forKey:@"rangeIds"];
//    [paramDic setObject:@"'305'" forKey:@"rangeIds"];
    [paramDic setObject:operateValue forKey:@"operateValue"];
    
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            // 全部取消选中
            [_aptParkData enumerateObjectsUsingBlock:^(AirCompanyModel *companyModel, NSUInteger idx, BOOL * _Nonnull stop) {
                companyModel.isSelect = NO;
                [companyModel.layers enumerateObjectsUsingBlock:^(AirLayerModel *airLayerModel, NSUInteger idx, BOOL * _Nonnull stop) {
                    airLayerModel.isSelect = NO;
                }];
            }];
            [_aptTableView reloadData];
            
            // 记录日志
            NSString *OperateName;
            if([operateValue isEqualToString:@"1"]){
                OperateName = [NSString stringWithFormat:@"空调批量开启"];
            }else {
                OperateName = [NSString stringWithFormat:@"空调批量关闭"];
            }
            [self logRecordTagId:rangeIds withOperateName:OperateName withUrl:@"/airConditioner/batchOperate"];
            
        }
        NSString *message = responseObject[@"message"];
        if(message != nil && ![message isKindOfClass:[NSNull class]]) {
            [self showHint:message];
        }
        
    }failure:^(NSError *error) {
        [self showHint:KRequestFailMsg];
    }];
}

- (NSString *)achieveSelAir {
    NSMutableString *airRooms = @"".mutableCopy;
    [_aptParkData enumerateObjectsUsingBlock:^(AirCompanyModel *companyModel, NSUInteger idx, BOOL * _Nonnull stop) {
        [companyModel.layers enumerateObjectsUsingBlock:^(AirLayerModel *layerModel, NSUInteger idx, BOOL * _Nonnull stop) {
            if(layerModel.isSelect){
                [layerModel.rooms enumerateObjectsUsingBlock:^(AirRoomModel *roomModel, NSUInteger idx, BOOL * _Nonnull stop) {
                    [airRooms appendFormat:@"'%@',", roomModel.roomId];
                }];
            }
        }];
    }];
    
    if(airRooms.length > 1){
        [airRooms deleteCharactersInRange:NSMakeRange(airRooms.length - 1, 1)];
    }
    
    return airRooms;
}
- (NSString *)achieveSelLayer {
    NSMutableString *airRooms = @"".mutableCopy;
    [_aptParkData enumerateObjectsUsingBlock:^(AirCompanyModel *companyModel, NSUInteger idx, BOOL * _Nonnull stop) {
        [companyModel.layers enumerateObjectsUsingBlock:^(AirLayerModel *layerModel, NSUInteger idx, BOOL * _Nonnull stop) {
            if(layerModel.isSelect){
                [airRooms appendFormat:@"%@,", layerModel.layerName];
            }
        }];
    }];
    
    if(airRooms.length > 1){
        [airRooms deleteCharactersInRange:NSMakeRange(airRooms.length - 1, 1)];
    }
    
    return airRooms;
}

#pragma mark 记录日志
- (void)logRecordTagId:(NSString *)tagId withOperateName:(NSString *)operateName withUrl:(NSString *)operateUrl {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:[NSString stringWithFormat:@"%@", operateName] forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:[NSString stringWithFormat:@"%@", operateName] forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:operateUrl forKey:@"operateUrl"];//操作url
    //    [logDic setObject:@"" forKey:@"operateLocation"];//操作地点
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:tagId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"空调批量操作" forKey:@"operateDeviceName"];//操作设备名  模块
    //    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AirALlSelNotification" object:nil];
}

#define UILABEL_LINE_SPACE 1
#define UILABEL_CHAR_SPACE 1.5
#define HEIGHT [[UIScreen mainScreen] bounds].size.height
//计算UILabel的高度(带有行间距的情况)
-(CGFloat)getSpaceLabelHeight:(NSString*)str withFont:(UIFont*)font withWidth:(CGFloat)width {
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = UILABEL_LINE_SPACE;
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@UILABEL_CHAR_SPACE
                          };
    
    CGSize size = [str boundingRectWithSize:CGSizeMake(width, HEIGHT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    
    return size.height;
    
}

@end
