//
//  BatchLockCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/6/19.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BatchLockCell.h"

@implementation BatchLockCell
{

    __weak IBOutlet UIImageView *_iconImgView;
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UIButton *_selBt;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setParkSpaceModel:(ParkSpaceModel *)parkSpaceModel {
    _parkSpaceModel = parkSpaceModel;
    
    _selBt.selected = parkSpaceModel.isSelect;
    
    _nameLabel.text = [NSString stringWithFormat:@"%@", parkSpaceModel.parkingSpaceName];
    
    if(_parkSpaceModel.parkingAreaId != nil && ![_parkSpaceModel.parkingAreaId isKindOfClass:[NSNull class]] && [_parkSpaceModel.parkingAreaId isEqualToString:@"2001"]){
        // 前坪地锁车位
        _iconImgView.image = [UIImage imageNamed:@"down_lock_free"];
    }else {
        // 地下车库
        _iconImgView.image = [UIImage imageNamed:@"up_lock_free"];
    }
}

- (IBAction)selAction:(id)sender {
    _parkSpaceModel.isSelect = !_parkSpaceModel.isSelect;
    _selBt.selected = _parkSpaceModel.isSelect;
}

@end
