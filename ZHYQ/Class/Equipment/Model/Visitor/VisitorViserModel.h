//
//  VisitorViserModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/20.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface VisitorViserModel : BaseModel

/*
{
    "address": "长沙市开福区东风二村2栋1门202房",
    "birthday": "1976-03-10 00:00:00",
    "id": 14,
    "idNum": "430105197603101046",
    "isbindface": 1,
    "isbindfinger": 0,
    "issuing": "长沙市公安局开福分局",
    "name": "罗琼",
    "nation": "汉",
    "photo": "\\image\\idpic\\430105197603101046.png",
    "pinYin": "lq",
    "sex": "女",
    "validityDateEnd": "2037-05-22",
    "validityDateStart": "2017-05-22 00:00:00"
}
 */

@property (nonatomic,copy) NSString *idNum;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *sex;
@property (nonatomic,copy) NSString *phone;

@end
