//
//  ParkOverViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/9/19.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "ParkOverViewController.h"
#import "CarRoundView.h"
#import "UnOnlineHomeViewController.h"
#import "WranHomeCenViewController.h"
#import "CloseEqHomeViewController.h"
#import "CheckHomeCenViewController.h"

#import "ParkOverModel.h"
#import "OverLineTableView.h"

@interface ParkOverViewController ()
{
    __weak IBOutlet UILabel *_onlineNumLabel;
    __weak IBOutlet UILabel *_offlineNumLabel;
    __weak IBOutlet CarRoundView *_onlineRoundView;
    
    __weak IBOutlet UIView *_wranBgView;
    __weak IBOutlet UILabel *_wramAllNumLabel;
    
    __weak IBOutlet OverLineTableView *_wranLineTableView;
    
    __weak IBOutlet UILabel *_openNumLabel;
    __weak IBOutlet UILabel *_closeNumLabel;
    __weak IBOutlet CarRoundView *_openRoundView;
    
    __weak IBOutlet UIView *_checkBgView;
    __weak IBOutlet UILabel *_checkAllNumLabel;
    
    __weak IBOutlet OverLineTableView *_checkLineTableView;
    
    NSArray *_titleData;
    
    ParkOverModel *_overModel;
}
@end

@implementation ParkOverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"园区概况";
    
    [self _initView];
    
    [self _loadData];
}

- (void)_initView {
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    _titleData = @[@"连接数据", @"告警数据", @"在用数据", @"巡检任务"];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self _loadData];
    }];
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _wranBgView.layer.cornerRadius = 5;
    _checkBgView.layer.cornerRadius = 5;
    
//    _onlineRoundView.freParkNum = _freNumPark.integerValue;
//    _onlineRoundView.maintainEndNum = (_allNumPark.floatValue - _freNumPark.floatValue)/_allNumPark.floatValue;
//    _onlineRoundView.freParkNum = 5;
    _onlineRoundView.maintainEndNum = 0.00;
    [_onlineRoundView setDataTitle:[NSString stringWithFormat:@"%.0f%%", 0.00]];
    [_onlineRoundView setSubTitle:@"在线率"];
    
//    _openRoundView.freParkNum = 0;
    _openRoundView.maintainEndNum = 0.00;
    [_openRoundView setDataTitle:[NSString stringWithFormat:@"%.0f%%", 0.00*100]];
    [_openRoundView setSubTitle:@"使用率"];
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parkSituation/all", Main_Url];
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self.tableView.mj_header endEditing:YES];
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            _overModel = [[ParkOverModel alloc] initWithDataDic:responseObject[@"responseData"]];
            [self fullTableData:_overModel];
        }else {
            NSString *message = responseObject[@"message"];
            if(message != nil && ![message isKindOfClass:[NSNull class]] && [message isEqualToString:@"1"]){
                [self showHint:message];
            }
        }
        
    } failure:^(NSError *error) {
        [self.tableView.mj_header endEditing:YES];
    }];
}

- (void)fullTableData:(ParkOverModel *)overModel {
    // 连接数据
    NSArray *onlines = overModel.onlines;
    [onlines enumerateObjectsUsingBlock:^(OverOnlineModel *onlineModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if(onlineModel.onlineStatus != nil && [onlineModel.onlineStatus isEqualToString:@"1"]){
            // 在线
            _onlineNumLabel.text = [NSString stringWithFormat:@"%@", onlineModel.onlineStatusCount];
            [self roundView:_onlineRoundView withNumerator:onlineModel.onlineStatusCount withDenominator:overModel.onlineTotalCount];
        }
        if(onlineModel.onlineStatus != nil && [onlineModel.onlineStatus isEqualToString:@"0"]){
            // 在线
            _offlineNumLabel.text = [NSString stringWithFormat:@"%@", onlineModel.onlineStatusCount];
        }
    }];
    
    // 告警数据
    _wranLineTableView.totalCount = overModel.alarmTotalCount;
    _wranLineTableView.traceData = overModel.alarms;
    [_wranLineTableView reloadData];
    NSString *wranText = [NSString stringWithFormat:@"%@ 条", overModel.alarmTotalCount];
    [self lastChartFont:_wramAllNumLabel withStr:wranText];
    
    // 使用数据
    NSArray *useds = overModel.useds;
    [useds enumerateObjectsUsingBlock:^(OverDealModel *dealModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if(dealModel.overallStatus != nil && [dealModel.overallStatus isEqualToString:@"1"]){
            // 开启
            _openNumLabel.text = [NSString stringWithFormat:@"%@", dealModel.overallStatusCount];
            [self roundView:_openRoundView withNumerator:dealModel.overallStatusCount withDenominator:overModel.usedTotalCount];
        }
        if(dealModel.overallStatus != nil && [dealModel.overallStatus isEqualToString:@"2"]){
            // 关闭
            _closeNumLabel.text = [NSString stringWithFormat:@"%@", dealModel.overallStatusCount];
        }
    }];
    
    // 巡检数据
    _checkLineTableView.totalCount = overModel.inspectionTotalCount;
    _checkLineTableView.traceData = overModel.inspections;
    [_checkLineTableView reloadData];
    NSString *checkText = [NSString stringWithFormat:@"%@ 条", overModel.inspectionTotalCount];
    [self lastChartFont:_checkAllNumLabel withStr:checkText];
}

- (void)roundView:(CarRoundView *)roundView withNumerator:(NSNumber *)numerator withDenominator:(NSNumber *)denominator {
    if(numerator != nil && ![numerator isKindOfClass:[NSNull class]] && denominator != nil && ![denominator isKindOfClass:[NSNull class]] && denominator.integerValue != 0){
        CGFloat proportion = numerator.floatValue/denominator.floatValue;
        roundView.maintainEndNum = [NSString stringWithFormat:@"%.2f", proportion].floatValue;
        [roundView setDataTitle:[NSString stringWithFormat:@"%.0f%%", proportion*100]];
    }
}
- (void)lastChartFont:(UILabel *)label withStr:(NSString *)text {
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(text.length - 1, 1)];
    label.attributedText = attStr;
}

#pragma mark UITableView协议
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(section == 3){
        return 40;
    }else {
        return 0.1;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 40)];
    footerView.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 40)];
    label.text = @"数据截止至2018-08-08 00:00:00";
    label.textColor = [UIColor colorWithHexString:@"#C4C4C4"];
    label.font = [UIFont systemFontOfSize:13];
    label.textAlignment = NSTextAlignmentCenter;
    [footerView addSubview:label];
    
    if(section == 3){
        return footerView;
    }else {
        return [UIView new];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 40)];
    headerView.tag = 100+section;
    headerView.backgroundColor = [UIColor clearColor];
    
    UILabel *pointLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,35/2, 5, 5)];
    pointLabel.backgroundColor = [UIColor blackColor];
    [headerView addSubview:pointLabel];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(pointLabel.right + 6, 0, 100, 40)];
    label.text = _titleData[section];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:17];
    label.textAlignment = NSTextAlignmentLeft;
    [headerView addSubview:label];
    
    UIImageView *flagImgView = [[UIImageView alloc] initWithFrame:CGRectMake(KScreenWidth - 31, 10, 20, 20)];
    flagImgView.image = [UIImage imageNamed:@"door_list_right_narrow"];
    [headerView addSubview:flagImgView];
    
    UITapGestureRecognizer *headerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerAction:)];
    [headerView addGestureRecognizer:headerTap];
    return headerView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self indexPush:indexPath.section];
}
- (void)indexPush:(NSInteger)index {
    switch (index) {
        case 0:
        {
            UnOnlineHomeViewController *onLineVC = [[UnOnlineHomeViewController alloc] init];
            onLineVC.title = @"离线设备";
            onLineVC.onlines = _overModel.onlines;
            [self pushVC:onLineVC];
            break;
        }
        case 1:
        {
            WranHomeCenViewController *wranVC = [[WranHomeCenViewController alloc] initWithWrans:_overModel.alarms];
            wranVC.title = @"告警数据";
            [self pushVC:wranVC];
            break;
        }
        case 2:
        {
            CloseEqHomeViewController *closeVC = [[CloseEqHomeViewController alloc] init];
            closeVC.title = @"关闭设备";
            [self pushVC:closeVC];
            break;
        }
        case 3:
        {
            CheckHomeCenViewController *checkVC = [[CheckHomeCenViewController alloc] initWithTasks:_overModel.inspections];
            checkVC.title = @"巡检任务";
            [self pushVC:checkVC];
            break;
        }
            
        default:
            break;
    }
}
- (void)pushVC:(UIViewController *)viewCon {
    [self.navigationController pushViewController:viewCon animated:YES];
}

- (void)headerAction:(UITapGestureRecognizer *)tap {
    [self indexPush:tap.view.tag - 100];
}

@end
