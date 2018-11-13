//
//  EquipmentFloorCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/12.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "EquipmentFloorCell.h"

@implementation EquipmentFloorCell
{
    __weak IBOutlet UILabel *_floorName;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setFloorModel:(FloorModel *)floorModel {
    _floorModel = floorModel;
    
    _floorName.text = floorModel.LAYER_NAME;
}

@end
