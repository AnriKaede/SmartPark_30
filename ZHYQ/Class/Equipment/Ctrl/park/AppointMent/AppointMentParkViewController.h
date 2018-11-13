//
//  AppointMentParkViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/6/7.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "RootViewController.h"
@class AptListModel;

typedef enum {
    AppointMentParkAll = 0,
    AppointMentParkIng,
    AppointMentParkComplete,
    AppointMentParkCancel
}AppointMentParkStyle;

@protocol ManagerCancelAptDelegate <NSObject>

- (void)cancelApt:(AptListModel *)aptListModel;

@end

@interface AppointMentParkViewController : RootViewController

@property (nonatomic,assign) AppointMentParkStyle appointMentParkStyle;
@property (nonatomic,assign) id<ManagerCancelAptDelegate> managerCancelAptDelegate;

@end
