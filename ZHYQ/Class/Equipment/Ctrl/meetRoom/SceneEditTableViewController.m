//
//  SceneEditTableViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/10.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "SceneEditTableViewController.h"
#import "YQSlider.h"
#import "YQSwitch.h"

#import "MeetRoomModel.h"
#import "SceneEquipmentModel.h"
#import "SingleCtrlTableViewCell.h"
#import "SceneEditCell.h"

#import "Utils.h"

@interface SceneEditTableViewController ()<SliderLightDelegate, TextChangeDelegate>
{
    NSString *_sceneName;
    
    NSMutableArray *_editData;
    NSMutableArray *_sceneData;
    
    // 修改前数据
    NSMutableArray *_updateForwardData;
    
    NSInteger _sceneSliderValue;
    
    SceneEditCell *_sceneCell;
}
@end

@implementation SceneEditTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _editData = @[].mutableCopy;
    _sceneData = @[].mutableCopy;
    _updateForwardData = @[].mutableCopy;
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self _initView];
    
    [self _loadData];
}

- (void)_initView {
    self.title = @"场景编辑";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
    
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SingleCtrlTableViewCell" bundle:nil] forCellReuseIdentifier:@"SingleCtrlTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SceneEditCell" bundle:nil] forCellReuseIdentifier:@"SceneEditCell"];
    
    if(_isSceneModel && _sceneOnOffModel.modelName != nil && ![_sceneOnOffModel.modelName isKindOfClass:[NSNull class]]){
        _sceneName = _sceneOnOffModel.modelName;
    }
    
}
- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 保存
- (void)saveAction {
    [self.view endEditing:YES];
    
    if(_sceneCell.sceneNameTF.text == nil || _sceneCell.sceneNameTF.text.length <= 0){
        [self showHint:@"请输入场景名字"];
        return;
    }
    
    NSMutableArray *paramArys = @[].mutableCopy;
    NSString *urlStr;
    NSMutableDictionary *jsonParam = @{}.mutableCopy;
    
    [_sceneData enumerateObjectsUsingBlock:^(SceneEquipmentModel *sceneModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSMutableDictionary *params = @{}.mutableCopy;
        // 是否是可调亮度的筒灯
        if(_isSceneModel){
            // 修改模式
            [params setObject:sceneModel.uuid forKey:@"uuid"];
            [params setObject:_sceneOnOffModel.modelId forKey:@"modeId"];
        }
        [params setObject:sceneModel.tagId forKey:@"tagId"];
        [params setObject:sceneModel.tagStatus forKey:@"tagStatus"];
        [params setObject:sceneModel.tagType forKey:@"tagType"];
        [params setObject:_sceneCell.sceneNameTF.text forKey:@"modeName"];
        [params setObject:sceneModel.tagName forKey:@"tagName"];
        [params setObject:sceneModel.deviceType forKey:@"deviceType"];
        
        if([sceneModel.deviceType isEqualToString:@"18-1"]){
            if(sceneModel.tagStatus != nil && ![sceneModel.tagStatus isKindOfClass:[NSNull class]] && [sceneModel.tagStatus isEqualToString:@"ON"]){
                [params setObject:[NSNumber numberWithInteger:_sceneSliderValue] forKey:@"tagValue"];
            }else {
                [params setObject:[NSNumber numberWithInteger:0] forKey:@"tagValue"];
            }
        }else {
            
        }
        
        [paramArys addObject:params];
    }];
    
    NSString *jsonStr = [Utils convertToJsonData:@{@"equipmentList":paramArys}];
    
    [jsonParam setObject:jsonStr forKey:@"param"];
    
    if(_isSceneModel){
        // 修改模式
        urlStr = [NSString stringWithFormat:@"%@/lighting/mode/update",Main_Url];
    }else {
        // 新增模式
        urlStr = [NSString stringWithFormat:@"%@/lighting/mode/insert?roomId=%@",Main_Url, _model.ROOM_ID];
    }
        
        /*
        // 新增模式
        [_editData enumerateObjectsUsingBlock:^(MeetRoomModel *roomModel, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSMutableDictionary *params = @{}.mutableCopy;
            // 是否是可调亮度的筒灯
            [params setObject:roomModel.TAGID forKey:@"tagId"];
            NSString *tagStatus = @"";
            if([roomModel.current_state isEqualToString:@"0"]){
                tagStatus = @"OFF";
            }else {
                tagStatus = @"ON";
            }
            [params setObject:tagStatus forKey:@"tagStatus"];
            
            if([roomModel.DEVICE_TYPE isEqualToString:@"18-1"]){
                [params setObject:@"0" forKey:@"tagType"];
                [params setObject:[NSNumber numberWithInteger:_sceneSliderValue] forKey:@"tagValue"];
            }else {
                [params setObject:@"1" forKey:@"tagType"];
            }
            [params setObject:roomModel.DEVICE_NAME forKey:@"tagName"];
            [params setObject:_sceneCell.sceneNameTF.text forKey:@"modeName"];
            [params setObject:roomModel.DEVICE_TYPE forKey:@"deviceType"];
            
            [paramArys addObject:params];
        }];
        
        NSString *jsonStr = [Utils convertToJsonData:@{@"equipmentList":paramArys
                                                       }];
        
        [jsonParam setObject:jsonStr forKey:@"param"];
        
        urlStr = [NSString stringWithFormat:@"%@/lighting/mode/insert?roomId=%@",Main_Url, _model.ROOM_ID];
         */
    
    [[NetworkClient sharedInstance] POST:urlStr dict:jsonParam progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        if([responseObject[@"code"] isEqualToString:@"1"]){
            if(_isSceneModel){
                // 修改
                _sceneOnOffModel.modelName = _sceneName;
                
                // 记录日志
                [_updateForwardData enumerateObjectsUsingBlock:^(SceneEquipmentModel *forwardModel, NSUInteger idx, BOOL * _Nonnull stop) {
                    SceneEquipmentModel *nowModel = _sceneData[idx];
                    if(![forwardModel.tagStatus isEqualToString:nowModel.tagStatus]){
                        // 修改设备
                        NSString *operate;
                        if([nowModel.tagStatus isEqualToString:@"ON"]){
                            operate = @"开启";
                        }else {
                            operate = @"关闭";
                        }
                        [self logRecordUpdateModelID:_sceneOnOffModel.modelId withTagID:forwardModel.tagId withOperate:[NSString stringWithFormat:@"会议室场景模式\"%@\"%@%@", _sceneOnOffModel.modelName, operate, forwardModel.tagName] withOldValue:forwardModel.tagStatus withNewValue:nowModel.tagStatus];
                    }
                    if([forwardModel.deviceType isEqualToString:@"18-1"] && forwardModel.tagValue.integerValue != nowModel.tagValue.integerValue){
                        // 可调节亮度设备
                        [self logRecordUpdateModelID:_sceneOnOffModel.modelId withTagID:forwardModel.tagId withOperate:[NSString stringWithFormat:@"会议室场景模式\"%@\"调节%@亮度", _sceneOnOffModel.modelName, forwardModel.tagName] withOldValue:forwardModel.tagValue withNewValue:[NSString stringWithFormat:@"%.0f", nowModel.tagValue.floatValue]];
                    }
                }];
                
            }else {
                // 新增
                // 记录新增日志
                NSDictionary *responseData = responseObject[@"responseData"];
                if(responseData != nil && ![responseData isKindOfClass:[NSNull class]] && [responseData.allKeys containsObject:@"modeId"]){
                    NSString *modelID = responseData[@"modeId"];
                    [self logRecordAddModelID:modelID withModelName:_sceneCell.sceneNameTF.text];
                }
            }
            if(_addDelegate){
                [_addDelegate addModelSuc];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
            [self showHint:responseObject[@"message"]];
        }
    } failure:^(NSError *error) {
    }];
}

#pragma mark 加载场景模式设备
-(void)_loadData {
    NSString *urlStr;
    if(_isSceneModel && _sceneOnOffModel.modelId != nil){
        // 编辑场景模式
        urlStr = [NSString stringWithFormat:@"%@/lighting/model/%@?roomId=%@",Main_Url, _sceneOnOffModel.modelId, _model.ROOM_ID];
    }else {
        // 新增场景模式
        _sceneSliderValue = 100;    // 新增默认100
        urlStr = [NSString stringWithFormat:@"%@/lighting/model/meeting?roomId=%@",Main_Url, _model.ROOM_ID];
    }
        
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            [_sceneData removeAllObjects];
            NSArray *responseData = responseObject[@"responseData"];
            [responseData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                SceneEquipmentModel *model = [[SceneEquipmentModel alloc] initWithDataDic:obj];
                if([model.deviceType isEqualToString:@"18-1"]){
                    _sceneSliderValue = model.tagValue.floatValue;
                }
                [_sceneData addObject:model];
                // 保存修改前数据
                SceneEquipmentModel *forwardModel = [[SceneEquipmentModel alloc] initWithDataDic:obj];
                [_updateForwardData addObject:forwardModel];
            }];
//            _isSceneModel = YES;
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        DLog(@"%@",error);
    }];
    
    /*
        // 新增场景模式
        _sceneSliderValue = 100;    // 新增默认100
        NSString *urlStr = [NSString stringWithFormat:@"%@/lighting/model/meeting?roomId=%@",Main_Url, _model.ROOM_ID];
        
        [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
            if ([responseObject[@"code"] isEqualToString:@"1"]) {
                [_editData removeAllObjects];
                NSDictionary *resDic = responseObject[@"responseData"];
                NSArray *equipmentList = resDic[@"equipmentList"];
                [equipmentList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    MeetRoomModel *model = [[MeetRoomModel alloc] initWithDataDic:obj];
                    [_editData addObject:model];
                }];
            }
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            DLog(@"%@",error);
        }];
    */
    
}

#pragma mark - Table view 协议
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 1){
        return 45;
    }
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(section == 1){
        UIView *secView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 16)];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 14, secView.width, secView.height)];
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.text = @"场景设备";
        [secView addSubview:titleLabel];
        return secView;
    }
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        return 75;
    }else {
//        if(_isSceneModel){
            SceneEquipmentModel *model = _sceneData[indexPath.row];
            if([model.deviceType isEqualToString:@"18-1"] && [model.tagStatus isEqualToString:@"ON"]){
                // 灯筒
                return 120;
            }
//        }
//        else {
//            MeetRoomModel *model = _editData[indexPath.row];
//            if([model.DEVICE_TYPE isEqualToString:@"18-1"] && ![model.current_state isEqualToString:@"0"]){
//                // 灯筒
//                return 120;
//            }
//        }
        return 75;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return 1;
    }else {
//        if(_isSceneModel){
            return _sceneData.count;
//        }else {
//            return _editData.count;
//        }
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        _sceneCell = [tableView dequeueReusableCellWithIdentifier:@"SceneEditCell"];
        _sceneCell.selectionStyle = UITableViewCellSelectionStyleNone;
        if(_isSceneModel){
            _sceneCell.sceneName = _sceneName;
            _sceneCell.changeDelegate = self;
        }
        return _sceneCell;
    }else {
        SingleCtrlTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SingleCtrlTableViewCell" forIndexPath:indexPath];
        cell.isEdit = YES;
        cell.lightDelegare = self;
//        if(_isSceneModel){
            SceneEquipmentModel *model = _sceneData[indexPath.row];
            // 灯筒
            cell.sceneModel = model;
//        }else {
//            MeetRoomModel *model = _editData[indexPath.row];
//            cell.model = model;
//        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.isScene = _isSceneModel;
        return cell;
    }
    
}


#pragma mark 添加场景模式
- (void)switchOnOff:(MeetRoomModel *)meetRoomModel withOpen:(BOOL)open {
    [self.view endEditing:YES];
    // 开关
    if(open){
        meetRoomModel.current_state = @"1";
    }else {
        meetRoomModel.current_state = @"0";
    }
    
    if([meetRoomModel.DEVICE_TYPE isEqualToString:@"6"]){
        // 空调
        [meetRoomModel.airList enumerateObjectsUsingBlock:^(MeetRoomDeviceModel *deviceDodel, NSUInteger idx, BOOL * _Nonnull stop) {
            if([deviceDodel.TAGNAME isEqualToString:@"AIRSTATUS"]){
                if(open){
                    meetRoomModel.current_state = @"1";
                }else {
                    meetRoomModel.current_state = @"0";
                }
            }
        }];
    }
    
    NSInteger index = [_editData indexOfObject:meetRoomModel];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
}
- (void)sliderValue:(MeetRoomModel *)meetRoomModel withValue:(CGFloat)slider {
    [self.view endEditing:YES];
    // 筒灯滑动
    _sceneSliderValue = slider*100;
}


#pragma mark 修改场景模式
- (void)switchSceneOnOff:(SceneEquipmentModel *)sceneModel withOpen:(BOOL)open {
    [self.view endEditing:YES];
    // 开关
    if(open){
        sceneModel.tagStatus = @"ON";
    }else {
        sceneModel.tagStatus = @"OFF";
    }
    NSInteger index = [_sceneData indexOfObject:sceneModel];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
}
- (void)sliderSceneValue:(SceneEquipmentModel *)sceneModel withValue:(CGFloat)slider {
    [self.view endEditing:YES];
    // 筒灯滑动
    _sceneSliderValue = slider*100;
}


#pragma mark 修改模式修改text 协议
- (void)changeText:(NSString *)text {
    _sceneName = text;
}

#pragma mark 新增场景模式日志
- (void)logRecordAddModelID:(NSString *)modelID withModelName:(NSString *)modelName {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:[NSString stringWithFormat:@"新增场景模式\"%@\"", modelName] forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:[NSString stringWithFormat:@"新增场景模式\"%@\"", modelName] forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"lighting/mode/insert" forKey:@"operateUrl"];//操作url
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:modelID forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"会议室" forKey:@"operateDeviceName"];//操作设备名  模块
    //    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

#pragma mark 修改场景模式日志 记录模式每个设备修改前后的值
- (void)logRecordUpdateModelID:(NSString *)modelID withTagID:(NSString *)tagId withOperate:(NSString *)operate withOldValue:(NSString *)oldValue withNewValue:(NSString *)newValue{
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:operate forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:[NSString stringWithFormat:@"%@ %@至%@", operate, oldValue, newValue] forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"lighting/mode/update" forKey:@"operateUrl"];//操作url
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
    [logDic setObject:newValue forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:tagId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"会议室" forKey:@"operateDeviceName"];//操作设备名  模块
    [logDic setObject:oldValue forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    [logDic setObject:modelID forKey:@"expand2"];//扩展字段 场景模式id
    
    [LogRecordObj recordLog:logDic];
}

@end
