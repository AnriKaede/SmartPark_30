//
//  CarBlackListModel.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/29.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface CarBlackListModel : BaseModel

/*
 {
 "illegalId": "8a10c189589eb2ee01589fe8ae8f0002",
 "illegalAgentid": "8a04a41f56bc33a20156bc33a29f0000",
 "illegalParkid": "8a04a41f56bc33a20156bc3726df0004",
 "illegalParkcode": "40000021",
 "illegalCarno": "鄂A99K63",
 "illegalName": "",
 "illegalPhone": "",
 "illegalType": "01",
 "illegalNum": 2,
 "illegalStatus": "01",
 "agentCompany": null,
 "parkName": null,
 "illegalUpdatetime": "20161201172635"
 },
 */

@property (nonatomic,copy) NSString *illegalId;
@property (nonatomic,copy) NSString *illegalAgentid;
@property (nonatomic,copy) NSString *illegalParkcode;
@property (nonatomic,strong) NSNumber *illegalNum;
@property (nonatomic,copy) NSString *illegalCarno;
@property (nonatomic,copy) NSString *illegalStatus;
@property (nonatomic,copy) NSString *illegalUpdatetime;
@property (nonatomic,copy) NSString *illegalType;
@property (nonatomic,copy) NSString *parkName;
@property (nonatomic,copy) NSString *illegalName;
@property (nonatomic,copy) NSString *illegalParkid;
@property (nonatomic,copy) NSString *agentCompany;
@property (nonatomic,copy) NSString *illegalPhone;

@property (nonatomic,copy) NSString *illegalContent;

@end
