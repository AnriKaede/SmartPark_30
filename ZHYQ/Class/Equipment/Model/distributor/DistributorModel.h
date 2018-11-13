//
//  DistributorModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/8/16.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"
#import "MeetRoomStateModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DistributorModel : BaseModel

/*
{
    "deviceAddr": "地下车库配电间",
    "deviceId": "-6088019",
    "deviceName": "变压器",
    "deviceOfferName": "变压器",
    "tagArray": [],
    "tagId": "184614913,184614914,184614915,184614916,184614918,184614919,184614920,184614921"
}
 */

@property (nonatomic,copy) NSString *deviceAddr;
@property (nonatomic,copy) NSString *deviceId;
@property (nonatomic,copy) NSString *deviceName;
@property (nonatomic,copy) NSString *deviceOfferName;
@property (nonatomic,copy) NSArray *tagArray;
@property (nonatomic,copy) NSString *tagId;

@property (nonatomic,copy) NSString *stateType; // 1:正常，2:超温，3:故障，4:跳闸
@property (nonatomic,copy) NSString *stateText;

@property (nonatomic,copy) NSString *ATemp;
@property (nonatomic,copy) NSString *BTemp;
@property (nonatomic,copy) NSString *CTemp;
@property (nonatomic,copy) NSString *hisHeightTemp;

@end

NS_ASSUME_NONNULL_END
