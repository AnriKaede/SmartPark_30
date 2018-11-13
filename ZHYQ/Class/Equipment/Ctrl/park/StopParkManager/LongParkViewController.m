//
//  LongParkViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/9/28.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "LongParkViewController.h"
#import "YQSwitch.h"
#import "LongParkCell.h"
#import "StopParkSelDayView.h"
#import "StopParkListModel.h"

@interface LongParkViewController ()<UITableViewDelegate, UITableViewDataSource, switchTapDelegate, SelDayDelegate, CYLTableViewPlaceHolderDelegate>
{
    UITableView *_longTableView;
    NSMutableArray *_longData;
    StopParkSelDayView *_selDayView;
    
    UIView *_headerView;
    
    BOOL _isVip;
    NSString *_dayNum;
}
@end

@implementation LongParkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isVip = NO;
    _dayNum = @"4";
    _longData = @[].mutableCopy;
    
    [self _initView];
    
    [self _loadData];
}
- (void)_initView {
    _headerView = [self headerView];
    
    _longTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight - kTabBarHeight) style:UITableViewStyleGrouped];
    _longTableView.delegate = self;
    _longTableView.dataSource = self;
    _longTableView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    _longTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_longTableView];
    
    _longTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self _loadData];
    }];
    
    [_longTableView registerNib:[UINib nibWithNibName:@"LongParkCell" bundle:nil] forCellReuseIdentifier:@"LongParkCell"];
    
    _selDayView = [[StopParkSelDayView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight)];
    _selDayView.selDayDelegate = self;
    [self.view addSubview:_selDayView];
    
}

- (void)_loadData {
    NSString *isVip = @"0";
    if(_isVip){
        isVip = @"1";
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/getParkStopCar?stopDay=%@&isVip=%@", Main_Url, _dayNum, isVip];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        [_longTableView.mj_header endRefreshing];
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            [_longData removeAllObjects];
            NSArray *responseData = responseObject[@"responseData"];
            [responseData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                StopParkListModel *model = [[StopParkListModel alloc] initWithDataDic:obj];
                model.isVip = _isVip;
                [_longData addObject:model];
            }];
            [_longTableView cyl_reloadData];
        }
    } failure:^(NSError *error) {
        [_longTableView.mj_header endRefreshing];
        if(_longData.count <= 0){
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
    return _longData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 140;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 75;
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
    LongParkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LongParkCell" forIndexPath:indexPath];
    cell.stopParkListModel = _longData[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark Switch开关协议
-(void)switchTap:(BOOL)on {
    YQSwitch *yqSwtch = [_headerView viewWithTag:2000];
    _isVip = yqSwtch.on;
    
    [_longTableView.mj_header beginRefreshing];
}

- (UIView *)headerView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 75)];
    headerView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    
    UILabel *outLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 13, 48, 20)];
    outLabel.text = @"久停超";
    outLabel.textColor = [UIColor blackColor];
    outLabel.font = [UIFont systemFontOfSize:15];
    outLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:outLabel];
    
    UIButton *dayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dayButton.tag = 3000;
    dayButton.frame = CGRectMake(outLabel.right + 6, 7, 60, 30);
    dayButton.titleLabel.font = [UIFont systemFontOfSize:15];
    dayButton.backgroundColor = [UIColor whiteColor];
    [dayButton setTitle:@"4天" forState:UIControlStateNormal];
    [dayButton setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
    [dayButton setImage:[UIImage imageNamed:@"apt_filter_right"] forState:UIControlStateNormal];
    dayButton.layer.cornerRadius = 5;
    dayButton.layer.borderColor = [UIColor colorWithHexString:@"#D2D2D2"].CGColor;
    dayButton.layer.borderWidth = 1;
    [dayButton addTarget:self action:@selector(selParkDay) forControlEvents:UIControlEventTouchUpInside];
    // button标题的偏移量
    dayButton.titleEdgeInsets = UIEdgeInsetsMake(0, -14, 0, 12);
    // button图片的偏移量
    dayButton.imageEdgeInsets = UIEdgeInsetsMake(0, 29, 0, -25);
    [headerView addSubview:dayButton];
    
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
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, dayButton.bottom + 8, KScreenWidth, 1)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#E2E2E2"];
    [headerView addSubview:lineView];
    
    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake((KScreenWidth - 160)/2, lineView.bottom + 5, 160, 20)];
    countLabel.text = @"共 20 条明细";
    countLabel.textColor = [UIColor colorWithHexString:@"#B2B2B2"];
    countLabel.font = [UIFont systemFontOfSize:13];
    countLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:countLabel];
    
    return headerView;
}

- (void)selParkDay {
    [_selDayView showView:_dayNum.integerValue - 1];
}

- (void)selDay:(NSString *)day {
    NSLog(@"%@", day);
    UIButton *dayButton = [_headerView viewWithTag:3000];
    [dayButton setTitle:[NSString stringWithFormat:@"%@天", day] forState:UIControlStateNormal];
    
    _dayNum = day;
    
    if(day.intValue > 9){
        dayButton.titleEdgeInsets = UIEdgeInsetsMake(0, -14, 0, 12);
        dayButton.imageEdgeInsets = UIEdgeInsetsMake(0, 37, 0, -25);
    }else {
        dayButton.titleEdgeInsets = UIEdgeInsetsMake(0, -14, 0, 12);
        dayButton.imageEdgeInsets = UIEdgeInsetsMake(0, 29, 0, -25);
    }
    
    [_longTableView.mj_header beginRefreshing];
}

@end
