//
//  MealInTimeViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/2/1.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "MealInTimeViewController.h"
#import "MealIntimeCell.h"

#import "PreviewManager.h"
#import "TalkManager.h"

@interface MealInTimeViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_countTableView;
    NSMutableArray *_todayCountData;
    
    MealIntimeCell *_mealCell;
}

@end

@implementation MealInTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _todayCountData = @[].mutableCopy;
    
    [self _initView];
    
    [self _loadData];
}

- (void)_initView {
    _countTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64 - 49) style:UITableViewStylePlain];
    _countTableView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    _countTableView.dataSource = self;
    _countTableView.delegate = self;
    [_countTableView registerNib:[UINib nibWithNibName:@"MealIntimeCell" bundle:nil] forCellReuseIdentifier:@"MealIntimeCell"];
    [self.view addSubview:_countTableView];
}

- (void)_loadData {
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *statDate = [dateFormat stringFromDate:nowDate];
    
    // 当天按小时统计
    NSString *urlStr = [NSString stringWithFormat:@"%@/parkCard/threeMeals",Main_Url];
    
    NSMutableDictionary *searchParam = @{}.mutableCopy;
    [searchParam setObject:statDate forKey:@"statDate"];
    
    NSString *jsonStr = [Utils convertToJsonData:searchParam];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            
            NSMutableArray *numData = @[].mutableCopy;
            NSMutableArray *costData = @[].mutableCopy;
            
            NSDictionary *responseData = responseObject[@"responseData"];
            if(responseData != nil && ![responseData isKindOfClass:[NSNull class]]){
                NSDictionary *morning = responseData[@"morning"];
                [_todayCountData addObject:morning];
                [numData addObject:morning[@"chargeCount"]];
                [costData addObject:morning[@"costMoney"]];
                
                NSDictionary *noon = responseData[@"noon"];
                [_todayCountData addObject:noon];
                [numData addObject:noon[@"chargeCount"]];
                [costData addObject:noon[@"costMoney"]];
                
                NSDictionary *night = responseData[@"night"];
                [_todayCountData addObject:night];
                [numData addObject:night[@"chargeCount"]];
                [costData addObject:night[@"costMoney"]];
            }
            
            _mealCell.xRollerData = @[@"早餐", @"中餐", @"晚餐"];
            _mealCell.numData = numData;
            _mealCell.costData = costData;  // 最后调，触发刷新数据
        }
        
//        [_countTableView reloadData];
        
    } failure:^(NSError *error) {
        [self showHint:KRequestFailMsg];
    }];
}

#pragma mark UITableView 协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (568 - 233) + 233*wScale;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    _mealCell = [tableView dequeueReusableCellWithIdentifier:@"MealIntimeCell" forIndexPath:indexPath];
    _mealCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return _mealCell;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    [[PreviewManager sharedInstance]stopRealPlay];
//    [[TalkManager sharedInstance]stopTalk];
//    [[PreviewManager sharedInstance]initData];
    
    [[PreviewManager sharedInstance] pauseRealPlay:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[PreviewManager sharedInstance] pauseRealPlay:NO];
}

- (void)dealloc {
    [[PreviewManager sharedInstance]stopRealPlay];
    [[TalkManager sharedInstance]stopTalk];
    [[PreviewManager sharedInstance]initData];
}

@end
