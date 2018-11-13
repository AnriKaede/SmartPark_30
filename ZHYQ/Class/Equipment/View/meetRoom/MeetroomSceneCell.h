//
//  MeetroomSceneCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/10.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "SceneOnOffModel.h"

#import <UIKit/UIKit.h>
#import "SceneOnOffModel.h"

@protocol ConSceneDelegate <NSObject>

- (void)conScene:(SceneOnOffModel *)sceneOnOffModel withOpen:(BOOL)open;

@end


@interface MeetroomSceneCell : UITableViewCell

@property (nonatomic, retain) SceneOnOffModel *sceneOnOffModel;
@property (nonatomic,assign) id<ConSceneDelegate> sceneDelegate;

@end
