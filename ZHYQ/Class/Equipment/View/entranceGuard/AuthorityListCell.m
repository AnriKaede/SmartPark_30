//
//  AuthorityListCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/11.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "AuthorityListCell.h"

@interface AuthorityListCell()

@property (weak, nonatomic) IBOutlet UILabel *numLab;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *cardTypeLab;

@end

@implementation AuthorityListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setModel:(AuthModel *)model
{
    _model = model;
    _nameLab.text = [NSString stringWithFormat:@"%@",model.Base_PerName];
    _numLab.text = [NSString stringWithFormat:@"%@",model.Base_PerNo];
    
    _cardTypeLab.text = @"权限卡";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
