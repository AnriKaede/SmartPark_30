//
//  FindCarNoModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/3.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface FindCarNoModel : BaseModel

/*
 {
     "CARD_CARCOLOR": "白色",
     "CARD_DEPARTMENT": "数据产品事业部",
     "CARD_JOB": "3",
     "CARD_JOBNUMBER": "020539",
     "CARD_LEVEL": "00",
     "CARD_NAME": "周桂宗",
     "CARD_NATURE": "1",
     "CARD_PHONE": "18008443877",
     "CARD_SEX": "1",
     "CARD_UNITINFO": "创发",
     "CAR_NO": "湘KAY725"
 }

 */

@property (nonatomic,copy) NSString *CAR_NO;
@property (nonatomic,copy) NSString *CARD_NAME;
@property (nonatomic,copy) NSString *CARD_PHONE;
@property (nonatomic,copy) NSString *CARD_DEPARTMENT;
@property (nonatomic,copy) NSString *CARD_UNITINFO;
@property (nonatomic,copy) NSString *CARD_CARCOLOR;

@end
