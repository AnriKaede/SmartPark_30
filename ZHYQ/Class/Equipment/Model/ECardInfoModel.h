//
//  ECardInfoModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/22.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface ECardInfoModel : BaseModel

/*
{
    "baseCardNo": "67B4DA5D",
    "baseIsIDIC": "D",
    "basePerId": "0000000961",
    "basePerName": "朱志强",
    "basePerNo": "000005",
    "baseSex": "1",
    "baseState": "1",
    "baseType": "0 ",
    "companyId": "0038",
    "companyName": "省通信服务有限公司",
    "departId": "0056",
    "departName": "公司领导"
}
 */

@property (nonatomic,copy) NSString *baseCardNo;
@property (nonatomic,copy) NSString *baseIsIDIC;
@property (nonatomic,copy) NSString *basePerId;
@property (nonatomic,copy) NSString *basePerName;
@property (nonatomic,copy) NSString *basePerNo;
@property (nonatomic,copy) NSString *baseSex;
@property (nonatomic,copy) NSString *baseState;
@property (nonatomic,copy) NSString *baseType;
@property (nonatomic,copy) NSString *companyId;
@property (nonatomic,copy) NSString *companyName;
@property (nonatomic,copy) NSString *departId;
@property (nonatomic,copy) NSString *departName;

@end
