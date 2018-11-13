//
//  ParkLockModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/2.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface ParkLockModel : BaseModel

/*
{
    "lockId": "SPOTCOMME00530FDDF48488272727171",
    "lockName": "BTPL_11E8A0",
    "lockMac": "00:1B:35:11:E8:A0",
    "lockSecret": "SPOTCOMME00530FDDF48488272727171",
    "lockAgentid": "8a04a41f56bc33a20156bc33a29f0000",
    "lockParkid": "8a04a41f56bc33a20156bc3726df0004",
    "lockParkcode": "40000021",
    "lockAreaid": "8a04a41f56bc33a20156bc3726df0006",
    "lockSeatId": "8a10c18958a8d36d0158aed8281f002a",
    "lockSeatCode": "1002",
    "lockFlag": "0",
    "lockLng": null,
    "lockLat": null,
    "lockOccutime": null,
    "lockVoltage": null
}
 */

@property (nonatomic, copy) NSString *lockId;
@property (nonatomic, copy) NSString *lockName;
@property (nonatomic, copy) NSString *lockMac;
@property (nonatomic, copy) NSString *lockSecret;
@property (nonatomic, copy) NSString *lockAgentid;
@property (nonatomic, copy) NSString *lockParkid;
@property (nonatomic, copy) NSString *lockParkcode;
@property (nonatomic, copy) NSString *lockAreaid;
@property (nonatomic, copy) NSString *lockSeatId;
@property (nonatomic, copy) NSString *lockSeatCode;
@property (nonatomic, copy) NSString *lockFlag;
@property (nonatomic, copy) NSString *lockLng;
@property (nonatomic, copy) NSString *lockLat;
@property (nonatomic, copy) NSString *lockOccutime;
@property (nonatomic, copy) NSString *lockVoltage;

@end
