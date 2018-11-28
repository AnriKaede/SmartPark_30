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
    __weak IBOutlet UILabel *_nameLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setFaceWranModel:(FaceWranModel *)faceWranModel {
    _faceWranModel = faceWranModel;
    
    _nameLabel.text = [NSString stringWithFormat:@"%@", faceWranModel.name];
    
    NSString *base64Str = [faceWranModel.faceImageBase64 componentsSeparatedByString:@"base64,"].lastObject;
    NSData *decodedImageData = [[NSData alloc] initWithBase64EncodedString:base64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *decodedImage = [UIImage imageWithData:decodedImageData];
    _bgImgView.image = decodedImage;
    
    _deleteSelBt.selected = faceWranModel.isSelDelete;
}

- (void)setIsDelete:(BOOL)isDelete {
    _isDelete = isDelete;
    
    _deleteSelBt.hidden = !isDelete;
    _editBt.hidden = isDelete;
}

- (IBAction)deleteSelect:(id)sender {
    _deleteSelBt.selected = !_deleteSelBt.selected;
    _faceWranModel.isSelDelete = _deleteSelBt.selected;
}
- (IBAction)editImg:(id)sender {
    if(_updateImgDelegate != nil && [_updateImgDelegate respondsToSelector:@selector(updateImg:)]){
        [_updateImgDelegate updateImg:_faceWranModel];
    }
}

@end
