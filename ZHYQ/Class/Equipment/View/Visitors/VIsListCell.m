//
//  VIsListCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/20.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "VIsListCell.h"

@implementation VIsListCell
{
    __weak IBOutlet UILabel *_comLabel;
    
    __weak IBOutlet UILabel *_numLabel;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setVisCountItemModel:(VisCountItemModel *)visCountItemModel {
    _visCountItemModel = visCountItemModel;
    
    _comLabel.text = visCountItemModel.areaName;
    _numLabel.text = [NSString stringWithFormat:@"%@人",visCountItemModel.totalVisitor];
}

@end
