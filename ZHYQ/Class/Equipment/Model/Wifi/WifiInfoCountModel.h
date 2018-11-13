//
//  WifiInfoCountModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/6.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "BaseModel.h"
#import "WifiCountTypeModel.h"
#import "WifiCountTimeModel.h"
#import "WifiCountSpeedModel.h"
#import "WifiCountStrongModel.h"
#import "WifiNewUserModel.h"
#import "APNumModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WifiInfoCountModel : BaseModel

@property (nonatomic,copy) NSArray *addNewUser;
@property (nonatomic,copy) NSArray *clientType;
@property (nonatomic,copy) NSArray *sendAndRec;
@property (nonatomic,copy) NSArray *signalStrength;
@property (nonatomic,copy) NSArray *onlineTime;
@property (nonatomic,retain) APNumModel *APNum;

@end

NS_ASSUME_NONNULL_END
