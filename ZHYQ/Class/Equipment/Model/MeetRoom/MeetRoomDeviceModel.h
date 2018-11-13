//
//  MeetRoomDeviceModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/7/25.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"


@interface MeetRoomDeviceModel : BaseModel

/*
{
    "DEVICE_ID": "5347654",
    "DEVICE_TYPE": "1",
    "READ_ID": "151322648",
    "TAGNAME": "TEMPERATUR",
    "WRITE_ID": "168099864"
}
 */

@property (nonatomic, copy) NSString *DEVICE_ID;
@property (nonatomic, copy) NSString *DEVICE_NAME;
@property (nonatomic, copy) NSString *DEVICE_TYPE;
@property (nonatomic, copy) NSString *READ_ID;
@property (nonatomic, copy) NSString *WRITE_ID;
@property (nonatomic, copy) NSString *TAGNAME;

@property (nonatomic, copy) NSString *current_state;

@end
