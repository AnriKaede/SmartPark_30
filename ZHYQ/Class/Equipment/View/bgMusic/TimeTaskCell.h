//
//  TimeTaskCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicTimeModel.h"

@protocol PlayStopMusicDelegate <NSObject>

- (void)playStopMusic:(MusicTimeModel *)musicTimeModel;
- (void)sliderModel:(MusicTimeModel *)musicTimeModel withVol:(CGFloat)vol;

@end

@interface TimeTaskCell : UITableViewCell

@property (nonatomic, retain) MusicTimeModel *musicTimeModel;
@property (nonatomic,assign) id<PlayStopMusicDelegate> musicDelegate;

@end
