//
//  SceneEditTableViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/10.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseTableViewController.h"
#import "SceneOnOffModel.h"
#import "MeetRoomGroupModel.h"

@protocol AddSceneModelDelegate <NSObject>

- (void)addModelSuc;

@end

@interface SceneEditTableViewController : BaseTableViewController

@property(nonatomic, retain) MeetRoomGroupModel *model;

@property (nonatomic,retain) SceneOnOffModel *sceneOnOffModel;  // 修改模式

@property (nonatomic,assign) BOOL isSceneModel; // 是否是场景模式变换

@property (nonatomic,assign) id<AddSceneModelDelegate> addDelegate;

@end
