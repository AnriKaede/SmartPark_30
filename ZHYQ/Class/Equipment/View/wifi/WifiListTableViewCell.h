//
//  WifiListTableViewCell.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/15.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InDoorWifiModel.h"
#import "WifiMapModel.h"
#import "WifiInfoModel.h"

@class YQSwitch;

@interface WifiListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *wifiNameLab;

@property (weak, nonatomic) IBOutlet YQSwitch *wifiSwitch;

@property (weak, nonatomic) IBOutlet UIView *selectView;

@property (weak, nonatomic) IBOutlet UILabel *locationLab;
@property (weak, nonatomic) IBOutlet UILabel *locationNumLab;

@property (weak, nonatomic) IBOutlet UILabel *netSepLab;
@property (weak, nonatomic) IBOutlet UILabel *netSepNumLab;

@property (weak, nonatomic) IBOutlet UILabel *sendLab;
@property (weak, nonatomic) IBOutlet UILabel *sendNumLab;

@property (weak, nonatomic) IBOutlet UILabel *userLab;
@property (weak, nonatomic) IBOutlet UILabel *userNumLab;
@property (weak, nonatomic) IBOutlet UIButton *userNumBt;

@property (nonatomic,strong) InDoorWifiModel *model;
@property (nonatomic,strong) WifiMapModel *mapModel;
@property (nonatomic,retain) WifiInfoModel *wifiInfoModel;

@end
