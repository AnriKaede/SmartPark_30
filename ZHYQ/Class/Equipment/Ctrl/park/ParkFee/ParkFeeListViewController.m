//
//  ParkFeeListViewController.m
//  ZHYQ
//
//  Created by coder on 2018/10/24.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "ParkFeeListViewController.h"
#import "ParkFeeListCell.h"
#import "ParkFeeDetailViewController.h"
#import "ParkFeeFilterView.h"
#import "ParkConsumeModel.h"

@interface ParkFeeListViewController ()<ParkFeeFaliterPopViewDelegate, UITableViewDelegate, UITableViewDataSource>

{
    UITableView *_tableView;
    int _page;
    int _length;
    
    NSMutableArray *_consumeData;
    
    ParkFeeFilterModel *_parkFeeFilterModel;
}
@property (nonatomic,retain) ParkFeeFilterView *filterView;
@end

@implementation ParkFeeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _consumeData = @[].mutableCopy;
    
    [self initNav];
    
    [self initView];
}

-(void)initNav{
    self.title = @"收费明细";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *rightBtn = [[UIButton alloc] init];
    rightBtn.frame = CGRectMake(0, 0, 40, 40);
    [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [rightBtn setImage:[UIImage imageNamed:@"nav_filter_icon"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(_rightBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)_rightBarBtnItemClick
{
    if (_filterView.isShow) {
        return;
    }
    _filterView = [[ParkFeeFilterView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    //显示
    _filterView.delegate = self;
    [_filterView showInView:_tableView];
    _tableView.scrollEnabled = NO;
}

-(void)initView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _tableView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    [self.view addSubview:_tableView];
    
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    
    [_tableView registerNib:[UINib nibWithNibName:@"ParkFeeListCell" bundle:nil] forCellReuseIdentifier:@"ParkFeeListCell"];

    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self _loadData:_parkFeeFilterModel];
    }];
    // 上拉刷新
    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self _loadData:_parkFeeFilterModel];
    }];
    _tableView.mj_footer.hidden = YES;
}

- (void)_loadData:(ParkFeeFilterModel *)filterModel {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/payDetailList", Main_Url];
    
    NSDictionary *params = [self fullParam:filterModel];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        
        [_tableView.mj_header endRefreshing];
        [_tableView.mj_footer endRefreshing];
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            if(_page == 1){
                [_consumeData removeAllObjects];
            }
            
            NSArray *data = responseObject[@"responseData"][@"responseData"][@"items"];
            if(data.count > _length-1){
                _tableView.mj_footer.state = MJRefreshStateIdle;
                _tableView.mj_footer.hidden = NO;
            }else {
                _tableView.mj_footer.state = MJRefreshStateNoMoreData;
                _tableView.mj_footer.hidden = YES;
            }
            
            __block NSMutableArray *monthData = @[].mutableCopy;
            [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ParkConsumeModel *model = [[ParkConsumeModel alloc] initWithDataDic:obj];
                if(model.isMonthFirst && monthData.count > 0){
                    [_consumeData addObject:monthData];
                    monthData = @[].mutableCopy;
                }
                [monthData addObject:model];
                if(idx >= data.count-1 && monthData.count > 0){
                    [_consumeData addObject:monthData];
                }
            }];
        }
        [_tableView cyl_reloadData];
        
    } failure:^(NSError *error) {
        [_tableView.mj_header endRefreshing];
        [_tableView.mj_footer endRefreshing];
        if(_consumeData.count <= 0){
            [self showNoDataImageWithY:60];
        }else {
            [self showHint:KRequestFailMsg];
        }
        
    }];
}

- (NSDictionary *)fullParam:(ParkFeeFilterModel *)filterModel {
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:[NSNumber numberWithInteger:_page] forKey:@"pageNumber"];
    [paramDic setObject:[NSNumber numberWithInteger:_length] forKey:@"pageSize"];
    
    if(filterModel != nil){
        if(filterModel.orderCode != nil){
            [paramDic setObject:filterModel.orderCode forKey:@"orderId"];
        }
        if(filterModel.carNo != nil){
            [paramDic setObject:filterModel.carNo forKey:@"carNo"];
        }
        // 缴费范围
        if(filterModel.lowMoney != nil && filterModel.heightMoney != nil){
            [paramDic setObject:filterModel.lowMoney forKey:@"beginFee"];
            [paramDic setObject:filterModel.heightMoney forKey:@"endFee"];
        }
        if(filterModel.parkPayTypes != nil && filterModel.parkPayTypes.count > 0){
            NSString *payType = [self payType:filterModel.parkPayTypes];
            [paramDic setObject:payType forKey:@"payType"];
        }
        if(filterModel.beginTime != nil){
            [paramDic setObject:filterModel.beginTime forKey:@"startDate"];
        }
        if(filterModel.endTime != nil){
            [paramDic setObject:filterModel.endTime forKey:@"endDate"];
        }
    }
    
    NSString *paramStr = [Utils convertToJsonData:paramDic];
    NSDictionary *params = @{@"params":paramStr};
    
    return params;
}

- (NSString *)payType:(NSArray *)pays {
    __block NSMutableString *payType = @"".mutableCopy;
    [pays enumerateObjectsUsingBlock:^(NSString *typeStr, NSUInteger idx, BOOL * _Nonnull stop) {
        /* 010微信，020 支付宝，060qq钱包，080京东钱包，090口碑，100翼支付，110银联二维码 000现金非必填
        @"全部" : @"0" ,
        @"微信" : @"1",
        @"现金" : @"2",
        @"翼支付" : @"3",
        @"支付宝" : @"4",
         */
        if([typeStr isEqualToString:@"0"]){
            payType = @"".mutableCopy;
            *stop = YES;
        }else if ([typeStr isEqualToString:@"1"]) {
            [payType appendString:@"010,"];
        }else if ([typeStr isEqualToString:@"2"]) {
            [payType appendString:@"000,"];
        }else if ([typeStr isEqualToString:@"3"]) {
            [payType appendString:@"100,"];
        }else if ([typeStr isEqualToString:@"4"]) {
            [payType appendString:@"020,"];
        }
    }];
    if(payType.length > 0){
        [payType deleteCharactersInRange:NSMakeRange(payType.length - 1, 1)];
    }
    return payType;
}

// 无网络重载
- (void)reloadTableData {
    [self _loadData:nil];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 60, KScreenWidth, KScreenHeight - 63)];
    return noDataView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _consumeData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *items = _consumeData[section];
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ParkFeeListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ParkFeeListCell" forIndexPath:indexPath];
    ParkConsumeModel *model = _consumeData[indexPath.section][indexPath.row];
    cell.parkConsumeModel = model;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 75;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithHexString:@"#EFEFEF"];
    
    UILabel *timeLab = [[UILabel alloc] initWithFrame:CGRectMake(9, 16, 120, 18)];
    timeLab.text = @"2017年12月";
    timeLab.textColor = [UIColor colorWithHexString:@"#333333"];
    timeLab.textAlignment = NSTextAlignmentLeft;
    timeLab.font = [UIFont systemFontOfSize:17];
    [view addSubview:timeLab];
    
    UILabel *incomeLab = [[UILabel alloc] initWithFrame:CGRectMake(9, timeLab.bottom + 11, 120, 18)];
    incomeLab.text = @"收入1234.0元";
    incomeLab.textColor = [UIColor colorWithHexString:@"#333333"];
    incomeLab.textAlignment = NSTextAlignmentLeft;
    incomeLab.font = [UIFont systemFontOfSize:16];
    [view addSubview:incomeLab];
    
    return view;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ParkFeeDetailViewController *parkFeeDetailVc = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"ParkFeeDetailViewController"];
    [self.navigationController pushViewController:parkFeeDetailVc animated:YES];
}

#pragma mark 筛选协议
-(void)resetCallBackAction {
    _parkFeeFilterModel = nil;
    _tableView.scrollEnabled = YES;
    [self _loadData:nil];
}
-(void)completeCallBackAction:(ParkFeeFilterModel *)parkFeeFilterModel {
    _tableView.scrollEnabled = YES;
    _parkFeeFilterModel = parkFeeFilterModel;
    [self _loadData:parkFeeFilterModel];
}
-(void)hideShowAction {
    _tableView.scrollEnabled = YES;
}

@end
