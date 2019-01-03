//
//  CommunLockCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/21.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "CommunLockCell.h"
#import "CommncQueryViewController.h"

@implementation CommunLockCell
{
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UILabel *_topStateLabel;
    
    __weak IBOutlet UIView *_bgView;
    
    __weak IBOutlet UILabel *_numLabel;
    __weak IBOutlet UILabel *_stateLabel;
    __weak IBOutlet UILabel *_eqStateLabel;
    __weak IBOutlet UILabel *_wranInfoTitleLabel;
    __weak IBOutlet UILabel *_wranInfoLabel;
    __weak IBOutlet UILabel *_timeTitleLabel;
    __weak IBOutlet UILabel *_timeLabel;
    
    __weak IBOutlet NSLayoutConstraint *_addressTop;
    __weak IBOutlet UILabel *_addressLabel;
    __weak IBOutlet UILabel *_modelLabel;
    
    
    __weak IBOutlet UIButton *_lockBt;
    __weak IBOutlet NSLayoutConstraint *_findLeft;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setCoverModel:(CommnncCoverModel *)coverModel {
    _coverModel = coverModel;
    
    _findLeft.constant = -30;
    
    [_bgView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(coverModel.isSelect){
            obj.hidden = NO;
        }else {
            obj.hidden = YES;
        }
    }];
    
    _lockBt.hidden = YES;
    
    [self fullData:coverModel];
}
- (void)setLockModel:(CommnncLockModel *)lockModel {
    _lockModel = lockModel;
    
    _findLeft.constant = 20;
    _lockBt.hidden = NO;
    
    [_bgView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(lockModel.isSelect){
            obj.hidden = NO;
        }else {
            obj.hidden = YES;
        }
    }];
    
    [self fullData:(CommnncCoverModel *)lockModel];
}

- (void)fullData:(CommnncCoverModel *)model {
    _nameLabel.text = model.deviceName;
    
    if(model.runingStatus != nil && ![model.runingStatus isKindOfClass:[NSNull class]]){
        if([model.runingStatus isEqualToString:@"ABNORMAL"]){
            _topStateLabel.text = @"异常";
            _topStateLabel.textColor = [UIColor colorWithHexString:@"#FF2A2A"];
            _eqStateLabel.text = @"异常";
            
            [self eqWran:YES withSel:model.isSelect];
        }else if([model.runingStatus isEqualToString:@"FAULT"]) {
            _topStateLabel.text = @"故障";
            _topStateLabel.textColor = [UIColor colorWithHexString:@"#FFB400"];
            _eqStateLabel.text = @"故障";
            [self eqWran:NO withSel:model.isSelect];
        }else if([model.runingStatus isEqualToString:@"NORMAL"]){
            _topStateLabel.text = @"正常";
            _topStateLabel.textColor = [UIColor colorWithHexString:@"#189517"];
            _eqStateLabel.text = @"正常";
            [self eqWran:NO withSel:model.isSelect];
        }else {
            _topStateLabel.text = @"正常";
            _topStateLabel.textColor = [UIColor colorWithHexString:@"#189517"];
            _eqStateLabel.text = @"正常";   // 默认正常
            
            [self eqWran:NO withSel:model.isSelect];
        }
    }
    
    _stateLabel.text = @"在线";
    if(model.state != nil && ![model.state isKindOfClass:[NSNull class]]){
        if([model.state isEqualToString:@"ONLINE"]){
            _stateLabel.text = @"在线";
        }else if([model.runingStatus isEqualToString:@"OFFLINE"]) {
            _stateLabel.text = @"离线";
        }else if([model.runingStatus isEqualToString:@"INBOX"]) {
            _stateLabel.text = @"停用";
        }
    }
    
    _numLabel.text = [NSString stringWithFormat:@"%@", model.equipSn];
    _wranInfoLabel.text = [NSString stringWithFormat:@"%@", model.stateDetail];
    _timeLabel.text = [NSString stringWithFormat:@"%@", model.triggerDate];
    _addressLabel.text = [NSString stringWithFormat:@"%@", model.addressInfo];
    _modelLabel.text = [NSString stringWithFormat:@"%@(%@)", model.modelCode, model.manufactureName];
}

- (void)eqWran:(BOOL)isWran withSel:(BOOL)isSel {
    
    if(isWran){
        _addressTop.constant = 15;
        if(isSel){
            _wranInfoTitleLabel.hidden = NO;
            _wranInfoLabel.hidden = NO;
            _timeTitleLabel.hidden = NO;
            _timeLabel.hidden = NO;
        }else {
            _wranInfoTitleLabel.hidden = YES;
            _wranInfoLabel.hidden = YES;
            _timeTitleLabel.hidden = YES;
            _timeLabel.hidden = YES;
        }
    }else {
        _addressTop.constant = -47;
        _wranInfoTitleLabel.hidden = YES;
        _wranInfoLabel.hidden = YES;
        _timeTitleLabel.hidden = YES;
        _timeLabel.hidden = YES;
    }
}

- (IBAction)openLockAction:(id)sender {
    if(_lockModel != nil){
        if(_cellMemuDelegate && [_cellMemuDelegate respondsToSelector:@selector(unLock:)]){
            [_cellMemuDelegate unLock:_lockModel];
        }
    }
}

- (IBAction)findAction:(id)sender {
    if(_lockModel != nil){
        if(_cellMemuDelegate && [_cellMemuDelegate respondsToSelector:@selector(queryLock:)]){
            [_cellMemuDelegate queryLock:_lockModel];
        }
    }else if(_coverModel != nil){
        if(_cellMemuDelegate && [_cellMemuDelegate respondsToSelector:@selector(queryCover:)]){
            [_cellMemuDelegate queryCover:_coverModel];
        }
    }
}

@end
