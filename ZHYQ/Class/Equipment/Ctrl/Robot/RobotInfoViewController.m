//
//  RobotInfoViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/2/27.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "RobotInfoViewController.h"
#import "RobotInfoCell.h"

@interface RobotInfoViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_infoTableView;
}
@end

@implementation RobotInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_infoTableView cyl_reloadData];
}

- (void)_initView {
    _infoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) style:UITableViewStyleGrouped];
    _infoTableView.delegate = self;
    _infoTableView.dataSource = self;
    _infoTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _infoTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _infoTableView.tableFooterView = [UITableView new];
    [self.view addSubview:_infoTableView];
    
    [_infoTableView registerNib:[UINib nibWithNibName:@"RobotInfoCell" bundle:nil] forCellReuseIdentifier:@"RobotInfoCell"];
    
    self.title = @"系统信息";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

// 无网络重载
- (void)reloadTableData {
//    [self _loadData];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 60, KScreenWidth, KScreenHeight - 63)];
    return noDataView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark UItableView协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_infoModel != nil){
        return 8;
    }else {
        return 0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RobotInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RobotInfoCell" forIndexPath:indexPath];
    
    cell.nameLabel.text = [self cellName:indexPath];
    cell.valueLabel.text = [self valueName:indexPath];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)cellName:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            return @"机器人型号";
            break;
        case 1:
            return @"Android版本";
            break;
        case 2:
            return @"内核版本";
            break;
        case 3:
            return @"版本号";
            break;
        case 4:
            return @"转接板版本";
            break;
        case 5:
            return @"胸腔版本";
            break;
        case 6:
            return @"头部版本";
            break;
        case 7:
            return @"ROS版本";
            break;
            
        default:
            return @"";
            break;
    }
}

- (NSString *)valueName:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            return _infoModel.model;
            break;
        case 1:
            return _infoModel.version;
            break;
        case 2:
            return _infoModel.kernelVersion;
            break;
        case 3:
            return _infoModel.numberVersion;
            break;
        case 4:
            return _infoModel.pinboardVersion;
            break;
        case 5:
            return _infoModel.pleuralVersion;
            break;
        case 6:
            return _infoModel.headVersion;
            break;
        case 7:
            return _infoModel.rosVersion;
            break;
            
        default:
            return @"";
            break;
    }
}
@end
