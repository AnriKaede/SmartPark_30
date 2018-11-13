//
//  PlayBackView.h
//  CourtHearing
//
//  Created by jbin on 14-3-19.
//  Copyright (c) 2014年 dahatech. All rights reserved.
//  回放窗口

#import <UIKit/UIKit.h>
#import "DHVideoWnd.h"

@protocol PlayBackViewDelagate;
@interface PlayBackView : UIView
{
    DHVideoWnd                 *videoWnd_;          //播放窗口
    UIButton                   *popupBtn_;          //弹出按钮
    BOOL                        bPopup_;            //弹出按钮是否弹出
}

@property (retain,nonatomic) DHVideoWnd    *videoWnd;
@property (assign,nonatomic)  id<PlayBackViewDelagate>    delegate_;
- (id)initWithFrame:(CGRect)frame delegate:(id<PlayBackViewDelagate>)delegate;

- (void)hidePopMenu:(BOOL)hided;

@end


@protocol PlayBackViewDelagate <NSObject>
@optional
- (void)playBackViewPopMenuClicked;

@end
