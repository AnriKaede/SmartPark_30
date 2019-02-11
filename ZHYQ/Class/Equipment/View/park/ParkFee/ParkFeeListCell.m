//
//  ParkFeeListCell.m
//  ZHYQ
//
//  Created by coder on 2018/10/24.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "ParkFeeListCell.h"

@implementation ParkFeeListCell
{
    __weak IBOutlet UILabel *_dayTitleLabel;
    __weak IBOutlet UILabel *_timeLabel;
    __weak IBOutlet UIImageView *_typeImgView;
    __weak IBOutlet UILabel *_valueLabel;
    __weak IBOutlet UILabel *_payTypeLabel;
    __weak IBOutlet UILabel *_carNoLabel;   // 缴费车辆 : 湘A 12345
    __weak IBOutlet UILabel *_orderCodeLabel;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setParkConsumeModel:(ParkConsumeModel *)parkConsumeModel {
    _parkConsumeModel = parkConsumeModel;
    
    if(parkConsumeModel.payTime != nil){
        //时间戳转化成时间
        NSDate *stampDate = [NSDate dateWithTimeIntervalSince1970:parkConsumeModel.payTime.doubleValue/1000.0];
        if(stampDate.isToday){
            _dayTitleLabel.text = @"今天";
        }else if (stampDate.isYesterday) {
            _dayTitleLabel.text = @"昨天";
        }else {
            NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
            [stampFormatter setDateFormat:@"yyyy-MM-dd"];
            _dayTitleLabel.text = [NSString stringWithFormat:@"%@", [stampFormatter stringFromDate:stampDate]];
        }
    }else {
        _dayTitleLabel.text = @"";
    }
    
    if(parkConsumeModel.payTime != nil){
        NSDate *stampDate = [NSDate dateWithTimeIntervalSince1970:parkConsumeModel.payTime.doubleValue/1000.0];
        NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
        [stampFormatter setDateFormat:@"HH:mm"];
        _timeLabel.text = [stampFormatter stringFromDate:stampDate];
    }
    
    
    _typeImgView.image = [UIImage imageNamed:[self payType:parkConsumeModel.payType isImg:YES]];
    _payTypeLabel.text = [NSString stringWithFormat:@"%@", [self payType:parkConsumeModel.payType isImg:NO]];
    if(parkConsumeModel.totalFee.floatValue > 0){
        _valueLabel.text = [NSString stringWithFormat:@"+%.2f 元", parkConsumeModel.totalFee.floatValue/100];
    }else {
        _valueLabel.text = [NSString stringWithFormat:@"%.2f 元", parkConsumeModel.totalFee.floatValue/100];
    }
    _carNoLabel.text = [NSString stringWithFormat:@"缴费车辆 : %@", parkConsumeModel.carNo];
    _orderCodeLabel.text = [NSString stringWithFormat:@"订单号 : %@", parkConsumeModel.orderId];
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

@end
