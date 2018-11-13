//
//  inDoorMusicTabCell.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/7.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BgMusicModel.h"
#import "MusicGroupModel.h"

@protocol inDoorChooseMusicDelegate <NSObject>

-(void)inDoor_chooseMusicTap:(MusicGroupModel *)groupModel withVolum:(CGFloat)volum;    // 点击更换音乐

-(void)inDoor_seeDetailsClick:(MusicGroupModel *)musicGroupModel;  // 点击查看详情室内

- (void)playMusic:(MusicGroupModel *)musicGroupModel withVolum:(CGFloat)volum;
- (void)pauseMusic:(MusicGroupModel *)musicGroupModel;
- (void)stopMusic:(MusicGroupModel *)musicGroupModel;
- (void)upMusic:(MusicGroupModel *)musicGroupModel;
- (void)downMusic:(MusicGroupModel *)musicGroupModel;


@end

@interface inDoorMusicTabCell : UITableViewCell

@property (nonatomic,weak) id<inDoorChooseMusicDelegate> inDoorDelegate;

@property (nonatomic,retain) BgMusicModel *model;

@property (nonatomic, retain) MusicGroupModel *musicGroupModel;

@end
