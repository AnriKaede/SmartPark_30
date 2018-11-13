//
//  FindCarCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/3.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "FindCarCell.h"

@implementation FindCarCell
{
    __weak IBOutlet UILabel *_carNoLabel;
    __weak IBOutlet UILabel *_carTypeLabel;
    
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UILabel *_phoneNumLabel;
    __weak IBOutlet UILabel *_companyLabel;
    __weak IBOutlet UILabel *_departmentLabel;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setFindCarNoModel:(FindCarNoModel *)findCarNoModel {
    _findCarNoModel = findCarNoModel;
    
    _carNoLabel.text = [NSString stringWithFormat:@"%@", findCarNoModel.CAR_NO];
    
    _carTypeLabel.text = [NSString stringWithFormat:@"%@", findCarNoModel.CARD_CARCOLOR];
    
    _nameLabel.text = [NSString stringWithFormat:@"%@", findCarNoModel.CARD_NAME];
    
    _phoneNumLabel.text = [NSString stringWithFormat:@"%@", findCarNoModel.CARD_PHONE];
    
    _companyLabel.text = [NSString stringWithFormat:@"%@", findCarNoModel.CARD_UNITINFO];
    
    _departmentLabel.text = [NSString stringWithFormat:@"%@", findCarNoModel.CARD_DEPARTMENT];
}

@end
