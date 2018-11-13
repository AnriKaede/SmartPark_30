//
//  AppointMentParkCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/6/7.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "AppointMentParkCell.h"

@implementation AppointMentParkCell
{
    __weak IBOutlet UIButton *_cancelFlagBt;
    
    __weak IBOutlet NSLayoutConstraint *_carNoLeft;
    
    __weak IBOutlet UILabel *_carNoLabel;
    
    __weak IBOutlet UIImageView *_stateImgView;
    
    __weak IBOutlet UILabel *_parkNameLabel;
    
    __weak IBOutlet UILabel *_uaernameLabel; // name(
    __weak IBOutlet UILabel *_phoneLabel; // name)
    
    __weak IBOutlet UILabel *_aptTimeLabel;
    
    __weak IBOutlet UILabel *_laterTimeLabel;
    
    __weak IBOutlet UILabel *_remarkLabel;
    
    __weak IBOutlet UIButton *_cancelAptBt;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _cancelAptBt.layer.cornerRadius = 6;
    _cancelAptBt.layer.borderWidth = 0.8;
    _cancelAptBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
}

- (void)setIsCancelApt:(BOOL)isCancelApt {
    _isCancelApt = isCancelApt;
    
    NSString *status = _aptListModel.orderModel.status;
    if(isCancelApt && status != nil && ![status isKindOfClass:[NSNull class]] && [status isEqualToString:@"0"]){
        _cancelFlagBt.hidden = NO;
        _carNoLeft.constant = 40;
    }else {
        _cancelFlagBt.hidden = YES;
        _carNoLeft.constant = 10;
    }
}

- (void)setAptListModel:(AptListModel *)aptListModel {
    _aptListModel = aptListModel;
    
    _cancelFlagBt.selected = aptListModel.isSelect;
    
    _carNoLabel.text = [NSString stringWithFormat:@"%@", aptListModel.orderModel.carNo];
    
    // 设置默认状态
    _stateImgView.hidden = YES;
    _cancelAptBt.hidden = NO;
    // 订单状态 0预约中 1入场 2取消 3超时取消 4完成
    if(aptListModel.orderModel.status != nil && ![aptListModel.orderModel.status isKindOfClass:[NSNull class]]){
        _stateImgView.hidden = NO;
        if([aptListModel.orderModel.status isEqualToString:@"0"]){
            _stateImgView.image = [UIImage imageNamed:@"apt_list_ing"];
            
            [_cancelAptBt setTitle:@"取消预约" forState:UIControlStateNormal];
            [_cancelAptBt setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
            _cancelAptBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
        }else if([aptListModel.orderModel.status isEqualToString:@"2"] || [aptListModel.orderModel.status isEqualToString:@"3"]){
            _stateImgView.image = [UIImage imageNamed:@"apt_list_cancel"];
            
            _cancelAptBt.hidden = YES;
            /*
            [_cancelAptBt setTitle:@"订单取消" forState:UIControlStateNormal];
            [_cancelAptBt setTitleColor:[UIColor colorWithHexString:@"#A3A3A3"] forState:UIControlStateNormal];
            _cancelAptBt.layer.borderColor = [UIColor colorWithHexString:@"#A3A3A3"].CGColor;
             */
        }else if([aptListModel.orderModel.status isEqualToString:@"1"]){
            _stateImgView.image = [UIImage imageNamed:@"carin"];
            
            if(aptListModel.parkingAreaModel.parkingAreaId != nil && ![aptListModel.parkingAreaModel.parkingAreaId isKindOfClass:[NSNull class]] && [aptListModel.parkingAreaModel.parkingAreaId isEqualToString:@"2001"]){
                // 前坪地锁车位
                _cancelAptBt.hidden = YES;
            }else {
                _cancelAptBt.hidden = NO;
                [_cancelAptBt setTitle:@"开锁出场" forState:UIControlStateNormal];
            }
            [_cancelAptBt setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
            _cancelAptBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
        }else if ([aptListModel.orderModel.status isEqualToString:@"4"]) {
            _stateImgView.image = [UIImage imageNamed:@"carout"];    // 已完成
            
            _cancelAptBt.hidden = YES;
//            [_cancelAptBt setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
//            _cancelAptBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
        }
    }
    
    _parkNameLabel.text = [NSString stringWithFormat:@"%@", aptListModel.orderModel.parkingSpaceName];
    
    _uaernameLabel.text = [NSString stringWithFormat:@"%@(", aptListModel.orderModel.custName];
    _phoneLabel.text = [NSString stringWithFormat:@"%@)", aptListModel.orderModel.phone];    // 暂无参数
    
    _aptTimeLabel.text = [NSString stringWithFormat:@"%@", aptListModel.orderModel.orderTime];
    _laterTimeLabel.text = [NSString stringWithFormat:@"%@", aptListModel.orderModel.invalidTime];
    if(aptListModel.orderModel.remark != nil && ![aptListModel.orderModel.remark isKindOfClass:[NSNull class]]){
        _remarkLabel.text = [NSString stringWithFormat:@"%@", aptListModel.orderModel.remark];
    }else {
        _remarkLabel.text = @"-";
    }
}

- (IBAction)cancelFlagAction:(id)sender {
    _cancelFlagBt.selected = !_cancelFlagBt.selected;
    
    _aptListModel.isSelect = !_aptListModel.isSelect;
}

- (IBAction)cancelAptAction:(id)sender {
    if(_aptListModel.orderModel.status != nil && ![_aptListModel.orderModel.status isKindOfClass:[NSNull class]]){
        if([_aptListModel.orderModel.status isEqualToString:@"0"]){
            // 取消预约
            if(_spaceOpearteDelegate && [_spaceOpearteDelegate respondsToSelector:@selector(cancelAptOpearte:)]){
                [_spaceOpearteDelegate cancelAptOpearte:_aptListModel];
            }
        }else if([_aptListModel.orderModel.status isEqualToString:@"1"]){
            // 开锁出场
            if(_spaceOpearteDelegate && [_spaceOpearteDelegate respondsToSelector:@selector(openLockOpearte:)]){
                [_spaceOpearteDelegate openLockOpearte:_aptListModel];
            }
        }
    }
}

@end
