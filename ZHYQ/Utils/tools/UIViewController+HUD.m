/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "UIViewController+HUD.h"

#import "MBProgressHUD.h"
#import <objc/runtime.h>

static const void *HttpRequestHUDKey = &HttpRequestHUDKey;

@implementation UIViewController (HUD)

- (MBProgressHUD *)HUD{
    return objc_getAssociatedObject(self, HttpRequestHUDKey);
}

- (void)setHUD:(MBProgressHUD *)HUD{
    objc_setAssociatedObject(self, HttpRequestHUDKey, HUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/*
- (void)showHudInView:(UIView *)view hint:(NSString *)hint{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    
    HUD.mode = MBProgressHUDModeCustomView;
    
    UIImage *image = [[UIImage imageNamed:@"loading"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
    
    // 加载动画帧数组
    NSMutableArray *imgsAry = @[].mutableCopy;
    for (int i=1; i<=10; i++) {
        [imgsAry addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%d", i]]];
    }
    
    imgView.animationDuration = 0.8;
    imgView.animationImages = imgsAry;
    [imgView startAnimating];
    
    HUD.customView = imgView;
    HUD.removeFromSuperViewOnHide = YES;
    
    [imgView setNeedsDisplayInRect:CGRectMake(0, 0, 100, 100)];
    
    HUD.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    HUD.bezelView.backgroundColor = [UIColor clearColor];
    
    HUD.label.text = @"加载中~";
    HUD.label.textColor = [UIColor colorWithHexString:@"#1B82D1"];
    
    [view addSubview:HUD];
    [HUD showAnimated:YES];
    [self setHUD:HUD];
}
 */
- (void)showHudInView:(UIView *)view hint:(NSString *)hint{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
//    HUD.label.text = hint;
    HUD.label.text = @"加载中~";
    HUD.mode = MBProgressHUDModeIndeterminate;
    [view addSubview:HUD];
    [HUD showAnimated:YES];
    [self setHUD:HUD];
}
- (void)showHudInView:(UIView *)view hint:(NSString *)hint yOffset:(float)yOffset {
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    //    HUD.label.text = hint;
    NSLog(@"======%f", yOffset);
    HUD.offset = CGPointMake(0, yOffset);
    HUD.label.text = @"加载中~";
    HUD.mode = MBProgressHUDModeIndeterminate;
    [view addSubview:HUD];
    [HUD showAnimated:YES];
    [self setHUD:HUD];
}

- (void)showHint:(NSString *)hint
{
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.bezelView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.6];
    hud.label.textColor = [UIColor whiteColor];
    hud.label.text = hint;
    hud.margin = 10.f;
    hud.yOffset = 120;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:2];
}

- (void)showHint:(NSString *)hint yOffset:(float)yOffset
{
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.bezelView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.6];
    hud.label.textColor = [UIColor whiteColor];
    hud.label.text = hint;
    hud.margin = 10.f;
    hud.yOffset = 180;
    hud.yOffset += yOffset;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}


- (void)hideHud{
//    [[self HUD] hide:YES];
    [[self HUD] hideAnimated:YES];
    [[self HUD] removeFromSuperview];
}


@end
