//
//  RepairsManModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/14.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface RepairsManModel : BaseModel

/*
{
    "USER_ID": "1",
    "USER_NAME": "超级管理员"
}
 */

@property (nonatomic,copy) NSString *USER_ID;
@property (nonatomic,copy) NSString *USER_NAME;

@end
