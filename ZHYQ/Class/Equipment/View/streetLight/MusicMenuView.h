//
//  MusicMenuView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubDeviceModel.h"

@protocol MusicOperateDelegate <NSObject>

- (void)noSuportMsg;

@end

@interface MusicMenuView : UIView
- (void)showMenu;
- (void)hidMenu;

@property (nonatomic, retain) SubDeviceModel *subDeviceModel;
@property (nonatomic,assign) id<MusicOperateDelegate> musicOperateDelegate;
@end
