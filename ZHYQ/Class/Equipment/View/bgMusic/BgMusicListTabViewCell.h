//
//  BgMusicListTabViewCell.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/16.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InDoorBgMusicMapModel.h"
#import "BgMusicMapModel.h"

@protocol CellPlayMusicDelegate <NSObject>

- (void)chooseMusicList;

- (void)playMusic;
- (void)pauseMusic;
- (void)stopMusic;
- (void)upMusic;
- (void)downMusic;

- (void)sliderVolumValue:(CGFloat)volum;

@end

@class YQSwitch;
@class YQSlider;

@interface BgMusicListTabViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *selectView;
@property (weak, nonatomic) IBOutlet UILabel *equipmentNameLab;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentMusicLab;
@property (weak, nonatomic) IBOutlet UILabel *currentMusicDetailLab;
@property (weak, nonatomic) IBOutlet UIButton *changeMusicBtn;
@property (weak, nonatomic) IBOutlet UILabel *volumeAdjustLab;
@property (weak, nonatomic) IBOutlet YQSlider *volumeAdjustSlider;

@property (weak, nonatomic) IBOutlet UIView *musicMenuView;


@property (nonatomic,retain) InDoorBgMusicMapModel *inDoorModel;
@property (nonatomic,retain) BgMusicMapModel *model;
@property (nonatomic,assign) CGFloat volum;

@property (nonatomic, assign) id<CellPlayMusicDelegate> cellPlayMusicDelegate;

@end
