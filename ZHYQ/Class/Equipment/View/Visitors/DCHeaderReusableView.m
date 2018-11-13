//
//  DCHeaderReusableView.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/18.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "DCHeaderReusableView.h"

#import "DCFiltrateItem.h"

@interface DCHeaderReusableView ()

@property (weak, nonatomic) IBOutlet UILabel *headLabel;

@end

@implementation DCHeaderReusableView

#pragma mark - Intial
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setHeadFiltrate:(DCFiltrateItem *)headFiltrate
{
    _headLabel.text = headFiltrate.headTitle;
    
    if (headFiltrate.isOpen) { //箭头
        [self.upDownButton setImage:[UIImage imageNamed:@"arrow_down"] forState:0];
    }else{
        [self.upDownButton setImage:[UIImage imageNamed:@"arrow_up"] forState:0];
    }
}


- (IBAction)upDownClick:(UIButton *)sender {
    
    !_sectionClick ? : _sectionClick();

}



@end
