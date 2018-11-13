//
//  DrainWaterCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/10.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "DrainWaterCell.h"

#import "YQSwitch.h"

@interface DrainWaterCell()

@end

@implementation DrainWaterCell
{
    __weak IBOutlet UIImageView *_iconImgView;
    __weak IBOutlet UILabel *_drainStateLabel;
    
    __weak IBOutlet UILabel *_nameLabel;
    
}

- (void)_waterOnOrOffClick:(YQSwitch *)yqSwitch {
    
}


- (void)awakeFromNib {
    
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setPumpStateModel:(PumpStateModel *)pumpStateModel {
    _pumpStateModel = pumpStateModel;
    
    _iconImgView.image = [UIImage imageNamed:pumpStateModel.iconName];
    _nameLabel.text = pumpStateModel.pumpTitle;
    _drainStateLabel.text = pumpStateModel.pumpValue;
    _drainStateLabel.textColor = [UIColor colorWithHexString:pumpStateModel.valueColor];
}

@end
