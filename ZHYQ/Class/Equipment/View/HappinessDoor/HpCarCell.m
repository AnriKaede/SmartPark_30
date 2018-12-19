//
//  HpCarCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/17.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "HpCarCell.h"

@implementation HpCarCell
{
    __weak IBOutlet UIImageView *_carImgView;
    
    __weak IBOutlet UILabel *_carNoLabel;
    __weak IBOutlet UILabel *_addresLabel;
    __weak IBOutlet UILabel *_timeLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)setHpCarModel:(HpCarModel *)hpCarModel {
    _hpCarModel = hpCarModel;
    
    if(hpCarModel.PLATEPIC != nil && ![hpCarModel.PLATEPIC isKindOfClass:[NSNull class]] && [hpCarModel.PLATEPIC containsString:@"base64,"]){
        NSString *base64Str = [hpCarModel.PLATEPIC componentsSeparatedByString:@"base64,"].lastObject;
        NSData *decodedImageData = [[NSData alloc] initWithBase64EncodedString:base64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *decodedImage = [UIImage imageWithData:decodedImageData];
        
        _carImgView.image = decodedImage;
    }else {
        _carImgView.image = nil;
    }

    _timeLabel.text = [NSString stringWithFormat:@"%@", [self timeFormat:hpCarModel.OPEN_TIME]];
    
    _carNoLabel.text = [NSString stringWithFormat:@"%@", hpCarModel.PLATE];
    
    _addresLabel.text = [NSString stringWithFormat:@"%@", hpCarModel.FM_DEVICE_NAME];
}

- (NSString *)timeFormat:(NSString *)timeStr {
    if(timeStr != nil && ![timeStr isKindOfClass:[NSNull class]]){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSDate *orgData = [formatter dateFromString:timeStr];
        
        NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
        [inputFormatter setDateFormat:@"MM-dd HH:mm:ss"];
        NSString *inputTime = [inputFormatter stringFromDate:orgData];
        return inputTime;
    }else {
        return @"";
    }
}

@end
