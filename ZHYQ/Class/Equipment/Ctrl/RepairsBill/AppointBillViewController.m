//
//  AppointBillViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/18.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "AppointBillViewController.h"
#import "InquiryDeviceViewController.h"
#import "RepairsPeopleViewController.h"

#import "WranUndealModel.h"
#import "WSDatePickerView.h"
#import "RepairsManModel.h"

#import "BillListModel.h"
#import "WranUndealModel.h"
#import "HandLogModel.h"

#import "RejectBillView.h"

#import "DeviceInfoModel.h"

#define KInputMaxLength 200

@interface AppointBillViewController ()<UITextViewDelegate, SelRepairManDelegate, UIGestureRecognizerDelegate, RejectWindowChooseDelegate, SelDeviceDelegate, UITextFieldDelegate>
{
    __weak IBOutlet UITextField *_nameTF;
    __weak IBOutlet UITextField *_idTF;
    __weak IBOutlet UITextField *_locationTF;
    
    __weak IBOutlet UITextView *_describeTV;
    UILabel *_tvMsgLabel;
    __weak IBOutlet UIImageView *_stateImgView;
    
    NSDate *_completeDate;
    __weak IBOutlet UILabel *_timeLabel;
    __weak IBOutlet UITextField *_repairManTF;
    __weak IBOutlet UITextField *_sendManTF;
    __weak IBOutlet UITextField *_remarksTF;
    
    __weak IBOutlet UIImageView *_resultImgView;
    
    __weak IBOutlet UIView *_footerView;
    __weak IBOutlet UIButton *_cerReportBt;
    
    UIView *_bottomView;
    
    __weak IBOutlet UIButton *chooseRepairsPeopleBtn;
    
    RepairsManModel *_repairsManModel;
    DeviceInfoModel *_deviceInfoModel;
    
    RejectBillView *_rejectBillView;
}
@end

@implementation AppointBillViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
    
    if(_wranUndealModel != nil){
        [self fullWranInfo];
    }
    
    if(_appointState == AppointRepairing || _appointState == AppointComplete || _appointState == AppointClose){
        [self closeTextfieldEnable];
    }
    
    // 待派单、维修中、已完成、已关闭 需要查询详情
    if(_appointState == AppointUnDeal || _appointState == AppointRepairing || _appointState == AppointComplete || _appointState == AppointClose){
        // 从维修派单进入，有工单列表_billListModel
        if(_billListModel != nil){
            NSString *urlStr = [NSString stringWithFormat:@"%@/deviceAlarm/alarmOrder/%@", Main_Url,_billListModel.orderId];
            [self _loadBillInfoData:urlStr];
        }else if(_wranUndealModel != nil){
            // 从故障列表进入，有故障列表_wranUndealModel
            NSString *urlStr = [NSString stringWithFormat:@"%@/deviceAlarm/alarmOrderByAlarmId/%@", Main_Url,_wranUndealModel.alarmId];
            [self _loadBillInfoData:urlStr];
        }
    }
}

- (void)_initView {
    self.title = @"维修派单";
    
    _idTF.enabled = NO;
    _sendManTF.enabled = NO;
    
    UITapGestureRecognizer *endEditTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEdit)];
    endEditTap.delegate = self;
    [self.view addGestureRecognizer:endEditTap];
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _describeTV.delegate = self;
    
    _remarksTF.delegate = self;
    
    // textView提示label
    _tvMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 9, _describeTV.width - 4, 17)];
    _tvMsgLabel.text = @"请简单描述物品故障情况";
    _tvMsgLabel.textColor = [UIColor colorWithHexString:@"#c7c7cd"];
    _tvMsgLabel.font = [UIFont systemFontOfSize:17];
    _tvMsgLabel.textAlignment = NSTextAlignmentLeft;
    [_describeTV addSubview:_tvMsgLabel];
    
    _footerView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    
    _cerReportBt.layer.cornerRadius = 4;
    _cerReportBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    _cerReportBt.layer.borderWidth = 0.8;
    
    // 派单状态图标
    switch (_appointState) {
        case AppointSend:
            _stateImgView.hidden = YES;
            break;
            
        case AppointUnDeal:
            _stateImgView.image = [UIImage imageNamed:@"repair_send"];
            break;
            
        case AppointRepairing:
            _stateImgView.image = [UIImage imageNamed:@"repair_ing"];
            break;
            
        case AppointComplete:
            _stateImgView.image = [UIImage imageNamed:@"repair_complete"];
            break;
            
        case AppointClose:
            _stateImgView.image = [UIImage imageNamed:@"repair_close"];
            break;
    }
    
    // 根据情况设置最下方按钮
    if(_appointState == AppointSend || _appointState == AppointUnDeal){
        _footerView.hidden = NO;
    }else if(_appointState == AppointRepairing || _appointState == AppointClose) {
        _footerView.hidden = YES;
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, -_footerView.height, 0);
    }else {
        _footerView.hidden = YES;
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, -_footerView.height + 60, 0);
        
        [self _createBottomView];
    }
    
    // 派单人
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    if(userName != nil && ![userName isKindOfClass:[NSNull class]]){
        _sendManTF.text = userName;
    }
    
    // 退回工单弹窗
    _rejectBillView = [[RejectBillView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight)];
    _rejectBillView.chooseDelegate = self;
    [_rejectBillView changeTitle:@"重新维修"];
    [self.view addSubview:_rejectBillView];
}

#pragma mark 加载工单详情
- (void)_loadBillInfoData:(NSString *)urlStr {
    
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
                _wranUndealModel = wranUndealModel;
            }
            HandLogModel *handLogModel;
            if(responseObject[@"responseData"][@"handleLog"] != nil && ![responseObject[@"responseData"][@"handleLog"] isKindOfClass:[NSNull class]]){
                handLogModel = [[HandLogModel alloc] initWithDataDic:responseObject[@"responseData"][@"handleLog"]];
            }
            // 填充数据
            [self fullBillInfo:billInfoListModel withWranModel:wranUndealModel withHandLogModel:handLogModel];
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

#pragma mark 填充故障信息
- (void)fullWranInfo {
    
    _nameTF.text = _wranUndealModel.deviceName;
    _nameTF.enabled = NO;
    
    _locationTF.text = _wranUndealModel.alarmLocation;
//    _locationTF.enabled = NO;
    
    _describeTV.text = _wranUndealModel.alarmInfo;
    _tvMsgLabel.hidden = YES;
//    _describeTV.editable = NO;
    
    _idTF.enabled = NO;
}

#pragma mark 填充工单信息
- (void)fullBillInfo:(BillListModel *)billListModel withWranModel:(WranUndealModel *)wranUndealModel withHandLogModel:(HandLogModel *)handLogModel{
    _nameTF.text = [NSString stringWithFormat:@"%@", wranUndealModel.deviceName];
    if(billListModel.deviceId != nil && ![billListModel.deviceId isKindOfClass:[NSNull class]]){
        _idTF.text = [NSString stringWithFormat:@"%@", billListModel.deviceId];
    }
    _locationTF.text = [NSString stringWithFormat:@"%@", wranUndealModel.alarmLocation];
    _describeTV.text = [NSString stringWithFormat:@"%@", billListModel.alarmContent];
    _tvMsgLabel.hidden = YES;
    
    if(billListModel.expectDate != nil && ![billListModel.expectDate isKindOfClass:[NSNull class]]){
        _timeLabel.text = [NSString stringWithFormat:@"%@", [self timeForTimeStr:billListModel.expectDate]];
        _timeLabel.textColor = [UIColor blackColor];

        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *inputDate = [dateFormat dateFromString:billListModel.expectDate];
        
        _completeDate = inputDate;
    }
    if(billListModel.repairName != nil && ![billListModel.repairName isKindOfClass:[NSNull class]]){
        _repairManTF.text = [NSString stringWithFormat:@"%@", billListModel.repairName];
    }
    _sendManTF.text = [NSString stringWithFormat:@"%@", billListModel.createrName];
    if(billListModel.remark != nil && ![billListModel.remark isKindOfClass:[NSNull class]]){
        _remarksTF.text = [NSString stringWithFormat:@"%@", billListModel.remark];
    }
    if(handLogModel.handleImage != nil && ![handLogModel.handleImage isKindOfClass:[NSNull class]]){
        [_resultImgView sd_setImageWithURL:[NSURL URLWithString:handLogModel.handleImage]];
        _resultImgView.contentMode = UIViewContentModeScaleAspectFit;
        _resultImgView.clipsToBounds = YES;
    }
    
}
- (NSString *)timeForTimeStr:(NSString *)timeStr {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *expDate = [dateFormat dateFromString:timeStr];
    
    NSDateFormatter *inputDateFormat = [[NSDateFormatter alloc] init];
    [inputDateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *inputStr = [inputDateFormat stringFromDate:expDate];
    
    return inputStr;
}

- (void)closeTextfieldEnable {
    _nameTF.enabled = NO;
    _locationTF.enabled = NO;
    _describeTV.editable = NO;
    _remarksTF.enabled = NO;
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_createBottomView {
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, KScreenHeight - kTopHeight - 60, KScreenWidth, 60)];
    _bottomView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:_bottomView];
    
    NSString *leftTitle = @"";
    if(_appointState == AppointUnDeal){
        leftTitle = @"修改派单";
    }else if (_appointState == AppointComplete) {
        leftTitle = @"重新维修";
    }
    UIButton *bottomLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    bottomLeftButton.frame = CGRectMake(0, 0, KScreenWidth/2, _bottomView.height);
    [bottomLeftButton setBackgroundImage:[UIImage imageNamed:@"scene_all_close_bg"] forState:UIControlStateNormal];
    [bottomLeftButton setTitle:leftTitle forState:UIControlStateNormal];
    [bottomLeftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bottomLeftButton addTarget:self action:@selector(bottomLeftAction) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:bottomLeftButton];
    
    NSString *rightTitle = @"";
    if(_appointState == AppointUnDeal){
        rightTitle = @"立即派单";
    }else if (_appointState == AppointComplete) {
        rightTitle = @"确认完成";
    }
    UIButton *bottomRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    bottomRightButton.frame = CGRectMake(KScreenWidth/2, 0, KScreenWidth/2, _bottomView.height);
    bottomRightButton.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    [bottomRightButton setTitle:rightTitle forState:UIControlStateNormal];
    [bottomRightButton setTitleColor:[UIColor colorWithHexString:@"#CCFF00"] forState:UIControlStateNormal];
    [bottomRightButton addTarget:self action:@selector(bottomRightAction) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:bottomRightButton];
    
}

#pragma mark 下方左边按钮点击事件
- (void)bottomLeftAction {
    if(_appointState == AppointComplete){
        // 重新维修 驳回
        [_rejectBillView showRejectView:_billListModel.orderId];
        
        self.tableView.contentOffset = CGPointMake(0, 0);
        self.tableView.scrollEnabled = NO;
    }
}

#pragma mark 下方右边按钮点击事件
- (void)bottomRightAction {
    if(_appointState == AppointComplete){
        // 确认完成
        UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"此故障是否确认维修完成" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确认完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self confirmComplete];
        }];
        [alertCon addAction:cancel];
        [alertCon addAction:confirm];
        [self presentViewController:alertCon animated:YES completion:nil];
        
    }
}
#pragma mark 确认完成
- (void)confirmComplete {
    NSString *urlStr = [NSString stringWithFormat:@"%@/deviceAlarm/confirmOrder", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:_billListModel.orderId forKey:@"orderId"];
    [paramDic setObject:@"" forKey:@"remark"];
    
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            // 确认完成 成功
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BillCompleteConfirm" object:nil userInfo:@{@"orderId":_billListModel.orderId}];
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

#pragma mark 搜索按钮
- (IBAction)searchAction:(id)sender {
    if(_appointState == AppointRepairing || _appointState == AppointComplete || _appointState == AppointClose){
        return;
    }
    InquiryDeviceViewController *inquDeceiceVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"InquiryDeviceViewController"];
    inquDeceiceVC.selDeviceDelegate = self;
    [self.navigationController pushViewController:inquDeceiceVC animated:YES];
}
#pragma mark 选择维修人
- (IBAction)chooseRepairsPeopleBtnAction:(id)sender {
    if(_appointState == AppointRepairing || _appointState == AppointComplete || _appointState == AppointClose){
        return;
    }
    RepairsPeopleViewController *chooseRepPeopleVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"RepairsPeopleViewController"];
    chooseRepPeopleVC.selRepairManDelegate = self;
    [self.navigationController pushViewController:chooseRepPeopleVC animated:YES];
}

#pragma mark 提交维修派单
- (IBAction)submitAction:(id)sender {
    if(_nameTF.text == nil || _nameTF.text.length <= 0){
        [self showHint:@"请填写故障设备名称"];
        return;
    }
    if(_locationTF.text == nil || _locationTF.text.length <= 0){
        [self showHint:@"请填写设备位置"];
        return;
    }
    if(_describeTV.text == nil || _describeTV.text.length <= 0){
        [self showHint:@"请填写故障描述"];
        return;
    }
    if(_completeDate == nil){
        [self showHint:@"请选择期望完成时间"];
        return;
    }
    if(_repairManTF.text == nil || _repairManTF.text.length <= 0){
        [self showHint:@"请选择维修人"];
        return;
    }
    if(_remarksTF.text == nil || _remarksTF.text.length <= 0){
        [self showHint:@"请填写派单备注"];
        return;
    }
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    
    NSString *urlStr = @"";
    if(_appointState == AppointSend){
        // 故障/直接填写派单
        urlStr = [NSString stringWithFormat:@"%@/deviceAlarm/alarmOrder", Main_Url];
    }else if(_appointState == AppointUnDeal){
        // 被驳回，待派单 再派单
        urlStr = [NSString stringWithFormat:@"%@/deviceAlarm/distributeOrder", Main_Url];
        [paramDic setObject:_billListModel.orderId forKey:@"orderId"];
        [paramDic setObject:_billListModel.alarmId forKey:@"alarmId"];
    }
    
    if(_wranUndealModel != nil && _wranUndealModel.alarmId != nil){
        [paramDic setObject:_wranUndealModel.alarmId forKey:@"alarmId"];
    }
    
    [paramDic setObject:_nameTF.text forKey:@"deviceName"];
    if(_idTF.text != nil && _idTF.text.length > 0){
        [paramDic setObject:_idTF.text forKey:@"deviceId"];
    }
    [paramDic setObject:_locationTF.text forKey:@"alarmLocation"];
    [paramDic setObject:_describeTV.text forKey:@"alarmInfo"];
    if(_completeDate != nil){
        NSString *timeStr = [self formatTimeStr:@"yyyy-MM-dd" withDate:_completeDate];
        [paramDic setObject:timeStr forKey:@"expectDate"];
    }
    [paramDic setObject:_remarksTF.text forKey:@"remark"];
    [paramDic setObject:_repairsManModel.USER_ID forKey:@"repairId"];
    [paramDic setObject:_repairsManModel.USER_NAME forKey:@"repairName"];
    
    NSString *paramStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param" : paramStr};
    
    [self showHudInView:self.view hint:@"" yOffset:self.tableView.contentOffset.y];
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            // 派单成功刷新故障列表
            if(_appointState == AppointSend){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"WranPostSuccess" object:nil];
            }else if(_appointState == AppointUnDeal){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ReReportSuccess" object:nil userInfo:@{@"orderId":_billListModel.orderId}];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        NSString *message = responseObject[@"message"];
        if(message != nil && ![message isKindOfClass:[NSNull class]]) {
            [self showHint:message];
        }
    } failure:^(NSError *error) {
        [self hideHud];
        [self showHint:KRequestFailMsg];
    }];
    
}

- (NSString *)formatTimeStr:(NSString *)format withDate:(NSDate *)date {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormat setDateFormat:format];
    NSString *inputStr = [dateFormat stringFromDate:date];
    return inputStr;
}

#pragma mark UITableView 协议
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 1:
            return 0.1;
            break;
            
        case 3:
            return 213;
            break;
            
        case 8:
            if(_appointState == AppointComplete || _appointState == AppointClose){
                return 200;
            }else {
                return 0.1;
            }
            break;
            
        default:
            return 75;
            break;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_appointState == AppointRepairing || _appointState == AppointComplete || _appointState == AppointClose){
        return;
    }
    switch (indexPath.row) {
        case 1:
            // 设备id
            [self searchAction:nil];
            break;
            
        case 4:
            // 期望完成时间
            [self selTimePicker];
            break;
            
        default:
            break;
    }
}

- (void)selTimePicker {
    // 期望完成时间 选择器
    WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDay scrollToDate:[NSDate date] CompleteBlock:^(NSDate *selectDate) {
        NSString *date = [selectDate stringWithFormat:@"yyyy-MM-dd"];
        _timeLabel.text = date;
        _timeLabel.textColor = [UIColor blackColor];
        
        _completeDate = selectDate;
    }];
    datepicker.dateLabelColor = [UIColor colorWithHexString:@"1B82D1"];//年-月-日-时-分 颜色
    datepicker.datePickerColor = [UIColor blackColor];//滚轮日期颜色
    datepicker.doneButtonColor = [UIColor colorWithHexString:@"1B82D1"];//确定按钮的颜色
    datepicker.yearLabelColor = [UIColor clearColor];//大号年份字体颜色
    datepicker.minLimitDate = [NSDate date];;
    [datepicker show];
}

#pragma mark UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *tvString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if(tvString.length <= 0){
        _tvMsgLabel.hidden = NO;
    }else {
        _tvMsgLabel.hidden = YES;
    }
    
    if(tvString.length > KInputMaxLength){
        return NO;
    }else {
        return YES;
    }
}

- (void)endEdit {
    [self.view endEditing:YES];
}

#pragma mark UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string {
    NSString *textString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(textString.length > KInputMaxLength){
        return NO;
    }else {
        return YES;
    }
}

#pragma mark 选择维修人协议selRepairManDelegate
- (void)selRepairMan:(RepairsManModel *)repairsManModel {
    _repairsManModel = repairsManModel;
    
    _repairManTF.text = repairsManModel.USER_NAME;
}

#pragma mark 选择设备ID协议selDeviceDelegate
- (void)selDevice:(DeviceInfoModel *)deviceInfoModel {
    _deviceInfoModel = deviceInfoModel;
    
    _nameTF.text = [NSString stringWithFormat:@"%@", deviceInfoModel.DEVICE_NAME];
    _idTF.text = [NSString stringWithFormat:@"%@", deviceInfoModel.DEVICE_ID];
    _locationTF.text = [NSString stringWithFormat:@"%@", deviceInfoModel.DEVICE_ADDR];
}

#pragma mark 解决手势冲突
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        [self endEdit];
        return NO;
    }
    return YES;
}

#pragma mark 驳回回调
- (void)cancel {
    self.tableView.scrollEnabled = YES;
}

- (void)confirmReject:(NSString *)orderId withRemark:(NSString *)remark {
    // 驳回
    NSString *urlStr = [NSString stringWithFormat:@"%@/deviceAlarm/rejectOrderByAssignor", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:orderId forKey:@"orderId"];
    [paramDic setObject:remark forKey:@"remark"];
    
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            [_rejectBillView hidRejectView];
            
            [self.navigationController popViewControllerAnimated:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RejectCompleteBillSuccess" object:nil userInfo:@{@"orderId":orderId}];
        }
        NSString *message = responseObject[@"message"];
        if(message != nil && ![message isKindOfClass:[NSNull class]]){
            [self showHint:message];
        }
    } failure:^(NSError *error) {
        [self showHint:KRequestFailMsg];
    }];
}

@end
