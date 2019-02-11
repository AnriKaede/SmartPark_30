//
//  ParkFeeFilterModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/24.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    PayTypeAll = 0,
    PayTypeWeChat,
    PayTypeCash,
    PayTypeYiPay,
    PayTypeAliPay
}ParkPayType;

@interface ParkFeeFilterModel : BaseModel

@property (nonatomic,copy) NSString *orderCode;
@property (nonatomic,copy) NSString *carNo;
@property (nonatomic,copy) NSString *lowMoney;
@property (nonatomic,copy) NSString *heightMoney;
@property (nonatomic,copy) NSArray *parkPayTypes;
@property (nonatomic,copy) NSString *beginTime;
@property (nonatomic,copy) NSString *endTime;

@end

NS_ASSUME_NONNULL_END
