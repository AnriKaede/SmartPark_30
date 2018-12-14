//
//  BatchAddFaceCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/28.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "BatchAddFaceCell.h"

@interface BatchAddFaceCell()<UITextFieldDelegate>

@end

@implementation BatchAddFaceCell
{
    __weak IBOutlet UIImageView *_faceImageView;
    
    __weak IBOutlet UITextField *_nameTF;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _nameTF.delegate = self;
    _faceImageView.contentMode = UIViewContentModeScaleAspectFit;
    _faceImageView.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF"];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _addBatchFaceModel.name = textField.text;
}

- (void)setAddBatchFaceModel:(AddBatchFaceModel *)addBatchFaceModel {
    _addBatchFaceModel = addBatchFaceModel;
    
    if(addBatchFaceModel.faceImage){
        _faceImageView.image = addBatchFaceModel.faceImage;
    }else {
        _faceImageView.image = nil;
    }
    
    if(addBatchFaceModel.name != nil && ![addBatchFaceModel.name isKindOfClass:[NSNull class]]){
        _nameTF.text = [NSString stringWithFormat:@"%@", addBatchFaceModel.name];
    }else {
        _nameTF.text = @"";
    }
    
}

@end
