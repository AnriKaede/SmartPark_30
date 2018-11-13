//
//  MeetRoomViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/10.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "MeetRoomViewController.h"
#import "MeetroomSceneCell.h"
#import "SceneEditTableViewController.h"
#import "SceneOnOffModel.h"

@interface MeetRoomViewController ()<UITableViewDelegate, UITableViewDataSource, ConSceneDelegate, AddSceneModelDelegate>
{
    __weak IBOutlet UIImageView *_topSceneImgView;
    
    __weak IBOutlet UITableView *_sceneTableView;
    
    __weak IBOutlet UIButton *_addBt;
    
    NSMutableArray *_sceneOnOffData;
}
@end

@implementation MeetRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _sceneOnOffData = @[].mutableCopy;
    
    [self _initView];
    
    [self _loadSceneData];
    
    // 接受全部控制控制，关闭所有场景模式
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allConScene) name:@"AllControlScene" object:nil];
}

- (void)_initView {
    self.title = @"场景模式";
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    
    _addBt.backgroundColor = [UIColor colorWithHexString:@"#e8e8e8"];
    _addBt.layer.borderColor = [UIColor colorWithHexString:@"#b0b0b0"].CGColor;
    _addBt.layer.borderWidth = 0.5;
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _sceneTableView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    _sceneTableView.tableFooterView = [UIView new];
    _sceneTableView.delegate = self;
    _sceneTableView.dataSource = self;
    [_sceneTableView registerNib:[UINib nibWithNibName:@"MeetroomSceneCell" bundle:nil] forCellReuseIdentifier:@"MeetroomSceneCell"];
}
- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_loadSceneData {
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/lighting/model?roomId=%@",Main_Url, _model.ROOM_ID];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSArray *responseData = responseObject[@"responseData"];
            [_sceneOnOffData removeAllObjects];
            [responseData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                SceneOnOffModel *model = [[SceneOnOffModel alloc] initWithDataDic:obj];
                model.onOff = @0;
                [_sceneOnOffData addObject:model];
            }];
            [_sceneTableView cyl_reloadData];
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        if(_sceneOnOffData.count <= 0){
            [self showNoDataImage];
        }else {
            [self showHint:KRequestFailMsg];
        }
    }];
}
// 无网络重载
- (void)reloadTableData {
    [self _loadSceneData];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight - 240)];
    return noDataView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark UITableView 协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sceneOnOffData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MeetroomSceneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MeetroomSceneCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(_sceneOnOffData.count > indexPath.row){
        cell.sceneOnOffModel = _sceneOnOffData[indexPath.row];
    }
    cell.sceneDelegate = self;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SceneOnOffModel *model = _sceneOnOffData[indexPath.row];
    // 模式编辑
    SceneEditTableViewController *sceneEditVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"SceneEditTableViewController"];
    sceneEditVC.isSceneModel = YES;
    sceneEditVC.sceneOnOffModel = model;
    sceneEditVC.addDelegate = self;
    sceneEditVC.model = _model;
    [self.navigationController pushViewController:sceneEditVC animated:YES];
}
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    SceneOnOffModel *model = _sceneOnOffData[indexPath.row];
    if([model.modelId isEqualToString:@"outing"] ||
       [model.modelId isEqualToString:@"meeting"] ||
       [model.modelId isEqualToString:@"shadowing"]
       ){
        return @[];
    }
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除"handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        // 删除
        [self deleteSceneModel:model];
    }];
    
    // 将设置好的按钮放到数组中返回
    return @[deleteRowAction];
}

- (void)deleteSceneModel:(SceneOnOffModel *)model {
    NSString *urlStr = [NSString stringWithFormat:@"%@/lighting/mode/delete",Main_Url];
    
    NSString *jsonStr = [Utils convertToJsonData:@{@"modeId":model.modelId,
                                                   @"roomId":_model.ROOM_ID
                                                   }];
    
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSInteger index = [_sceneOnOffData indexOfObject:model];
            [_sceneOnOffData removeObjectAtIndex:index];
            [_sceneTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            
            // 记录日志
            [self logRecordDeleteModel:model];
        }else {
            NSString *meesage = responseObject[@"message"];
            if(meesage != nil && ![meesage isKindOfClass:[NSNull class]]){
                [self showHint:meesage];
            }
        }
        
        [_sceneTableView reloadData];
    } failure:^(NSError *error) {
    }];
}
#pragma mark 删除会议模式日志
- (void)logRecordDeleteModel:(SceneOnOffModel *)model {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:[NSString stringWithFormat:@"删除会议室场景模式\"%@\"", model.modelName] forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:[NSString stringWithFormat:@"删除会议室场景模式\"%@\"", model.modelName] forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"lighting/mode/delete" forKey:@"operateUrl"];//操作url
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:model.modelId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"会议室" forKey:@"operateDeviceName"];//操作设备名  模块
//    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

#pragma mark 添加会议模式
- (IBAction)addScene:(id)sender {
    // 模式编辑
    SceneEditTableViewController *sceneEditVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"SceneEditTableViewController"];
    sceneEditVC.addDelegate = self;
    sceneEditVC.model = _model;
    [self.navigationController pushViewController:sceneEditVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)conScene:(SceneOnOffModel *)sceneOnOffModel withOpen:(BOOL)open {
    NSString *urlStr = [NSString stringWithFormat:@"%@/lighting/model/%@?roomId=%@",Main_Url, sceneOnOffModel.modelId, _model.ROOM_ID];
    [self showHudInView:self.view hint:@""];
    [[NetworkClient sharedInstance] POST:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *resDic = responseObject[@"responseData"];
            if(resDic != nil && ![resDic isKindOfClass:[NSNull class]]){
                NSString *result = resDic[@"result"];
                if(result != nil && ![result isKindOfClass:[NSNull class]] && [result isEqualToString:@"success"]){
                    // 成功
                    [_sceneOnOffData enumerateObjectsUsingBlock:^(SceneOnOffModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
                        if(model != sceneOnOffModel){
                            model.onOff = @0;
                        }else {
                            model.onOff = @1;
                        }
                    }];
                    
                    // 记录日志
                    [self logRecordModelId:sceneOnOffModel.modelId];
                    
                    // 改变当前模式图片
                    [self changeSceneTopCurrentModel:sceneOnOffModel.modelId];
                    
                    // 发送模式开启通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeSceneModel" object:nil userInfo:@{@"modelId":sceneOnOffModel.modelId}];
                }
            }
        }else {
            if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
                [self showHint:responseObject[@"message"]];
            }
        }
        
        [_sceneTableView reloadData];
    } failure:^(NSError *error) {
        [self hideHud];
        
        [_sceneTableView reloadData];
    }];
    
}
#pragma mark 记录日志
- (void)logRecordModelId:(NSString *)modelId {
    NSString *operate = @"";
    if([modelId isEqualToString:@"off"]){
        operate = @"会议室设备全关";
    }else if([modelId isEqualToString:@"on"]){
        operate = @"会议室设备全开";
    }else if([modelId isEqualToString:@"meeting"]){
        operate = @"会议室开启会议模式";
    }else if([modelId isEqualToString:@"outing"]){
        operate = @"会议室开启离场模式";
    }else if([modelId isEqualToString:@"shadowing"]){
        operate = @"会议室开启投影模式";
    }
    
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

#pragma mark 根据当前模式设置顶部图片
- (void)changeSceneTopCurrentModel:(NSString *)modelId {
    if([modelId isEqualToString:@"outing"]){
        // 离场模式
        _topSceneImgView.image = [UIImage imageNamed:@"mode_leaving"];
    }else if([modelId isEqualToString:@"meeting"]){
        // 会议模式
        _topSceneImgView.image = [UIImage imageNamed:@"meetroom_mode_meeting"];
    }else if([modelId isEqualToString:@"shadowing"]){
        // 投影模式
        _topSceneImgView.image = [UIImage imageNamed:@"meetroom_mode_display"];
    }else {
        _topSceneImgView.image = [UIImage imageNamed:@"mode_self"];
    }
}

#pragma mark 全部控制通知
- (void)allConScene {
    [_sceneOnOffData enumerateObjectsUsingBlock:^(SceneOnOffModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        model.onOff = @0;
    }];
    [_sceneTableView reloadData];
}

// 新增模式协议
- (void)addModelSuc {
    [self _loadSceneData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AllControlScene" object:nil];
}

@end
