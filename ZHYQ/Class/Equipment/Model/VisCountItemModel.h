//
//  VisCountItemModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/22.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface VisCountItemModel : BaseModel

/*
{
    "areaId": "1001",
    "areaName": "创发",
    "female": "5",
    "leave": "40",
    "male": "45",
    "stay": "10",
    "totalVisitor": "50"
}
 */

@property (nonatomic, copy) NSString *areaId;
@property (nonatomic, copy) NSString *areaName;
@property (nonatomic, copy) NSString *female;
@property (nonatomic, copy) NSString *leave;
@property (nonatomic, copy) NSString *male;
@property (nonatomic, copy) NSString *stay;
@property (nonatomic, copy) NSString *totalVisitor;

@end
