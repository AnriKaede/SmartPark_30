//
//  MeetRoomCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/7/24.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "MeetRoomCell.h"

@implementation MeetRoomCell
{
    __weak IBOutlet UILabel *_nameLabel;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setModel:(MeetRoomGroupModel *)model {
    _model = model;
    
    _nameLabel.text = [NSString stringWithFormat:@"%@", model.ROOM_NAME];
}

@end
