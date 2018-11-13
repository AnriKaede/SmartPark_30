//
//  FirstMenuModel.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/10.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface FirstMenuModel : BaseModel
/*
 {
 "MENU_ICON" = "<null>";
 "MENU_ID" = 1;
 "MENU_LEVEL" = 1;
 "MENU_NAME" = "\U57fa\U7840\U8bbe\U5907";
 "MENU_ORDER" = 1;
 "MENU_TYPE" = 2;
 "MENU_URL" = "<null>";
 "PARENT_MENU_ID" = "-1";
 }
 */

@property (nonatomic,strong) NSNumber *MENU_ID;
@property (nonatomic,copy) NSString *MENU_TYPE;
@property (nonatomic,strong) NSNumber *MENU_ORDER;
@property (nonatomic,copy) NSString *MENU_ICON;
@property (nonatomic,copy) NSString *MENU_NAME;
@property (nonatomic,copy) NSString *MENU_LEVEL;
@property (nonatomic,copy) NSString *MENU_URL;
@property (nonatomic,strong) NSNumber *PARENT_MENU_ID;

@end
