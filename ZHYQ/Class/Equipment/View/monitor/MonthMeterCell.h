//
//  MonthMeterCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/11.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MonthMeterModel.h"

@interface MonthMeterCell : UITableViewCell

@property (nonatomic, retain) MonthMeterModel *monthMeterModel;
@property (nonatomic, assign) BOOL isWater;

@end
