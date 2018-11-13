//
//  ReportWarnViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/17.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "ReportWarnViewController.h"
#import "InquiryDeviceViewController.h"
#import "DeviceInfoModel.h"

@interface ReportWarnViewController ()<UITextViewDelegate, SelDeviceDelegate>
{
    __weak IBOutlet UITextField *_nameLabel;
    __weak IBOutlet UITextField *_locationLabel;
    __weak IBOutlet UITextView *_describeTV;
    
    __weak IBOutlet UIButton *_cerBt;
    UILabel *_msgLabel;
}
@end

@implementation ReportWarnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
}

- (void)_initView {
    self.title = @"故障报修";
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 50, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _describeTV.delegate = self;
    
    _msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 9, _describeTV.width - 4, 17)];
    _msgLabel.text = @"请简单描述物品故障情况";
    _msgLabel.textColor = [UIColor colorWithHexString:@"#c7c7cd"];
    _msgLabel.font = [UIFont systemFontOfSize:17];
    _msgLabel.textAlignment = NSTextAlignmentLeft;
    [_describeTV addSubview:_msgLabel];
    
    _cerBt.layer.cornerRadius = 4;
    _cerBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    _cerBt.layer.borderWidth = 0.8;
}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *tvString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if(tvString.length <= 0){
        _msgLabel.hidden = NO;
    }else {
        _msgLabel.hidden = YES;
    }
    
    return YES;
}

#pragma mark 提交报修
- (IBAction)submitAction:(id)sender {
    if(_nameLabel.text <= 0){
        [self showHint:@"请输入故障设备名"];
        return;
    }
    if(_locationLabel.text <= 0){
        [self showHint:@"请输入故障设备位置"];
        return;
    }
    if(_describeTV.text <= 0){
        [self showHint:@"请输入故障描述"];
        return;
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/deviceAlarm/report", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:KAdminUserId];
    if(userId != nil){
        [paramDic setObject:userId forKey:@"reporter"];
    }
    NSString *loginName = [[NSUserDefaults standardUserDefaults] objectForKey:KLoginUserName];
    if(loginName != nil){
        [paramDic setObject:loginName forKey:@"reportName"];
    }
    
    [paramDic setObject:_nameLabel.text forKey:@"deviceName"];
    [paramDic setObject:_describeTV.text forKey:@"alarmInfo"];
    [paramDic setObject:_locationLabel.text forKey:@"alarmLocation"];
    
    NSString *paramStr = [Utils convertToJsonData:paramDic];
    NSDictionary *params = @{@"param":paramStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            // 发送添加故障通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WranPostSuccess" object:nil];
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

- (IBAction)queryEquipment:(id)sender {
    InquiryDeviceViewController *inquDeceiceVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"InquiryDeviceViewController"];
    inquDeceiceVC.selDeviceDelegate = self;
    [self.navigationController pushViewController:inquDeceiceVC animated:YES];
}

- (void)selDevice:(DeviceInfoModel *)deviceInfoModel {
    _nameLabel.text = [NSString stringWithFormat:@"%@", deviceInfoModel.DEVICE_NAME];
    _locationLabel.text = [NSString stringWithFormat:@"%@", deviceInfoModel.DEVICE_ADDR];
}

@end
