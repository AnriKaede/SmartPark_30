//
//  AloneConCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/17.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeetRoomModel.h"
#import "SceneEquipmentModel.h"

@protocol AloneConDelegate <NSObject>

- (void)aloneCon:(MeetRoomModel *)meetRoomModel withOpen:(BOOL)open;

@end

@interface AloneConCell : UITableViewCell

@property (nonatomic,strong) MeetRoomModel *model;
@property (nonatomic,retain) SceneEquipmentModel *sceneModel;
@property (nonatomic,assign) id<AloneConDelegate> aloneDelegate;

@end
