//
//  AppDelegate.m
//  ZHYQ
//
//  Created by 焦平 on 2017/10/21.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import <sys/sysctl.h>
#import <SAMKeychain.h>

#import <Hyphenate/Hyphenate.h>

#import "LauchViewController.h"

@interface AppDelegate ()<UITabBarControllerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KFirstLauch];
    // Override point for customization after application launch.
    if(![[NSUserDefaults standardUserDefaults] boolForKey:KFirstLauch]){
        LauchViewController *lauchVC = [[LauchViewController alloc] init];
        
        self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        [self.window makeKeyAndVisible];
        self.window.rootViewController = lauchVC;
    }else {
        //初始化window
        [self initWindow];
    }
    
    //初始化环信
    [self initIM];
    //初始化极光推送(环信中推送设置在极光中同步初始化)
    [self initJPush:launchOptions];
    //初始化高德地图
    [self initMap];
    
    //程序启动后创建DPSDK句柄
    /// 由于dpsdk是长连接，为防止程序在后台时信号量引发问题
    struct sigaction sa;
    sa.sa_handler = SIG_IGN;
    sigaction(SIGPIPE, &sa,0);

    // 保存信息
    [self saveDeviceModel];
    [self saveDeviceId];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // 后台到前台
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EnterForegroundAlert" object:nil];
    
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (tabBarController.selectedIndex == 1||tabBarController.selectedIndex == 2) {
        if (![kUserDefaults boolForKey:KLoginState]) {
            [tabBarController setSelectedIndex:0];
            RootNavigationController *loginVC = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginNavViewController"];
            [self.window.rootViewController.childViewControllers.firstObject presentViewController:loginVC animated:YES completion:nil];
            return;
        }
    }
}

- (void)saveDeviceModel{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = new char[size];
    
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    NSString *deviceModel = @"";
    
    if ([platform isEqualToString:@"iPhone1,1"]) deviceModel = @"iPhone 2G (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"]) deviceModel = @"iPhone 3G (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"]) deviceModel = @"iPhone 3GS (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"]) deviceModel = @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,2"]) deviceModel = @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,3"]) deviceModel = @"iPhone 4 (A1349)";
    if ([platform isEqualToString:@"iPhone4,1"]) deviceModel = @"iPhone 4S (A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"]) deviceModel = @"iPhone 5 (A1428)";
    if ([platform isEqualToString:@"iPhone5,2"]) deviceModel = @"iPhone 5 (A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"]) deviceModel = @"iPhone 5c (A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"]) deviceModel = @"iPhone 5c (A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"]) deviceModel = @"iPhone 5s (A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"]) deviceModel = @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"]) deviceModel = @"iPhone 6 Plus (A1522/A1524)";
    if ([platform isEqualToString:@"iPhone7,2"]) deviceModel = @"iPhone 6 (A1549/A1586)";
    if ([platform isEqualToString:@"iPhone8,1"]) deviceModel = @"iPhone 6S";
    if ([platform isEqualToString:@"iPhone8,2"]) deviceModel = @"iPhone 6S Plus";
    if ([platform isEqualToString:@"iPhone8,4"]) deviceModel = @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"]) deviceModel = @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"]) deviceModel = @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone10,1"]) deviceModel = @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,4"]) deviceModel = @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,2"]) deviceModel = @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,5"]) deviceModel = @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,3"]) deviceModel = @"iPhone X";
    
    //iPot Touch
    if ([platform isEqualToString:@"iPod1,1"]) deviceModel = @"iPodTouch";
    
    if ([platform isEqualToString:@"iPod2,1"]) deviceModel = @"iPodTouch2";
    
    if ([platform isEqualToString:@"iPod3,1"]) deviceModel = @"iPodTouch3";
    
    if ([platform isEqualToString:@"iPod4,1"]) deviceModel = @"iPodTouch4";
    
    if ([platform isEqualToString:@"iPod5,1"]) deviceModel = @"iPodTouch5";
    
    //iPad
    
    if ([platform isEqualToString:@"iPad1,1"]) deviceModel = @"iPad";
    
    if ([platform isEqualToString:@"iPad2,1"]) deviceModel = @"iPad2";
    
    if ([platform isEqualToString:@"iPad2,2"]) deviceModel = @"iPad2";
    
    if ([platform isEqualToString:@"iPad2,3"]) deviceModel = @"iPad2";
    
    if ([platform isEqualToString:@"iPad2,4"]) deviceModel = @"iPad2";
    
    if ([platform isEqualToString:@"iPad2,5"]) deviceModel = @"iPadMini1";
    
    if ([platform isEqualToString:@"iPad2,6"]) deviceModel = @"iPadMini1";
    
    if ([platform isEqualToString:@"iPad2,7"]) deviceModel = @"iPadMini1";
    
    if ([platform isEqualToString:@"iPad3,1"]) deviceModel = @"iPad3";
    
    if ([platform isEqualToString:@"iPad3,2"]) deviceModel = @"iPad3";
    
    if ([platform isEqualToString:@"iPad3,3"]) deviceModel = @"iPad3";
    
    if ([platform isEqualToString:@"iPad3,4"]) deviceModel = @"iPad4";
    
    if ([platform isEqualToString:@"iPad3,5"]) deviceModel = @"iPad4";
    
    if ([platform isEqualToString:@"iPad3,6"]) deviceModel = @"iPad4";
    
    if ([platform isEqualToString:@"iPad4,1"]) deviceModel = @"iPadAir";
    
    if ([platform isEqualToString:@"iPad4,2"]) deviceModel = @"iPadAir";
    
    if ([platform isEqualToString:@"iPad4,3"]) deviceModel = @"iPadAir";
    
    if ([platform isEqualToString:@"iPad4,4"]) deviceModel = @"iPadMini2";
    
    if ([platform isEqualToString:@"iPad4,5"]) deviceModel = @"iPadMini2";
    
    if ([platform isEqualToString:@"iPad4,6"]) deviceModel = @"iPadMini2";
    
    if ([platform isEqualToString:@"iPad4,7"]) deviceModel = @"iPadMini3";
    
    if ([platform isEqualToString:@"iPad4,8"]) deviceModel = @"iPadMini3";
    
    if ([platform isEqualToString:@"iPad4,9"]) deviceModel = @"iPadMini3";
    
    if ([platform isEqualToString:@"iPad5,3"]) deviceModel = @"iPadAir2";
    
    if ([platform isEqualToString:@"iPad5,4"]) deviceModel = @"iPadAir2";
    // 模拟器
    if ([platform isEqualToString:@"i386"])        deviceModel = @"iPhoneSimulator";
    
    if ([platform isEqualToString:@"x86_64"])    deviceModel = @"iPhoneSimulator";
    
    if ([platform isEqualToString:@"iPhoneSimulator"]) deviceModel = @"iPhoneSimulator";
    
    [[NSUserDefaults standardUserDefaults] setObject:deviceModel forKey:KDeviceModel];
    
}

- (void)saveDeviceId
{
    NSString *appName=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    NSString * currentDeviceUUIDStr = [SAMKeychain passwordForService:appName account:@"incoding"];
    if (currentDeviceUUIDStr == nil || [currentDeviceUUIDStr isEqualToString:@""])
    {
        NSUUID * currentDeviceUUID  = [UIDevice currentDevice].identifierForVendor;
        currentDeviceUUIDStr = currentDeviceUUID.UUIDString;
        [SAMKeychain setPassword:currentDeviceUUIDStr forService:appName account:@"incoding"];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:currentDeviceUUIDStr forKey:KDeviceUUID];
}

//此方法会在设备横竖屏变化的时候调用
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {
    if (_allowRotate) {
        return UIInterfaceOrientationMaskAll;
    }else{
        return (UIInterfaceOrientationMaskPortrait);
    }
}

@end
