//
//  ChooseMusicViewController.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/7.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "RootViewController.h"
#import "SoundModel.h"
#import "InDoorBgMusicMapModel.h"
#import "BgMusicMapModel.h"
#import "MusicGroupModel.h"

@protocol ChangeMusicSuccessDelegate <NSObject>

@optional
- (void)changeMusicSuc:(NSString *)seccionId;

- (void)changeGroupMusicSuc:(NSString *)seccionId withVolum:(NSString *)volum;

@end

@interface ChooseMusicViewController : RootViewController

@property (nonatomic,retain) SoundModel *soundModel;

// 三个model 只会同时赋值一个 室内、室外、分组
@property (nonatomic, retain) InDoorBgMusicMapModel *musicMapModel;
@property (nonatomic, retain) BgMusicMapModel *outMusicMapModel;
@property (nonatomic, retain) MusicGroupModel *musicGroupModel;

@property (nonatomic, copy) NSString *volume;

@property (nonatomic, assign) id<ChangeMusicSuccessDelegate> changeMusicDelegate;

@end
