//
//  InTimeVisitorViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/17.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "InTimeVisitorViewController.h"
#import "VisotorListViewController.h"
#import "AAChartView.h"
#import "SnapCountCell.h"
#import "VIsListCell.h"

#import "CommpanyVisViewController.h"

#import "VisCountModel.h"

@interface InTimeVisitorViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_inTimeTableView;
    NSMutableArray *_inTimeData;
    
    NSMutableArray *_todayCountData;
    NSString *_totalNum;
    NSString *_levNum;
    NSString *_stayNum;
    
    VisCountModel *_visCountModel;
}
@property (nonatomic, strong) AAChartModel *cakeChartModel;
@property (nonatomic, strong) AAChartView  *cakeChartView;

@end

@implementation InTimeVisitorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _inTimeData = @[].mutableCopy;
    _todayCountData = @[].mutableCopy;
    
    [self _initView];
    
    // GCD控制两个网络都完成时再刷新tableView
    dispatch_group_t groupRequest = dispatch_group_create();
    
    [self _loadData:groupRequest];
    [self _loadTimeCountData:groupRequest];
    
    dispatch_group_notify(groupRequest, dispatch_get_main_queue(), ^{
        [_inTimeTableView reloadData];
        [self refreshCake];
    });
}

-(void)_initView
{
    // 创建饼状图
    [self _createCakeView];
    
    // 初始化tableView
    _inTimeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64 - kTabBarHeight) style:UITableViewStyleGrouped];
    _inTimeTableView.contentInset = UIEdgeInsetsMake(0, 0, 5, 0);
    _inTimeTableView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    _inTimeTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _inTimeTableView.dataSource = self;
    _inTimeTableView.delegate = self;
    [_inTimeTableView registerNib:[UINib nibWithNibName:@"SnapCountCell" bundle:nil] forCellReuseIdentifier:@"SnapCountCell"];
    [_inTimeTableView registerNib:[UINib nibWithNibName:@"VIsListCell" bundle:nil] forCellReuseIdentifier:@"VIsListCell"];
    [self.view addSubview:_inTimeTableView];
}

- (void)_loadData:(id)group {
    dispatch_group_enter(group);
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/visitor/status/0",Main_Url];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        dispatch_group_leave(group);
        
        NSDictionary *dataDic = responseObject;
        if ([dataDic[@"code"] isEqualToString:@"1"]) {
            
            NSDictionary *dic = dataDic[@"responseData"];
            _visCountModel = [[VisCountModel alloc] initWithDataDic:dic];
            _inTimeData = _visCountModel.items.mutableCopy;
            
        };
    } failure:^(NSError *error) {
        dispatch_group_leave(group);
        
//        DLog(@"%@",error);
        [self showHint:KRequestFailMsg];
    }];
}

- (void)_loadTimeCountData:(id)group {
    dispatch_group_enter(group);
    
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *statDate = [dateFormat stringFromDate:nowDate];
    
    // 当天按小时统计
    NSString *urlStr = [NSString stringWithFormat:@"%@/visitor/hourFlowStat",Main_Url];
    
    NSMutableDictionary *searchParam = @{}.mutableCopy;
    [searchParam setObject:statDate forKey:@"statDate"];
    
    NSString *jsonStr = [Utils convertToJsonData:searchParam];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        dispatch_group_leave(group);
        
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSArray *hourStat = responseObject[@"responseData"][@"hourStat"];
            if(hourStat != nil && ![hourStat isKindOfClass:[NSNull class]]){
                _todayCountData = hourStat.mutableCopy;
            }
        }
        
    } failure:^(NSError *error) {
        dispatch_group_leave(group);
    }];
    
    // 加载当日统计数据
    NSString *countStr = [NSString stringWithFormat:@"%@/visitor/dayStat",Main_Url];
    
    NSMutableDictionary *countParam = @{}.mutableCopy;
    [countParam setObject:statDate forKey:@"statDate"];
    
    NSString *countJsonStr = [Utils convertToJsonData:countParam];
    NSDictionary *cParam = @{@"param":countJsonStr};
    [[NetworkClient sharedInstance] POST:countStr dict:cParam progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            // 总数
            _totalNum = [NSString stringWithFormat:@"%@", responseObject[@"responseData"][@"total"]];
            
            // 未离开
            _stayNum = [NSString stringWithFormat:@"%@", responseObject[@"responseData"][@"stay"]];
            
            // 已离开
            _levNum = [NSString stringWithFormat:@"%@", responseObject[@"responseData"][@"leave"]];
        }
        
        [_inTimeTableView reloadData];
        
    } failure:^(NSError *error) {
    }];
}

#pragma mark 饼状图
- (void)_createCakeView {
    self.cakeChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, 220)];
    self.cakeChartView.contentHeight = 200;
    self.cakeChartView.isClearBackgroundColor = YES;
    self.cakeChartView.backgroundColor = [UIColor whiteColor];
    
    /*
    self.cakeChartModel = AAObject(AAChartModel)
    .chartTypeSet(AAChartTypePie)
    .colorsThemeSet(@[@"#edc443",@"#ea9731",@"#ed3732",@"#4db6f9",@"#63d540"])
    .titleSet(@"")
    .subtitleSet(@"")
    .dataLabelEnabledSet(true)//是否直接显示扇形图数据
    .yAxisTitleSet(@"")
    .seriesSet(
               @[
                 AAObject(AASeriesElement)
                 .nameSet(@"访问人员")
                 .innerSizeSet(@"0%")//内部圆环半径大小占比
                 .dataSet(@[
                            @[@"园区广场" , @10],
                            @[@"园区广场" , @18],
                            @[@"园区广场" , @12],
                            @[@"办公楼宇" , @30],
                            @[@"园区广场" , @30],
                            ]),
                 ]
               )
    ;
    
    _cakeChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.cakeChartModel.symbol = AAChartSymbolTypeCircle;
     */
    
    [self.cakeChartView aa_drawChartWithChartModel:_cakeChartModel];
}
- (void)refreshCake {
    NSArray *modelAry = _visCountModel.items;
    NSMutableArray *countAry = @[].mutableCopy;
    [modelAry enumerateObjectsUsingBlock:^(VisCountItemModel *visCountItemModel, NSUInteger idx, BOOL * _Nonnull stop) {
        [countAry addObject:@[visCountItemModel.areaName, [NSNumber numberWithString:visCountItemModel.totalVisitor]]];
    }];
    
    self.cakeChartModel = AAObject(AAChartModel)
    .chartTypeSet(AAChartTypePie)
    .colorsThemeSet(@[@"#edc443",@"#ea9731",@"#ed3732",@"#4db6f9",@"#63d540"])
    .titleSet(@"")
    .subtitleSet(@"")
    .dataLabelEnabledSet(true)//是否直接显示扇形图数据
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#ffffff")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#ffffff")    // y轴坐标值颜色
    .seriesSet(
               @[
                 AAObject(AASeriesElement)
                 .nameSet(@"访问人员")
                 .innerSizeSet(@"0%")//内部圆环半径大小占比
                 .dataSet(countAry),
                 ]
               )
    ;
    
    _cakeChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.cakeChartModel.symbol = AAChartSymbolTypeCircle;
    
    [self.cakeChartView aa_refreshChartWithChartModel:self.cakeChartModel];
}

#pragma mark UITableView 协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 3;
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 2){
        return _inTimeData.count;
    }else {
        return 1;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return 0;
    }else {
        return 40;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return [UIView new];
    }else {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 40)];
        UILabel *headLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 11, 100, 17)];
        if(section == 1){
            headLabel.text = @"访问人员";
        }else if (section == 2){
            headLabel.text = @"访问公司";
        }
        [headView addSubview:headLabel];
        return headView;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return 400;
            break;
        case 1:
            return 220;
            break;
        case 2:
            return 60;
            break;
            
        default:
            return 0;
            break;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        SnapCountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SnapCountCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.allVis = _totalNum;
        cell.levVis = _levNum;
        cell.unLevVis = _stayNum;
        cell.todayData = _todayCountData;
        return cell;
    }else if (indexPath.section == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"topSnapViewCell"];
        [cell.contentView addSubview:_cakeChartView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else {
        VIsListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VIsListCell" forIndexPath:indexPath];
        cell.visCountItemModel = _inTimeData[indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    CommpanyVisViewController *ComVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"CommpanyVisViewController"];
    if(indexPath.section == 2){
        CommpanyVisViewController *comVC = [[CommpanyVisViewController alloc] init];
        [self.navigationController pushViewController:comVC animated:YES];
    }
}


-(void)btnClick:(id)sender
{
    VisotorListViewController *visVC = [[VisotorListViewController alloc] init];
    [self.navigationController pushViewController:visVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
