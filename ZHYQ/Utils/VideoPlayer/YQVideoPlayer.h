//
//  YQVideoPlayer.h
//  ZHYQ
//
//  Created by 焦平 on 2017/10/31.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YQVideoPlayer : UIView

@property (nonatomic,strong) NSURL *mediaURL;
@property (nonatomic,assign) BOOL isFullscreenModel;

- (void)showInView:(UIView *)view;

@end
