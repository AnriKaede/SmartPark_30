//
//  LedListModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/2/2.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface LedListModel : BaseModel

/*
{
    "deviceId": "1401",
    "deviceName": "LED广告屏(西)",
    "layerId": 20,
    "status": "0",
    "tagid": "5a4af8d298f1ac15eefab9f4",
    "type": "1"
}
 */

@property (nonatomic,copy) NSString *deviceId;
@property (nonatomic,copy) NSString *deviceName;
@property (nonatomic,strong) NSNumber *layerId;
@property (nonatomic,copy) NSString *tagid;
@property (nonatomic,copy) NSString *type;
@property (nonatomic,copy) NSString *status;

@property (nonatomic,copy) NSString *mainstatus;

@property (nonatomic,copy) NSString *program;

@property (nonatomic,assign) BOOL isSelect;

@end
