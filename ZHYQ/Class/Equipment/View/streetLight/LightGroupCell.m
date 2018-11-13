//
//  LightGroupCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/3/21.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "LightGroupCell.h"

@implementation LightGroupCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
