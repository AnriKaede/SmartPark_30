//
//  ParkSpaceCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/6/19.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "ParkSpaceCell.h"

// 车位状态 0空闲 1预占 2已占 3禁止预约 4异常 5 非预约停车
typedef enum {
    ParkSpaceFree = 0,
    ParkSpaceApt,
    ParkSpaceAptStopCar,
    ParkSpaceStop,
    ParkSpaceWran,
    ParkSpaceStopCar
}ParkSpaceState;

@implementation ParkSpaceCell
{
    __weak IBOutlet UIImageView *_iconImgView;
    __weak IBOutlet NSLayoutConstraint *_iconWidth;
    __weak IBOutlet NSLayoutConstraint *_iconHeight;
    
    __weak IBOutlet UILabel *_parkNameLabel;
    
    __weak IBOutlet UILabel *_stateLabel;
    
    __weak IBOutlet UIButton *_topBt;
    __weak IBOutlet NSLayoutConstraint *_topBtTop;
    
    __weak IBOutlet UIButton *_middleBt;
    __weak IBOutlet NSLayoutConstraint *_middleWidth;
    __weak IBOutlet NSLayoutConstraint *_middleLeft;
    
    __weak IBOutlet UIButton *_bottomBt;
    __weak IBOutlet NSLayoutConstraint *_bottomWidth;
    __weak IBOutlet NSLayoutConstraint *_bottomLeft;
    
    __weak IBOutlet UIButton *_advBt;
    __weak IBOutlet NSLayoutConstraint *_advBtWidth;
    
    __weak IBOutlet NSLayoutConstraint *_advBtLeft;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    _topBt.layer.cornerRadius = 6;
    _middleBt.layer.cornerRadius = 6;
    _bottomBt.layer.cornerRadius = 6;
    _advBt.layer.cornerRadius = 6;
    
    _topBt.layer.borderWidth = 0.8;
    _middleBt.layer.borderWidth = 0.8;
    _bottomBt.layer.borderWidth = 0.8;
    _advBt.layer.borderWidth = 0.8;
    _advBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    
}

- (void)setParkSpaceModel:(ParkSpaceModel *)parkSpaceModel {
    _parkSpaceModel = parkSpaceModel;
    
    _iconWidth.constant = 27;
    if([self isFront]){
        _iconHeight.constant = 22;
    }else {
        _iconHeight.constant = 27;
    }
    
    _parkNameLabel.text = parkSpaceModel.parkingSpaceName;
    
    _stateLabel.textColor = [UIColor blackColor];
    
    _middleWidth.constant = 70;
    _middleLeft.constant = 4;
    _bottomWidth.constant = 70;
    _bottomLeft.constant = 4;
    
    // 车位状态 0空闲 1预占 2已占 3禁止预约 4异常 5 非预约停车
    if([parkSpaceModel.parkingStatus isEqualToString:@"0"]){
        _stateLabel.text = @"暂未停车";
        _topBt.hidden = NO;
        _middleBt.hidden = NO;

        [_topBt setTitle:@"开车位" forState:UIControlStateNormal];
        [_middleBt setTitle:@"锁车位" forState:UIControlStateNormal];
        
        _bottomBt.hidden = NO;
        _topBtTop.constant = 12;
        [_bottomBt setTitle:@"禁止预约" forState:UIControlStateNormal];
        
        _topBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
        [_topBt setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
        _middleBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
        [_middleBt setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
        _bottomBt.layer.borderColor = [UIColor colorWithHexString:@"#FF4359"].CGColor;
        [_bottomBt setTitleColor:[UIColor colorWithHexString:@"#FF4359"] forState:UIControlStateNormal];
        
        [self iconWithParkSpaceState:ParkSpaceFree];
    }else if([parkSpaceModel.parkingStatus isEqualToString:@"1"]){
        _stateLabel.text = [NSString stringWithFormat:@"%@已预约", parkSpaceModel.carNo];
        _topBt.hidden = NO;
        [_topBt setTitle:@"取消预约" forState:UIControlStateNormal];
        
        _topBtTop.constant = 50;
        
        _middleBt.hidden = YES;
        _middleWidth.constant = 0;
        _middleLeft.constant = 0;
        _bottomBt.hidden = YES;
        _bottomWidth.constant = 0;
        _bottomLeft.constant = 0;
        
        _topBt.layer.borderColor = [UIColor colorWithHexString:@"#FF4359"].CGColor;
        [_topBt setTitleColor:[UIColor colorWithHexString:@"#FF4359"] forState:UIControlStateNormal];
        
        [self iconWithParkSpaceState:ParkSpaceApt];
    }else if([parkSpaceModel.parkingStatus isEqualToString:@"2"]){
        _stateLabel.text = [NSString stringWithFormat:@"%@已停车", parkSpaceModel.carNo];
        [_topBt setTitle:@"开车位" forState:UIControlStateNormal];
        [_middleBt setTitle:@"锁车位" forState:UIControlStateNormal];
        
        _topBt.hidden = NO;
        _topBtTop.constant = 27;
        _middleBt.hidden = NO;
        _bottomBt.hidden = YES;
        _bottomWidth.constant = 0;
        _bottomLeft.constant = 0;
        
        _topBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
        [_topBt setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
        _middleBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
        [_middleBt setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
        
        [self iconWithParkSpaceState:ParkSpaceAptStopCar];
    }else if([parkSpaceModel.parkingStatus isEqualToString:@"3"]){
        _stateLabel.text = @"禁止预约";
        _stateLabel.textColor = [UIColor colorWithHexString:@"#FF4359"];
        _topBt.hidden = NO;
        _middleBt.hidden = NO;
        _bottomBt.hidden = NO;

        [_topBt setTitle:@"开车位" forState:UIControlStateNormal];
        [_middleBt setTitle:@"锁车位" forState:UIControlStateNormal];
        [_bottomBt setTitle:@"开放预约" forState:UIControlStateNormal];
        _topBtTop.constant = 12;
        
        _topBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
        [_topBt setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
        _middleBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
        [_middleBt setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
        _bottomBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
        [_bottomBt setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
        
        [self iconWithParkSpaceState:ParkSpaceStop];
    }else if([parkSpaceModel.parkingStatus isEqualToString:@"5"]){
        _stateLabel.text = [NSString stringWithFormat:@"已停车"];
        [_topBt setTitle:@"开车位" forState:UIControlStateNormal];
        [_middleBt setTitle:@"锁车位" forState:UIControlStateNormal];
        
        _topBt.hidden = NO;
        _topBtTop.constant = 27;
        _middleBt.hidden = NO;
        _bottomBt.hidden = YES;
        _bottomWidth.constant = 0;
        _bottomLeft.constant = 0;
        
        _topBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
        [_topBt setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
        _middleBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
        [_middleBt setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
        
        [self iconWithParkSpaceState:ParkSpaceStopCar];
    }else {
        _stateLabel.text = @"异常";
        _topBt.hidden = YES;
        _middleBt.hidden = YES;
        _bottomBt.hidden = YES;
        
        [self iconWithParkSpaceState:ParkSpaceWran];
    }
    
    if([self isFront]){
        // 前坪地锁车位
        _advBtLeft.constant = 0;
        _advBtWidth.constant = 0;
        _advBt.hidden = YES;
    }else {
        // 地下车库
        _advBtLeft.constant = 4;
        _advBtWidth.constant = 70;
        _advBt.hidden = NO;
        
        if(parkSpaceModel.ledStatus != nil && ![parkSpaceModel.ledStatus isKindOfClass:[NSNull class]] && [parkSpaceModel.ledStatus isEqualToString:@"1"]){
            // 开
            [_advBt setTitle:@"关广告灯" forState:UIControlStateNormal];
            [_advBt setTitleColor:[UIColor colorWithHexString:@"#FF4359"] forState:UIControlStateNormal];
            _advBt.layer.borderColor = [UIColor colorWithHexString:@"#FF4359"].CGColor;
        }else {
            // 关
            [_advBt setTitle:@"开广告灯" forState:UIControlStateNormal];
            [_advBt setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
            _advBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
        }
        
    }
}
- (BOOL)isFront {
    if(_parkSpaceModel.parkingAreaId != nil && ![_parkSpaceModel.parkingAreaId isKindOfClass:[NSNull class]] && [_parkSpaceModel.parkingAreaId isEqualToString:@"2001"]){
        // 前坪地锁车位
        return YES;
    }else {
        // 地下车库
        return NO;
    }
}

// 根据状态改变图标
- (void)iconWithParkSpaceState:(ParkSpaceState)parkSpaceState {
    switch (parkSpaceState) {
        case ParkSpaceFree:
        {
            if([self isFront]){
                _iconImgView.image = [UIImage imageNamed:@"down_lock_free"];
            }else {
                _iconImgView.image = [UIImage imageNamed:@"up_lock_free"];
            }
            break;
        }
        case ParkSpaceApt:
        {
            if([self isFront]){
                _iconImgView.image = [UIImage imageNamed:@"down_lock_apt"];
            }else {
                _iconImgView.image = [UIImage imageNamed:@"up_lock_apt"];
            }
            break;
        }
        case ParkSpaceAptStopCar:
        {
            if([self isFront]){
                _iconImgView.image = [UIImage imageNamed:@"down_lock_stopCar"];
            }else {
                _iconImgView.image = [UIImage imageNamed:@"up_lock_stopCar"];
            }
            break;
        }
        case ParkSpaceStop:
        {
            if([self isFront]){
                _iconImgView.image = [UIImage imageNamed:@"down_lock_stop"];
            }else {
                _iconImgView.image = [UIImage imageNamed:@"up_lock_stop"];
            }
            break;
        }
        case ParkSpaceWran:
        {
            if([self isFront]){
                _iconImgView.image = [UIImage imageNamed:@"down_lock_warn"];
            }else {
                _iconImgView.image = [UIImage imageNamed:@"up_lock_wran"];
            }
            break;
        }
        case ParkSpaceStopCar:
        {
            if([self isFront]){
                _iconImgView.image = [UIImage imageNamed:@"down_lock_occupy"];
            }else {
                _iconImgView.image = [UIImage imageNamed:@"up_lock_occupy"];
            }
            break;
        }
    }
}

- (IBAction)topAction:(id)sender {
    if([_parkSpaceModel.parkingStatus isEqualToString:@"0"] || [_parkSpaceModel.parkingStatus isEqualToString:@"3"] ||
       [_parkSpaceModel.parkingStatus isEqualToString:@"2"] ||
       [_parkSpaceModel.parkingStatus isEqualToString:@"5"]){
        // 开车位锁
        if(_spaceOperateDelegate && [_spaceOperateDelegate respondsToSelector:@selector(openLock:)]){
            [_spaceOperateDelegate openLock:_parkSpaceModel];
        }
    }else if([_parkSpaceModel.parkingStatus isEqualToString:@"1"]){
        // 取消预约
        if(_spaceOperateDelegate && [_spaceOperateDelegate respondsToSelector:@selector(cancelApt:)]){
            [_spaceOperateDelegate cancelApt:_parkSpaceModel];
        }
    }
}

- (IBAction)middleAction:(id)sender {
    // 锁车位锁
    if(_spaceOperateDelegate && [_spaceOperateDelegate respondsToSelector:@selector(lockLock:)]){
        [_spaceOperateDelegate lockLock:_parkSpaceModel];
    }
}


- (IBAction)bottomAction:(id)sender {
    if([_parkSpaceModel.parkingStatus isEqualToString:@"0"]){
        // 禁止预约
        if(_spaceOperateDelegate && [_spaceOperateDelegate respondsToSelector:@selector(prohibitApt:)]){
            [_spaceOperateDelegate prohibitApt:_parkSpaceModel];
        }
    }else if([_parkSpaceModel.parkingStatus isEqualToString:@"3"]){
        // 开放预约
        if(_spaceOperateDelegate && [_spaceOperateDelegate respondsToSelector:@selector(openApt:)]){
            [_spaceOperateDelegate openApt:_parkSpaceModel];
        }
    }
}
- (IBAction)advAction:(id)sender {
    if(_spaceOperateDelegate && [_spaceOperateDelegate respondsToSelector:@selector(operateLedApt:)]){
        [_spaceOperateDelegate operateLedApt:_parkSpaceModel];
    }
}

@end
