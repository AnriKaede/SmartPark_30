//
//  SurplusParkCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/20.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "SurplusParkCell.h"

@interface SurplusParkCell()

@property (weak, nonatomic) IBOutlet UILabel *parkNameLab;

@property (weak, nonatomic) IBOutlet UILabel *overageLab;

@property (weak, nonatomic) IBOutlet UILabel *totalLab;

@end

@implementation SurplusParkCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setModel:(ParkAreasModel *)model
{
    _model = model;
    
    _parkNameLab.text = [NSString stringWithFormat:@"%@",model.areaName];
    
    _overageLab.text = [NSString stringWithFormat:@"%@",model.areaIdle];
    
    _totalLab.text = [NSString stringWithFormat:@"剩/%@总",model.areaNum];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
