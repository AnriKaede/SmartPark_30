//
//  EntranceCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/25.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DoorModel.h"

@protocol EntranceDelegate <NSObject>

- (void)unLockDoor:(DoorModel *)doorModel withOperate:(NSString *)operate;
- (void)viewAuthorityList:(DoorModel *)doorModel;
- (void)openRecord:(DoorModel *)doorModel;

@end

@interface EntranceCell : UITableViewCell

@property (nonatomic,retain) DoorModel *model;
@property (nonatomic,assign) id<EntranceDelegate> entranceDelegate;

@end
