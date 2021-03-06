//
//  AppDelegate+PushService.m
//  ZHYQ
//
//  Created by 焦平 on 2017/10/22.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "AppDelegate+PushService.h"
#import "YQJPushTool.h"
#import <JPUSHService.h>

#import <UserNotifications/UserNotifications.h>

#import <Hyphenate/Hyphenate.h>
#import "EMCDDeviceManager+Remind.h"
#import <AudioToolbox/AudioToolbox.h>

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

static NSString *JPushAppKey  = JPushKey;
static NSString *JPushChannel = @"Publish channel";

#ifdef DEBUG
// 开发 极光FALSE为开发环境
static BOOL const JPushIsProduction = FALSE;
#else
// 生产 极光TRUE为生产环境
static BOOL const JPushIsProduction = TRUE;
#endif

@implementation AppDelegate (PushService)


-(void)initJPush:(NSDictionary *)launchOptions
{
    //极光推送
    [YQJPushTool setupWithOption:launchOptions appKey:JPushAppKey channel:JPushChannel apsForProduction:JPushIsProduction advertisingIdentifier:nil];
    
    [self initAPServiceWithOptions:launchOptions];
    
    // 注册环信推送
    [self initIMPush];
}

- (void)initAPServiceWithOptions:(NSDictionary *)launchOptions
{
    //为消息监听方法注册监听器
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(networkDidSetup:) name:kJPFNetworkDidSetupNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(networkDidClose:) name:kJPFNetworkDidCloseNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(networkDidRegister:) name:kJPFNetworkDidRegisterNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(networkDidLogin:) name:kJPFNetworkDidLoginNotification object:nil];
    
    [defaultCenter addObserver:self selector:@selector(networkIsConnecting:) name:kJPFNetworkIsConnectingNotification object:nil];
    
}

#pragma mark 环信推送
- (void)initIMPush {
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        //注册推送, 用于iOS8以及iOS8之后的系统
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        //注册推送，用于iOS8之前的系统
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

-(void)networkIsConnecting:(NSNotification *)notification
{
    DLog(@"正在连接中...");
}

- (void)networkDidSetup:(NSNotification *)notification {
    
    DLog(@"已连接");
}

- (void)networkDidClose:(NSNotification *)notification {
    
    DLog(@"未连接");
}

- (void)networkDidRegister:(NSNotification *)notification {
    
    DLog(@"已注册");
}

- (void)networkDidLogin:(NSNotification *)notification {
    
    NSString *registrationID = [JPUSHService registrationID];
//    DLog(@"%@",registrationID);
    [kUserDefaults setObject:registrationID forKey:@"registrationID"];
    [kUserDefaults synchronize];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Required - 注册 DeviceToken
    [YQJPushTool registerDeviceToken:deviceToken];
    
#pragma mark 环信推送
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[EMClient sharedClient] bindDeviceToken:deviceToken];
    });
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required,For systems with less than or equal to iOS6
    [YQJPushTool handleRemoteNotification:userInfo completion:nil];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [self reviceMsgDeal:application];
    
}

//iOS10新增：应用处于后台时的远程推送接受
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    //    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于后台时的远程推送接受
        completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge);
        [self reviceMsgDeal:[UIApplication sharedApplication]];
        
    }else{
        //应用处于后台时的本地推送接受
        completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge);
        [self reviceMsgDeal:[UIApplication sharedApplication]];
    }
}

//iOS10新增：处理前台收到通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    //    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于前台时的远程推送接受
        completionHandler(UNNotificationPresentationOptionSound);
        [self reviceMsgDeal:[UIApplication sharedApplication]];
        
    }else{
        //应用处于前台时的本地推送接受
        completionHandler(UNNotificationPresentationOptionSound);
        [self reviceMsgDeal:[UIApplication sharedApplication]];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#pragma mark 接收消息处理
- (void)reviceMsgDeal:(UIApplication *)application{
    
    // 应用正处理前台状态下，不会收到推送消息，因此在此处需要额外处理一下
    NSString *stateStr;
    if (application.applicationState == UIApplicationStateActive) {
        // 应用在前台运行时, 直接提示不做处理
        // 收到消息时，震动(系统可自带)
//        [self playSound];
        stateStr = @"UIApplicationStateActive";
        NSLog(@"UIApplicationStateActive");
    }else if (application.applicationState == UIApplicationStateInactive){
        // 应用在后台运行时，点击通知进入应用，跳转到消息页面
        // application.applicationIconBadgeNumber = 1;
        stateStr = @"UIApplicationStateInactive";
        
    }else if (application.applicationState == UIApplicationStateBackground){
        // 不调用
        stateStr = @"UIApplicationStateBackground";
        NSLog(@"UIApplicationStateBackground");
    }
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [YQJPushTool showLocalNotificationAtFront:notification];
    return;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [application setApplicationIconBadgeNumber:0];
    return;
}

@end

