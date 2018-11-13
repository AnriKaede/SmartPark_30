//
//  StopParkListModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/9/29.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface StopParkListModel : BaseModel

/*
{
    "CARD_NAME": "王宏",
    "CARD_PHONE": "18975189098",
    "CARD_UNITINFO": "金迅",
    "SEAT_IDLE_CARNO": "湘AU4K46",
    "SEAT_NO": "0196",
    "SEAT_OCCUTIME": "20180911163318"
}
 */

@property (nonatomic,copy) NSString *CARD_NAME;
@property (nonatomic,copy) NSString *CARD_PHONE;
@property (nonatomic,copy) NSString *CARD_UNITINFO;
@property (nonatomic,copy) NSString *SEAT_IDLE_CARNO;
@property (nonatomic,copy) NSString *SEAT_NO;
@property (nonatomic,copy) NSString *SEAT_OCCUTIME;

@property (nonatomic,assign) BOOL isVip;
@property (nonatomic,assign) NSInteger topNum;

@end

NS_ASSUME_NONNULL_END
