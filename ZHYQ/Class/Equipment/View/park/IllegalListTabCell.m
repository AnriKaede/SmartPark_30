//
//  IllegalListTabCell.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/8.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "IllegalListTabCell.h"

@interface IllegalListTabCell()
{
    __weak IBOutlet UILabel *_carNoLabel;
    __weak IBOutlet UILabel *_blackFlagLabel;
    __weak IBOutlet UILabel *_timeLabel;
    __weak IBOutlet UILabel *_msgLabel;
}

@end

@implementation IllegalListTabCell

-(void)setIllegaListModel:(IllegaListModel *)illegaListModel
{
    _illegaListModel = illegaListModel;
    
    _carNoLabel.text = [NSString stringWithFormat:@"%@",illegaListModel.illegalCarno];
    
    NSString *string = illegaListModel.illegalCreatetime;
    NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *inputDate = [inputFormatter dateFromString:string];
    NSDateFormatter *outputFormatter= [[NSDateFormatter alloc] init];
    [outputFormatter setLocale:[NSLocale currentLocale]];
    [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *str= [outputFormatter stringFromDate:inputDate];
    
    _timeLabel.text = [NSString stringWithFormat:@"%@",str];
    
    if(illegaListModel.illegalContent != nil && ![illegaListModel.illegalContent isKindOfClass:[NSNull class]]){
        _msgLabel.text = [NSString stringWithFormat:@"%@",illegaListModel.illegalContent];
    }else {
        _msgLabel.text = @"违停说明：";
    }
    
    if([illegaListModel.illegalStatus isEqualToString:@"01"]){
        _blackFlagLabel.hidden = NO;
    }else {
        _blackFlagLabel.hidden = YES;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _blackFlagLabel.layer.borderColor = _blackFlagLabel.textColor.CGColor;
    _blackFlagLabel.layer.borderWidth = 0.8;
    _blackFlagLabel.layer.cornerRadius = 3;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
