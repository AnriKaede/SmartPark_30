//
//  TodayParkViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/20.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "TodayParkViewController.h"
#import "SurplusParkCell.h"
#import "AAChartView.h"

#import "HourFlowCountModel.h"
#import "ParkAreasModel.h"

#define PageLineWidth (KScreenWidth - 60)/7

@interface TodayParkViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_parkTableView;
    NSMutableArray *_surplusData;
    NSMutableArray *_dataArr;
    
    UIScrollView *_chartScrollView;
}
@property (nonatomic, strong) AAChartModel *snapChartModel;
@property (nonatomic, strong) AAChartView  *snapChartView;
@property (nonatomic, strong) AAChartModel *cakeChartModel;
@property (nonatomic, strong) AAChartView  *cakeChartView;
@end

@implementation TodayParkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _surplusData = @[].mutableCopy;
    _dataArr = @[].mutableCopy;
//    _surplusData = @[@"1",@"1",@"1",@"1"].mutableCopy;
    
    [self _initView];
    
    //加载折线图数据
    [self _loadData];
    
    //加载对应停车场数据
    [self _loadParkData];
    
    //加载各个公司车辆情况
    [self _loadCompanyCarData];
}

- (void)_initView {
    // 创建折线图
    [self _createSnapView];
    // 创建饼状图
    [self _createCakeView];
    
    // 初始化tableView
    _parkTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64 - kTabBarHeight) style:UITableViewStyleGrouped];
    _parkTableView.contentInset = UIEdgeInsetsMake(0, 0, 5, 0);
    _parkTableView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    _parkTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _parkTableView.dataSource = self;
    _parkTableView.delegate = self;
    [_parkTableView registerNib:[UINib nibWithNibName:@"SurplusParkCell" bundle:nil] forCellReuseIdentifier:@"SurplusParkCell"];
    [self.view addSubview:_parkTableView];
}

- (void)_loadData {
    NSDate *nowDate = [NSDate new];
    NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:@"yyyyMMdd"];
    NSString *todayString = [inputFormatter stringFromDate:nowDate];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/analysis/loadHourFlowCount",ParkMain_Url];
    
    NSMutableDictionary *params = @{}.mutableCopy;
    [params setObject:todayString forKey:@"reportOccurDate"];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        
        [_dataArr removeAllObjects];
        if([responseObject[@"success"] boolValue]){
            NSArray *arr = responseObject[@"data"];
#warning 添加判断
            if(arr == nil || [arr isKindOfClass:[NSNull class]]){
                return ;
            }
            
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                HourFlowCountModel *model = [[HourFlowCountModel alloc] initWithDataDic:obj];
                [_dataArr addObject:model];
            }];
            [self refreshSnap];
        }
    } failure:^(NSError *error) {
        [self showHint:KRequestFailMsg];
    }];
    
}

-(void)_loadParkData
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/status",ParkMain_Url];
    
    NSMutableDictionary *params = @{}.mutableCopy;
    [params setObject:KParkId forKey:@"parkId"];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        //        DLog(@"%@",responseObject);
        [_surplusData removeAllObjects];
        if([responseObject[@"success"] boolValue]){
            NSDictionary *dic = responseObject[@"data"];
            NSArray *parkAreasArr = dic[@"parkAreas"];
            [parkAreasArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ParkAreasModel *model = [[ParkAreasModel alloc] initWithDataDic:obj];
                [_surplusData addObject:model];
            }];
            
        }
        
        [_parkTableView reloadSection:1 withRowAnimation:UITableViewRowAnimationNone];
    } failure:^(NSError *error) {
        
    }];
}

-(void)_loadCompanyCarData {
    NSDate *nowDate = [NSDate new];
    NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:@"yyyyMMdd"];
    NSString *todayString = [inputFormatter stringFromDate:nowDate];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/analysis/loadCompPackingStatus",ParkMain_Url];
    
    NSMutableDictionary *params = @{}.mutableCopy;
    [params setObject:todayString forKey:@"reportOccurDate"];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        
        if([responseObject[@"success"] boolValue]){
            NSDictionary *dic = responseObject[@"data"];
            NSArray *arr = dic.allKeys;
            
            NSMutableArray *dataSet = @[].mutableCopy;
            
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSMutableArray *cakeArr = @[].mutableCopy;
                NSNumber *num = dic[obj];
                
                [cakeArr addObject:[NSString stringWithFormat:@"%@",obj]];
                [cakeArr addObject:num];
                
                [dataSet addObject:cakeArr];
                
            }];
            
            [self refreshCake:dataSet];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)refreshSnap {
    
    NSMutableArray *countAry = @[].mutableCopy;
    NSMutableArray *timeArr = @[].mutableCopy;
    [_dataArr enumerateObjectsUsingBlock:^(HourFlowCountModel *hourCountModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [timeArr addObject:hourCountModel.reportOccurHour];
        [countAry addObject:hourCountModel.totalTotalCount];
        
    }];
    
    if(timeArr.count > 7){
        // 大于7列 滑动
        CGFloat snapChartWidth = 60 + PageLineWidth*timeArr.count;
        _chartScrollView.contentSize = CGSizeMake(snapChartWidth, 0);
        [_chartScrollView setContentOffset:CGPointMake(_chartScrollView.contentSize.width - KScreenWidth, 0) animated:YES];
        
        self.snapChartView = nil;
        [_snapChartView removeFromSuperview];
        
        self.snapChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, snapChartWidth, 275)];
        self.snapChartView.contentHeight = 260;
        self.snapChartView.isClearBackgroundColor = YES;
        self.snapChartView.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
        [_chartScrollView addSubview:self.snapChartView];
        
    }
    
    self.snapChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeLine)
    .titleSet(@"")
    .subtitleSet(@"")
    .categoriesSet(timeArr)
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#ffffff")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#ffffff")    // y轴坐标值颜色
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .nameSet(@"停车次数")
                 .dataSet(countAry),
                 ]
               )
    ;
    
    self.snapChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.snapChartModel.symbol = AAChartSymbolTypeCircle;
    self.snapChartModel.colorsTheme = @[@"#FFC921"];
    
    [self.snapChartView aa_drawChartWithChartModel:self.snapChartModel];
//    [_parkTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)refreshCake:(NSMutableArray *)arr
{
    
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
                 .nameSet(@"停车数量")
                 .innerSizeSet(@"0%")//内部圆环半径大小占比
                 .dataSet(arr),
                 ]
               )
    ;
    
    _cakeChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.cakeChartModel.symbol = AAChartSymbolTypeCircle;
    
    [self.cakeChartView aa_refreshChartWithChartModel:self.cakeChartModel];
}

#pragma mark 折线图
- (void)_createSnapView {
    // 创建折线背景scrollView
    _chartScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 275)];
    _chartScrollView.bounces = NO;
//    _chartScrollView.contentSize = CGSizeMake(self.view.frame.size.width*2, 0);
    [self.view addSubview:_chartScrollView];
    
    self.snapChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, 275)];
    self.snapChartView.contentHeight = 260;
    self.snapChartView.isClearBackgroundColor = YES;
    self.snapChartView.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    [_chartScrollView addSubview:self.snapChartView];
    
    self.snapChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeLine)
    .titleSet(@"")
    .subtitleSet(@"")
    .categoriesSet(@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7"])
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#ffffff")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#ffffff")    // y轴坐标值颜色
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .nameSet(@"停车次数")
                 .dataSet(@[@0,@0,@0,@0,@0,@0,@0]),
                 ]
               )
    ;
    
    self.snapChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.snapChartModel.symbol = AAChartSymbolTypeCircle;
    self.snapChartModel.colorsTheme = @[@"#FFC921"];
    
    [self.snapChartView aa_drawChartWithChartModel:_snapChartModel];
}
#pragma mark 饼状图
- (void)_createCakeView {
    self.cakeChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, 270)];
    self.cakeChartView.contentHeight = 250;
    self.cakeChartView.isClearBackgroundColor = YES;
    self.cakeChartView.backgroundColor = [UIColor whiteColor];
    
    self.cakeChartModel = AAObject(AAChartModel)
    .chartTypeSet(AAChartTypePie)
    .colorsThemeSet(@[@"#efefef"])
    .titleSet(@"")
    .subtitleSet(@"")
    .dataLabelEnabledSet(true)//是否直接显示扇形图数据
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#ffffff")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#ffffff")    // y轴坐标值颜色
    .seriesSet(
               @[
                 AAObject(AASeriesElement)
                 .nameSet(@"停车数量")
                 .innerSizeSet(@"0%")//内部圆环半径大小占比
                 .dataSet(@[
                            @[@"" , @0],
                            ]),
                 ]
               )
    ;
    
    _cakeChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.cakeChartModel.symbol = AAChartSymbolTypeCircle;
    
    [self.cakeChartView aa_drawChartWithChartModel:_cakeChartModel];
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITableView 协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 1){
        return _surplusData.count;
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
            headLabel.text = @"剩余车位";
        }else if (section == 2){
            headLabel.text = @"车辆情况";
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
            return 275;
            break;
        case 1:
            return 75;
            break;
        case 2:
            return 270;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"topSnapViewCell"];
        [cell.contentView addSubview:_chartScrollView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (indexPath.section == 1) {
        SurplusParkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SurplusParkCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.model = _surplusData[indexPath.row];
        return cell;
    }else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"topCakeViewCell"];
        [cell.contentView addSubview:_cakeChartView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
