//
//  StreetLigGroupViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/12.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "StreetLigGroupViewController.h"
#import "StreetLightModel.h"
#import "LightGroupCell.h"

#import "StreetLightPointViewController.h"
#import "StreLigAllConViewController.h"

@interface StreetLigGroupViewController ()<UITableViewDelegate, UITableViewDataSource, CYLTableViewPlaceHolderDelegate>
{
    UITableView *_groupTableView;
    
    NSMutableArray *_entranceData;
}
@end

@implementation StreetLigGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _entranceData = @[].mutableCopy;
    
    [self _initView];
    
    [self _initEntranceData];
}

- (void)_initView {
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"批量开关" style:UIBarButtonItemStylePlain target:self action:@selector(allConAction)];
    
    _groupTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64) style:UITableViewStylePlain];
    _groupTableView.delegate = self;
    _groupTableView.dataSource = self;
    _groupTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _groupTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_groupTableView];
    
    [_groupTableView registerNib:[UINib nibWithNibName:@"LightGroupCell" bundle:nil] forCellReuseIdentifier:@"LightGroupCell"];
}
- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)allConAction {
    StreLigAllConViewController *allConVC = [[StreLigAllConViewController alloc] init];
    [self.navigationController pushViewController:allConVC animated:YES];
}

// 加载路灯数据
- (void)_initEntranceData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/roadLamp/info/",Main_Url];
    [self showHudInView:self.view hint:@""];
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        [self hideHud];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *dic = responseObject[@"responseData"];
            NSArray *arr = dic[@"items"];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                StreetLightModel *model = [[StreetLightModel alloc] initWithDataDic:obj];
                [_entranceData addObject:model];
            }];
        }
        [_groupTableView cyl_reloadData];
    } failure:^(NSError *error) {
        [self hideHud];
        if(_entranceData.count <= 0){
            [self showNoDataImage];
        }else {
            [self showHint:KRequestFailMsg];
        }
    }];
    
}
// 无网络重载
- (void)reloadTableData {
    [self _initEntranceData];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight)];
    return noDataView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark UITableView 协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _entranceData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LightGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LightGroupCell" forIndexPath:indexPath];
    
    StreetLightModel *model = _entranceData[indexPath.row];
    cell.nameLabel.text = model.DEVICE_NAME;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    StreetLightModel *model = _entranceData[indexPath.row];
    // 跳转点位图
    StreetLightPointViewController *streetVC = [[StreetLightPointViewController alloc] init];
    streetVC.model = model;
    [self.navigationController pushViewController:streetVC animated:YES];
}


@end
