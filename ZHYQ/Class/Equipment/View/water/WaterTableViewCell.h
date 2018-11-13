//
//  WaterTableViewCell.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/6.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WaterModel.h"

@protocol WaterSwitchDelegate <NSObject>

- (void)switchWater:(WaterModel *)waterModel withOpen:(BOOL)isOpen withAllCon:(BOOL)isAllCon;

@end

@interface WaterTableViewCell : UITableViewCell

@property (nonatomic,strong) WaterModel *model;
@property (nonatomic,assign) id<WaterSwitchDelegate> switchDelegate;

@end
