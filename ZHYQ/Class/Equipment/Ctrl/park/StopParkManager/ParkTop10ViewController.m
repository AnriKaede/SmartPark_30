//
//  ParkTop10ViewController.m
//  
//
//  Created by 魏唯隆 on 2018/9/28.
//

#import "ParkTop10ViewController.h"
#import "YQSwitch.h"
#import "ParkTop10Cell.h"
#import "StopParkListModel.h"

@interface ParkTop10ViewController ()<UITableViewDelegate, UITableViewDataSource, switchTapDelegate, CYLTableViewPlaceHolderDelegate>
{
    UITableView *_topTableView;
    NSMutableArray *_topData;
    
    UIView *_headerView;
    
    BOOL _isVip;
}
@end

@implementation ParkTop10ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isVip = NO;
    _topData = @[].mutableCopy;
    
    [self _initView];
    
    [self _loadData];
}

- (void)_initView {
    _headerView = [self headerView];
    
    _topTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight - kTabBarHeight) style:UITableViewStyleGrouped];
    _topTableView.delegate = self;
    _topTableView.dataSource = self;
    _topTableView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    _topTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_topTableView];
    
    [_topTableView registerNib:[UINib nibWithNibName:@"ParkTop10Cell" bundle:nil] forCellReuseIdentifier:@"ParkTop10Cell"];
    
    _topTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self _loadData];
    }];
}

- (void)_loadData {
    NSString *isVip = @"0";
    if(_isVip){
        isVip = @"1";
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/getParkTop?isVip=%@&topNumber=10", Main_Url, isVip];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        [_topTableView.mj_header endRefreshing];
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            [_topData removeAllObjects];
            NSArray *responseData = responseObject[@"responseData"];
            [responseData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                StopParkListModel *model = [[StopParkListModel alloc] initWithDataDic:obj];
                model.isVip = _isVip;
                model.topNum = idx;
                [_topData addObject:model];
            }];
            [_topTableView cyl_reloadData];
        }
    } failure:^(NSError *error) {
        [_topTableView.mj_header endRefreshing];
        if(_topData.count <= 0){
            [self showNoDataImage];
        }else {
            [self showHint:KRequestFailMsg];
        }
    }];
}

// 无网络重载
- (void)reloadTableData {
    [self _loadData];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDateView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64-49)];
    return noDateView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark UITableView协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _topData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 135;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return _headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ParkTop10Cell *cell = [tableView dequeueReusableCellWithIdentifier:@"ParkTop10Cell" forIndexPath:indexPath];
    cell.stopParkListModel = _topData[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
- (UIView *)headerView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 46)];
    headerView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    
    YQSwitch *yqSwtch = [[YQSwitch alloc] initWithFrame:CGRectMake(KScreenWidth - 63, 8, 55, 20)];
    yqSwtch.tag = 2000;
    yqSwtch.onText = @"";
    yqSwtch.offText = @"";
    yqSwtch.on = _isVip;
    yqSwtch.backgroundColor = [UIColor clearColor];
    yqSwtch.onTintColor = [UIColor colorWithHexString:@"6BDB6A"];
    yqSwtch.tintColor = [UIColor colorWithHexString:@"FF4359"];
    //    yqSwtch.tintColor = [UIColor colorWithHexString:@"ffffff"];
    yqSwtch.switchDelegate = self;
    [headerView addSubview:yqSwtch];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(yqSwtch.left - 128, 13, 120, 20)];
    label.text = @"包含VIP车辆";
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentRight;
    [headerView addSubview:label];
    
    return headerView;
}

#pragma mark Switch开关协议
-(void)switchTap:(BOOL)on {
    YQSwitch *yqSwtch = [_headerView viewWithTag:2000];
    _isVip = yqSwtch.on;
    
    [_topTableView.mj_header beginRefreshing];
}

@end
