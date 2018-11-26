//
//  MusicTimeModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/12.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface MusicTimeModel : BaseModel

/*
{
    "days": [],                     ----每周天数列表，type=2时才有效
    "duration": 0,                   ----持续时间，单位秒
    "endTime": "2017-12-09 00:00:00",  ----任务过期时间(RW)
    "id": 2,                         ----定时任务ID
    "intrs": 1,                   ----定时间隔，如1，表示每一天或每一周
    "jobData": 0,                   ----默认赋值1 任务数据
    "mask": 0,                      ----默认赋值0 任务掩码
    "mode": 1,                     ----任务播放模式 1 - 随机, 0 - 顺序
    "name": "测试定时任务",         ----任务名称
    "owner": "admin",               ----任务创建人
    "prePower": 0,                  ----预开电源时间 秒
    "repeated": 1,                    ----播放重复次数
    "startTime": "2017-12-09 16:27:23",    ----任务开始时间
    "status": 0,                  ----任务执行状态：0未启动；1启动
    "type": 4,            ----1,每天;2每周;3每月(不支持);4一次性任务
    "vol": 2                  ----任务音量
}
 */

@property (nonatomic,copy) NSArray *days;
@property (nonatomic,strong) NSNumber *musicTimeId;
@property (nonatomic,copy) NSString *startTime;
@property (nonatomic,strong) NSNumber *status;
@property (nonatomic,copy) NSString *name;

@property (nonatomic,strong) NSNumber *vol;

@property (nonatomic,copy) NSString *musicType;

@property (nonatomic,assign) BOOL isSelect;

@end
