//
//  CommunLockCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/21.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "CommunLockCell.h"

@implementation CommunLockCell
{
    __weak IBOutlet UILabel *_nameLabel;
    
    __weak IBOutlet UIView *_bgView;
    
    
    
    __weak IBOutlet UILabel *_numLabel;
    __weak IBOutlet UILabel *_stateLabel;
    __weak IBOutlet UILabel *_reasonLabel;
    __weak IBOutlet UILabel *_timeLabel;
    __weak IBOutlet UILabel *_addressLabel;
    __weak IBOutlet UILabel *_modelLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)openLockAction:(id)sender {
}

- (IBAction)findAction:(id)sender {
}

@end
