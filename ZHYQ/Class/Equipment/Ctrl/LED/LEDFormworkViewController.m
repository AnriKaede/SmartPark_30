//
//  LEDFormworkViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/16.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "LEDFormworkViewController.h"
#import "LedFormworkCell.h"
#import "LEDForworkDetailViewController.h"
#import "LEDFormworkModel.h"

@interface LEDFormworkViewController ()<UITableViewDelegate, UITableViewDataSource, LEDFormworkDelegate>
{
    UITableView *_workTableView;
    NSMutableArray *_workData;
    
    NSInteger _page;
    NSInteger _length;
}
@end

@implementation LEDFormworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _page = 1;
    _length = 8;
    
    _workData = @[].mutableCopy;
    
    [self _initNavItems];
    [self _initView];
    
    [self _loadData];
}
-(void)_initNavItems {
    self.title = @"LED内容模板";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}
-(void)_leftBarBtnItemClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)_initView {
    _workTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight) style:UITableViewStyleGrouped];
    _workTableView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    _workTableView.delegate = self;
    _workTableView.dataSource = self;
    [self.view addSubview:_workTableView];
    
    [_workTableView registerNib:[UINib nibWithNibName:@"LedFormworkCell" bundle:nil] forCellReuseIdentifier:@"LedFormworkCell"];
    
    // ios 11tableView闪动
    _workTableView.estimatedRowHeight = 0;
    _workTableView.estimatedSectionHeaderHeight = 0;
    _workTableView.estimatedSectionFooterHeight = 0;
    
    _workTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self _loadData];
    }];
    // 上拉刷新
    _workTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self _loadData];
    }];
    _workTableView.mj_footer.hidden = YES;
}

#pragma mark 加载数据
- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/udpController/findAllTemplateInfo", Main_Url];
//    NSMutableDictionary *paramDic = @{}.mutableCopy;
//    [paramDic setObject:[NSNumber numberWithInteger:_page] forKey:@"pageNumber"];
//    [paramDic setObject:[NSNumber numberWithInteger:_length] forKey:@"pageSize"];
//
//    NSString *jsonStr = [Utils convertToJsonData:paramDic];
//    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        
        [_workTableView.mj_header endRefreshing];
        [_workTableView.mj_footer endRefreshing];
        
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            
            if(_page == 1){
                [_workData removeAllObjects];
            }
            
            NSArray *data = responseObject[@"responseData"][@"templateList"];
            
            if(data.count > _length-1){
                _workTableView.mj_footer.state = MJRefreshStateIdle;
                _workTableView.mj_footer.hidden = NO;
            }else {
                _workTableView.mj_footer.state = MJRefreshStateNoMoreData;
                _workTableView.mj_footer.hidden = YES;
            }
            
            [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                LEDFormworkModel *model = [[LEDFormworkModel alloc] initWithDataDic:obj];
                [_workData addObject:model];
            }];
            [_workTableView cyl_reloadData];
        }
    } failure:^(NSError *error) {
        [_workTableView.mj_header endRefreshing];
        [_workTableView.mj_footer endRefreshing];
        if(_workData.count <= 0){
            [self showNoDataImage];
        }else {
            [self showHint:KRequestFailMsg];
        }
    }];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight - 60)];
    noDataView.backgroundColor = [UIColor whiteColor];
    return noDataView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

// 无网络重载
- (void)reloadTableData {
    [self _loadData];
}

#pragma mark UITableView协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _workData.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 178;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return 12;
    }else {
        return 5;
    }
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
    LedFormworkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LedFormworkCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.formworkDelegate = self;
    if(_workData.count > indexPath.section){
        cell.formworkModel = _workData[indexPath.section];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LEDForworkDetailViewController *detailVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"LEDForworkDetailViewController"];
    if(_workData.count > indexPath.section){
        LEDFormworkModel *formworkModel = _workData[indexPath.section];
        detailVC.formworkModel = formworkModel;
    }
    detailVC.isEdit = NO;
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark UITableViewCell协议
- (void)edit:(LEDFormworkModel *)formworkModel {
    LEDForworkDetailViewController *detailVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"LEDForworkDetailViewController"];
    detailVC.isEdit = YES;
    detailVC.formworkModel = formworkModel;
    [self.navigationController pushViewController:detailVC animated:YES];
}
- (void)deleteForwork:(LEDFormworkModel *)formworkModel {
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否删除此模板" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *removeAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertCon addAction:cancelAction];
    [alertCon addAction:removeAction];
    [self presentViewController:alertCon animated:YES completion:^{
    }];
}
- (void)user:(LEDFormworkModel *)formworkModel {
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否使用此模板" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *removeAction = [UIAlertAction actionWithTitle:@"使用" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertCon addAction:cancelAction];
    [alertCon addAction:removeAction];
    [self presentViewController:alertCon animated:YES completion:^{
    }];
}

@end
