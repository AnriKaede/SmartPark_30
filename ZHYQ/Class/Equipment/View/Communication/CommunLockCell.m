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
    __weak IBOutlet UILabel *_reasonLabel;
    __weak IBOutlet UILabel *_timeLabel;
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
    
    if([model.runingStatus isEqualToString:@"ABNORMAL"]){
        _topStateLabel.text = @"异常";
        _topStateLabel.textColor = [UIColor colorWithHexString:@"#FF2A2A"];
        _stateLabel.text = @"异常";
    }else if([model.runingStatus isEqualToString:@"FAULT"]) {
        _topStateLabel.text = @"故障";
        _topStateLabel.textColor = [UIColor colorWithHexString:@"#FFB400"];
        _stateLabel.text = @"故障";
    }else {
        _topStateLabel.text = @"正常";
        _topStateLabel.textColor = [UIColor colorWithHexString:@"#189517"];
        _stateLabel.text = @"正常";
    }
    
    _numLabel.text = [NSString stringWithFormat:@"%@", model.equipSn];
    _reasonLabel.text = [NSString stringWithFormat:@"%@", model.stateDetail];
    _timeLabel.text = [NSString stringWithFormat:@"%@", model.triggerDate];
    _addressLabel.text = [NSString stringWithFormat:@"%@", model.addressInfo];
    _modelLabel.text = [NSString stringWithFormat:@"%@(%@)", model.modelCode, model.manufactureName];
}

- (IBAction)openLockAction:(id)sender {
}

- (IBAction)findAction:(id)sender {
    CommncQueryViewController *queryVC = [[CommncQueryViewController alloc] init];
    [self.viewController.navigationController pushViewController:queryVC animated:YES];
}

@end
