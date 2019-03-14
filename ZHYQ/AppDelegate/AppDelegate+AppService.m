//
//  AppDelegate+AppService.m
//  ZHYQ
//
//  Created by 焦平 on 2017/10/22.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "AppDelegate+AppService.h"
#import "PersonalViewController.h"
#import <Hyphenate/Hyphenate.h>

@implementation AppDelegate (AppService)

#pragma mark ————— 初始化window —————
-(void)initWindow{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = KWhiteColor;
    
    [[UIButton appearance] setExclusiveTouch:YES];
    //    [[UIButton appearance] setShowsTouchWhenHighlighted:YES];
    [UIActivityIndicatorView appearanceWhenContainedIn:[MBProgressHUD class], nil].color = KWhiteColor;
    if (@available(iOS 11.0, *)){
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    
    //1、初始化控制器
    PersonalViewController *leftVC = [[UIStoryboard storyboardWithName:@"Personal" bundle:nil] instantiateViewControllerWithIdentifier:@"PersonalViewController"];
    self.mainTabBar = [BaseTabbarCtrl new];
    
    self.mainTabBar.delegate = kAppDelegate;
    //2、使用MMDrawerController
    self.drawerController = [[MMDrawerController alloc] initWithCenterViewController:self.mainTabBar leftDrawerViewController:leftVC rightDrawerViewController:nil];
    
    //4、设置打开/关闭抽屉的手势
    self.drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    self.drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureModeAll;
    //5、设置左右两边抽屉显示的多少
    self.drawerController.maximumLeftDrawerWidth = KScreenWidth*0.75;
    
    self.window.rootViewController = self.drawerController;
    //分界颜色
    //self.drawerController.shadowColor = [UIColor clearColor];
    
    [self.window makeKeyAndVisible];
}

#pragma mark 初始化高德地图
-(void)initMap{
    [AMapServices sharedServices].apiKey = AMapKey;
    [AMapServices sharedServices].enableHTTPS = YES;
}

#pragma mark 初始化环信
-(void)initIM {
    //AppKey:注册的AppKey，详细见下面注释。
    //apnsCertName:推送证书名（不需要加后缀），详细见下面注释。
    EMOptions *options = [EMOptions optionsWithAppkey:IMAppKey];
    options.apnsCertName = IMCertNameDevelop;
    options.isAutoLogin = YES;
    [[EMClient sharedClient] initializeSDKWithOptions:options];
}

+ (AppDelegate *)shareAppDelegate{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


-(UIViewController *)getCurrentVC{
    
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
        else
            result = window.rootViewController;
            
            return result;
}

-(UIViewController *)getCurrentUIVC
{
    UIViewController  *superVC = [self getCurrentVC];
    
    if ([superVC isKindOfClass:[UITabBarController class]]) {
        
        UIViewController  *tabSelectVC = ((UITabBarController*)superVC).selectedViewController;
        
        if ([tabSelectVC isKindOfClass:[UINavigationController class]]) {
            
            return ((UINavigationController*)tabSelectVC).viewControllers.lastObject;
        }
        return tabSelectVC;
    }else
        if ([superVC isKindOfClass:[UINavigationController class]]) {
            
            return ((UINavigationController*)superVC).viewControllers.lastObject;
        }
    return superVC;
}


@end

