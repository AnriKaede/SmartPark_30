//
//  ParkConsumeModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/18.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ParkConsumeModel : BaseModel

/*
{
    "carNo": "湘AK7N68",
    "isMonthFirst": true,
    "monthCnt": 6,
    "monthTotalFee": 15,
    "orderId": "AK7N68_219201812132640580270",
    "outTradeNo": "107142959751318121315450408397",
    "payTime": 1544687067000,
    "payType": "010",
    "terminalTime": "20181213154427",
    "totalFee": "1"
}
 */

@property (nonatomic,copy) NSString *carNo;
@property (nonatomic,assign) BOOL isMonthFirst; // 为yes 代表另起一组
@property (nonatomic,strong) NSNumber *monthCnt;
@property (nonatomic,strong) NSNumber *monthTotalFee;
@property (nonatomic,copy) NSString *orderId;
@property (nonatomic,copy) NSString *outTradeNo;
@property (nonatomic,strong) NSNumber *payTime;
@property (nonatomic,copy) NSString *payType;
@property (nonatomic,copy) NSString *terminalTime;
@property (nonatomic,copy) NSString *totalFee;

@end

NS_ASSUME_NONNULL_END
