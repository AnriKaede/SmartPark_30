//
//  ECardListCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/13.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ECardListCell.h"

@implementation ECardListCell
{
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UILabel *_compLabel;
    __weak IBOutlet UILabel *_positionLabel;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setECardInfoModel:(ECardInfoModel *)eCardInfoModel {
    _eCardInfoModel = eCardInfoModel;
    
    if(eCardInfoModel.basePerName != nil && ![eCardInfoModel.basePerName isKindOfClass:[NSNull class]]){
        _nameLabel.text = eCardInfoModel.basePerName;
    }else {
        _nameLabel.text = @"";
    }
    
    if(eCardInfoModel.companyName != nil && ![eCardInfoModel.companyName isKindOfClass:[NSNull class]]){
        _compLabel.text = eCardInfoModel.companyName;
    }else {
        _compLabel.text = @"";
    }
    
    if(eCardInfoModel.basePerNo != nil && ![eCardInfoModel.basePerNo isKindOfClass:[NSNull class]]){
        _positionLabel.text = eCardInfoModel.basePerNo;
    }else {
        _positionLabel.text = @"";
    }
}

@end
