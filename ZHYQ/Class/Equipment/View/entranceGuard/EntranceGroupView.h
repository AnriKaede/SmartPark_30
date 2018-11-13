//
//  EntranceGroupView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/11.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DoorModel;

@protocol GroupConDelegate <NSObject>

- (void)unLockDoor:(DoorModel *)doorModel;
- (void)viewAuthorityList:(DoorModel *)doorModel;
- (void)openRecord:(DoorModel *)doorModel;

@end

@interface EntranceGroupView : UIView

@property (nonatomic,assign) id<GroupConDelegate> groupConDelegate;

@end
