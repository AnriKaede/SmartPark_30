//
//  ParkTop10Cell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/9/28.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "ParkTop10Cell.h"

@implementation ParkTop10Cell
{
    __weak IBOutlet UIImageView *_topImgView;
    __weak IBOutlet UILabel *_topNumLabel;
    
    __weak IBOutlet UILabel *_carNoLabel;
    
    __weak IBOutlet UIImageView *_topBgImgView;
    __weak IBOutlet NSLayoutConstraint *_topBgImgWidth;
    __weak IBOutlet NSLayoutConstraint *_topBgImgRight;
    
    __weak IBOutlet UILabel *_parkTimeLabel;
    
    __weak IBOutlet UILabel *_parkNumLabel;
    __weak IBOutlet UILabel *_inTimeLabel;
    __weak IBOutlet UILabel *_nameLabel;    // name  (
    __weak IBOutlet UILabel *_phoneNumLabel;
    
    __weak IBOutlet UIImageView *_vipImgView;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITapGestureRecognizer *phoneTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callPhone)];
    _phoneNumLabel.userInteractionEnabled = YES;
    [_phoneNumLabel addGestureRecognizer:phoneTap];
}

- (void)callPhone {
    if(_stopParkListModel.CARD_PHONE != nil && ![_stopParkListModel.CARD_PHONE isKindOfClass:[NSNull class]]){
        //获取目标号码字符串,转换成URL
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",_stopParkListModel.CARD_PHONE]];
        //调用系统方法拨号
        [kApplication openURL:url];
    }
}

- (void)setStopParkListModel:(StopParkListModel *)stopParkListModel {
    _stopParkListModel = stopParkListModel;
    
    _topNumLabel.text = [NSString stringWithFormat:@"%ld", (long)stopParkListModel.topNum + 1];
    if(stopParkListModel.topNum > 3){
        _topImgView.hidden = YES;
        _topNumLabel.textColor = [UIColor colorWithHexString:@"#009CF3"];
    }else {
        _topImgView.hidden = NO;
        _topNumLabel.textColor = [UIColor whiteColor];
    }
    
    _carNoLabel.text = [NSString stringWithFormat:@"%@", stopParkListModel.SEAT_IDLE_CARNO];
    
    _parkNumLabel.text = [NSString stringWithFormat:@"%@", stopParkListModel.SEAT_NO];
    
    if(stopParkListModel.SEAT_OCCUTIME != nil && ![stopParkListModel.SEAT_OCCUTIME isKindOfClass:[NSNull class]] && stopParkListModel.SEAT_OCCUTIME.length >= 14){
        _inTimeLabel.text = [self timeFormat:stopParkListModel.SEAT_OCCUTIME];
    }else {
        _inTimeLabel.text = @"";
    }
    
    _nameLabel.text = [NSString stringWithFormat:@"%@  (", stopParkListModel.CARD_NAME];
    
    _phoneNumLabel.text = [NSString stringWithFormat:@"%@", stopParkListModel.CARD_PHONE];
    
    if(stopParkListModel.isVip){
        _vipImgView.hidden = NO;
    }else {
        _vipImgView.hidden = YES;
    }
    
    _topBgImgWidth.constant = 210 - stopParkListModel.topNum * 20;
    _topBgImgRight.constant = stopParkListModel.topNum * 20;
    if(stopParkListModel.topNum > 8){
        _topBgImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"park_top_%ld", stopParkListModel.topNum + 1]];
    }else {
        _topBgImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"park_top_0%ld", stopParkListModel.topNum + 1]];
    }
}

- (NSString *)timeFormat:(NSString *)time {
    NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *inDate = [inputFormatter dateFromString:time];
    
    NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *inpoutStr = [dateFormatter stringFromDate:inDate];
    
    return inpoutStr;
}

@end
