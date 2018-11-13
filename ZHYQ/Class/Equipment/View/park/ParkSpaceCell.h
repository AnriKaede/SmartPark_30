//
//  ParkSpaceCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/6/19.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParkSpaceModel.h"

@protocol SpaceOperateDelegate <NSObject>

- (void)openLock:(ParkSpaceModel *) parkSpaceModel;
- (void)lockLock:(ParkSpaceModel *) parkSpaceModel;
- (void)cancelApt:(ParkSpaceModel *) parkSpaceModel;
- (void)prohibitApt:(ParkSpaceModel *) parkSpaceModel;
- (void)openApt:(ParkSpaceModel *) parkSpaceModel;
- (void)operateLedApt:(ParkSpaceModel *) parkSpaceModel;

@end

@interface ParkSpaceCell : UITableViewCell

@property (nonatomic,retain) ParkSpaceModel *parkSpaceModel;
@property (nonatomic,retain) NSString *areaId;

@property (nonatomic,assign) id<SpaceOperateDelegate> spaceOperateDelegate;

@end
