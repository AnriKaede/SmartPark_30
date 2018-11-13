//
//  AppointMentParkCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/6/7.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AptListModel.h"

@protocol SpaceOpearteDelegate <NSObject>

- (void)cancelAptOpearte:(AptListModel *) aptListModel;
- (void)openLockOpearte:(AptListModel *) aptListModel;

@end

@interface AppointMentParkCell : UITableViewCell

@property (nonatomic,assign) BOOL isCancelApt;
@property (nonatomic,retain) AptListModel *aptListModel;
@property (nonatomic,assign) id<SpaceOpearteDelegate> spaceOpearteDelegate;

@end
