//
//  wifiSticalCenterViewController.h
//  ZHYQ
//
//  Created by coder on 2018/10/25.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "RootViewController.h"
#import "WifiInfoModel.h"
#import "InDoorWifiModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface wifiSticalCenterViewController : RootViewController

@property (nonatomic,retain) InDoorWifiModel *inDoorWifiModel;
@property (nonatomic,retain) WifiInfoModel *wifiInfoModel;

@property (nonatomic,assign) BOOL isALl;

@end

NS_ASSUME_NONNULL_END
