//
//  BillProgressModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/15.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface BillProgressModel : BaseModel

/*
{
    "deviceId": null,
    "deviceName": null,
    "deviceOfferName": null,
    "handleContent": "测试 上报故障,测试故障信息1:admin",
    "handleDate": "2018-05-03 00:00:00",
    "handleId": null,
    "handleImage": null,
    "orderId": null,
    "orderStateAfter": null,
    "orderStateBefore": null,
    "remark": null,
    "userId": "admin",
    "userName": "测试"
}
 */

@property (nonatomic,copy) NSString *deviceId;
@property (nonatomic,copy) NSString *deviceName;
@property (nonatomic,copy) NSString *deviceOfferName;
@property (nonatomic,copy) NSString *handleContent;
@property (nonatomic,copy) NSString *handleDate;
@property (nonatomic,copy) NSString *handleId;
@property (nonatomic,copy) NSString *handleImage;
@property (nonatomic,copy) NSString *orderId;
@property (nonatomic,copy) NSString *orderStateAfter;
@property (nonatomic,copy) NSString *orderStateBefore;
@property (nonatomic,copy) NSString *remark;
@property (nonatomic,copy) NSString *userId;
@property (nonatomic,copy) NSString *userName;

@property (nonatomic,assign) BOOL isFirst;
@property (nonatomic,assign) BOOL isLast;

@end
