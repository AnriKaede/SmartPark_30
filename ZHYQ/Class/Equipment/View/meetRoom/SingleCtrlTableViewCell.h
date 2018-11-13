//
//  SingleCtrlTableViewCell.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/28.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeetRoomModel.h"
#import "SceneEquipmentModel.h"

@protocol SliderLightDelegate <NSObject>

- (void)switchOnOff:(MeetRoomModel *)meetRoomModel withOpen:(BOOL)open;
- (void)sliderValue:(MeetRoomModel *)meetRoomModel withValue:(CGFloat)slider;

- (void)switchSceneOnOff:(SceneEquipmentModel *)sceneModel withOpen:(BOOL)open;
- (void)sliderSceneValue:(SceneEquipmentModel *)sceneModel withValue:(CGFloat)slider;

- (void)modelCutData:(NSString *)writeId withDeviceId:(NSString *)deviceId withTagName:(NSString *)tagName withValue:(NSString *)operateValue withMeetModel:(MeetRoomModel *)meetModel;

@end

@interface SingleCtrlTableViewCell : UITableViewCell

@property (nonatomic,retain) MeetRoomModel *model;
@property (nonatomic,retain) SceneEquipmentModel *sceneModel;
@property (nonatomic,assign) BOOL isScene;  // 开关设备Model是场景模式还是状态（都可实际操控）
@property (nonatomic, assign) id<SliderLightDelegate> lightDelegare;

@property (nonatomic,assign) BOOL isEdit;   // 是否是场景模式编辑（不可实际开关设备）

@end
