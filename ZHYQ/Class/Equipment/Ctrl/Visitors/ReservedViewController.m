//
//  ReservedViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/18.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ReservedViewController.h"
#import "ReservedCell.h"
#import "NoDataView.h"
#import "ReservedDelViewController.h"

#import "ReservedModel.h"

@interface ReservedViewController ()<UITableViewDelegate,UITableViewDataSource,reserveCallTelePhoneDelegate, CYLTableViewPlaceHolderDelegate>
{
    NSInteger _page;
    NSInteger _length;
    NSMutableArray *_reservedData;
    
    NSString *_startTime;
    NSString *_endTime;
    NSString *_visitorName;
    NSString *_carNo;
}
@end

@implementation ReservedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _reservedData = @[].mutableCopy;
    _page = 1;
    _length = 10;
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    
    [self _initView];
    
    [self _loadData:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterAction:) name:@"ReservedVisitorFilter" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterResSet) name:@"ReservedVisitorResSet" object:nil];

}

-(void)_initView
{
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"ReservedCell" bundle:nil] forCellReuseIdentifier:@"ReservedCell"];
    self.tableView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight-64-50);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.mj_header.hidden = NO;
    self.tableView.mj_footer.hidden = NO;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    
    //    [self.tableView cyl_reloadData];
}
-(void)headerRereshing {
    _page = 1;
    [self _loadData:NO];
}

-(void)footerRereshing {
    _page ++;
    [self _loadData:NO];
}

- (void)_loadData:(BOOL)isTop {
    // 请求访客数据
    NSString *urlStr = [NSString stringWithFormat:@"%@/visitor/getAppointments",Main_Url];
    
    NSMutableDictionary *searchParam = @{}.mutableCopy;
    [searchParam setObject:[NSNumber numberWithInteger:_length] forKey:@"pageSize"];
    [searchParam setObject:[NSNumber numberWithInteger:_page] forKey:@"pageNumber"];
    [searchParam setObject:@"0,3" forKey:@"status"];
    
    if(_startTime != nil && _startTime.length > 0){
        [searchParam setObject:_startTime forKey:@"beginTime"];
    }
    if(_endTime != nil && _endTime.length > 0){
        [searchParam setObject:_endTime forKey:@"endTime"];
    }
    if(_visitorName != nil && _visitorName.length > 0){
        [searchParam setObject:_visitorName forKey:@"visitorName"];
    }
    if(_carNo != nil && _carNo.length > 0){
        [searchParam setObject:_carNo forKey:@"carNo"];
    }
    
    NSString *jsonStr = [self convertToJsonData:searchParam];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSArray *items = responseObject[@"responseData"][@"rows"];
            if(items.count > _length-1){
                self.tableView.mj_footer.state = MJRefreshStateIdle;
                self.tableView.mj_footer.hidden = NO;
            }else {
                self.tableView.mj_footer.state = MJRefreshStateNoMoreData;
                self.tableView.mj_footer.hidden = YES;
            }
            if(_page == 1){
                [_reservedData removeAllObjects];
            }
            [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ReservedModel *model = [[ReservedModel alloc] initWithDataDic:obj];
                [_reservedData addObject:model];
            }];
        }
        
        [self.tableView cyl_reloadData];
        
        if(isTop){
            [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        if(_reservedData.count <= 0){
            [self showNoDataImage];
        }else {
            [self showHint:KRequestFailMsg];
        }
    }];
}

- (void)_loadData {
    [self.tableView cyl_reloadData];
}


#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDateView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 60)];
    return noDateView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark UItableView 协议
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _reservedData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ReservedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReservedCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.reservedModel = _reservedData[indexPath.row];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 250;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ReservedDelViewController *delVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"ReservedDelViewController"];
    delVC.reservedModel = _reservedData[indexPath.row];
    [self.navigationController pushViewController:delVC animated:YES];
}

#pragma mark 点击拨打电话
-(void)reserveCallTelePhone:(NSString *)telephone
{
    //获取目标号码字符串,转换成URL
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",telephone]];
    //调用系统方法拨号
    [kApplication openURL:url];
}

- (NSString *)convertToJsonData:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range];
    return mutStr;
}

#pragma mark 筛选通知
- (void)filterAction:(NSNotification *)notification {
    NSString *startTime = notification.userInfo[@"startTime"];
    NSString *endTime = notification.userInfo[@"endTime"];
    NSString *visitorName = notification.userInfo[@"visitorName"];
    NSString *carNo = notification.userInfo[@"carNo"];
    
    _startTime = [self timeFormatWithStyle:@"yyyy-MM-dd HH:mm:ss" withTimeStr:startTime];
    _endTime = [self timeFormatWithStyle:@"yyyy-MM-dd HH:mm:ss" withTimeStr:endTime];
    if(visitorName != nil){
        _visitorName = visitorName;
    }
    if(carNo != nil){
        _carNo = carNo;
    }
    
    _page = 1;
    [self _loadData:YES];
}

// 重置
- (void)filterResSet {
    if(_startTime != nil && _endTime != nil){
        _startTime = nil;
        _endTime = nil;
        _visitorName = nil;
        _carNo = nil;
        
        _page = 1;
        [self _loadData:YES];
    }
}

// 格式化时间字符
- (NSString *)timeFormatWithStyle:(NSString *)style withTimeStr:(NSString *)timeStr {
    NSDateFormatter *oldFormat = [[NSDateFormatter alloc] init];
    [oldFormat setDateFormat:style];
    NSDate *date = [oldFormat dateFromString:timeStr];
    
    NSDateFormatter *inputFormat = [[NSDateFormatter alloc] init];
    [inputFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [inputFormat stringFromDate:date];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ReservedVisitorFilter" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ReservedVisitorResSet" object:nil];
}

@end
