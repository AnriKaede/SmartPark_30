//
//  SeatStatusModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/5.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface SeatStatusModel : BaseModel

/*
{
    "seatOccutimeView": "2017-12-05 15:25:25",
    "seatOccutimeTime": "4小时33分钟",
    "seatId": "8a10c18958a8d36d0158aed827f50017",
    "seatCode": "10000001",
    "seatNo": "0001",
    "seatAreaid": "8a04a41f56c0c3f90157277802150065",
    "seatAgentid": "8a04a41f56bc33a20156bc33a29f0000",
    "seatParkid": "8a04a41f56bc33a20156bc3726df0004",
    "seatParkcode": "40000021",
    "seatIdle": "1",
    "seatIdleCarno": "湘AFE996",
    "seatOccutime": "20171205152525",
    "seatUrl": ""
}
 */

@property (nonatomic, copy) NSString *seatOccutimeView;
@property (nonatomic, copy) NSString *seatOccutimeTime;
@property (nonatomic, copy) NSString *seatId;
@property (nonatomic, copy) NSString *seatCode;
@property (nonatomic, copy) NSString *seatNo;
@property (nonatomic, copy) NSString *seatAreaid;
@property (nonatomic, copy) NSString *seatAgentid;
@property (nonatomic, copy) NSString *seatParkid;
@property (nonatomic, copy) NSString *seatParkcode;
@property (nonatomic, copy) NSString *seatIdle;
@property (nonatomic, copy) NSString *seatIdleCarno;
@property (nonatomic, copy) NSString *seatOccutime;
@property (nonatomic, copy) NSString *seatUrl;

@property (nonatomic, copy) NSString *seatXY;

@end
