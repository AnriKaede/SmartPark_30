//
//  VisitedTableViewCell.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/18.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "VisitedTableViewCell.h"

@implementation VisitedTableViewCell
{
    __weak IBOutlet UILabel *_compLabel;
    
    __weak IBOutlet UILabel *_startTimeLabel;
    
    __weak IBOutlet UILabel *_visNameLabel;
    __weak IBOutlet UIImageView *_phoneImgView;
    __weak IBOutlet UILabel *_visPhoneLabel;
    __weak IBOutlet UILabel *_visSexLabel;
    __weak IBOutlet UILabel *_visIdCardLabel;
    
    __weak IBOutlet UILabel *_userNameLabel;
    
    __weak IBOutlet UILabel *_reasonLabel;
    
    __weak IBOutlet UILabel *_levTitleLabel;
    __weak IBOutlet UILabel *_levTimeLabel;
    
    __weak IBOutlet UIImageView *_flagImgView;
    
    __weak IBOutlet UIImageView *_faceImgView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    if (iPhone5) {
        _leadSpace.constant = 5;
        _phoneLeadSpace.constant = 0;
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    _telephoneLab.userInteractionEnabled = YES;
    [_telephoneLab addGestureRecognizer:tap];

    UITapGestureRecognizer *faceTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(faceQueryAction)];
    _faceImgView.userInteractionEnabled = YES;
    [_faceImgView addGestureRecognizer:faceTap];
    
    _faceImgView.contentMode = UIViewContentModeScaleAspectFill;
    _faceImgView.clipsToBounds = YES;
}

-(void)tapAction
{
    if (self.delegate!=nil&&[self.delegate respondsToSelector:@selector(isArraiveCallTelePhone:)]) {
        [self.delegate isArraiveCallTelePhone:_telephoneLab.text];
    }
}

- (void)faceQueryAction {
    if([_delegate respondsToSelector:@selector(faceQuery:)]){
        [_delegate faceQuery:_visitorFinishModel];
    }
}

- (void)setVisitorFinishModel:(VisitorFinishModel *)visitorFinishModel {
    _visitorFinishModel = visitorFinishModel;
    
    _compLabel.text = @"-";
    
    _startTimeLabel.text = [self timeFormatWithStyle:@"yyyy-MM-dd HH:mm:ss" withTimeStr:visitorFinishModel.startTime];
    
    _visNameLabel.text = visitorFinishModel.viserModel.name;
    if(visitorFinishModel.viserModel.phone != nil && ![visitorFinishModel.viserModel.phone isKindOfClass:[NSNull class]] && visitorFinishModel.viserModel.phone.length > 0){
        _visPhoneLabel.text = visitorFinishModel.viserModel.phone;
//        _phoneImgView.hidden = NO;
    }else {
        _visPhoneLabel.text = @"";
//        _phoneImgView.hidden = YES;
    }
    
    _visSexLabel.text = [NSString stringWithFormat:@"(%@)", visitorFinishModel.viserModel.sex];
    if(visitorFinishModel.viserModel.idNum != nil && visitorFinishModel.viserModel.idNum.length >= 10){
        NSString *firstStr = [visitorFinishModel.viserModel.idNum substringWithRange:NSMakeRange(0, 6)];
        NSString *lastStr = [visitorFinishModel.viserModel.idNum substringWithRange:NSMakeRange(visitorFinishModel.viserModel.idNum.length - 4, 4)];
        NSString *idCard = [NSString stringWithFormat:@"%@********%@", firstStr, lastStr];
        _visIdCardLabel.text = idCard;
    }else {
        _visIdCardLabel.text = visitorFinishModel.viserModel.idNum;
    }
    
    _userNameLabel.text = visitorFinishModel.userModel.nickname;
    
    _reasonLabel.text = visitorFinishModel.reasons;
    
    
    NSNumber *states =visitorFinishModel.status;
    if(states != nil && ![states isKindOfClass:[NSNull class]] && states.integerValue == 2){
        // 离开
        _flagImgView.hidden = YES;
        _levTitleLabel.hidden = NO;
        if(visitorFinishModel.logOffTime != nil && ![visitorFinishModel.logOffTime isKindOfClass:[NSNull class]]) {
            _levTimeLabel.text = [self timeFormatWithStyle:@"yyyy-MM-dd HH:mm:ss" withTimeStr:visitorFinishModel.logOffTime];
        }else {
            _levTimeLabel.text = @"-";
        }
    }else {
        // 未离开
        _levTitleLabel.hidden = YES;
        _flagImgView.hidden = NO;
        _levTimeLabel.text = @"";
    }
    
    if(visitorFinishModel.sitePhoto != nil && ![visitorFinishModel.sitePhoto isKindOfClass:[NSNull class]]){
        [_faceImgView sd_setImageWithURL:[NSURL URLWithString:visitorFinishModel.sitePhoto]];
    }else {
        _faceImgView.image = nil;
    }
}

- (NSString *)timeFormatWithStyle:(NSString *)style withTimeStr:(NSString *)timeStr {
    NSDateFormatter *oldFormat = [[NSDateFormatter alloc] init];
    [oldFormat setDateFormat:style];
    NSDate *date = [oldFormat dateFromString:timeStr];
    
    NSDateFormatter *inputFormat = [[NSDateFormatter alloc] init];
    [inputFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [inputFormat stringFromDate:date];
}

@end
