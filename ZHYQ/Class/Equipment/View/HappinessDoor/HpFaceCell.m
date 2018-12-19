//
//  HpFaceCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/17.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "HpFaceCell.h"

@implementation HpFaceCell
{
    __weak IBOutlet UIImageView *_faceImgView;
    
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UILabel *_addressLabel;

    __weak IBOutlet UILabel *_timeLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setHpFaceModel:(HpFaceModel *)hpFaceModel {
    _hpFaceModel = hpFaceModel;
    
    if(hpFaceModel.FACEPHOTO != nil && ![hpFaceModel.FACEPHOTO isKindOfClass:[NSNull class]] && [hpFaceModel.FACEPHOTO containsString:@"base64,"]){
        NSString *base64Str = [hpFaceModel.FACEPHOTO componentsSeparatedByString:@"base64,"].lastObject;
        NSData *decodedImageData = [[NSData alloc] initWithBase64EncodedString:base64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *decodedImage = [UIImage imageWithData:decodedImageData];
        
        _faceImgView.image = decodedImage;
    }else {
        _faceImgView.image = nil;
    }
    
    _nameLabel.text = [NSString stringWithFormat:@"%@", hpFaceModel.NAME];
    
    _timeLabel.text = [NSString stringWithFormat:@"%@", [self timeFormat:hpFaceModel.OPEN_TIME]];
    
    _addressLabel.text = [NSString stringWithFormat:@"%@", [self timeFormat:hpFaceModel.FM_DEVICE_NAME]];
}

- (NSString *)timeFormat:(NSString *)timeStr {
    if(timeStr != nil && ![timeStr isKindOfClass:[NSNull class]]){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSDate *orgData = [formatter dateFromString:timeStr];
        
        NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
        [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *inputTime = [inputFormatter stringFromDate:orgData];
        return inputTime;
    }else {
        return @"";
    }
}

@end
