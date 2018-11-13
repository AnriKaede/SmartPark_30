//
//  MessageCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/13.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell
{
    __weak IBOutlet UILabel *_titleLabel;
    __weak IBOutlet UILabel *_timeLabel;
    __weak IBOutlet UILabel *_contentLabel;
    
    __weak IBOutlet UILabel *_redFlagLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _redFlagLabel.layer.masksToBounds = YES;
    _redFlagLabel.layer.cornerRadius = 5;
    
    _contentLabel.textColor = [UIColor grayColor];
}

- (void)setMessageModel:(MessageModel *)messageModel {
    _messageModel = messageModel;
    
    _titleLabel.text = messageModel.PUSH_TITLE;
    
    _timeLabel.text = messageModel.PUSH_TIMESTR;
    
    _contentLabel.text = messageModel.PUSH_CONTENT;
    
    if(messageModel.IS_READ.integerValue == 0){
        // 未读
        _redFlagLabel.hidden = NO;
    }else {
        // 已读
        _redFlagLabel.hidden = YES;
    }
}

@end
