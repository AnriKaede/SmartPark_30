//
//  MonitorTableViewCell.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/20.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InDoorMonitorMapModel.h"
#import "MonitorMapModel.h"

@class YQSwitch;

@interface MonitorTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *selectView;
@property (weak, nonatomic) IBOutlet UILabel *monitorNameLab;
@property (weak, nonatomic) IBOutlet UILabel *statusLab;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *screen;

@property (weak, nonatomic) IBOutlet UILabel *hisLab;
@property (weak, nonatomic) IBOutlet UIButton *playBackBtn;

@property (nonatomic,assign) BOOL isOpen;

@property (nonatomic,strong) InDoorMonitorMapModel *indoorModel;
@property (nonatomic,strong) MonitorMapModel *mapModel;

@end
