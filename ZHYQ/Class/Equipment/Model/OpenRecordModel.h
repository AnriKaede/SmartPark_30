//
//  OpenRecordModel.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/23.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface OpenRecordModel : BaseModel
/*
 {
 "Base_Access_DateTime_STR" = "2017-11-23 12:56:39";
 "Base_Card_No" = 964FE2EC;
 "Base_Card_Status" = 1;
 "Base_Employee_ID" = 0000000003;
 "Base_Log_ID" = 17;
 "Base_Open_Flag" = 16;
 "Base_PerName" = "\U6d4b\U8bd51";
 }
 */

@property (nonatomic,copy) NSString *Base_Card_No;
@property (nonatomic,copy) NSString *Base_Card_Status;
@property (nonatomic,strong) NSNumber *Base_Open_Flag;
@property (nonatomic,copy) NSString *Base_Employee_ID;
@property (nonatomic,strong) NSNumber *Base_Log_ID;
@property (nonatomic,copy) NSString *Base_Access_DateTime_STR;
@property (nonatomic,copy) NSString *Base_PerName;
@property (nonatomic,copy) NSString *Base_PerNo;

@property (nonatomic,copy) NSString *openDoorLogType;

@property (nonatomic,strong) NSNumber *Base_Access_DateTime;

@end
