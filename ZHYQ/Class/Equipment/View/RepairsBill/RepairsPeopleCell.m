//
//  RepairsPeopleCell.m
//  ZHYQ
//
//  Created by 焦平 on 2018/4/19.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "RepairsPeopleCell.h"

@interface RepairsPeopleCell()
{
    
    __weak IBOutlet NSLayoutConstraint *peopleNameLab;
    
    __weak IBOutlet UILabel *_nameLabel;
    
}

@end

@implementation RepairsPeopleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setRepairsManModel:(RepairsManModel *)repairsManModel {
    _repairsManModel = repairsManModel;
    
    _nameLabel.text = repairsManModel.USER_NAME;
}

@end
