//
//  RepairProgressCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/18.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "RepairProgressCell.h"

@implementation RepairProgressCell
{
    __weak IBOutlet UIView *_circleView;
    __weak IBOutlet UIView *_topView;
    __weak IBOutlet UIView *_bottomView;
    
    __weak IBOutlet UILabel *_timeLabel;
    __weak IBOutlet UILabel *_msgLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _circleView.layer.cornerRadius = _circleView.width/2;
}

- (void)setBillProgressModel:(BillProgressModel *)billProgressModel {
    _billProgressModel = billProgressModel;
    
    _timeLabel.text = [self timeForTimeStr:[NSString stringWithFormat:@"%@", billProgressModel.handleDate]];
    
    _msgLabel.text = [NSString stringWithFormat:@"%@", billProgressModel.handleContent];
    
    if(billProgressModel.isFirst){
        _topView.hidden = YES;
    }else {
        _topView.hidden = NO;
    }
    
    if(billProgressModel.isLast){
        _bottomView.hidden = YES;
    }else {
        _bottomView.hidden = NO;
    }
}

- (NSString *)timeForTimeStr:(NSString *)timeStr {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *expDate = [dateFormat dateFromString:timeStr];
    
    NSDateFormatter *inputDateFormat = [[NSDateFormatter alloc] init];
    [inputDateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *inputStr = [inputDateFormat stringFromDate:expDate];
    
    return inputStr;
}

@end
