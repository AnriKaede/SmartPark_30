//
//  EnergyConCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/11.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaterListModel.h"
#import "ElectricInfoModel.h"

@interface EnergyConCell : UITableViewCell

@property (nonatomic, retain) WaterListModel *waterListModel;
@property (nonatomic, retain) ElectricInfoModel *electricInfoModel;

@property (weak, nonatomic) IBOutlet UIView *topLineView;


@end
