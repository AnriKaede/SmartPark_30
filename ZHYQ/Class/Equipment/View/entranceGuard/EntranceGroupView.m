//
//  EntranceGroupView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/11.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "EntranceGroupView.h"
#import "EntranceCell.h"
#import "FloorModel.h"
#import "DoorModel.h"
#import "NoDataView.h"

@interface EntranceGroupView ()<UITableViewDelegate, UITableViewDataSource, EntranceDelegate>
{
    UITableView *_groupTableView;
    
    NSMutableArray *_floorData;
    NSMutableArray *_entranceData;
    
    NSInteger _selGroupNum;
    DoorModel *_selDoorModel;
    
    NoDataView *_noDataView;
}
@end

@implementation EntranceGroupView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        [self _initView];
        
        _selGroupNum = -1;
        _floorData = @[].mutableCopy;
        _entranceData = @[].mutableCopy;
        
        [self _initFloorData];
    }
    return self;
}

- (void)_initView {
    _groupTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, self.height) style:UITableViewStylePlain];
    _groupTableView.delegate = self;
    _groupTableView.dataSource = self;
    _groupTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _groupTableView.tableFooterView = [UIView new];
    [self addSubview:_groupTableView];
    
    [_groupTableView registerNib:[UINib nibWithNibName:@"EntranceCell" bundle:nil] forCellReuseIdentifier:@"EntranceCell"];
}

// 加载楼层数据
- (void)_initFloorData {
//    NSString *urlStr = [NSString stringWithFormat:@"%@/public/getChildBulidingList?bulidId=1",Main_Url];
    NSString *urlStr = [NSString stringWithFormat:@"%@/public/getChildBulidingList?bulidId=-11",Main_Url];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        
        [_floorData removeAllObjects];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            
            NSArray *dataArr = responseObject[@"responseData"];
            
            [dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FloorModel *model = [[FloorModel alloc] initWithDataDic:obj];
                [_floorData addObject:model];
            }];
            
            [_groupTableView reloadData];
        }
        if(_floorData.count <= 0){
            [self showNoDataView];
        }
    } failure:^(NSError *error) {
        if(_floorData.count <= 0){
            [self showNoDataImage];
        }else {
        }
    }];
}

// 无网络占位图
-(void)showNoDataImage
{
    [self removeNoDataImage];
    
    // 无数据视图
    _noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64-49)];
    _noDataView.imgView.image = [UIImage imageNamed:@"customvoice_networkerror"];
    _noDataView.label.text = @"对不起,网络连接失败";
    _noDataView.label.textColor = [UIColor colorWithHexString:@"#1B82D1"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = 3001;
    button.frame = CGRectMake((KScreenWidth - 200)/2, _noDataView.height/2 + 110, 200, 40);
    button.backgroundColor = [UIColor clearColor];
    button.titleLabel.font = [UIFont systemFontOfSize:17];
    [button setTitle:@"加载失败，点击重试~" forState:UIControlStateNormal];
    button.layer.borderColor = [UIColor colorWithHexString:@"#e2e2e2"].CGColor;
    button.layer.borderWidth = 0.5;
    button.layer.cornerRadius = 4;
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(reloadTableData) forControlEvents:UIControlEventTouchUpInside];
    [_noDataView addSubview:button];
    
    [_noDataView setFrame:CGRectMake(0, 0,self.frame.size.width, self.size.height)];
    [self addSubview:_noDataView];
}

// 无数据占位图
- (void)showNoDataView {
    [self removeNoDataImage];
    
    // 无数据视图
    _noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64-49)];
    _noDataView.imgView.image = [UIImage imageNamed:@"new_no_date"];
    _noDataView.label.text = @"暂时没有数据~";
    _noDataView.label.textColor = [UIColor colorWithHexString:@"#1B82D1"];
    
    UIButton *button = [_noDataView viewWithTag:3001];
    if(button != nil){
        button.hidden = YES;
    }
    
    [_noDataView setFrame:CGRectMake(0, 0,self.frame.size.width, self.size.height)];
    [self addSubview:_noDataView];
}

-(void)removeNoDataImage{
    if (_noDataView) {
        [_noDataView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_noDataView removeFromSuperview];
        _noDataView = nil;
        _noDataView.hidden = YES;
    }
}
// 无网络重载
- (void)reloadTableData {
    [self _initFloorData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkReconvert" object:nil];
}

// 加载楼层门禁数据
- (void)_loadEntranceData:(NSString *)layerId {
    [[self viewController] showHudInView:[self viewController].view hint:@""];
    NSString *urlStr = [NSString stringWithFormat:@"%@/visitor/getInDoorGuardList?layerId=%@",Main_Url,layerId];
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [[self viewController] hideHud];
        [_entranceData removeAllObjects];
        
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *respData = responseObject[@"responseData"];
            NSArray *arr = respData[@"DoorList"];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DoorModel *model = [[DoorModel alloc] initWithDataDic:obj];
                [_entranceData addObject:model];
            }];
        }
        
        [_groupTableView reloadData];
    } failure:^(NSError *error) {
        [[self viewController] hideHud];
    }];
}

#pragma mark UITableView 协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _floorData.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == _selGroupNum){
        return _entranceData.count;
    }else {
        return 0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DoorModel *model = _entranceData[indexPath.row];
    if(model.isSpread){
        return 226;
    }
    return 60;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    FloorModel *model = _floorData[section];
    
    CGFloat height;
    UIColor *bgColor;
    BOOL isHidFlag;
    if(_selGroupNum == section){
        height = 60;
        bgColor = [UIColor colorWithHexString:@"#e2e2e2"];
        isHidFlag = NO;
    }else {
        height = 60;
        bgColor = [UIColor whiteColor];
        isHidFlag = YES;
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, height)];
    headerView.tag = 1000 + section;
    UITapGestureRecognizer *seccionTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(seccionAction:)];
    [headerView addGestureRecognizer:seccionTap];
    headerView.backgroundColor = bgColor;
    
    CGFloat flagHeight = 5;
    if(_selGroupNum == section){
        flagHeight = 20;
    }
    UIView *flagView = [[UIView alloc] initWithFrame:CGRectMake(8, (60 - flagHeight)/2, 5, flagHeight)];
//    flagView.hidden = isHidFlag;
    flagView.layer.cornerRadius = 2;
    flagView.backgroundColor = [UIColor colorWithHexString:@"#3a7af6"];
    [headerView addSubview:flagView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(flagView.right + 4, 0, KScreenWidth - 20, height)];
    label.text = model.LAYER_NAME;
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:17];
    label.textAlignment = NSTextAlignmentLeft;
    [headerView addSubview:label];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, height - 0.5, KScreenWidth, 0.5)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    [headerView addSubview:lineView];
    
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EntranceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EntranceCell" forIndexPath:indexPath];
    cell.model = _entranceData[indexPath.row];
    cell.entranceDelegate = self;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DoorModel *model = _entranceData[indexPath.row];
    
    if(_selDoorModel != nil){
        NSInteger index = [_entranceData indexOfObject:_selDoorModel];
        if(_selDoorModel == model){
            _selDoorModel.isSpread = !_selDoorModel.isSpread;
        }else {
            _selDoorModel.isSpread = NO;
            model.isSpread = YES;
        }
        
        [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:indexPath.section], indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }else {
        model.isSpread = YES;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    _selDoorModel = model;
}

- (void)seccionAction:(UITapGestureRecognizer *)tap {
    NSInteger section = tap.view.tag - 1000;
    
    if(_selGroupNum == section){
        _selGroupNum = -1;
        
        [_groupTableView reloadData];
    }else {
        _selGroupNum = section;
        FloorModel *model = _floorData[section];
        [self _loadEntranceData:[NSString stringWithFormat:@"%@", model.LAYER_ID]];
    }
    
}

#pragma mark Cell 协议
- (void)unLockDoor:(DoorModel *)doorModel {
    if(_groupConDelegate){
        [_groupConDelegate unLockDoor:doorModel];
    }
}
- (void)viewAuthorityList:(DoorModel *)doorModel {
    if(_groupConDelegate){
        [_groupConDelegate viewAuthorityList:doorModel];
    }
}
- (void)openRecord:(DoorModel *)doorModel {
    if(_groupConDelegate){
        [_groupConDelegate openRecord:doorModel];
    }
}

@end
