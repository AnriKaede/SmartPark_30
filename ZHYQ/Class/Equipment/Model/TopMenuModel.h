//
//  TopMenuModel.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/11.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface TopMenuModel : BaseModel

/*
 {
 "AREA_ID" = 1;
 "BUILDING_ID" = 1;
 "BUILDING_NAME" = "\U7814\U53d1\U697c";
 }
 */

@property (nonatomic,copy) NSString *AREA_ID;
@property (nonatomic,copy) NSString *BUILDING_ID;
@property (nonatomic,copy) NSString *BUILDING_NAME;

@property (nonatomic,copy) NSString *IS_OUT;

@end
