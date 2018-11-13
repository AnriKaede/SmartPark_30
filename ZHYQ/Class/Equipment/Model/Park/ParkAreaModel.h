//
//  ParkAreaModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/6/19.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface ParkAreaModel : BaseModel

@property (nonatomic,copy) NSString *areaId;    // 2001前坪，2002南坪，2003地下
@property (nonatomic,copy) NSString *areaName;    // 2001前坪，2002南坪，2003地下
@property (nonatomic,copy) NSArray *parkSpaces; // ParkSpaceModel数组

@property (nonatomic,assign) BOOL isDisplay;    // 是否展开/批量操作时代表当前组是否选中

@end

