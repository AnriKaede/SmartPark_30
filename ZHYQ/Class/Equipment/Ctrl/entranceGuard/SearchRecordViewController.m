//
//  SearchRecordViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/21.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "SearchRecordViewController.h"
#import "OpenRecordCell.h"

#import "NoDataView.h"

#import "WSDatePickerView.h"

#import "RemoteModel.h"

@interface SearchRecordViewController ()<UITableViewDelegate, UITableViewDataSource, CYLTableViewPlaceHolderDelegate>
{
    UITableView *_recordTableView;
    
    NSMutableArray *_recordData;
    
    UIView *_headView;
    UIView *_dateFliterView;
    
    UILabel *startTimeLabel;
    UILabel *endTimeLabel;
    
    NSString *_startTime;   // 查询开始时间
    NSString *_endTime;     // 查询结束时间
    
    NSInteger _page;
    NSInteger _length;
}
//@property (nonatomic,strong) NSMutableArray *dataArr;
@end

@implementation SearchRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _recordData = @[].mutableCopy;
    _page = 1;
    _length = 10;
    
    self.title = @"搜索记录";
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [self _initHeaderView];
    
    [self _initTableView];
    
}
- (void)_initHeaderView {
    // 头部搜索视图
    _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 65)];
    _headView.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    [self.view addSubview:_headView];
    
    CGFloat btWidth = KScreenWidth/4;
    NSArray *titles = @[@"当日", @"近三日", @"历史明细"];
    for (int i=0; i<3; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(btWidth/4*(i+1) + btWidth*i, 18, btWidth, 30);
        button.backgroundColor = [UIColor colorWithHexString:@"#33A4FB"];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(fliterAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 1000 + i;
        [_headView addSubview:button];
    }
    
    _dateFliterView = [[UIView alloc] initWithFrame:CGRectMake(0, 65, KScreenWidth, 45)];
    _dateFliterView.backgroundColor = [UIColor whiteColor];
    _dateFliterView.hidden = YES;
    [_headView addSubview:_dateFliterView];
    
    // 按日期搜索视图
    UIView *dateStartView = [[UIView alloc] initWithFrame:CGRectMake(10*wScale, 8, 135*wScale, 30)];
    dateStartView.backgroundColor = [UIColor colorWithHexString:@"#D3ECFF"];
    dateStartView.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    dateStartView.layer.borderWidth = 0.5;
    [_dateFliterView addSubview:dateStartView];
    UITapGestureRecognizer *startTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dateStartAction)];
    [dateStartView addGestureRecognizer:startTap];
    
    NSDate *nowDate = [NSDate date];
    NSDate *formatMonthhDate = [self formatMonthDate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *nowDateStr = [formatter stringFromDate:nowDate];
    NSString *formatMonthhDateStr = [formatter stringFromDate:formatMonthhDate];
    
    startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, dateStartView.width, dateStartView.height)];
    startTimeLabel.text = formatMonthhDateStr;
    startTimeLabel.textColor = [UIColor blackColor];
    startTimeLabel.font = [UIFont systemFontOfSize:17];
    startTimeLabel.textAlignment = NSTextAlignmentCenter;
    [dateStartView addSubview:startTimeLabel];
    
    UILabel *rangeLabel = [[UILabel alloc] initWithFrame:CGRectMake(dateStartView.right + 8, 16, 17, 17)];
    rangeLabel.text = @"至";
    rangeLabel.textColor = [UIColor blackColor];
    rangeLabel.font = [UIFont systemFontOfSize:17];
    rangeLabel.textAlignment = NSTextAlignmentCenter;
    [_dateFliterView addSubview:rangeLabel];
    
    UIView *dateEndView = [[UIView alloc] initWithFrame:CGRectMake(rangeLabel.right + 8, 8, 135*wScale, 30)];
    dateEndView.backgroundColor = [UIColor colorWithHexString:@"#D3ECFF"];
    dateEndView.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    dateEndView.layer.borderWidth = 0.5;
    [_dateFliterView addSubview:dateEndView];
    UITapGestureRecognizer *endTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dateEndAction)];
    [dateEndView addGestureRecognizer:endTap];
    
    endTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, dateEndView.width, dateEndView.height)];
    endTimeLabel.text = nowDateStr;
    endTimeLabel.textColor = [UIColor blackColor];
    endTimeLabel.font = [UIFont systemFontOfSize:17];
    endTimeLabel.textAlignment = NSTextAlignmentCenter;
    [dateEndView addSubview:endTimeLabel];
    
    UIButton *queryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    queryButton.frame = CGRectMake(dateEndView.right + 16, 8, 40, 30);
    [queryButton setTitle:@"查询" forState:UIControlStateNormal];
    [queryButton setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
    [queryButton addTarget:self action:@selector(queryAction) forControlEvents:UIControlEventTouchUpInside];
    [_dateFliterView addSubview:queryButton];
}
- (void)_initTableView {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, KScreenWidth, 20)];
    label.text = @"请选择查询时间段";
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:17];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    _recordTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 65, KScreenWidth, KScreenHeight-kTopHeight - 65) style:UITableViewStyleGrouped];
    _recordTableView.delegate = self;
    _recordTableView.dataSource = self;
    [self.view addSubview:_recordTableView];
    
    [_recordTableView registerNib:[UINib nibWithNibName:@"OpenRecordCell" bundle:nil] forCellReuseIdentifier:@"OpenRecordCell"];
    
    _recordTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self _loadData];
    }];
    // 上拉刷新
    _recordTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self _loadData];
    }];
//    _recordTableView.mj_footer.automaticallyHidden = NO;
    _recordTableView.mj_footer.hidden = YES;
}
- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 选择开始时间
- (void)dateStartAction {
    WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDay scrollToDate:[self formatMonthDate] CompleteBlock:^(NSDate *selectDate) {
        NSString *date = [selectDate stringWithFormat:@"yyyy-MM-dd"];
        startTimeLabel.text = date;
        
    }];
    datepicker.dateLabelColor = [UIColor colorWithHexString:@"1B82D1"];//年-月-日-时-分 颜色
    datepicker.datePickerColor = [UIColor blackColor];//滚轮日期颜色
    datepicker.doneButtonColor = [UIColor colorWithHexString:@"1B82D1"];//确定按钮的颜色
    datepicker.yearLabelColor = [UIColor clearColor];//大号年份字体颜色
    [datepicker show];
}
- (void)dateEndAction {
    WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDay scrollToDate:[NSDate date] CompleteBlock:^(NSDate *selectDate) {
        NSString *date = [selectDate stringWithFormat:@"yyyy-MM-dd"];
        endTimeLabel.text = date;
        
    }];
    datepicker.dateLabelColor = [UIColor colorWithHexString:@"1B82D1"];//年-月-日-时-分 颜色
    datepicker.datePickerColor = [UIColor blackColor];//滚轮日期颜色
    datepicker.doneButtonColor = [UIColor colorWithHexString:@"1B82D1"];//确定按钮的颜色
    datepicker.yearLabelColor = [UIColor clearColor];//大号年份字体颜色
    [datepicker show];
}

#pragma mark 筛选按钮
- (void)fliterAction:(UIButton *)fliterBt {
    _startTime = nil;
    _endTime = nil;
    
    UIButton *dayBt = [_headView viewWithTag:1000];
    UIButton *threeBt = [_headView viewWithTag:1001];
    UIButton *hisBt = [_headView viewWithTag:1002];
    NSArray *bts = @[dayBt, threeBt, hisBt];
    [bts enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL * _Nonnull stop) {
        if(fliterBt == button){
            button.backgroundColor = [UIColor whiteColor];
            [button setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
        }else {
            button.backgroundColor = [UIColor colorWithHexString:@"#33A4FB"];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }];
    
#pragma mark 筛选查询时间段
    [_recordData removeAllObjects];
    switch (fliterBt.tag) {
        case 1000:
        {
            // 当日
//            NSDateFormatter *nowDate = [[NSDateFormatter alloc] init];
//            [nowDate setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
//            [nowDate setDateFormat:@"yyyy-MM-dd"];
            _startTime = [self getNDay:0 withDate:[NSDate date]];
            _endTime = [self getNDay:-1 withDate:[NSDate date]];
            
            _dateFliterView.hidden = YES;
            _headView.frame = CGRectMake(0, 0, KScreenWidth, 65);
            
            [self _loadData];
        }
            break;
            
        case 1001:
        {
            // 三日
            NSDateFormatter *nowDate = [[NSDateFormatter alloc] init];
            [nowDate setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
            [nowDate setDateFormat:@"yyyy-MM-dd"];
            NSString *nowDateStr = [nowDate stringFromDate:[NSDate date]];
            _startTime = nowDateStr;
            
            _startTime = [self getNDay:3 withDate:[NSDate date]];
            _endTime = [self getNDay:-1 withDate:[NSDate date]];
            
            _dateFliterView.hidden = YES;
            _headView.frame = CGRectMake(0, 0, KScreenWidth, 65);
            
            [self _loadData];
        }
            break;
            
        case 1002:
        {
            // 历史
            _dateFliterView.hidden = NO;
            _headView.frame = CGRectMake(0, 0, KScreenWidth, 110);
        }
            break;
    }
    
    _recordTableView.frame = CGRectMake(0, _headView.bottom, KScreenWidth, KScreenHeight - kTopHeight - _headView.bottom);
    
    [_recordTableView reloadData];
}
// 查询时间段
- (void)queryAction {
    _startTime = startTimeLabel.text;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *endDate = [formatter dateFromString:endTimeLabel.text];
    
    _endTime = [self getNDay:-1 withDate:endDate];
    
    [self _loadData];
}

#pragma mark 查询数据
- (void)_loadData {
    NSString *urlStr;
    if(_openType == RemoteOpen){
        urlStr = [NSString stringWithFormat:@"%@/visitor/getTelecontrolOpenDoorLog",Main_Url];
    }else {
        urlStr = [NSString stringWithFormat:@"%@/visitor/getOpenDoorLog",Main_Url];
    }
    
    // 未选择范围
    if(_startTime == nil || _endTime == nil){
        [_recordTableView.mj_header endRefreshing];
        [_recordTableView.mj_footer endRefreshing];
        return;
    }
    
    NSMutableDictionary *param = @{}.mutableCopy;
    if(_openType == RemoteOpen && _deivedID != nil){
        [param setObject:_deivedID forKey:@"deviceId"];
    }else if(_tagID != nil){
        [param setObject:_tagID forKey:@"tagId"];
    }
    [param setObject:_startTime forKey:@"startDay"];
    [param setObject:_endTime forKey:@"endDay"];
    [param setObject:[NSNumber numberWithInteger:_page] forKey:@"page"];
    [param setObject:[NSNumber numberWithInteger:_length] forKey:@"line"];
    
    if(_openType == RemoteOpen){
        [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
            [self querySuc:responseObject];
        } failure:^(NSError *error) {
            [_recordTableView.mj_header endRefreshing];
            [_recordTableView.mj_footer endRefreshing];
            DLog(@"%@",error);
        }];
    }else {
        [[NetworkClient sharedInstance] GET:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
            [self querySuc:responseObject];
        } failure:^(NSError *error) {
            [_recordTableView.mj_header endRefreshing];
            [_recordTableView.mj_footer endRefreshing];
            DLog(@"%@",error);
        }];
    }
}

- (void)querySuc:(NSDictionary *)responseObject {
    [_recordTableView.mj_header endRefreshing];
    [_recordTableView.mj_footer endRefreshing];
    if ([responseObject[@"code"] isEqualToString:@"1"]) {
        
        if(_page == 1){
            [_recordData removeAllObjects];
        }
        
        NSDictionary *dic = responseObject[@"responseData"];
        NSArray *arr = dic[@"OpenLog"];
        
        if(arr.count > _length-1){
            _recordTableView.mj_footer.state = MJRefreshStateIdle;
            _recordTableView.mj_footer.hidden = NO;
        }else {
            _recordTableView.mj_footer.state = MJRefreshStateNoMoreData;
            _recordTableView.mj_footer.hidden = YES;
        }
        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(_openType == RemoteOpen){
                RemoteModel *remoteModel = [[RemoteModel alloc] initWithDataDic:obj];
                [_recordData addObject:remoteModel];
            }else {
                OpenRecordModel *model = [[OpenRecordModel alloc] initWithDataDic:obj];
                [_recordData addObject:model];
            }
        }];
    }
    [_recordTableView cyl_reloadData];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDateView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64-49)];
    return noDateView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark UItableView 协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _recordData.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 121;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OpenRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OpenRecordCell" forIndexPath:indexPath];
    if(_openType == RemoteOpen){
        cell.remoteModel = _recordData[indexPath.section];
        cell.isRemote = YES;
    }else {
        cell.model = _recordData[indexPath.section];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark 返回前n天 时间  单位天
- (NSString *)getNDay:(NSInteger)n withDate:(NSDate *)date{
    NSDate* theDate;
    
    if(n!=0){
        NSTimeInterval  oneDay = 24*60*60*1;  //1天的长度
        theDate = [date initWithTimeIntervalSinceNow: -oneDay*n ];//initWithTimeIntervalSinceNow是从现在往前后推的秒数
        
    }else{
        theDate = date;
    }
    
    NSDateFormatter *date_formatter = [[NSDateFormatter alloc] init];
    [date_formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [date_formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *the_date_str = [date_formatter stringFromDate:theDate];
    
    return the_date_str;
}

// 前一个月时间
- (NSDate *)formatMonthDate {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = nil;
    comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    [adcomps setYear:0];
    [adcomps setMonth:-1];
    [adcomps setDay:0];
    NSDate *newdate = [calendar dateByAddingComponents:adcomps toDate:[NSDate date] options:0];
    
    return newdate;
}

@end
