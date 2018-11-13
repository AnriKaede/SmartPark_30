//
//  AptingDetailViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/6/19.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "AptingDetailViewController.h"
#import "AptCancelView.h"
#import "CalculateHeight.h"

@interface AptingDetailViewController ()<WindowChooseDelegate>
{
    __weak IBOutlet UILabel *_topMsgLabel;
    __weak IBOutlet UILabel *_minuteLabel;
    __weak IBOutlet UILabel *_secordLabel;
    
    __weak IBOutlet UIButton *_openLockBt;
    __weak IBOutlet UIButton *_cancelAptBt;
    
    __weak IBOutlet UILabel *_orderLabel;
    __weak IBOutlet UILabel *_nameLabel;    // 最后带 "("
    __weak IBOutlet UILabel *_phoneLabel;   // 最后带 ")"
    
    __weak IBOutlet UILabel *_aptTimeLabel;
    __weak IBOutlet UILabel *_laterTimeLabel;
    __weak IBOutlet UILabel *_remarkLabel;
    
    AptCancelView *_aptCancelView;
    
    int _second;
    NSTimer *_timer;
}
@end

@implementation AptingDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _second = 0;
    
    [self _initView];
    
    [self _loadData];
    
    // 接受应用从后台到前台通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(foreground) name:@"EnterForegroundAlert" object:nil];
}

- (void)foreground {
    [self _loadData];
}

- (void)_loadData {
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    if(_aptListModel.orderModel.orderId != nil && ![_aptListModel.orderModel.orderId isKindOfClass:[NSNull class]]){
        [paramDic setObject:_aptListModel.orderModel.orderId forKey:@"orderId"];
    }
    NSDictionary *param = @{@"param":[Utils convertToJsonData:paramDic]};
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/parkingOrderDetail", Main_Url];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        if([responseObject[@"code"] isEqualToString:@"1"]){
            NSDictionary *responseData = responseObject[@"responseData"];
            if(responseData == nil || [responseData isKindOfClass:[NSNull class]]){
                return ;
            }
            
            AptListModel *aptListModel = [[AptListModel alloc] initWithDataDic:responseData];
            _aptListModel = aptListModel;
            
            // 初始化视图
            [self fullData];
        }else {
            [self showHint:responseObject[@"message"]];
        }
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)_initView {
    self.title = @"预约详情";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"efefef"];
    self.tableView.scrollEnabled = NO;  // 禁止滑动
    
    _openLockBt.layer.cornerRadius = 6;
    
    _cancelAptBt.layer.cornerRadius = 6;
    _cancelAptBt.layer.borderWidth = 0.8;
    _cancelAptBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    
    // 确认取消弹窗
    _aptCancelView = [[AptCancelView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight)];
    _aptCancelView.chooseDelegate = self;
    [self.view addSubview:_aptCancelView];
}

- (void)fullData {
    // 倒计时
    [self calculateTime:_aptListModel.cunrentTime withEndTime:_aptListModel.orderModel.invalidTime];
    
    // 填充数据
    _topMsgLabel.text = [NSString stringWithFormat:@"%@ 预订车位 %@,车位将保留30分钟", _aptListModel.orderModel.carNo, _aptListModel.orderModel.parkingSpaceName];
    
    NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:_topMsgLabel.text];
    if(_aptListModel.orderModel.carNo != nil && ![_aptListModel.orderModel.carNo isKindOfClass:[NSNull class]]){
        [attriStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#FF0000"] range:NSMakeRange(0, _aptListModel.orderModel.carNo.length)];
    }
    if(_aptListModel.orderModel.parkingSpaceName != nil && ![_aptListModel.orderModel.parkingSpaceName isKindOfClass:[NSNull class]]){
        if(_aptListModel.orderModel.carNo != nil && ![_aptListModel.orderModel.carNo isKindOfClass:[NSNull class]]){
            [attriStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#FF0000"] range:NSMakeRange(_aptListModel.orderModel.carNo.length + 6, _aptListModel.orderModel.parkingSpaceName.length)];
        }else {
            [attriStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#FF0000"] range:NSMakeRange(6, _aptListModel.orderModel.parkingSpaceName.length)];
        }
    }
    _topMsgLabel.attributedText = attriStr;
    
    _orderLabel.text = [NSString stringWithFormat:@"%@", _aptListModel.orderModel.orderId];
    _nameLabel.text = [NSString stringWithFormat:@"%@(", _aptListModel.orderModel.custName];
    _phoneLabel.text = [NSString stringWithFormat:@"%@)", _aptListModel.orderModel.phone];
    _aptTimeLabel.text = [NSString stringWithFormat:@"%@", _aptListModel.orderModel.orderTime];
    _laterTimeLabel.text = [NSString stringWithFormat:@"%@", _aptListModel.orderModel.invalidTime];
    
    _remarkLabel.text = [NSString stringWithFormat:@"%@", _aptListModel.orderModel.remark];
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)openLockAction:(id)sender {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/forceOperateParkingLock", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:_aptListModel.orderModel.parkingSpaceId forKey:@"parkingSpaceId"];
    [paramDic setObject:@"on" forKey:@"operateType"];
    
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            // 刷新tableView
            // 记录日志
            NSString *OperateName = [NSString stringWithFormat:@"打开车位锁 %@", _aptListModel.orderModel.parkingSpaceName];
            [self logRecordTagId:_aptListModel.orderModel.parkingSpaceId withOperateName:OperateName withUrl:@"/parking/forceOperateParkingLock"];
        }
        NSString *message = responseObject[@"message"];
        if(message != nil && ![message isKindOfClass:[NSNull class]]) {
            [self showHint:message];
        }
    }failure:^(NSError *error) {
        
    }];
}

- (IBAction)cancelAptAction:(id)sender {
    _aptCancelView.hidden = NO;
}

#pragma mark WindowChooseDelegate确认取消协议
- (void)cancel:(NSString *)orderId withRemark:(NSString *)remark {
    
}
- (void)confirmComplete:(NSString *)orderId withRemark:(NSString *)remark {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/forceCancelOrder", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:_aptListModel.orderModel.parkingSpaceId forKey:@"parkingSpaceId"];
    [paramDic setObject:remark forKey:@"remark"];
    
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            // 发送通知 刷新tableView 全部和预约中
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CancelAptSucess" object:nil];
            
            // 记录日志
            NSString *OperateName = [NSString stringWithFormat:@"取消 %@ 预约 %@", _aptListModel.orderModel.carNo, _aptListModel.orderModel.parkingSpaceName];;
            [self logRecordTagId:_aptListModel.orderModel.parkingSpaceId withOperateName:OperateName withUrl:@"/parking/forceCancelOrder"];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        NSString *message = responseObject[@"message"];
        if(message != nil && ![message isKindOfClass:[NSNull class]]) {
            [self showHint:message];
        }
    }failure:^(NSError *error) {
        
    }];
}

#pragma mark UITableView 协议
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return 241;
            break;
            
        case 1:
        {
            CGFloat height = [CalculateHeight heightForString:_aptListModel.orderModel.remark fontSize:17 andWidth:(KScreenWidth - 30)];
            
            return 200 + height;
            break;
        }
            
        default:
            return 0;
            break;
    }
}

#pragma mark 计算时间差
- (void)calculateTime:(NSString *)beginTime withEndTime:(NSString *)endTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *beginDate = [dateFormatter dateFromString:beginTime];
    NSDate *endDate = [dateFormatter dateFromString:endTime];
    
    NSTimeInterval start = [beginDate timeIntervalSince1970]*1;
    NSTimeInterval end = [endDate timeIntervalSince1970]*1;
    NSTimeInterval value = end - start;
    
    int second = (int)value %60;//秒
    int minute = (int)value /60%60;
    int house = (int)value / (24 * 3600)%3600;
    
    NSLog(@"h: %d M: %d  S: %d", house, minute, second);
    
    _second = value;
    
    [self refreshTime:_second];
    
    if(_timer == nil){
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 block:^(NSTimer * _Nonnull timer) {
            if(_second <= 0){
                [timer invalidate];
            }
            _second --;
            [self refreshTime:_second];
        } repeats:YES];
    }
     
}

- (void)refreshTime:(int)value {
    int minute = (int)value /60%60;
    int second = (int)value %60;
    
    if(minute < 10){
        _minuteLabel.text = [NSString stringWithFormat:@"0%d", minute];
    }else {
        _minuteLabel.text = [NSString stringWithFormat:@"%d", minute];
    }
    
    if(second < 10){
        _secordLabel.text = [NSString stringWithFormat:@"0%d", second];
    }else {
        _secordLabel.text = [NSString stringWithFormat:@"%d", second];
    }
    NSLog(@"定时器-----%d", _second);
}

#pragma mark 记录日志
- (void)logRecordTagId:(NSString *)tagId withOperateName:(NSString *)operateName withUrl:(NSString *)operateUrl {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:[NSString stringWithFormat:@"%@", operateName] forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:[NSString stringWithFormat:@"%@", operateName] forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:operateUrl forKey:@"operateUrl"];//操作url
    //    [logDic setObject:@"" forKey:@"operateLocation"];//操作地点
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:tagId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"车位管理" forKey:@"operateDeviceName"];//操作设备名  模块
    //    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"EnterForegroundAlert" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_timer invalidate];
    _timer = nil;
}

@end
