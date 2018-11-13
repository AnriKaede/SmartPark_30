//
//  MessageModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/30.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface MessageModel : BaseModel

/*
{
    "IS_READ": "0",   --是否已读
    "MESSAGE_TYPE": "01",  消息类型
    "PUSH_CONTENT": "您的账号在另外一处登录，若是本人操作，请忽略！",
    "PUSH_ID": 351,   --
    "PUSH_STATUS": "1",  -- 0 未推送 1 推送  成功 2 推送失败
    "PUSH_TIMESTR": "2017-11-29 16:11:24",  推送时间
    "PUSH_TITLE": "账号异常登录",
    "PUSH_TYPE": "01",
    "ROWNUM_": 1
}
*/

@property (nonatomic, copy) NSString *IS_READ;
@property (nonatomic, copy) NSString *MESSAGE_TYPE;
@property (nonatomic, copy) NSString *PUSH_CONTENT;
@property (nonatomic, strong) NSNumber *PUSH_ID;
@property (nonatomic, copy) NSString *PUSH_STATUS;
@property (nonatomic, copy) NSString *PUSH_TIMESTR;
@property (nonatomic, copy) NSString *PUSH_TITLE;
@property (nonatomic, copy) NSString *PUSH_TYPE;
@property (nonatomic, strong) NSNumber *ROWNUM_;

@property (nonatomic, copy) NSString *MESSAGE_PUSH_INDEX;


@end
