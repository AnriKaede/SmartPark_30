//
//  WaterModel.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/24.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface WaterModel : BaseModel

/*
 {
 equipmentId = 1001;
 equipmentName = "\U667a\U80fd\U704c\U6e89NO1";
 fertilizerCost = 1;
 offTime = "10:20";
 onTime = "9:10";
 status = 0;
 waterCost = 2;
 }
 */

/*
@property (nonatomic,copy) NSString *onTime;
@property (nonatomic,copy) NSString *equipmentId;
@property (nonatomic,copy) NSString *equipmentName;
@property (nonatomic,copy) NSString *status;
@property (nonatomic,copy) NSString *fertilizerCost;
@property (nonatomic,copy) NSString *offTime;
@property (nonatomic,copy) NSString *waterCost;
*/

/*
{
    "ctrl_method": "0",
    "ctrl_status": 3,
    "dev_sd": 1,
    "device_id": 145893,
    "device_name": "土壤水分01",
    "device_num": 1,
    "down_name": "打开",
    "is_sync": "1",
    "run_time": 7200,
    "sensor_type_id": 162,
    "serial_num": "553648537",
    "sns_low_val": 5,
    "sns_up_val": 60,
    "stop_name": "关闭",
    "terminal_type": 33,
    "up_name": "打开"
}
 */

@property (nonatomic,copy) NSString *device_name;
@property (nonatomic,strong) NSNumber *device_id;
@property (nonatomic,strong) NSNumber *ctrl_status;
@property (nonatomic,strong) NSNumber *terminal_type;
@property (nonatomic,retain) NSString *serial_num;

@end
