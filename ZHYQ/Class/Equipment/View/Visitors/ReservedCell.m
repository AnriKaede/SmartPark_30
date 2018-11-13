//
//  ReservedCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/25.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ReservedCell.h"

@implementation ReservedCell
{
    __weak IBOutlet UILabel *_reservedTimeLabel;
    
    __weak IBOutlet UILabel *_statelabel;
    
    __weak IBOutlet UILabel *_reservedNameLabel;
    __weak IBOutlet UILabel *_phoneNumLabel;
    __weak IBOutlet UILabel *_sexLabel;
    
    __weak IBOutlet UILabel *_carNoLabel;
    
    __weak IBOutlet UILabel *_arriveTimeLabel;
    __weak IBOutlet UILabel *_visitedLabel;
    
    __weak IBOutlet UILabel *_reasonLabel;
    __weak IBOutlet UIImageView *_flagImgView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(telephoneTapAction)];
    _telephoneLab.userInteractionEnabled = YES;
    [_telephoneLab addGestureRecognizer:tap];
}

-(void)telephoneTapAction
{
    if (self.delegate != nil&&[self.delegate respondsToSelector:@selector(reserveCallTelePhone:)]) {
        [self.delegate reserveCallTelePhone:_telephoneLab.text];
    }
}

- (void)setReservedModel:(ReservedModel *)reservedModel {
    _reservedModel = reservedModel;
    
    _reservedTimeLabel.text = [NSString stringWithFormat:@"%@", [self timeStrWithInt:reservedModel.createTime]];
    
    //    0预约 1访问中 2离访 3预约取消 4来访完成
    NSString *state = reservedModel.status;
    if(state != nil && ![state isKindOfClass:[NSNull class]]){
        if([state isEqualToString:@"0"]){
            _statelabel.text = @"未到访";
            _statelabel.textColor = [UIColor colorWithHexString:@"#FF4359"];
        }else if([state isEqualToString:@"1"]) {
            _statelabel.text = @"访问中";
            _statelabel.textColor = [UIColor colorWithHexString:@"#1B82D1"];
        }else if([state isEqualToString:@"2"] || [state isEqualToString:@"4"]) {
            _statelabel.text = @"已离开";
            _statelabel.textColor = [UIColor colorWithHexString:@"#1B82D1"];
        }else if([state isEqualToString:@"3"]) {
            _statelabel.text = @"已取消";
            _statelabel.textColor = [UIColor colorWithHexString:@"#FF4359"];
        }else {
            _statelabel.text = @"";
        }
    }else {
        _statelabel.text = @"";
    }
    
    _reservedNameLabel.text = [NSString stringWithFormat:@"%@", reservedModel.visitorName];
    _phoneNumLabel.text = [NSString stringWithFormat:@"%@", reservedModel.visitorPhone];
    
    NSString *sex = _reservedModel.visitorSex;
    if(sex != nil && ![sex isKindOfClass:[NSNull class]]){
        if([sex isEqualToString:@"1"]){
            _sexLabel.text = @"男";
        }else if([sex isEqualToString:@"2"]){
            _sexLabel.text = @"女";
        }else {
            _sexLabel.text = @"未知";
        }
    }else {
        _sexLabel.text = @"未知";
    }
    
    NSString *peopleStr = reservedModel.persionWith;
    if(peopleStr != nil && ![peopleStr isKindOfClass:[NSNull class]] && peopleStr.length > 0){
        peopleStr = [peopleStr stringByReplacingOccurrencesOfString:@"，" withString:@","];
        NSArray *peoples = [peopleStr componentsSeparatedByString:@","];
        _sexLabel.text = [NSString stringWithFormat:@"%@   等%ld人", _sexLabel.text, peoples.count+1];
    }
    
    if(reservedModel.carNo != nil && ![reservedModel.carNo isKindOfClass:[NSNull class]]){
        _carNoLabel.text = [NSString stringWithFormat:@"%@", reservedModel.carNo];
    }else {
        _carNoLabel.text = @"无";
    }
    _arriveTimeLabel.text = [NSString stringWithFormat:@"起 %@\n至 %@", [self timeStrWithInt:reservedModel.beginTime], [self timeStrWithInt:reservedModel.endTime]];
    
    NSRange startRange = [_arriveTimeLabel.text rangeOfString:@"起"];
    NSRange endRange = [_arriveTimeLabel.text rangeOfString:@"至"];
    NSMutableAttributedString *atbStr = [[NSMutableAttributedString alloc] initWithString:_arriveTimeLabel.text];
    [atbStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#1B82D1"] range:startRange];
    [atbStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#FF4359"] range:endRange];
    _arriveTimeLabel.attributedText = atbStr;
    
    // 被访问人
    _visitedLabel.text = [NSString stringWithFormat:@"%@", reservedModel.userName];
    
    _reasonLabel.text = [NSString stringWithFormat:@"%@", reservedModel.reasionDesc];
    
    _flagImgView.hidden = YES;
}

- (NSString *)timeStrWithInt:(NSNumber *)time {
    if(time == nil || [time isKindOfClass:[NSNull class]]){
        return @"";
    }
    //时间戳转化成时间
    NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
    [stampFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *stampDate = [NSDate dateWithTimeIntervalSince1970:time.doubleValue/1000.0];
    return [stampFormatter stringFromDate:stampDate];
}

@end
