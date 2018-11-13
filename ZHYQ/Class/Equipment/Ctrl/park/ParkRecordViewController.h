//
//  ParkRecordViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/29.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "RootViewController.h"

typedef enum {
    ParkAll = 0,
    ParkAppointment,
    ParkIn,
    ParkOut
}ParkStyle;

@interface ParkRecordViewController : RootViewController

@property (nonatomic,assign) ParkStyle parkStyle;
@property (nonatomic,copy) NSString *carNo;

@end
