//
//  LedFormworkCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/16.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "LedFormworkCell.h"

@implementation LedFormworkCell
{
    __weak IBOutlet UILabel *_titleLabel;
    __weak IBOutlet UILabel *_contentLabel;
    
    __weak IBOutlet UIButton *_editBt;
    __weak IBOutlet UIButton *_deleteBt;
    __weak IBOutlet UIButton *_userBt;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _editBt.layer.cornerRadius = 5;
    _editBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    _editBt.layer.borderWidth = 1;
    
    _deleteBt.layer.cornerRadius = 5;
    _deleteBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    _deleteBt.layer.borderWidth = 1;
    
    _userBt.layer.cornerRadius = 5;
    _userBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    _userBt.layer.borderWidth = 1;
}

- (IBAction)editAction:(id)sender {
}
- (IBAction)deleteAction:(id)sender {
}
- (IBAction)userAction:(id)sender {
}

@end
