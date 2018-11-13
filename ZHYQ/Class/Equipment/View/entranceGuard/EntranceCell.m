//
//  EntranceCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/25.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "EntranceCell.h"

@implementation EntranceCell
{
    __weak IBOutlet UIView *_topView;
    
    __weak IBOutlet UIView *_nameBgView;
    
    __weak IBOutlet UIImageView *_stateImgView;
    
    __weak IBOutlet UILabel *_nameLabel;
    
    __weak IBOutlet UIView *_infoBgView;
    
    __weak IBOutlet UILabel *_stateLabel;
    __weak IBOutlet UIView *_authorityView;
    __weak IBOutlet UIView *_recordView;
    
    __weak IBOutlet UIImageView *rightView;
    
    __weak IBOutlet UILabel *_outLabel;
    __weak IBOutlet UIButton *_outBt;
    __weak IBOutlet NSLayoutConstraint *_outBtHeight;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITapGestureRecognizer *authorityTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(authorityAction)];
    [_authorityView addGestureRecognizer:authorityTap];
    
    UITapGestureRecognizer *recordTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openRecord)];
    [_recordView addGestureRecognizer:recordTap];
}

- (void)setModel:(DoorModel *)model {
    _model = model;
    
    if(model.DEVICE_NAME != nil && ![model.DEVICE_NAME isKindOfClass:[NSNull class]]){
        _nameLabel.text = model.DEVICE_NAME;
    }else {
        _nameLabel.text = @"";
    }
    
    if(model.isSpread){
        rightView.hidden = YES;
        _infoBgView.hidden = NO;
        
        _infoBgView.backgroundColor = [UIColor colorWithHexString:@"#F8FCFF"];
        _nameBgView.backgroundColor = [UIColor colorWithHexString:@"#F8FCFF"];
        _topView.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    }else {
        rightView.hidden = NO;
        _infoBgView.hidden = YES;
        
        _infoBgView.backgroundColor = [UIColor whiteColor];
        _nameBgView.backgroundColor = [UIColor whiteColor];
        _topView.backgroundColor = [UIColor whiteColor];
    }
    
    // 当前门禁状态 1 锁门状态 0故障 2开门
    if([model.DOOR_STATUS isEqualToString:@"1"]){
        _stateLabel.text = @"房间锁门中";
        _stateLabel.textColor = [UIColor colorWithHexString:@"#189517"];
        
    }else if([model.DOOR_STATUS isEqualToString:@"2"]){
        _stateLabel.text = @"房间开门中";
        _stateLabel.textColor = [UIColor colorWithHexString:@"#FF4359"];
        
    }else if([model.DOOR_STATUS isEqualToString:@"0"]){
        _stateLabel.text = @"门禁故障";
        _stateLabel.textColor = [UIColor colorWithHexString:@"#FF4359"];
        
    }else {
        _stateLabel.text = @"";
        _stateImgView.image = [UIImage imageNamed:@""];
    }
    
    // 4 普通门禁； 4-1 门禁道闸
    if([model.DEVICE_TYPE isEqualToString:@"4-1"]){
        _stateImgView.image = [UIImage imageNamed:@"gatemachine_close"];
        
        // 闸机有开关两行
        _outLabel.hidden = NO;
        _outBt.hidden = NO;
        _outBtHeight.constant = 60;
        
        if([model.TAGID isEqualToString:@"344"] || [model.TAGID isEqualToString:@"346"]){
            _stateLabel.text = @"自东向西进闸机门";
            _outLabel.text = @"自西向东出闸机门";
        }else {
            _stateLabel.text = @"进闸机门";
            _outLabel.text = @"出闸机门";
        }
        
        _stateLabel.textColor = [UIColor blackColor];
    }else {
        _stateImgView.image = [UIImage imageNamed:@"info_door_close"];
        
        _outLabel.hidden = YES;
        _outBt.hidden = YES;
        _outBtHeight.constant = 0;
        _stateLabel.text = @"房间锁门中";
        _stateLabel.textColor = [UIColor colorWithHexString:@"#189517"];
    }
    
}

// 开锁
- (IBAction)unLock:(id)sender {
    if(_entranceDelegate){
        // 进 2  出 1
        [_entranceDelegate unLockDoor:_model withOperate:@"2"];
    }
}

// 出闸门开锁
- (IBAction)outUnLock:(id)sender {
    [_entranceDelegate unLockDoor:_model withOperate:@"1"];
}

// 权限卡
- (void)authorityAction {
    if(_entranceDelegate){
        [_entranceDelegate viewAuthorityList:_model];
    }
}

// 开门记录
- (void)openRecord {
    if(_entranceDelegate){
        [_entranceDelegate openRecord:_model];
    }
}

@end
