//
//  MessageTypeModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/29.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"
#import "MessageModel.h"

@interface MessageTypeModel : BaseModel

/*
 {
 "MESSAGE_TYPE": "01",
 "TOTAL": 32,
 "UNREAD_SUM": 22,
 "latestMessage": {
 "IS_READ": "1",
 "MESSAGE_PUSH_INDEX": null,
 "MESSAGE_PUSH_TABLE": null,
 "MESSAGE_TYPE": "01",
 "PUSH_CONTENT": "您的账号在另外一处登录，若是本人操作，请忽略！",
 "PUSH_ID": 74544,
 "PUSH_STATUS": "0",
 "PUSH_TIMESTR": "2018-05-26 19:43:59",
 "PUSH_TITLE": "账号异常登录",
 "PUSH_TYPE": "01",
 "ROW_ID": 1
 }
 },
 */

@property (nonatomic,copy) NSString *MESSAGE_TYPE;
@property (nonatomic,strong) NSNumber *TOTAL;
@property (nonatomic,copy) NSNumber *UNREAD_SUM;
@property (nonatomic,retain) MessageModel *messageModel;

@end
