//
//  AirRoomModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/7/27.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"


@interface AirRoomModel : BaseModel

/*
{
    "roomId": "1000",
    "roomName": "1000"
}
 */

@property (nonatomic,copy) NSString *roomId;
@property (nonatomic,copy) NSString *roomName;

@end
