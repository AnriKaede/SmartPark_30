//
//  MeetRoomGroupModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/7/25.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface MeetRoomGroupModel : BaseModel

/*
{
    "ROOM_ID": "107",
    "ROOM_NAME": "107会议室"
}
*/

@property (nonatomic,copy) NSString *ROOM_ID;
@property (nonatomic,copy) NSString *ROOM_NAME;

@end
