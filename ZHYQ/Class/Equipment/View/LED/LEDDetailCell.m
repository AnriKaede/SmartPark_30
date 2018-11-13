//
//  LEDDetailCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "LEDDetailCell.h"

@implementation LEDDetailCell
{
    __weak IBOutlet UIImageView *_headerImgView;
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UILabel *_timeLabel;
    
    __weak IBOutlet UIImageView *_isShowImgView;
    
    __weak IBOutlet UILabel *_msgLabel;
    
    __weak IBOutlet UIButton *_editBt;
    __weak IBOutlet UIButton *_cancelBt;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)editAction:(id)sender {
}

- (IBAction)cancelShow:(id)sender {
}



@end
