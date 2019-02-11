//
//  OverLineCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/11.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "OverLineCell.h"

@implementation OverLineCell
{
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UIView *_proportionView;
    __weak IBOutlet NSLayoutConstraint *_proportionWidth;  // all screen.widht - 267.5
    __weak IBOutlet UILabel *_numLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setAlarmModel:(OverAlarmModel *)alarmModel {
    _alarmModel = alarmModel;
    
    _nameLabel.text = [NSString stringWithFormat:@"%@", alarmModel.alarmLevelName];
    _numLabel.text = [NSString stringWithFormat:@"%@", alarmModel.alarmLevelCount];
    
    if(_totalCount != nil && _totalCount.integerValue != 0){
        _proportionWidth.constant = alarmModel.alarmLevelCount.floatValue/_totalCount.floatValue * (KScreenWidth - 258.5);
    }else {
        _proportionWidth.constant = 0;
    }
}

- (void)setCheckModel:(OverCheckModel *)checkModel {
    _checkModel = checkModel;
    
    _nameLabel.text = [NSString stringWithFormat:@"%@", checkModel.routingOrderStatusName];
    _numLabel.text = [NSString stringWithFormat:@"%@", checkModel.routingOrderStatusCount];
    
    if(_totalCount != nil && _totalCount.integerValue != 0){
        _proportionWidth.constant = checkModel.routingOrderStatusCount.floatValue/_totalCount.floatValue * (KScreenWidth - 258.5);
    }else {
        _proportionWidth.constant = 0;
    }
}

- (void)setColorStr:(NSString *)colorStr {
    _colorStr = colorStr;
    
    _nameLabel.textColor = [UIColor colorWithHexString:colorStr];
    _proportionView.backgroundColor = [UIColor colorWithHexString:colorStr];
    _numLabel.textColor = [UIColor colorWithHexString:colorStr];
}

@end
