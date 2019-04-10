//
//  ElevatorViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ElevatorViewController.h"
#import "ElevatorTabCell.h"
#import "YQHeaderView.h"

#import "ElevatorModel.h"
#import "SubElevatorModel.h"

//#import "DHDataCenter.h"
#import "PlayVideoViewController.h"

@interface ElevatorViewController ()<UITableViewDelegate,UITableViewDataSource, ElevatorMonitorDelegate, CYLTableViewPlaceHolderDelegate>
{
    NSMutableArray *_elevatorData;
    
    BOOL _isEnd;
}

@property (nonatomic,strong) YQHeaderView *headerView;

@end

@implementation ElevatorViewController

-(YQHeaderView *)headerView
{
    if (_headerView == nil) {
        _headerView = [[YQHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 85)];
        _headerView.backgroundColor = [UIColor colorWithHexString:@"1B82D1"];
        
        _headerView.leftNumLab.text = @"0";
        _headerView.centerNumLab.text = @"0";
        _headerView.rightNumLab.text = @"0";
    }
    return _headerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _elevatorData = @[].mutableCopy;
    
    [self _initView];
    
    [self _initNavItems];
    
    [self _loadData];
}

-(void)_initNavItems
{
    //    self.title = @"电梯";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
}
-(void)_initView {
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.mj_header.hidden = YES;
    self.tableView.mj_footer.hidden = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight-64);
    
//    [self.tableView registerNib:[UINib nibWithNibName:@"ElevatorTabCell" bundle:nil] forCellReuseIdentifier:@"ElevatorTabCell"];
}

-(void)headerRereshing{
    [self _loadData];
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/equipment/getEquipmentList?deviceType=7",Main_Url];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        [self.tableView.mj_header endRefreshing];
        
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *resDic = responseObject[@"responseData"];
            /*
            NSString *openNum = [NSString stringWithFormat:@"%@", resDic[@"okEquipmentCount"]];
            NSString *errorNum = [NSString stringWithFormat:@"%@", resDic[@"errorEquipmentCount"]];
            NSString *downNum = [NSString stringWithFormat:@"%@", resDic[@"outEquipmentCount"]];
            
            _headerView.leftNumLab.text = openNum;
            _headerView.centerNumLab.text = errorNum;
            _headerView.rightNumLab.text = downNum;
             */
            
            [_elevatorData removeAllObjects];
            
            NSArray *equipmentList = resDic[@"equipmentList"];
            [equipmentList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ElevatorModel *model = [[ElevatorModel alloc] initWithDataDic:obj];
                [_elevatorData addObject:model];
                if(model.TAGID != nil && ![model.TAGID isKindOfClass:[NSNull class]]){
                    [self elevatorInfo:model];
                }
            }];
            
            [self.tableView cyl_reloadData];
        }
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
        if(_elevatorData.count <= 0){
            [self showNoDataImage];
        }else {
            [self showHint:KRequestFailMsg];
        }
    }];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 85, KScreenWidth, KScreenHeight - 64 - 85)];
    return noDataView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

// 无网络重载
- (void)reloadTableData {
    [self _loadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _isEnd = YES;
}

#pragma mark 请求单个电梯状态
- (void)elevatorInfo:(ElevatorModel *)model{
    if(_isEnd){
        return;
    }
    
    NSArray *tags = [model.TAGID componentsSeparatedByString:@","];
    NSMutableArray *tagParams = @[].mutableCopy;
    [tags enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [tagParams addObject:[NSNumber numberWithString:obj]];
    }];
    NSMutableString *tagids = @"".mutableCopy;
    [tagParams enumerateObjectsUsingBlock:^(NSNumber *tagId, NSUInteger idx, BOOL * _Nonnull stop) {
        if(tagId != nil && ![tagId isKindOfClass:[NSNull class]]){
            if(idx >= tagParams.count - 1){
                [tagids appendFormat:@"%@", tagId];
            }else {
                [tagids appendFormat:@"%@,", tagId];
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
                NSArray *tagArray = jsonDic[@"tagArray"];
                if(tagArray != nil && ![tagArray isKindOfClass:[NSNull class]]){
                    if(tagArray.count > 0){
                        NSDictionary *tagInfo = tagArray.firstObject;
                        model.floorNum = [NSString stringWithFormat:@"%@", tagInfo[@"value"]];
                    }
                    if(tagArray.count > 1){
                        NSDictionary *tagInfo = tagArray[1];
                        model.runState = [NSString stringWithFormat:@"%@", tagInfo[@"value"]];
                        // 电梯运行中设置 3s 调用一次更新状态，停止设置3s更新
                        [self performSelector:@selector(elevatorInfo:) withObject:model afterDelay:3];
                    }
                    if(tagArray.count > 2){
                        NSDictionary *tagInfo = tagArray[2];
                        model.warnState = [NSString stringWithFormat:@"%@", tagInfo[@"value"]];
                    }
                    
                    [self refreshTopCount];
                    
                    // 刷新cell
                    NSInteger index = [_elevatorData indexOfObject:model];
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];//rowAnimation
                }
            }
        }
            
    } failure:^(NSError *error) {
        [self performSelector:@selector(elevatorInfo:) withObject:model afterDelay:3];
    }];
    
}

#pragma mark 刷新顶部统计数量
- (void)refreshTopCount {
    __block NSInteger normalCount = 0;
    __block NSInteger colseCount = 0;
    __block NSInteger errorCount = 0;
    [_elevatorData enumerateObjectsUsingBlock:^(ElevatorModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        if(model.warnState != nil && ![model.warnState isKindOfClass:[NSNull class]] && [model.warnState isEqualToString:@"8"]){
            // 故障
            errorCount ++;
        }else {
            normalCount ++;
        }
    }];
    
    _headerView.leftNumLab.text = [NSString stringWithFormat:@"%ld", normalCount];
    _headerView.centerNumLab.text = [NSString stringWithFormat:@"%ld", colseCount];
    _headerView.rightNumLab.text = [NSString stringWithFormat:@"%ld", errorCount];
}

#pragma mark UITableView协议
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _elevatorData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    ElevatorTabCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ElevatorTabCell" forIndexPath:indexPath];
    
    ElevatorTabCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"ElevatorTabCell" owner:self options:nil].lastObject;
    }
    
    cell.elevatorModel = _elevatorData[indexPath.row];
    cell.elevatorDelegate = self;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    return 195;
    return 125;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 85;
}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 播放视频协议
- (void)elevatorMonitor:(ElevatorModel *)model {
    NSLog(@"%@", model.TAGID);
    
    if(model.subDeviceList != nil && ![model.subDeviceList isKindOfClass:[NSNull class]]){
        [model.subDeviceList enumerateObjectsUsingBlock:^(SubElevatorModel *subElevatorModel, NSUInteger idx, BOOL * _Nonnull stop) {
            if([subElevatorModel.DEVICE_TYPE isEqualToString:@"1-1"] ||
               [subElevatorModel.DEVICE_TYPE isEqualToString:@"1-2"] ||
               [subElevatorModel.DEVICE_TYPE isEqualToString:@"1-3"]){
                
                if(subElevatorModel.TAGID == nil || [subElevatorModel.TAGID isKindOfClass:[NSNull class]]){
                    [self showHint:@"相机无参数"];
                    return;
                }
                
                #warning 大华SDK旧版本
//                [DHDataCenter sharedInstance].channelID = subElevatorModel.TAGID;

                PlayVideoViewController *playVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"PlayVideoViewController"];
                playVC.deviceType = subElevatorModel.DEVICE_TYPE;
                [self.navigationController pushViewController:playVC animated:YES];
                *stop = YES;
            }
        }];
    }
    
}

- (void)dealloc {
    NSLog(@"=======电梯 dealloc");
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

@end
