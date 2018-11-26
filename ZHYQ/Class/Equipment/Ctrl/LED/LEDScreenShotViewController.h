//
//  LEDScreenShotViewController.h
//  ZHYQ
//
//  Created by coder on 2018/10/23.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "RootViewController.h"
#import "LedListModel.h"
#import "SubDeviceModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LEDScreenShotViewController : RootViewController

@property (nonatomic,retain) LedListModel *ledListModel;
@property (nonatomic,assign) BOOL isStreetLight;
@property (nonatomic,retain) SubDeviceModel *subDeviceModel;

@end

NS_ASSUME_NONNULL_END
