//
//  ParkOverModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/11.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "BaseModel.h"
#import "OverAlarmModel.h"
#import "OverCheckModel.h"
#import "OverOnlineModel.h"
#import "OverDealModel.h"

NS_ASSUME_NONNULL_BEGIN

/*
{
    "alarm": {
        "items": [
                  {
                      "alarmLevelCount": 170,
                      "alarmLevelId": "1",
                      "alarmLevelName": "可疑"
                  },
                  {
                      "alarmLevelCount": 880,
                      "alarmLevelId": "2",
                      "alarmLevelName": "一般"
                  },
                  {
                      "alarmLevelCount": 0,
                      "alarmLevelId": "3",
                      "alarmLevelName": "严重"
                  },
                  {
                      "alarmLevelCount": 0,
                      "alarmLevelId": "4",
                      "alarmLevelName": "灾难"
                  }
                  ],
        "totalCount": 1050
    },
    "inspection": {
        "items": [
                  {
                      "routingOrderStatus": "1",
                      "routingOrderStatusCount": 0,
                      "routingOrderStatusName": "待执行"
                  },
                  {
                      "routingOrderStatus": "2",
                      "routingOrderStatusCount": 0,
                      "routingOrderStatusName": "执行中"
                  },
                  {
                      "routingOrderStatus": "3",
                      "routingOrderStatusCount": 0,
                      "routingOrderStatusName": "已执行"
                  },
                  {
                      "routingOrderStatus": "4",
                      "routingOrderStatusCount": 0,
                      "routingOrderStatusName": "未执行"
                  }
                  ],
        "totalCount": 0
    },
    "online": {
        "items": [
                  {
                      "onlineStatus": "1",
                      "onlineStatusCount": 0,
                      "onlineStatusName": "在线"
                  },
                  {
                      "onlineStatus": "0",
                      "onlineStatusCount": 0,
                      "onlineStatusName": "离线"
                  }
                  ],
        "totalCount": 0
    },
    "used": {
        "items": [
                  {
                      "overallStatus": "1",
                      "overallStatusCount": 0,
                      "overallStatusName": "开启"
                  },
                  {
                      "overallStatus": "2",
                      "overallStatusCount": 0,
                      "overallStatusName": "关闭"
                  }
                  ],
        "totalCount": 0
    }
}
*/

@interface ParkOverModel : BaseModel

@property (nonatomic,copy) NSArray *onlines;
@property (nonatomic,strong) NSNumber *onlineTotalCount;

@property (nonatomic,copy) NSArray *alarms;
@property (nonatomic,strong) NSNumber *alarmTotalCount;

@property (nonatomic,copy) NSArray *useds;
@property (nonatomic,strong) NSNumber *usedTotalCount;

@property (nonatomic,copy) NSArray *inspections;
@property (nonatomic,strong) NSNumber *inspectionTotalCount;

@end

NS_ASSUME_NONNULL_END
