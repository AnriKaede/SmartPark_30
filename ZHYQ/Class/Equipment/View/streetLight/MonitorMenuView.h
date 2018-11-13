//
//  MonitorMenuView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/14.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubDeviceModel.h"

@protocol PlayMonitorDelegate <NSObject>

- (void)playMonitorDelegate:(SubDeviceModel *)subDeviceModel;
- (void)playBackMonitorDelegate:(SubDeviceModel *)subDeviceModel;

@end

@interface MonitorMenuView : UIView
- (void)showMenu;
- (void)hidMenu;

@property (nonatomic, retain) SubDeviceModel *subDeviceModel;
@property (nonatomic, assign) id<PlayMonitorDelegate> playMonitorDelegate;

@end
