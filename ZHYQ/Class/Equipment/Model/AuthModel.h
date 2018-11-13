//
//  AuthModel.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/23.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface AuthModel : BaseModel
/*
 {
 "Base_CardNo" = 964FE2EC;
 "Base_Device_ID" = 1;
 "Base_Employee_ID" = 0000000003;
 "Base_PerName" = "\U6d4b\U8bd51";
 }
 */

@property (nonatomic,strong) NSNumber *Base_Device_ID;
@property (nonatomic,copy) NSString *Base_CardNo;
@property (nonatomic,copy) NSString *Base_Employee_ID;
@property (nonatomic,copy) NSString *Base_PerName;

@property (nonatomic,copy) NSString *Base_PerNo;
@end
