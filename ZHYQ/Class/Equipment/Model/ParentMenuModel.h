//
//  ParentMenuModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/23.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface ParentMenuModel : BaseModel
/*
{
    items =     (
                 {
                     "MENU_ICON" = "equipment_brokenEquipment";
                     "MENU_ID" = 5;
                     "MENU_LEVEL" = 2;
                     "MENU_NAME" = "\U6545\U969c\U8bbe\U5907";
                     "MENU_ORDER" = 5;
                     "MENU_TYPE" = 2;
                     "MENU_URL" = "<null>";
                     "PARENT_MENU_ID" = 0;
                 },
                 
                 );
    parentMenuId = 0;
}
 */

@property (nonatomic,copy) NSArray *items;
@property (nonatomic,copy) NSString *parentMenuId;

@end
