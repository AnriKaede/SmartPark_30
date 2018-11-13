//
//  WifiInfoModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/6.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WifiInfoModel : BaseModel

/*
{
    group = "研发楼";
    id = 15305687849901293568;
    mac = "D4-68-BA-01-A8-61";
    name = "3层306_A8_61";
    recv = "441.10000610352";
    send = "332.89999389648";
    status = 1;
    usercount = 4;
}
 */

@property (nonatomic,copy) NSString *group;
@property (nonatomic,strong) NSNumber *wifiId;
@property (nonatomic,copy) NSString *mac ;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *recv;
@property (nonatomic,copy) NSString *send;
@property (nonatomic,strong) NSNumber *status;
@property (nonatomic,strong) NSNumber *usercount;

@end

NS_ASSUME_NONNULL_END
