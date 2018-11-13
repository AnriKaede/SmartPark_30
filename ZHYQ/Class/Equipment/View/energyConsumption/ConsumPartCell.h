//
//  ConsumPartCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/15.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EnergyElectricUseModel.h"
#import "EnergyWaterUseModel.h"

@interface ConsumPartCell : UITableViewCell

@property (nonatomic, retain) EnergyElectricUseModel *electricUseModel;

@property (nonatomic, retain) EnergyWaterUseModel *waterUseModel;

@end
