//
//  FaceWranCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/14.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "FaceWranCell.h"

@implementation FaceWranCell
{
    __weak IBOutlet UIImageView *_bgImgView;
    
    __weak IBOutlet UIButton *_deleteSelBt;
    __weak IBOutlet UIButton *_editBt;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setIsDelete:(BOOL)isDelete {
    _isDelete = isDelete;
    
    _deleteSelBt.hidden = !isDelete;
    _editBt.hidden = isDelete;
}

- (IBAction)deleteSelect:(id)sender {
    _deleteSelBt.selected = !_deleteSelBt.selected;
}
- (IBAction)editImg:(id)sender {
}

@end
