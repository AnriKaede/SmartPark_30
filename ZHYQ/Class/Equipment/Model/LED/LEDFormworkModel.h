//
//  LEDFormworkModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/20.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LEDFormworkModel : BaseModel

/*
{
    "contents": "测试测试1111",
    "createTime": 1542352830000,
    "id": "1063330958888927232",
    "title": "测试测试1",
    "updateTime": 1542419645000
}
 */

@property (nonatomic,copy) NSString *contents;
@property (nonatomic,strong) NSNumber *createTime;
@property (nonatomic,copy) NSString *ledFormworkId;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,strong) NSNumber *updateTime;

@end

NS_ASSUME_NONNULL_END
