//
//  CloseEqHomeCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/7.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "CloseEqHomeCell.h"

@implementation CloseEqHomeCell
{
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UILabel *_itemNameLabel;
    __weak IBOutlet UILabel *_numLabel;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setUseModel:(OverUseListModel *)useModel {
    _useModel = useModel;
    
    _nameLabel.text = [NSString stringWithFormat:@"%@", useModel.deviceTypeName];
    _numLabel.text = [NSString stringWithFormat:@"%@", useModel.cnt];
}

@end
