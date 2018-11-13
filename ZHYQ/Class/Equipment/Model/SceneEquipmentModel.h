//
//  SceneEquipmentModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/17.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface SceneEquipmentModel : BaseModel

/*
{
    "modelId": "meeting",
    "modelName": "开会模式",
    "tagId": "50397194",
    "tagName": "灯膜2",
    "tagType": "1",
    "tagValue": "0"
}
*/

@property (nonatomic, copy) NSString *modelId;
@property (nonatomic, copy) NSString *modelName;
@property (nonatomic, copy) NSString *tagId;
@property (nonatomic, copy) NSString *tagName;
@property (nonatomic, copy) NSString *tagType;
@property (nonatomic, copy) NSString *tagValue;

@property (nonatomic, copy) NSString *uuid;

@property (nonatomic, copy) NSString *tagStatus;    // 开关状态

@property (nonatomic, copy) NSString *deviceType;
 
@end
