//
//  VisitorUserModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/20.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface VisitorUserModel : BaseModel

/*
{
    "address": "",
    "create_time": "2017-08-11 15:04:27",
    "depID": 30,
    "ecardNum": "",
    "email": "admin",
    "id": 1038,
    "idNum": "1304331",
    "isbindface": 1,
    "isbindfinger": 0,
    "issuing": "",
    "last_login_time": "2018-01-19 15:58:32",
    "nation": 1,
    "nickname": "管理员1",
    "phone": "13931021490",
    "photo": "/image/idpic/130433198911033511.png",
    "pinYin": "gly",
    "pswd": "c25baf3538db9cd490736598f88d2ad8",
    "rowtemp": "2018-01-19 15:58:32",
    "telephone": ""
}
 */

@property (nonatomic,copy) NSString *nickname;

@end
