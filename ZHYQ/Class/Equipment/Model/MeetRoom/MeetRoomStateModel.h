//
//  MeetRoomStateModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/6/29.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface MeetRoomStateModel : BaseModel

/*
{
    "id": 50397185,
    "name": "照明.会议室.筒灯Group1",
    "type": 1,
    "value": "0"
}
*/

@property (nonatomic,copy) NSString *state_id;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,strong) NSNumber *type;
@property (nonatomic,copy) NSString *value;

@property (nonatomic,copy) NSString *actionType;
@property (nonatomic,copy) NSString *writeId;

@end

