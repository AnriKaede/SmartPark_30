//
//  AdcMenuView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/14.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubDeviceModel.h"

@protocol CurrentScreenDelegate <NSObject>

- (void)currentScreen:(SubDeviceModel *)subDeviceModel;

@end

@interface AdcMenuView : UIView
- (void)showMenu;
- (void)hidMenu;

@property (nonatomic, retain) SubDeviceModel *subDeviceModel;

@property (nonatomic, copy) NSString *parentDevName;
@property (nonatomic,assign) id<CurrentScreenDelegate> currentScreenDelegate;

@end
