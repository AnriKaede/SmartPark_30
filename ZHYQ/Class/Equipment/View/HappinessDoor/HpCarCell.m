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
    
    if(hpCarModel.TRACE_OUTPHOTO != nil && ![hpCarModel.TRACE_OUTPHOTO isKindOfClass:[NSNull class]] && hpCarModel.TRACE_OUTPHOTO.length > 0){
        [_carImgView sd_setImageWithURL:[NSURL URLWithString:[hpCarModel.TRACE_OUTPHOTO stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }else if(hpCarModel.TRACE_INPHOTO != nil && ![hpCarModel.TRACE_INPHOTO isKindOfClass:[NSNull class]] && hpCarModel.TRACE_INPHOTO.length > 0){
        [_carImgView sd_setImageWithURL:[NSURL URLWithString:[hpCarModel.TRACE_INPHOTO stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }else {
        _carImgView.image = nil;
    }

    if(hpCarModel.TRACE_END != nil && ![hpCarModel.TRACE_END isKindOfClass:[NSNull class]]){
        _timeLabel.text = [NSString stringWithFormat:@"%@", [self timeFormat:hpCarModel.TRACE_END]];
    }else if (hpCarModel.TRACE_BEGIN != nil && ![hpCarModel.TRACE_BEGIN isKindOfClass:[NSNull class]]) {
        _timeLabel.text = [NSString stringWithFormat:@"%@", [self timeFormat:hpCarModel.TRACE_BEGIN]];
    }else {
        _timeLabel.text = @"";
    }
    
    _carNoLabel.text = [NSString stringWithFormat:@"%@", hpCarModel.TRACE_CARNO];
    
    NSString *address = @"";
    if(hpCarModel.TRACE_END != nil && ![hpCarModel.TRACE_END isKindOfClass:[NSNull class]] && hpCarModel.TRACE_END.length > 0){
        if([hpCarModel.TRACE_OUTGATEID isEqualToString:@"8a04a41f56bc33a20156bc3a914c000b"]){
            address = @"天园北大门入口";
        }else if([hpCarModel.TRACE_OUTGATEID isEqualToString:@"8a04a41f56bc33a20156bc3ac78f000d"]){
            address = @"天园北大门出口";
        }else if([hpCarModel.TRACE_OUTGATEID isEqualToString:@"8a04a41f56c0c3f90157277bdb9e006e"]){
            address = @"地下车库入口";
        }else if([hpCarModel.TRACE_OUTGATEID isEqualToString:@"8a04a41f56c0c3f90157277c0b350070"]){
            address = @"地下车库出口";
        }else if([hpCarModel.TRACE_OUTGATEID isEqualToString:@"8a04a41f56c0c3f90157277c362a0072"]){
            address = @"南坪停车场入口";
        }else if([hpCarModel.TRACE_OUTGATEID isEqualToString:@"8a04a41f56c0c3f90157277c66350074"]){
            address = @"南坪停车场出口";
        }
    }else {
        if([hpCarModel.TRACE_INGATEID isEqualToString:@"8a04a41f56bc33a20156bc3a914c000b"]){
            address = @"天园北大门入口";
        }else if([hpCarModel.TRACE_INGATEID isEqualToString:@"8a04a41f56bc33a20156bc3ac78f000d"]){
            address = @"天园北大门出口";
        }else if([hpCarModel.TRACE_INGATEID isEqualToString:@"8a04a41f56c0c3f90157277bdb9e006e"]){
            address = @"地下车库入口";
        }else if([hpCarModel.TRACE_INGATEID isEqualToString:@"8a04a41f56c0c3f90157277c0b350070"]){
            address = @"地下车库出口";
        }else if([hpCarModel.TRACE_INGATEID isEqualToString:@"8a04a41f56c0c3f90157277c362a0072"]){
            address = @"南坪停车场入口";
        }else if([hpCarModel.TRACE_INGATEID isEqualToString:@"8a04a41f56c0c3f90157277c66350074"]){
            address = @"南坪停车场出口";
        }
    }
    _addresLabel.text = address;
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
