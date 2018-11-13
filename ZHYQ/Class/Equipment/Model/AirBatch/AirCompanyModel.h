//
//  AirCompanyModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/7/27.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface AirCompanyModel : BaseModel
/*
{
    "companyId": "1",
    "companyName": "湖南省通信产业服务有限公司",
    "layers": []
}
 */

@property (nonatomic,copy) NSString *companyId;
@property (nonatomic,copy) NSString *companyName;
@property (nonatomic,copy) NSArray *layers;

@property (nonatomic,assign) BOOL isSelect;
@property (nonatomic,assign) BOOL isDisplay;

@end
