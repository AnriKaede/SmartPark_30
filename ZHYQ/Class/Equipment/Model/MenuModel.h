//
//  MenuModel.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/11.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface MenuModel : BaseModel

/*
 {
 "MENU_ICON" = "equipment_smartHome";
 "MENU_ID" = 29;
 "MENU_LEVEL" = 2;
 "MENU_NAME" = "\U667a\U6167\U5bb6\U5c45";
 "MENU_ORDER" = 29;
 "MENU_TYPE" = 2;
 "MENU_URL" = "<null>";
 "PARENT_MENU_ID" = 4;
 }
 */

@property (nonatomic,copy) NSString *MENU_ICON;

@property (nonatomic,strong) NSNumber *MENU_ID;

@property (nonatomic,copy) NSString *MENU_TYPE;

@property (nonatomic,strong) NSNumber *MENU_ORDER;

@property (nonatomic,copy) NSString *MENU_NAME;

@property (nonatomic,copy) NSString *MENU_LEVEL;

@property (nonatomic,copy) NSString *MENU_URL;

@property (nonatomic,strong) NSNumber *PARENT_MENU_ID;

@end
