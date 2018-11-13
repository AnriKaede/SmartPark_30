//
//  WorkDetailViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/16.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WorkDetailViewController.h"
#import "CalculateHeight.h"

#import "RejectBillView.h"
#import "CompleteConfirmViewController.h"

#import "WranUndealModel.h"
#import "HandLogModel.h"

@interface WorkDetailViewController ()<RejectWindowChooseDelegate>
{
    __weak IBOutlet UIImageView *_topImgView;
    __weak IBOutlet UILabel *_topStateLabel;
    
    __weak IBOutlet UILabel *_deviceNameLabel;
    __weak IBOutlet UILabel *_locationLabel;
    __weak IBOutlet UILabel *_describeLabel;
    __weak IBOutlet UILabel *_expTimeLabel;
    __weak IBOutlet UILabel *_remarkLabel;
    __weak IBOutlet UILabel *_sendManLabel;
    __weak IBOutlet UILabel *_sendTimeLabel;
    
    __weak IBOutlet UIButton *_rejectBt;
    __weak IBOutlet UIButton *_completeBt;
    
//    __weak IBOutlet UIView *_bottomView;
    UIView *_bottomView;
    RejectBillView *_rejectBillView;
    
    BillListModel *_billListModel;
}
@end

@implementation WorkDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
    
    [self _loadBillInfoData];
}

- (void)_initView {
    self.title = @"工单详情";
    
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    // 退回工单弹窗
    _rejectBillView = [[RejectBillView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight)];
    _rejectBillView.chooseDelegate = self;
    [self.view addSubview:_rejectBillView];
}

// 根据数据填充新
- (void)fullBillInfo {
    // 01 派单 02 处理中 03 完成  04关闭 05无效
    if([_billListModel.orderState isEqualToString:@"02"]){
        _topImgView.image = [UIImage imageNamed:@"bill_detail_repairsIng"];
        _topStateLabel.text = @"处理中";
    }else if([_billListModel.orderState isEqualToString:@"03"]){
        _topImgView.image = [UIImage imageNamed:@"bill_detail_unConfirm"];
        _topStateLabel.text = @"待确认";
        _bottomView.hidden = YES;
        _topStateLabel.textColor = [UIColor colorWithHexString:@"#B5FEFF"];
    }else if([_billListModel.orderState isEqualToString:@"04"]){
        _topImgView.image = [UIImage imageNamed:@"bill_detail_end"];
        _topStateLabel.text = @"已结束";
        _bottomView.hidden = YES;
        _topStateLabel.textColor = [UIColor colorWithHexString:@"#78FF85"];
    }else if([_billListModel.orderState isEqualToString:@"01"]){
        _topImgView.image = [UIImage imageNamed:@"Bill_detail_report"];
        _topStateLabel.text = @"待派单";
        _bottomView.hidden = YES;
        _topStateLabel.textColor = [UIColor colorWithHexString:@"#f7c693"];
    }
    
    _deviceNameLabel.text = [NSString stringWithFormat:@"%@", _billListModel.deviceName];
    //_locationLabel.text = [NSString stringWithFormat:@"%@", _billListModel.deviceName];
    _describeLabel.text = [NSString stringWithFormat:@"%@", _billListModel.alarmContent];
    _expTimeLabel.text = [NSString stringWithFormat:@"%@", [self timeForTimeStr:_billListModel.expectDate]];
    _remarkLabel.text = [NSString stringWithFormat:@"%@", _billListModel.remark];
    _sendManLabel.text = [NSString stringWithFormat:@"%@", _billListModel.createrName];
    _sendTimeLabel.text = [NSString stringWithFormat:@"%@", [self timeForTimeStr:_billListModel.createDate]];
    
    //01 派单 02 处理中 03 完成  04无效
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:KAdminUserId];
    if([_billListModel.orderState isEqualToString:@"02"]){
        if(userId == nil || [userId isKindOfClass:[NSNull class]] || [userId isEqualToString:_billListModel.repairId]){
            [self _createBottomView];
        }else {
            _bottomView.hidden = YES;
        }
    }
}
- (NSString *)timeForTimeStr:(NSString *)timeStr {
    if(timeStr == nil || [timeStr isKindOfClass:[NSNull class]]){
        return @"";
    }
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *expDate = [dateFormat dateFromString:timeStr];
    
    NSDateFormatter *inputDateFormat = [[NSDateFormatter alloc] init];
    [inputDateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *inputStr = [inputDateFormat stringFromDate:expDate];
    
    return inputStr;
}

- (void)_createBottomView {
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, KScreenHeight - 64 - 60, KScreenWidth, 60)];
    [self.view addSubview:_bottomView];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, KScreenWidth/2, 60);
    [leftButton setBackgroundImage:[UIImage imageNamed:@"scene_all_close_bg"] forState:UIControlStateNormal];
    [leftButton setTitle:@"退回工单" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(rejectAction:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:leftButton];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(KScreenWidth/2, 0, KScreenWidth/2, 60);
    rightButton.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    [rightButton setTitle:@"完成反馈" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor colorWithHexString:@"#CCFF00"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(completeAction:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:rightButton];
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 加载工单详情
- (void)_loadBillInfoData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/deviceAlarm/alarmOrder/%@", Main_Url,_orderId];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            BillListModel *billInfoListModel;
            if(responseObject[@"responseData"][@"alarmOrder"] != nil && ![responseObject[@"responseData"][@"alarmOrder"] isKindOfClass:[NSNull class]]){
                billInfoListModel = [[BillListModel alloc] initWithDataDic:responseObject[@"responseData"][@"alarmOrder"]];
                _billListModel = billInfoListModel;
            }
            WranUndealModel *wranUndealModel;
            if(responseObject[@"responseData"][@"alarmInfo"] != nil && ![responseObject[@"responseData"][@"alarmInfo"] isKindOfClass:[NSNull class]]){
                wranUndealModel = [[WranUndealModel alloc] initWithDataDic:responseObject[@"responseData"][@"alarmInfo"]];
            }
            HandLogModel *handLogModel;
            if(responseObject[@"responseData"][@"handleLog"] != nil && ![responseObject[@"responseData"][@"handleLog"] isKindOfClass:[NSNull class]]){
                handLogModel = [[HandLogModel alloc] initWithDataDic:responseObject[@"responseData"][@"handleLog"]];
            }
            
            [self.tableView reloadData];
            
            // 填充设备位置数据
            [self fullBillInfo];
            _locationLabel.text = [NSString stringWithFormat:@"%@", wranUndealModel.alarmLocation];
            _deviceNameLabel.text = [NSString stringWithFormat:@"%@", wranUndealModel.deviceName];
            
        }else {
            NSString *message = responseObject[@"message"];
            if(message != nil && ![message isKindOfClass:[NSNull class]]){
                [self showHint:message];
            }
        }
    } failure:^(NSError *error) {
        [self showHint:KRequestFailMsg];
    }];
}

#pragma mark - Tableview 协议
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return 150;
            break;
            
        case 1:
            switch (indexPath.row) {
                case 2:
                {
                    // 故障描述
                    CGFloat labelHeight = 0;
                    if(_billListModel.alarmContent == nil || [_billListModel.alarmContent isKindOfClass:[NSNull class]] || _billListModel.alarmContent.length <= 0){
                        return 60;
                    }else {
                        labelHeight = [CalculateHeight heightForString:_billListModel.alarmContent fontSize:17 andWidth:KScreenWidth - 113];
                        return labelHeight + 30;
                    }
                    break;
                }
                    
                case 4:
                {
                    // 派单备注
                    CGFloat labelHeight = 0;
                    if(_billListModel.remark == nil || [_billListModel.remark isKindOfClass:[NSNull class]] || _billListModel.remark.length <= 0){
                        return 60;
                    }else {
                        labelHeight = [CalculateHeight heightForString:_billListModel.remark fontSize:17 andWidth:KScreenWidth - 113];
                        return labelHeight + 30;
                    }
                    break;
                }
                    
                default:
                    return 60;
                    break;
            }
            break;
            
        default:
            return 0;
            break;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return 0.1;
    }else {
        return 5;
    }
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

#pragma mark 点击退回工单
- (IBAction)rejectAction:(id)sender {
    self.tableView.contentOffset = CGPointMake(0, 0);
    self.tableView.scrollEnabled = NO;
    
    [_rejectBillView showRejectView:_billListModel.orderId];
}

- (IBAction)completeAction:(id)sender {
    CompleteConfirmViewController *comVC = [[UIStoryboard storyboardWithName:@"Personal" bundle:nil] instantiateViewControllerWithIdentifier:@"CompleteConfirmViewController"];
    comVC.billListModel = _billListModel;
    [self.navigationController pushViewController:comVC animated:YES];
}

#pragma mark RejectWindowChooseDelegate退回工单协议
- (void)cancel {
    self.tableView.scrollEnabled = YES;
    
    [_rejectBillView hidRejectView];
}
- (void)confirmReject:(NSString *)orderId withRemark:(NSString *)remark {
    // 确认退回
    NSString *urlStr = [NSString stringWithFormat:@"%@/deviceAlarm/rejectOrderByRepairman", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:orderId forKey:@"orderId"];
    [paramDic setObject:remark forKey:@"remark"];
    
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            [_rejectBillView hidRejectView];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RejectRepairsSuccess" object:nil userInfo:@{@"orderId":orderId}];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        NSString *message = responseObject[@"message"];
        if(message != nil && ![message isKindOfClass:[NSNull class]]){
            [self showHint:message];
        }
    } failure:^(NSError *error) {
        [self showHint:KRequestFailMsg];
    }];
}

#pragma mark UIScrollView协议
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    _bottomView.frame = CGRectMake(0, KScreenHeight - kTopHeight - 60 + scrollView.contentOffset.y, KScreenWidth, 60);
}

@end
