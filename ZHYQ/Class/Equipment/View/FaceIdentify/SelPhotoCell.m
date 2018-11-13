//
//  SelPhotoCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/3/28.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "SelPhotoCell.h"

@implementation SelPhotoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self imgCornerRadius];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITapGestureRecognizer *imgSelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selFace)];
    _selImgView.userInteractionEnabled = YES;
    [_selImgView addGestureRecognizer:imgSelTap];
    
    UITapGestureRecognizer *labelSelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selFace)];
    _msgLabel.userInteractionEnabled = YES;
    [_msgLabel addGestureRecognizer:labelSelTap];
}

- (void)imgCornerRadius {
    _selImgView.layer.cornerRadius = _selImgView.width/2;
    _selImgView.layer.masksToBounds = YES;
    _selImgView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)selFace {
    if(_selFaceDelegate && [_selFaceDelegate respondsToSelector:@selector(selFacePhoto)]){
        [_selFaceDelegate selFacePhoto];
    }
}

@end
