//
//  MeetPageViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/19.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <WMPageController/WMPageController.h>
#import "MeetRoomGroupModel.h"

@interface MeetPageViewController : WMPageController

- (instancetype)initWithModel:(MeetRoomGroupModel *)model;
@property(nonatomic, retain) MeetRoomGroupModel *model;

@end
