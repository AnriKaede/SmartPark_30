//
//  RemoteModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/23.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface RemoteModel : BaseModel

/*
{
    "APP_TYPE": "admin",
    "CERT_IDS": "admin",
    "CREATE_DATE": 1513936624000,
    "OPEN_LOGID": 602,
    "OS_RESULET": "1",
    "OS_USER": "admin",
    "RN": 10,
    "TAGID": "1"
}
 */

@property (nonatomic, copy) NSString *APP_TYPE;
@property (nonatomic, copy) NSString *CERT_IDS;
@property (nonatomic, strong) NSNumber *CREATE_DATE;
@property (nonatomic, strong) NSNumber *OPEN_LOGID;
@property (nonatomic, copy) NSString *OS_RESULET;
@property (nonatomic, copy) NSString *OS_USER;
@property (nonatomic, strong) NSNumber *RN;
@property (nonatomic, copy) NSString *TAGID;

@property (nonatomic, copy) NSString *CUST_NAME;

@end
