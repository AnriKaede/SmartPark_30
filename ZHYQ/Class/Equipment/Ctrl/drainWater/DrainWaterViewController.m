//
//  DrainWaterViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/10.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "DrainWaterViewController.h"
#import "YQHeaderView.h"
#import "DrainWaterCell.h"

#import "DrainWaterModel.h"
#import "PumpModel.h"
#import "PumpStateModel.h"

@interface DrainWaterViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    __weak IBOutlet YQHeaderView *_yqHeaderView;
    
    __weak IBOutlet UILabel *_oneRunTimeLabel;
    __weak IBOutlet UILabel *_oneTowTimeLabel;
    
    __weak IBOutlet UITableView *_drainWtTableView;
    
    NSMutableArray *_drainWaterData;
    
}
@end

@implementation DrainWaterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _drainWaterData = @[].mutableCopy;
    
    [self _initView];
    
    [self _loadData];
}

- (void)_initView {
//    self.title = @"恒压供水";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _yqHeaderView.backgroundColor = [UIColor colorWithHexString:@"1B82D1"];
    _yqHeaderView.centerLab.text = @"停止";
    _yqHeaderView.rightNumLab.textColor = [UIColor colorWithHexString:@"#FFB400"];
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    _drainWtTableView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    _drainWtTableView.tableFooterView = [UIView new];
    [_drainWtTableView registerNib:[UINib nibWithNibName:@"DrainWaterCell" bundle:nil] forCellReuseIdentifier:@"DrainWaterCell"];
    
    _drainWtTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _drainWtTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self _loadData];
    }];
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/airConditioner/pressureWaterStatus",Main_Url];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        [_drainWaterData removeAllObjects];
        
        [_drainWtTableView.mj_header endRefreshing];
        
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *resDic = responseObject[@"responseData"];
            // 处理顶部数据
            [self dealTopData:responseObject];
            
            
            NSDictionary *pumpInfo = resDic[@"pumpInfo"];
            PumpModel *pumpModel = [[PumpModel alloc] initWithDataDic:pumpInfo];
            [self dealCellData:pumpModel];
            
            [_drainWtTableView reloadData];
        }
    } failure:^(NSError *error) {
        [_drainWtTableView.mj_header endRefreshing];
        if(_drainWaterData.count <= 0){
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

#pragma mark UItableView 协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _drainWaterData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DrainWaterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DrainWaterCell" forIndexPath:indexPath];
    cell.pumpStateModel = _drainWaterData[indexPath.row];
    return cell;
}

- (void)dealTopData:(NSDictionary *)responseObject {
    NSDictionary *pump1 = responseObject[@"responseData"][@"pump1"];
    NSDictionary *pump2 = responseObject[@"responseData"][@"pump2"];
    
    NSMutableArray *openPumps = @[].mutableCopy;
    NSMutableArray *stopPumps = @[].mutableCopy;
    NSMutableArray *failPumps = @[].mutableCopy;
    
    if([pump1.allKeys containsObject:@"status"]){
        NSString *isFault = pump1[@"isFault"];
        if(isFault != nil && ![isFault isKindOfClass:[NSNull class]] && [isFault isEqualToString:@"1"]){
            [failPumps addObject:@"1"];
        }else {
            NSString *status = pump1[@"status"];
            if(status != nil && ![status isKindOfClass:[NSNull class]] && [status isEqualToString:@"1"]){
                [openPumps addObject:@"1"];
            }else {
                [stopPumps addObject:@"1"];
            }
        }
    }
    if([pump1.allKeys containsObject:@"runtime"]){
        _oneRunTimeLabel.text = [NSString stringWithFormat:@"%@", pump1[@"runtime"]];
    }
    
    if([pump2.allKeys containsObject:@"status"]){
        NSString *isFault = pump2[@"isFault"];
        if(isFault != nil && ![isFault isKindOfClass:[NSNull class]] && [isFault isEqualToString:@"2"]){
            [failPumps addObject:@"2"];
        }else {
            NSString *status = pump2[@"status"];
            if(status != nil && ![status isKindOfClass:[NSNull class]] && [status isEqualToString:@"2"]){
                [openPumps addObject:@"2"];
            }else {
                [stopPumps addObject:@"2"];
            }
        }
    }
    if([pump2.allKeys containsObject:@"runtime"]){
        _oneTowTimeLabel.text = [NSString stringWithFormat:@"%@", pump2[@"runtime"]];
    }
    
    NSString *openNum;
    if(openPumps.count == 0){
        openNum = @"0";
    }else if(openPumps.count == 1){
        openNum = [NSString stringWithFormat:@"%@号泵", openPumps.firstObject];
    }else if(openPumps.count == 2){
        openNum = [NSString stringWithFormat:@"%@、%@号泵", openPumps.firstObject, openPumps.lastObject];
    }
    _yqHeaderView.leftNumLab.font = [UIFont systemFontOfSize:25];
    _yqHeaderView.leftNumLab.text = openNum;
    
    NSString *downNum;
    if(stopPumps.count == 0){
        downNum = @"0";
    }else if(stopPumps.count == 1){
        downNum = [NSString stringWithFormat:@"%@号泵", stopPumps.firstObject];
    }else if(stopPumps.count == 2){
        downNum = [NSString stringWithFormat:@"%@、%@号泵", stopPumps.firstObject, stopPumps.lastObject];
    }
    _yqHeaderView.centerNumLab.font = [UIFont systemFontOfSize:25];
    _yqHeaderView.centerNumLab.text = downNum;
    
    NSString *errorNum;
    if(failPumps.count == 0){
        errorNum = @"0";
    }else if(failPumps.count == 1){
        errorNum = [NSString stringWithFormat:@"%@号泵", failPumps.firstObject];
    }else if(failPumps.count == 2){
        errorNum = [NSString stringWithFormat:@"%@、%@号泵", failPumps.firstObject, failPumps.lastObject];
    }
    _yqHeaderView.rightNumLab.font = [UIFont systemFontOfSize:25];
    _yqHeaderView.rightNumLab.text = errorNum;
}

- (void)dealCellData:(PumpModel *)pumpModel {
    PumpStateModel *modeModel = [[PumpStateModel alloc] init];
    modeModel.iconName = @"water_model";
    modeModel.pumpTitle = @"水泵模式";
    NSString *modeValue = @"-";
    if(pumpModel.mode != nil && ![pumpModel.mode isKindOfClass:[NSNull class]]){
        if([pumpModel.mode isEqualToString:@"0"]){
            modeValue = @"手动";
        }else {
            modeValue = @"自动";
        }
    }
    modeModel.pumpValue = modeValue;
    modeModel.valueColor = @"#189517";
    [_drainWaterData addObject:modeModel];
    
    PumpStateModel *outModel = [[PumpStateModel alloc] init];
    outModel.iconName = @"water_clock";
    outModel.pumpTitle = @"水泵出口压力";
    NSString *outValue = @"-";
    if(pumpModel.outPressure != nil && ![pumpModel.outPressure isKindOfClass:[NSNull class]]){
        outValue = [NSString stringWithFormat:@"%.3f Mpa", pumpModel.outPressure.floatValue];
    }
    outModel.pumpValue = outValue;
    outModel.valueColor = @"#1B82D1";
    [_drainWaterData addObject:outModel];
    
    PumpStateModel *inModel = [[PumpStateModel alloc] init];
    inModel.iconName = @"water_clock";
    inModel.pumpTitle = @"水泵入口压力";
    NSString *inValue = @"";
    if(pumpModel.inPressure != nil && ![pumpModel.inPressure isKindOfClass:[NSNull class]]){
        inValue = [NSString stringWithFormat:@"%.3f Mpa", pumpModel.inPressure.floatValue];
    }
    inModel.pumpValue = inValue;
    inModel.valueColor = @"#1B82D1";
    [_drainWaterData addObject:inModel];
    
    PumpStateModel *negativeModel = [[PumpStateModel alloc] init];
    negativeModel.iconName = @"water_warn";
    negativeModel.pumpTitle = @"水泵负压报警";
    NSString *negativeValue = @"";
    if(pumpModel.pressureAlarm != nil && ![pumpModel.pressureAlarm isKindOfClass:[NSNull class]]){
        if([pumpModel.pressureAlarm isEqualToString:@"0"]){
            negativeValue = @"正常";
            negativeModel.valueColor = @"#189517";
        }else {
            negativeValue = @"报警";
            negativeModel.valueColor = @"#FF4359";
        }
    }
    negativeModel.pumpValue = negativeValue;
    [_drainWaterData addObject:negativeModel];
    
    PumpStateModel *exceedModel = [[PumpStateModel alloc] init];
    exceedModel.iconName = @"water_model";
    exceedModel.pumpTitle = @"水泵超压报警";
    NSString *exceedValue = @"";
    if(pumpModel.overAlarm != nil && ![pumpModel.overAlarm isKindOfClass:[NSNull class]]){
        if([pumpModel.overAlarm isEqualToString:@"0"]){
            exceedValue = @"正常";
            exceedModel.valueColor = @"#189517";
        }else {
            exceedValue = @"警报";
            exceedModel.valueColor = @"#FF4359";
        }
    }
    exceedModel.pumpValue = exceedValue;
    [_drainWaterData addObject:exceedModel];
    
    PumpStateModel *frequencyModel = [[PumpStateModel alloc] init];
    frequencyModel.iconName = @"water_fault";
    frequencyModel.pumpTitle = @"水泵变频故障";
    NSString *frequencyValue = @"";
    if(pumpModel.fault != nil && ![pumpModel.fault isKindOfClass:[NSNull class]]){
        if([pumpModel.fault isEqualToString:@"0"]){
            frequencyValue = @"正常";
            frequencyModel.valueColor = @"#189517";
        }else {
            frequencyValue = @"警报";
            frequencyModel.valueColor = @"#FF4359";
        }
    }
    frequencyModel.pumpValue = frequencyValue;
    [_drainWaterData addObject:frequencyModel];
}

@end
