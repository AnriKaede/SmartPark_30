//
//  MonthMeterViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/11.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "RootViewController.h"
#import "WaterListModel.h"
#import "ElectricInfoModel.h"

@interface MonthMeterViewController : RootViewController

@property (nonatomic,retain) WaterListModel *waterListModel;

@property (nonatomic,retain) ElectricInfoModel *electricInfoModel;

@end
