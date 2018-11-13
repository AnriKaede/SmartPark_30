//
//  ChooseMusicTabCell.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/7.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicListModel.h"
#import "InDoorBgMusicMapModel.h"

@protocol PlayMusicDelegate <NSObject>

- (void)playMusicWithFile:(MusicListModel *)musicListModel;

@end

@interface ChooseMusicTabCell : UITableViewCell

@property (nonatomic,strong) MusicListModel *model;
@property (nonatomic, assign) id<PlayMusicDelegate> playMusicDelegate;

@end
