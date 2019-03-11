//
//  StreLigAllConViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/8.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "StreLigAllConViewController.h"
#import "StreetLampCell.h"
#import "StreetLampSubModel.h"

@interface StreLigAllConViewController ()<UITableViewDelegate, UITableViewDataSource, selectConDelegate, CYLTableViewPlaceHolderDelegate>
{
    UITableView *_streetLampTableView;
    UIView *_bottomView;
    UIButton *_allCloseButton;
    UIButton *_allOpenButton;
    
    BOOL _isAllSel; // 是否全选
    UIButton *_rightBt;
    
    NSMutableArray *_lampData;
}
@end

@implementation StreLigAllConViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _lampData = @[].mutableCopy;
    _isAllSel = NO;

    [self initNavItems];
    
    [self _initView];
    
    [self _loadData];
}

-(void)initNavItems
{
    self.title = @"批量开关";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _rightBt = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBt.frame = CGRectMake(0, 0, 60, 18);
    [_rightBt setTitle:@"全选" forState:UIControlStateNormal];
    [_rightBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_rightBt addTarget:self action:@selector(changeAllConAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBt];
    
}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_initView {
    // tableView
    _streetLampTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64 - 60) style:UITableViewStyleGrouped];
    _streetLampTableView.delegate = self;
    _streetLampTableView.dataSource = self;
    _streetLampTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.view addSubview:_streetLampTableView];
    [_streetLampTableView registerNib:[UINib nibWithNibName:@"StreetLampCell" bundle:nil] forCellReuseIdentifier:@"StreetLampCell"];
    
    // 下方全关/开控制
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, KScreenHeight - kTopHeight - 60, KScreenWidth, 60)];
    [self.view addSubview:_bottomView];
    
    _allCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _allCloseButton.frame = CGRectMake(0, 0, KScreenWidth/2, 60);
    [_allCloseButton setImage:[UIImage imageNamed:@"scene_all_close"] forState:UIControlStateNormal];
    [_allCloseButton setTitle:@" 批量关灯" forState:UIControlStateNormal];
    [_allCloseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_allCloseButton setBackgroundImage:[UIImage imageNamed:@"scene_all_close_bg"] forState:UIControlStateNormal];
    [_allCloseButton addTarget:self action:@selector(allClose) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_allCloseButton];
    
    _allOpenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _allOpenButton.backgroundColor = [UIColor colorWithHexString:@"#1B82D1 "];
    _allOpenButton.frame = CGRectMake(KScreenWidth/2, 0, KScreenWidth/2, 60);
    [_allOpenButton setImage:[UIImage imageNamed:@"scene_all_open"] forState:UIControlStateNormal];
    [_allOpenButton setTitle:@" 批量开灯" forState:UIControlStateNormal];
    [_allOpenButton setTitleColor:[UIColor colorWithHexString:@"#CCFF00"] forState:UIControlStateNormal];
    [_allOpenButton addTarget:self action:@selector(allOpen) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_allOpenButton];
}

-(void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/common/getSubDeviceListByType?deviceType=55,55-1,55-2&subDeviceType=18",Main_Url];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSArray *arr = responseObject[@"responseData"];
            [_lampData removeAllObjects];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                StreetLampSubModel *model = [[StreetLampSubModel alloc] initWithDataDic:obj];
                if(idx%2 == 0){
                    model.isColor = YES;
                }
                [_lampData addObject:model];
            }];
        }
        [_streetLampTableView cyl_reloadData];
    } failure:^(NSError *error) {
        if(_lampData.count <= 0){
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

#pragma mark 批量关
- (void)allClose {
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否全部关闭" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *removeAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSMutableArray *closeData = @[].mutableCopy;
        [_lampData enumerateObjectsUsingBlock:^(StreetLampSubModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            if(model.isConSelect){
                NSDictionary *lampDic = @{@"uid":model.SUB_TAGID,
                                          @"lampCtrlAddr":model.SUB_DEVICE_ADDR,
                                          };
                [closeData addObject:lampDic];
            }
        }];
        [self batchesCon:closeData withOnOff:@"OFF"];
    }];
    [alertCon addAction:cancelAction];
    [alertCon addAction:removeAction];
    if (alertCon.popoverPresentationController != nil) {
        alertCon.popoverPresentationController.sourceView = _bottomView;
        alertCon.popoverPresentationController.sourceRect = _bottomView.bounds;
    }
    [self presentViewController:alertCon animated:YES completion:^{
    }];
}

#pragma mark 批量开
- (void)allOpen {
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否全部开启" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *removeAction = [UIAlertAction actionWithTitle:@"开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSMutableArray *openData = @[].mutableCopy;
        [_lampData enumerateObjectsUsingBlock:^(StreetLampSubModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            if(model.isConSelect){
                NSDictionary *lampDic = @{@"uid":model.SUB_TAGID,
                                          @"lampCtrlAddr":model.SUB_DEVICE_ADDR,
                                          };
                [openData addObject:lampDic];
            }
        }];
        [self batchesCon:openData withOnOff:@"ON"];
    }];
    [alertCon addAction:cancelAction];
    [alertCon addAction:removeAction];
    if (alertCon.popoverPresentationController != nil) {
        alertCon.popoverPresentationController.sourceView = _bottomView;
        alertCon.popoverPresentationController.sourceRect = _bottomView.bounds;
    }
    [self presentViewController:alertCon animated:YES completion:^{
    }];
    
}

- (void)batchesCon:(NSArray *)lamps withOnOff:(NSString *)onOff {
    NSString *urlStr = [NSString stringWithFormat:@"%@/roadLamp/controlLamps",Main_Url];
    
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:lamps forKey:@"lamps"];
    [param setObject:@"24" forKey:@"lampCtrlType"];
    [param setObject:@"on" forKey:@"operateType"];
    [param setObject:onOff forKey:@"operateValue"];
    
    NSDictionary *paramDic =@{@"param":[Utils convertToJsonData:param]};
    
    [self showHudInView:self.view hint:@""];
    [[NetworkClient sharedInstance] POST:urlStr dict:paramDic progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            // 成功 记录日志
            [_lampData enumerateObjectsUsingBlock:^(StreetLampSubModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
                if(model.isConSelect){
                    NSString *operate;
                    if([onOff isEqualToString:@"ON"]){
                        operate = [NSString stringWithFormat:@"路灯批量\"%@\"开", model.DEVICE_NAME];
                    }else {
                        operate = [NSString stringWithFormat:@"路灯批量\"%@\"关", model.DEVICE_NAME];
                    }
                    
                    [self logRecordOperate:operate withUid:model.SUB_TAGID];
                }
            }];
        }
        
        if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
            [self showHint:responseObject[@"message"]];
        }
    } failure:^(NSError *error) {
        [self hideHud];
    }];
}
- (void)logRecordOperate:(NSString *)operate withUid:(NSString *)uid {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:operate forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:operate forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"roadLamp/controlLamps" forKey:@"operateUrl"];//操作url
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:uid forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"智能路灯" forKey:@"operateDeviceName"];//操作设备名  模块
//    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}



#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight)];
    return noDataView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark UITableView协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _lampData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StreetLampCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StreetLampCell" forIndexPath:indexPath];
    cell.streetLampSubModel = _lampData[indexPath.row];
    cell.selConDelegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    StreetLampSubModel *model = _lampData[indexPath.row];
    model.isConSelect = !model.isConSelect;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [self isAllSel];
}

- (void)selCon:(StreetLampSubModel *)streetLampSubModel {
    streetLampSubModel.isConSelect = !streetLampSubModel.isConSelect;
    
    NSInteger index = [_lampData indexOfObject:streetLampSubModel];
    [_streetLampTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
    [self isAllSel];
}

// 判断是否全选/全不选
- (void)isAllSel{
    __block BOOL isAllSel = YES;
    [_lampData enumerateObjectsUsingBlock:^(StreetLampSubModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        if(!model.isConSelect){
            isAllSel = NO;
        }
    }];
    
    if(isAllSel){
        _isAllSel = YES;
        [_rightBt setTitle:@"全不选" forState:UIControlStateNormal];
    }else {
        _isAllSel = NO;
        [_rightBt setTitle:@"全选" forState:UIControlStateNormal];
    }
    
}

#pragma mark 全选/全不选
- (void)changeAllConAction {
    [_lampData enumerateObjectsUsingBlock:^(StreetLampSubModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        if(_isAllSel){
            // 当前为全选，改为全不选
            model.isConSelect = NO;
        }else {
            // 改为全选
            model.isConSelect = YES;
        }
    }];
    
    _isAllSel = !_isAllSel;
    
    if(_isAllSel){
        [_rightBt setTitle:@"全不选" forState:UIControlStateNormal];
    }else {
        [_rightBt setTitle:@"全选" forState:UIControlStateNormal];
    }
    
    [_streetLampTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
