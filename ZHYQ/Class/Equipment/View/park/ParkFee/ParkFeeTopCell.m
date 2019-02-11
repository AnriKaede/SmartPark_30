//
//  ParkFeeTopCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/10/24.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "ParkFeeTopCell.h"

@implementation ParkFeeTopCell
{
    __weak IBOutlet UIView *_topBgView;
    __weak IBOutlet UIView *_ringBgView;
    
    __weak IBOutlet UIView *_bgView;
    
    __weak IBOutlet UILabel *_dateTitleLabel;
    __weak IBOutlet UILabel *_ratioMsgLabel;
    __weak IBOutlet UILabel *_numLabel;
    __weak IBOutlet UILabel *_ratioLabel;    // %
    __weak IBOutlet UIImageView *_upDownImgView;
    
    __weak IBOutlet UILabel *_wechatLabel;
    __weak IBOutlet UILabel *_alipayLabel;
    __weak IBOutlet UILabel *_yipayLabel;
    __weak IBOutlet UILabel *_cashLabel;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
//        [self _initView];
    }
    return self;
}

- (void)_initView {
    NSArray *btTitles = @[@"日", @"周", @"月"];
    //    NSArray *btTitles = @[@"日"];
    [btTitles enumerateObjectsUsingBlock:^(NSString *btTitle, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *dateBt = [UIButton buttonWithType:UIButtonTypeCustom];
        dateBt.frame = CGRectMake(KScreenWidth - 130 + idx*40, 10, 40, 25);
        //        dateBt.frame = CGRectMake(KScreenWidth - 50 + idx*40, 10, 40, 25);
        [dateBt setTitle:btTitle forState:UIControlStateNormal];
        dateBt.tag = 100 + idx;
        dateBt.layer.borderColor = [UIColor colorWithHexString:@"#D1E6F6"].CGColor;
        dateBt.layer.borderWidth = 1;
        if(idx == 0){
            dateBt.backgroundColor = [UIColor colorWithHexString:@"#D1E6F6"];
            [dateBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else {
            dateBt.backgroundColor = [UIColor clearColor];
            [dateBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        [dateBt addTarget:self action:@selector(dateFilterAction:) forControlEvents:UIControlEventTouchUpInside];
        [_topBgView addSubview:dateBt];
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _topBgView.backgroundColor = CNavBgColor;
    _bgView.backgroundColor = CNavBgColor;
    
    _bgView.layer.cornerRadius = _bgView.width/2;
    _bgView.backgroundColor = [UIColor clearColor];
    
    _ringBgView.layer.cornerRadius = _ringBgView.width/2;
    _ringBgView.backgroundColor = [UIColor clearColor];
    _ringBgView.layer.borderColor = [UIColor colorWithHexString:@"5BD3FF"].CGColor;
    _ringBgView.layer.borderWidth = 5;
    
    // 添加渐变色
    [NavGradient viewAddGradient:_topBgView];
    
    UIButton *bt = [_topBgView viewWithTag:100];
    if(!bt){
        [self _initView];
    }
}

#pragma mark 柱状图按日期筛选
- (void)dateFilterAction:(UIButton *)dateBt {
    [self changeBtState:dateBt];
    
    switch (dateBt.tag - 100) {
        case 0:
            // 日
            [self filter:FilterDay];
            break;
        case 1:
            // 周
            [self filter:FilterWeek];
            break;
        case 2:
            // 月
            [self filter:FilterMonth];
            break;
            
    }
}
- (void)changeBtState:(UIButton *)dateBt {
    for (int i=0; i<3; i++) {
        UIButton *button = [_topBgView viewWithTag:100 + i];
        if(button == dateBt){
            button.backgroundColor = [UIColor colorWithHexString:@"#D1E6F6"];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else {
            button.backgroundColor = [UIColor clearColor];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
    
}
- (void)filter:(FilterDateStyle)style {
    if(_filterDelegate && [_filterDelegate respondsToSelector:@selector(filterDelegate:)]){
        [_filterDelegate filterDelegate:style];
    }
}

- (void)setFilterDateStyle:(FilterDateStyle)filterDateStyle {
    _filterDateStyle = filterDateStyle;
    
    UIButton *bt = [_topBgView viewWithTag:100+filterDateStyle];
    [self changeBtState:bt];
    
    switch (filterDateStyle) {
        case FilterDay:
            _dateTitleLabel.text = @"今日收入";
            _ratioMsgLabel.text = @"日环比";
            break;
        case FilterWeek:
            _dateTitleLabel.text = @"本周收入";
            _ratioMsgLabel.text = @"周环比";
            break;
        case FilterMonth:
            _dateTitleLabel.text = @"本月收入";
            _ratioMsgLabel.text = @"月环比";
            break;
    }
}

#pragma mark 设置数据
- (void)setParkFeeCountModel:(ParkFeeCountModel *)parkFeeCountModel {
    _parkFeeCountModel = parkFeeCountModel;
    
    _numLabel.text = [NSString stringWithFormat:@"%.2f", parkFeeCountModel.totalFee.floatValue/100];
    
    _ratioLabel.text = [NSString stringWithFormat:@"%@%%", parkFeeCountModel.dodValue];
    
    _wechatLabel.text = @"";
    _alipayLabel.text = @"";
    _yipayLabel.text = @"";
    _cashLabel.text = @"";
    
    [parkFeeCountModel.items enumerateObjectsUsingBlock:^(ParkFeePayModel *payModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if(payModel.payType != nil && ![payModel.payType isKindOfClass:[NSNull class]]){
            if([payModel.payType isEqualToString:@"010"]){
                _wechatLabel.text = [NSString stringWithFormat:@"%.2f 元", payModel.totalFee.floatValue/100];
            }else if([payModel.payType isEqualToString:@"020"]){
                _alipayLabel.text = [NSString stringWithFormat:@"%.2f 元", payModel.totalFee.floatValue/100];
            }else if([payModel.payType isEqualToString:@"100"]){
                _yipayLabel.text = [NSString stringWithFormat:@"%.2f 元", payModel.totalFee.floatValue/100];
            }else if([payModel.payType isEqualToString:@"000"]){
                _cashLabel.text = [NSString stringWithFormat:@"%.2f 元", payModel.totalFee.floatValue/100];
            }
        }
    }];
}

@end
