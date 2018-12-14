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

- (void)setIsEdit:(BOOL)isEdit {
    _isEdit = isEdit;
    
    if(isEdit){
        _editBt.enabled = NO;
        _deleteBt.enabled = NO;
    }else {
        _editBt.enabled = YES;
        _deleteBt.enabled = YES;
    }
}

- (void)setFormworkModel:(LEDFormworkModel *)formworkModel {
    _formworkModel = formworkModel;
    
    _titleLabel.text = [NSString stringWithFormat:@"%@", formworkModel.title];
    _contentLabel.text = [NSString stringWithFormat:@"%@", formworkModel.contents];
}

- (IBAction)editAction:(id)sender {
    if(_formworkDelegate != nil && [_formworkDelegate respondsToSelector:@selector(edit:)]){
        [_formworkDelegate edit:_formworkModel];
    }
}
- (IBAction)deleteAction:(id)sender {
    if(_formworkDelegate != nil && [_formworkDelegate respondsToSelector:@selector(delete:)]){
        [_formworkDelegate deleteForwork:_formworkModel];
    }
}
- (IBAction)userAction:(id)sender {
    if(_formworkDelegate != nil && [_formworkDelegate respondsToSelector:@selector(user:)]){
        [_formworkDelegate user:_formworkModel];
    }
}

@end
