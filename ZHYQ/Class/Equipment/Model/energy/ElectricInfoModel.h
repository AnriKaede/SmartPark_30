//
//  ElectricInfoModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/28.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface ElectricInfoModel : BaseModel

/*
{
    "deviceIoValue": 0,
    "deviceName": "能源.电.双速风机电源13AT-1(主供)-电量",
    "tagid": "83951662"
}
 */

@property (nonatomic,strong) NSNumber *deviceIoValue;
@property (nonatomic,copy) NSString *deviceName;
@property (nonatomic,copy) NSString *tagid;

@end
