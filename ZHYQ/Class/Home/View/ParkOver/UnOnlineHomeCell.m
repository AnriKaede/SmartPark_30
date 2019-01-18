//
//  UnOnlineHomeCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/7.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "UnOnlineHomeCell.h"

@implementation UnOnlineHomeCell
{
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UILabel *_adressLabel;
    __weak IBOutlet UILabel *_timeLabel;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setOfflineModel:(OverOffLineModel *)offlineModel {
    _offlineModel = offlineModel;
    
    _nameLabel.text = [NSString stringWithFormat:@"%@", offlineModel.deviceName];
    _adressLabel.text = [NSString stringWithFormat:@"%@", offlineModel.deviceAddr];
    
    _timeLabel.text = [self timeStrWithInt:offlineModel.offlineTime];
}

- (void)setOverCloseListModel:(OverCloseListModel *)overCloseListModel {
    _overCloseListModel = overCloseListModel;
    
    _nameLabel.text = [NSString stringWithFormat:@"%@", overCloseListModel.deviceName];
    _adressLabel.text = [NSString stringWithFormat:@"%@", overCloseListModel.deviceAddr];
    
    _timeLabel.text = [self timeStrWithInt:overCloseListModel.statusTime];
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
