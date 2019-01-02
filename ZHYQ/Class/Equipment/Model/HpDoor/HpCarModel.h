//
//  HpCarModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/19.
//  Copyright © 2018 焦平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HpCarModel : BaseModel

/*
{
    "DID": "900001",
    "FM_DEVICE_NAME": "天园研发大楼西侧大门",
    "OPEN_TIME": "20181209121532",
    "PLATE": "赣G12345",
    "PLATEPIC": "",
    "ROW_ID": 6,
    "TYPE": "1"
}
 */

@property (nonatomic,copy) NSString *DID;
@property (nonatomic,copy) NSString *FM_DEVICE_NAME;
@property (nonatomic,copy) NSString *OPEN_TIME;
@property (nonatomic,copy) NSString *PLATE;
@property (nonatomic,copy) NSString *PLATEPIC;
@property (nonatomic,strong) NSNumber *ROW_ID;
@property (nonatomic,copy) NSString *TYPE;
@property (nonatomic,copy) NSString *FM_JOIN_ID;

@end

NS_ASSUME_NONNULL_END
