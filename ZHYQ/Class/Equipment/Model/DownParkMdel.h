//
//  DownParkMdel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/5.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface DownParkMdel : BaseModel

/*
{
    agentCompany = "<null>";
    areaName = "<null>";
    bayElectricity = "<null>";
    bayFlag = "<null>";
    carno = "<null>";
    parkAddress = "<null>";
    parkName = "<null>";
    seatAgentid = 8a04a41f56bc33a20156bc33a29f0000;
    seatAreaid = 8a04a41f56c0c3f90157277802150065;
    seatCode = 10000001;
    seatCtime = "<null>";
    seatExptime = "<null>";
    seatFreetime = "<null>";
    seatFx = 2;
    seatId = 8a10c18958a8d36d0158aed827f50017;
    seatIdle = 1;
    seatNo = 0001;
    seatOccutime = 20170907062104;
    seatParkcode = 40000021;
    seatParkid = 8a04a41f56bc33a20156bc3726df0004;
    seatPosition = "<null>";
    seatType = 0;
    seatUserid = 0000000000000000000000000000001;
    seatUtime = 20161129144911;
    seatXY = "337,408";
    traceMap = "<null>";
    traceTramt = "<null>";
}
 */

@property (nonatomic, copy) NSString *agentCompany;
@property (nonatomic, copy) NSString *areaName;
@property (nonatomic, copy) NSString *bayElectricity;
@property (nonatomic, copy) NSString *bayFlag;
@property (nonatomic, copy) NSString *carno;
@property (nonatomic, copy) NSString *parkAddress;
@property (nonatomic, copy) NSString *parkName;
@property (nonatomic, copy) NSString *seatAgentid;
@property (nonatomic, copy) NSString *seatAreaid;
@property (nonatomic, copy) NSString *seatCode;
@property (nonatomic, copy) NSString *seatCtime;
@property (nonatomic, copy) NSString *seatExptime;
@property (nonatomic, copy) NSString *seatFreetime;
@property (nonatomic, copy) NSString *seatFx;
@property (nonatomic, strong) NSNumber *seatId;
@property (nonatomic, copy) NSString *seatIdle;
@property (nonatomic, copy) NSString *seatNo;
@property (nonatomic, copy) NSString *seatOccutime;
@property (nonatomic, copy) NSString *seatParkcode;
@property (nonatomic, copy) NSString *seatParkid;
@property (nonatomic, copy) NSString *seatPosition;
@property (nonatomic, copy) NSString *seatType;
@property (nonatomic, copy) NSString *seatUserid;
@property (nonatomic, copy) NSString *seatUtime;
@property (nonatomic, copy) NSString *seatXY;
@property (nonatomic, copy) NSString *traceMap;
@property (nonatomic, copy) NSString *traceTramt;

@end
