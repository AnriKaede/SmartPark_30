//
//  HpCarViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/17.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "HpCarViewController.h"
#import "HpCarCell.h"
#import "HpCarModel.h"
#import "ParkRecordCenViewController.h"

@interface HpCarViewController ()<UITableViewDelegate, UITableViewDataSource, CYLTableViewPlaceHolderDelegate>
{
    UITableView *_carTableView;
    NSMutableArray *_carData;
    
    NSInteger _page;
    NSInteger _length;
    
    NoDataView *_noDataView;
    
    NSTimer *_timer;
    int timeIndex;
}
@end

@implementation HpCarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _carData = @[].mutableCopy;
    
    _page = 1;
    if(_isCount){
        _length = 3;
    }else {
        _length = 10;
    }
    
    [self _initView];
    
    [self loadCarData];
}
- (void)_initView {
    self.view.backgroundColor = [UIColor colorWithHexString:@"#EFEFEF"];
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _carTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight - 40) style:UITableViewStylePlain];
    _carTableView.backgroundColor = [UIColor colorWithHexString:@"#EFEFEF"];
    _carTableView.delegate = self;
    _carTableView.dataSource = self;
    _carTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _carTableView.backgroundColor = [UIColor clearColor];
    [_carTableView registerNib:[UINib nibWithNibName:@"HpCarCell" bundle:nil] forCellReuseIdentifier:@"HpCarCell"];
    [self.view addSubview:_carTableView];
    
    if(!_isCount){
        _carTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            _page = 1;
            [self loadCarData];
        }];
    }
    // 上拉刷新
    if(!_isCount){
        _carTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            _page ++;
            [self loadCarData];
        }];
    }
    _carTableView.mj_footer.hidden = YES;
    
    // 无数据视图
    _noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64-49)];
    _noDataView.hidden = YES;
    [self.view addSubview:_noDataView];
}

-(void)_leftBarBtnItemClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 请求数据
- (void)loadCarData {
    NSString *urlStr;
    if(_isCount){
        urlStr = [NSString stringWithFormat:@"%@/fumenController/getAllCarByTimeParking", Main_Url];
    }else {
        urlStr = [NSString stringWithFormat:@"%@/fumenController/getAllCarParking", Main_Url];
    }
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    if(_isCount && _carData.count > 0){
        HpCarModel *model = _carData.firstObject;
        if(model.TRACE_INDEX2 != nil && ![model.TRACE_INDEX2 isKindOfClass:[NSNull class]]){
            [paramDic setObject:model.TRACE_INDEX2 forKey:@"indexId"];
        }
    }
    [paramDic setObject:[NSNumber numberWithInteger:_page] forKey:@"pageNumber"];
    [paramDic setObject:[NSNumber numberWithInteger:_length] forKey:@"pageSize"];
    NSString *paramStr = [Utils convertToJsonData:paramDic];
    NSDictionary *params = @{@"param":paramStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        
        [_carTableView.mj_header endRefreshing];
        [_carTableView.mj_footer endRefreshing];
        
        NSString *code = responseObject[@"code"];
        NSMutableArray *animData = @[].mutableCopy;
        
        if (code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]) {
            NSArray *responseData = responseObject[@"responseData"];
            if(_page == 1 && !_isCount){
                [_carData removeAllObjects];
            }
            if(_isCount && responseData != nil && responseData.count > 0 && _carData.count > 0){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"HpDoorDataUpdate" object:nil];
            }
            
            if(responseData.count > 0){
                NSDictionary *dic = responseData.firstObject;
                NSArray *arr = dic[@"returnList"];
                if(arr.count > _length-1){
                    _carTableView.mj_footer.state = MJRefreshStateIdle;
                    _carTableView.mj_footer.hidden = NO;
                }else {
                    _carTableView.mj_footer.state = MJRefreshStateNoMoreData;
                    _carTableView.mj_footer.hidden = YES;
                }
                [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    HpCarModel *model = [[HpCarModel alloc] initWithDataDic:obj];
                    [animData addObject:model];
                }];
            }
        }
        
        if(_isCount){
            [self animData:animData];
        }else {
            _carData = animData.mutableCopy;
            [_carTableView cyl_reloadData];
        }
        
    } failure:^(NSError *error) {
        [_carTableView.mj_header endRefreshing];
        [_carTableView.mj_footer endRefreshing];
        
        if(_carData.count <= 0){
            [self showNoDataImage];
        }else {
            [self showHint:KRequestFailMsg];
        }
    }];
}
#pragma mark 根据数据设置动画
- (void)animData:(NSArray *)responseData {
    if(responseData.count <= 0){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self loadCarData];
        });
        return;
    }
    
    if (@available(iOS 10.0, *)) {
        //        __block BOOL isLoad = NO;
        timeIndex = 0;
        
        if(_timer){
            [_timer invalidate];
            _timer = nil;
        }
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(refreshTableAnim:) userInfo:@{@"responseData":responseData} repeats:YES];
        
//        [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
//            if(index < responseData.count){
//                HpCarModel *HpCarModel = responseData[responseData.count - index - 1];
//                [_carData insertObject:HpCarModel atIndex:0];
//                [_carTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
//
//                if(_carData.count > 3){
//                    [_carData removeLastObject];
//                    [_carTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//                }
//
//                index ++;
//            }else {
//                [timer invalidate];
//                timer = nil;
//
//                [self loadCarData];
//            }
//
//        }];
    } else {
        _carData = responseData.mutableCopy;
        [_carTableView cyl_reloadData];
    }
}

- (void)refreshTableAnim:(NSTimer *)timer {
    NSArray *responseData = [[timer userInfo] objectForKey:@"responseData"];
    
    if(timeIndex < responseData.count){
        HpCarModel *HpCarModel = responseData[responseData.count - timeIndex - 1];
        [_carData insertObject:HpCarModel atIndex:0];
        [_carTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        
        if(_carData.count > 3){
            [_carData removeLastObject];
            [_carTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        timeIndex ++;
    }else {
        [timer invalidate];
//        timer = nil;
        
        [self loadCarData];
    }
}

// 无网络重载
- (void)reloadTableData {
    [self loadCarData];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDateView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64 - 200)];
    return noDateView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark UITableView 协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _carData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 95;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HpCarCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HpCarCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.hpCarModel = _carData[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HpCarModel *hpCarModel = _carData[indexPath.row];
    
    ParkRecordCenViewController *parkRecordCenVC = [[ParkRecordCenViewController alloc] init];
    parkRecordCenVC.carNo = [NSString stringWithFormat:@"%@", hpCarModel.TRACE_CARNO];
    [self.navigationController pushViewController:parkRecordCenVC animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(_isCount){
        [self loadCarData];
    }
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if(_isCount){
//        [_timer setFireDate:[NSDate distantFuture]];
        [_timer invalidate];
        _timer = nil;
        [_carData removeAllObjects];
        [_carTableView reloadData];
    }
}
- (void)dealloc {
    [_timer invalidate];
    _timer = nil;
}

@end
