//
//  UnderParkModel.h
//  ZHYQ
//
//  Created by 焦平 on 2017/12/3.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface UnderParkModel : BaseModel
/*
 {
 seatAgentid = 8a04a41f56bc33a20156bc33a29f0000;
 seatAreaid = 8a04a41f56c0c3f90157277802150065;
 seatCode = 10000001;
 seatId = 8a10c18958a8d36d0158aed827f50017;
 seatIdle = 1;
 seatIdleCarno = "\U6e58AFE996";
 seatNo = 0001;
 seatOccutime = 20171202122626;
 seatParkcode = 40000021;
 seatParkid = 8a04a41f56bc33a20156bc3726df0004;
 seatUrl = "";
 }
 */


@property (nonatomic,copy) NSString *seatId;
@property (nonatomic,copy) NSString *seatCode;
@property (nonatomic,copy) NSString *seatNo;
@property (nonatomic,copy) NSString *seatAgentid;
@property (nonatomic,copy) NSString *seatOccutime;
@property (nonatomic,copy) NSString *seatUrl;
@property (nonatomic,copy) NSString *seatIdleCarno;
@property (nonatomic,copy) NSString *seatParkid;
@property (nonatomic,copy) NSString *seatIdle;
@property (nonatomic,copy) NSString *seatParkcode;
@property (nonatomic,copy) NSString *seatAreaid;


@end
