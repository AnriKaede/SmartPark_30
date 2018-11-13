//
//  ManholeListTableViewCell.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/15.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ManholeListTableViewCell.h"
#import "NewCoverInfoModel.h"

@implementation ManholeListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _selectView.backgroundColor = [UIColor colorWithHexString:@"1B82D1"];
    _statusLab.textColor = [UIColor colorWithHexString:@"189517"];
    _holeLockLab.textColor = [UIColor colorWithHexString:@"FF4359"];
}

-(void)setModel:(NewCoverModel *)model {
    _model = model;
    
    NewCoverInfoModel *holeModel = model.platItem;
    
    _holeNameLab.text = [NSString stringWithFormat:@"%@",model.DEVICE_NAME];
    _holeAreaLab.text = [NSString stringWithFormat:@"%@",model.DEVICE_ADDR];
    _holeNumDetailLab.text = [NSString stringWithFormat:@"%@",holeModel.iot_cover];
    
    if([model.IS_ALARM isEqualToString:@"1"]){
        // 是否是警告
        _statusLab.text = @"警告中";
        _statusLab.textColor = [UIColor colorWithHexString:@"#FF4359"];
    }else {
        _statusLab.text = @"正常运行";
        _statusLab.textColor = [UIColor colorWithHexString:@"#6BDB6A"];
    }
    
    if (!model.platItem.is_open.boolValue) {
        [_lockBtn setBackgroundImage:[UIImage imageNamed:@"_jingai_lock_in"] forState:UIControlStateNormal];
    }else
    {
        [_lockBtn setBackgroundImage:[UIImage imageNamed:@"_jingai_lock_off"] forState:UIControlStateNormal];
    }
    
}

- (IBAction)lockBtnClick:(id)sender {
    if(_unlockDelegate && [_unlockDelegate respondsToSelector:@selector(unLockCover:)]){
        [_unlockDelegate unLockCover:_model];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
