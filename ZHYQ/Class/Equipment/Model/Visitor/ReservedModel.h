//
//  ReservedModel.h
//  TCBuildingSluice
//
//  Created by 魏唯隆 on 2018/9/14.
//  Copyright © 2018年 魏唯隆. All rights reserved.
//

#import "BaseModel.h"


@interface ReservedModel : BaseModel

/*
{
    "appointmentId": "20180914116894",
    "arriveTime": null,
    "beginTime": 1536818400000,
    "cancelTime": null,
    "carNo": "湘B1ST23",
    "createTime": 1536888250000,
    "endTime": 1536840000000,
    "logoffTime": null,
    "persionWith": "jack",
    "qrCode": "http://220.168.59.15:8081/hntfEsb/upload/images/visit/D3499220C879191566FB8077D653406D.jpg",
    "reasionDesc": "拜访",
    "reasionId": "1",
    "remark": null,
    "reserveFive": null,
    "reserveFour": null,
    "reserveOne": null,
    "reserveThree": null,
    "reserveTwo": null,
    "status": "0",
    "tempCardId": "0000003365",
    "tempCardNo": "000a63f6",
    "userId": "1",
    "userName": "超级管理员",
    "visitorName": "文可为",
    "visitorPhone": "15367871667",
    "visitorSex": "1"
}
 */

@property (nonatomic,copy) NSString *appointmentId;
@property (nonatomic,strong) NSNumber *arriveTime;
@property (nonatomic,strong) NSNumber *beginTime;
@property (nonatomic,strong) NSNumber *cancelTime;
@property (nonatomic,copy) NSString *carNo;
@property (nonatomic,strong) NSNumber *createTime;
@property (nonatomic,strong) NSNumber *endTime;
@property (nonatomic,strong) NSNumber *logoffTime;
@property (nonatomic,copy) NSString *persionWith;
@property (nonatomic,copy) NSString *qrCode;
@property (nonatomic,copy) NSString *reasionDesc;
@property (nonatomic,copy) NSString *reasionId;
@property (nonatomic,copy) NSString *remark;
@property (nonatomic,copy) NSString *status;
@property (nonatomic,copy) NSString *tempCardId;
@property (nonatomic,copy) NSString *tempCardNo;
@property (nonatomic,copy) NSString *userName;
@property (nonatomic,copy) NSString *visitorName;
@property (nonatomic,copy) NSString *visitorPhone;
@property (nonatomic,copy) NSString *visitorSex;

@end
