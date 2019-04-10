//
//  PlaybackViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/2.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "RootViewController.h"
//#import "PlayBackView.h"
//#import "PlayControlBar.h"

@interface PlaybackViewController : RootViewController
{
//    PlayBackView    *playbackView_;
//    PlayControlBar  *controlBar_;
    NSTimer         *progressTimer_;   /**< 更新进度条定时器,默认0.2s */
    UIView          *pView;
}
@end
