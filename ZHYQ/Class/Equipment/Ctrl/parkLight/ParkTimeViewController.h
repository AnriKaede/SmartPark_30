//
//  ParkTimeViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/27.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "RootViewController.h"

typedef enum {
    ParkLightTask = 0,
    LEDTask,
    WaterTask
}TimeTaskType;

@interface ParkTimeViewController : RootViewController

@property (nonatomic,assign) TimeTaskType timeTaskType;

@property (nonatomic,copy) NSString *tagId;

@property (nonatomic,copy) NSString *navTitle;

@end
