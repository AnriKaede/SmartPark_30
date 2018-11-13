//
//  WaterListModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/27.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface WaterListModel : BaseModel

@property (nonatomic,strong) NSNumber *deviceIoValue;
@property (nonatomic,copy) NSString *deviceName;
@property (nonatomic,copy) NSString *tagid;

@end
