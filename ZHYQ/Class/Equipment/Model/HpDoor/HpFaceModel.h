//
//  HpFaceModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/19.
//  Copyright © 2018 焦平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HpFaceModel : BaseModel

/*
{
    "ICCARD": "11093712",
    "NAME": "张三",
    "OPEN_TIME": "20181209121532",
    "FACEPHOTO": "",
    "ROW_ID": 6
}
 */

@property (nonatomic,copy) NSString *ICCARD;
@property (nonatomic,copy) NSString *NAME;
@property (nonatomic,copy) NSString *OPEN_TIME;
@property (nonatomic,copy) NSString *FACEPHOTO;
@property (nonatomic,strong) NSNumber *ROW_ID;
@property (nonatomic,copy) NSString *FM_DEVICE_NAME;
@property (nonatomic,copy) NSString *FM_JOIN_ID;

@end

NS_ASSUME_NONNULL_END
