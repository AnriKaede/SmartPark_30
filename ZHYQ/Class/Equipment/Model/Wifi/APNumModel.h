//
//  APNumModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/7.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface APNumModel : BaseModel

// okNum在线,  out离线,trusteeship 是托管 aptotal 是总数 alarm 是烟感告警数
@property (nonatomic,copy) NSString *alarmNum;
@property (nonatomic,copy) NSString *APtotal;
@property (nonatomic,copy) NSString *okNum;
@property (nonatomic,copy) NSString *outNum;
@property (nonatomic,copy) NSString *trusteeshipNum;

@end

NS_ASSUME_NONNULL_END
