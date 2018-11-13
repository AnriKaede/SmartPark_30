//
//  ElectricListModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/28.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface ElectricListModel : BaseModel

/*
{
    "deviceList": [],
    "energyName": "办公室空调",
    "energyType": "1"
}
 */

@property (nonatomic,copy) NSArray *deviceList;
@property (nonatomic,copy) NSString *energyName;
@property (nonatomic,copy) NSString *energyType;

@end
