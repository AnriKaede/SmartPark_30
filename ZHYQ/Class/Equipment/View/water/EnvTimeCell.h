//
//  EnvTimeCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/3/1.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EvnDelModel.h"
#import "EvnDataModel.h"

@interface EnvTimeCell : UITableViewCell

@property (nonatomic, retain) EvnDataModel *evnDataModel;

@property (nonatomic, retain) EvnDelModel *evnDelModel;

@end
