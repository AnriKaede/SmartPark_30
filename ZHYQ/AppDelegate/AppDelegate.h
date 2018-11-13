//
//  AppDelegate.h
//  ZHYQ
//
//  Created by 焦平 on 2017/10/21.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTabbarCtrl.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) BaseTabbarCtrl *mainTabBar;

@property (nonatomic,strong) MMDrawerController * drawerController;

@property (nonatomic,assign) BOOL allowRotate;

@end

