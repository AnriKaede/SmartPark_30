//
//  WarnUnReportViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/25.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WarnUnReportViewController.h"
#import "WarnCell.h"
#import "AppointBillViewController.h"
#import "NoDataView.h"

#import "BillListModel.h"

@interface WarnUnReportViewController ()<CYLTableViewPlaceHolderDelegate>
{
    NSMutableArray *_warnData;
    NSInteger _page;
    NSInteger _length;
}
@end

@implementation WarnUnReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _page = 1;
    _length = 10;
    _warnData = @[].mutableCopy;
    
    [self _initView];
    
    [self _loadData];
    
    // 监听故障新增通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:@"WranPostSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:@"ReReportSuccess" object:nil];
}

- (void)_initView {
    self.warnTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64) style:UITableViewStyleGrouped];
    self.warnTableView.backgroundColor = [UIColor whiteColor];
    self.warnTableView.dataSource = self;
    self.warnTableView.delegate = self;
    [self.view addSubview:self.warnTableView];
    [self.warnTableView registerNib:[UINib nibWithNibName:@"WarnCell" bundle:nil] forCellReuseIdentifier:@"WarnCell"];
    
    self.warnTableView.showsVerticalScrollIndicator = NO;
    self.warnTableView.showsHorizontalScrollIndicator = NO;
    
    // ios 11tableView闪动
    self.warnTableView.estimatedRowHeight = 0;
    self.warnTableView.estimatedSectionHeaderHeight = 0;
    self.warnTableView.estimatedSectionFooterHeight = 0;
    
    self.warnTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self _loadData];
    }];
}

- (void)refreshData {
    if(_page == 1){
        [_warnData removeAllObjects];
    }
    [self _loadData];
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/deviceAlarm/alarmInfo", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    NSString *companyId = [[NSUserDefaults standardUserDefaults] objectForKey:KAdminCompanyId];
    if(companyId != nil){
        [paramDic setObject:companyId forKey:@"companyId"];
    }
    [paramDic setObject:@"3" forKey:@"alarmState"];
    [paramDic setObject:[NSNumber numberWithInteger:_page] forKey:@"pageNumber"];
    [paramDic setObject:[NSNumber numberWithInteger:_length] forKey:@"pageSize"];
    
    NSString *paramStr = [Utils convertToJsonData:paramDic];
    NSDictionary *params = @{@"param":paramStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        
        [self.warnTableView.mj_footer endRefreshing];
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            NSArray *data = responseObject[@"responseData"][@"items"];
            
            if(data.count > _length-1){
                self.warnTableView.mj_footer.state = MJRefreshStateIdle;
                self.warnTableView.mj_footer.hidden = NO;
            }else {
                self.warnTableView.mj_footer.state = MJRefreshStateNoMoreData;
                self.warnTableView.mj_footer.hidden = YES;
            }
            
            [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                WranUndealModel *model = [[WranUndealModel alloc] initWithDataDic:obj];
                [_warnData addObject:model];
            }];
            
            [self.warnTableView cyl_reloadData];
        }
        
    } failure:^(NSError *error) {
        [self.warnTableView.mj_footer endRefreshing];
        
        if(_warnData.count <= 0){
            [self showNoDataImageWithY:self.headerHeight/2];
        }else {
            [self showHint:KRequestFailMsg];
        }
    }];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight*4/3)];
    noDataView.backgroundColor = [UIColor whiteColor];
    return noDataView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

// 无网络重载
- (void)reloadTableData {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WranPostSuccess" object:nil];
}

#pragma mark UITableView协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _warnData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WarnCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WarnCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.wranBillStyle = WranUnSend;
    if(_warnData.count > indexPath.row){
        cell.wranModel = _warnData[indexPath.row];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WranUndealModel *wranModel = _warnData[indexPath.row];
    
    AppointBillViewController *appointVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"AppointBillViewController"];
    appointVC.appointState = AppointUnDeal;
    appointVC.wranUndealModel = wranModel;
    [self.navigationController pushViewController:appointVC animated:YES];
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat footerHeight = KScreenHeight - _warnData.count*60 - 64 - 80;
    return footerHeight > 0 ? footerHeight : 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"WranPostSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ReReportSuccess" object:nil];
}

@end
