//
//  PlayBackView.m
//  CourtHearing
//
//  Created by jbin on 14-3-19.
//  Copyright (c) 2014年 dahatech. All rights reserved.
//

#import "PlayBackView.h"
#import "PubDefine.h"

@implementation PlayBackView

@synthesize videoWnd = videoWnd_;

- (id)initWithFrame:(CGRect)frame  delegate:(id<PlayBackViewDelagate>)delegate
{
    _delegate_ = delegate;
    
    //标准尺寸720*524,以frame的宽度进行缩放
    float proportion   = frame.size.width / 718;
    frame.size.height  = 480*proportion;

    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        //Scrollview上面增加播放窗口videoWnd
        CGRect rectScroll = self.bounds;
        UIScrollView *videoFrame = [[UIScrollView alloc] initWithFrame:rectScroll];
        videoFrame.tag = 2001;
        videoFrame.backgroundColor = COLOR_DARKBLUE;
        videoFrame.userInteractionEnabled = FALSE;

		self.videoWnd = [[DHVideoWnd alloc] initWithFrame:rectScroll];
        [videoFrame addSubview:self.videoWnd];
		[self addSubview:videoFrame];
        
        //增加弹出按钮84*84,矩形中心位置偏移相应距离
        CGRect rectBtn;
        rectBtn.origin.x = (frame.size.width - proportion*84) / 2.0;
        rectBtn.origin.y = (frame.size.height - proportion*84) / 2.0;
        rectBtn.size = CGSizeMake(84*proportion, 84*proportion);
        
        popupBtn_ = [[UIButton alloc]initWithFrame:rectBtn];
        [popupBtn_ setBackgroundImage:[UIImage imageNamed:@"playback_add_n.png"]
                             forState:UIControlStateNormal];
        [popupBtn_ setBackgroundImage:[UIImage imageNamed:@"playback_add_h.png"]
                             forState:UIControlStateHighlighted];
        [popupBtn_ addTarget:self
                      action:@selector(popupBtnClicked)
            forControlEvents:UIControlEventTouchUpInside];
        //[self addSubview:popupBtn_];
        
        //增加tap手势识别
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc]
                                              initWithTarget:self
                                              action:@selector(handlePanGesture)];
        [self addGestureRecognizer:tapGesture];
    }
    
    return self;
}

- (void)hidePopMenu:(BOOL)hided
{
    float alpha = hided ? 0 : 1.0;
    [popupBtn_ setAlpha:alpha];
}

/************************************************************
 *点击手势处理:弹出按钮淡入淡出效果
 ***********************************************************/
- (void)handlePanGesture
{
    //显示弹出按钮,10s后,自动消失
    if (NO == bPopup_)
    {
        [self showPopupByAlpha:1.0 animated:YES];
        [self performSelector:@selector(hidePopupButton)
                   withObject:nil
                   afterDelay:10];
    }
    else
    {
        [self showPopupByAlpha:0 animated:YES];
    }
    bPopup_ = !bPopup_;
}

/************************************************************
 *显示弹出按钮
 *alplha:透明度,0--隐藏,1--显示
 *bAnimated:是否显示动画效果
 ***********************************************************/
- (void)showPopupByAlpha:(CGFloat)alpha animated:(BOOL)bAnimated
{
    if (!bAnimated)
    {
        [popupBtn_ setAlpha:alpha];
    }
    else
    {
        NSTimeInterval animationDuration = 0.50f;
        [UIView beginAnimations:@"ShowPopButton" context:nil];
        [UIView setAnimationDuration:animationDuration];
        [popupBtn_ setAlpha:alpha];
        [UIView commitAnimations];
    }
}

/************************************************************
 *隐藏弹出按钮
 ***********************************************************/
- (void)hidePopupButton
{
    if (bPopup_)
    {
        [self showPopupByAlpha:0 animated:YES];
        bPopup_ = NO;
    }
}


/************************************************************
 *弹出按钮点击响应
 ***********************************************************/
- (void)popupBtnClicked
{
    //传递delegate
    if (_delegate_ && [_delegate_ respondsToSelector:@selector(playBackViewPopMenuClicked)])
    {
        [_delegate_ playBackViewPopMenuClicked];
    }
}

- (void)drawRect:(CGRect)rect
{
    
}
@end
