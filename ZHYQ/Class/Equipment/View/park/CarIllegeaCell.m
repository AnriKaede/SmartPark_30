//
//  CarIllegeaCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/2.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "CarIllegeaCell.h"

@implementation CarIllegeaCell
{
    __weak IBOutlet UILabel *_timeLabel;
    __weak IBOutlet UILabel *_msgLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setIllegaListModel:(IllegaListModel *)illegaListModel {
    _illegaListModel = illegaListModel;
    
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

    _msgLabel.text = illegaListModel.illegalContent;
}

@end
