//
//  FaceHistoryCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/13.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "FaceHistoryCell.h"

@implementation FaceHistoryCell
{
    __weak IBOutlet UIImageView *_imgView;
    __weak IBOutlet UIButton *_selBt;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _imgView.backgroundColor = [UIColor colorWithHexString:@"#626262"];
    _imgView.contentMode = UIViewContentModeScaleAspectFit;
}

/*
- (void)setFaceImgHistory:(FaceImgHistory *)faceImgHistory {
    _faceImgHistory = faceImgHistory;
    
    _imgView.image = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@%@", FaceHistoryPath, faceImgHistory.imgFilePath]];
}
 */

- (void)setFaceHistoryModel:(FaceHistoryModel *)faceHistoryModel {
    _faceHistoryModel = faceHistoryModel;
    
    NSString *base64Str = [faceHistoryModel.faceInfo componentsSeparatedByString:@"base64,"].lastObject;
    NSData *decodedImageData = [[NSData alloc] initWithBase64EncodedString:base64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *decodedImage = [UIImage imageWithData:decodedImageData];
    _imgView.image = decodedImage;
    
    _selBt.selected = faceHistoryModel.isSelDelete;
}

- (void)setIsShowDelete:(BOOL)isShowDelete {
    _isShowDelete = isShowDelete;
    _selBt.hidden = !_isShowDelete;
}

- (IBAction)selImgAction:(id)sender {
    _selBt.selected = !_selBt.selected;
    _faceHistoryModel.isSelDelete = _selBt.selected;
}

@end
