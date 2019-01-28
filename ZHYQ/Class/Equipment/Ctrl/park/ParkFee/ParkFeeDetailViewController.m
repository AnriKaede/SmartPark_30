//
//  ParkFeeDetailViewController.m
//  ZHYQ
//
//  Created by coder on 2018/10/24.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "ParkFeeDetailViewController.h"

@interface ParkFeeDetailViewController ()
{
    __weak IBOutlet UILabel *_valueLabel;
    __weak IBOutlet UILabel *_timeLabel;
    __weak IBOutlet UIImageView *_typeImgView;
    __weak IBOutlet UILabel *_payTypeLabel;
    __weak IBOutlet UILabel *_carNoLabel;
    
    __weak IBOutlet UILabel *_payCountLabel;
    __weak IBOutlet UILabel *_orderCodeLabel;
}
@end

@implementation ParkFeeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNav];
    
    [self _initView];
}

-(void)initNav{
    self.title = @"收费详情";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)_initView {
    if(_parkConsumeModel.payTime != nil){
        NSDate *stampDate = [NSDate dateWithTimeIntervalSince1970:_parkConsumeModel.payTime.doubleValue/1000.0];
        NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
        [stampFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        _timeLabel.text = [stampFormatter stringFromDate:stampDate];
    }
    
    _typeImgView.image = [UIImage imageNamed:[self payType:_parkConsumeModel.payType isImg:YES]];
    _payTypeLabel.text = [NSString stringWithFormat:@"%@", [self payType:_parkConsumeModel.payType isImg:NO]];
    if(_parkConsumeModel.totalFee.floatValue > 0){
        _valueLabel.text = [NSString stringWithFormat:@"+%.2f", _parkConsumeModel.totalFee.floatValue/100];
    }else {
        _valueLabel.text = [NSString stringWithFormat:@"%.2f", _parkConsumeModel.totalFee.floatValue/100];
    }
    _carNoLabel.text = [NSString stringWithFormat:@"缴费车辆 : %@", _parkConsumeModel.carNo];
    _orderCodeLabel.text = [NSString stringWithFormat:@"%@", _parkConsumeModel.orderId];
    
    NSString *countStr = [_payTypeLabel.text substringWithRange:NSMakeRange(0, _payTypeLabel.text.length - 2)];
    _payCountLabel.text = [NSString stringWithFormat:@"%@", countStr];
}

- (NSString *)payType:(NSString *)payType isImg:(BOOL)isImg {
    NSString *payStr = @"";
    if(payType != nil && ![payType isKindOfClass:[NSNull class]]){
        // 010微信，020 支付宝，060qq钱包，080京东钱包，090口碑，100翼支付，110银联二维码 000现金
        if([payType isEqualToString:@"010"]){
            if(isImg){
                payStr = @"park_payment_wechat";
            }else {
                payStr = @"微信缴费";
            }
        }else if([payType isEqualToString:@"020"]){
            if(isImg){
                payStr = @"park_payment_alipay";
            }else {
                payStr = @"支付宝缴费";
            }
        }else if([payType isEqualToString:@"100"]){
            if(isImg){
                payStr = @"park_payment_yi";
            }else {
                payStr = @"翼支付缴费";
            }
        }else if([payType isEqualToString:@"000"]){
            if(isImg){
                payStr = @"park_payment_cash";
            }else {
                payStr = @"现金交易";
            }
        }
    }
    return payStr;
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
