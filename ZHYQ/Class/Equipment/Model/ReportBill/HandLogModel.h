//
//  HandLogModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/17.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface HandLogModel : BaseModel
/*
{
    "deviceId": null,
    "deviceName": "305左侧入口门",
    "deviceOfferName": null,
    "handleContent": null,
    "handleDate": "2018-05-17 11:05:37",
    "handleId": "68802",
    "handleImage": "http://220.168.59.15:8081/hntfEsb/upload/images//temp/1805171103100596057f081ba4a05958268a9b372f14a.jpg",
    "orderId": "68759",
    "orderStateAfter": "03",
    "orderStateBefore": "02",
    "remark": "真修好了",
    "userId": "2",
    "userName": "hntf"
}
*/

@property (nonatomic,copy) NSString *handleImage;
@property (nonatomic,copy) NSString *remark;

@end
