//
//  AppDelegate.m
//  Teameeting
//
//  Created by zjq on 16/1/11.
//  Copyright © 2016年 zjq. All rights reserved.
//

#import "AppDelegate.h"

#import "MainViewController.h"
#import "ServerVisit.h"
#import "ASNetwork.h"
#import "NtreatedDataManage.h"
#import "WXApi.h"
#import "WXApiManager.h"
#import "RoomApp.h"
#import "JPUSHService.h"
#import "ToolUtils.h"
#import "SvUDIDTools.h"

#import "TMMessageManage.h"

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //[application setApplicationIconBadgeNumber:0];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    NSDictionary *navbarTitleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor: [UIColor blackColor]];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [ASNetwork sharedNetwork];
    [SvUDIDTools shead];
   
    // Override point for customization after application launch.
    if (launchOptions) {
        NSString *string =  [NSString stringWithFormat:@"%@",launchOptions[UIApplicationLaunchOptionsURLKey]];
        if (![string isEqualToString:@"(null)"]) {
            NSLog(@"UIApplicationLaunchOptionsURLKey:%@",string);
            [self getUrlParamer:string withFirstIn:YES];
        }
    }
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    } else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                          UIRemoteNotificationTypeSound |
                                                          UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
    
    [JPUSHService setupWithOption:launchOptions appKey:appKey channel:channel apsForProduction:isProduction];
    
    [WXApi registerApp:@"wx4d9fbaec0a4c368f" withDescription:@"demo 2.0"];
    MainViewController *mainViewController = [MainViewController new];
    UINavigationController *nai = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    [RoomApp shead].appDelgate = self;
    [RoomApp shead].mainViewController = mainViewController;
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    nai.navigationBarHidden = YES;
    [self.window setRootViewController:nai];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"UIBackgroundFetchResult");
    [JPUSHService handleRemoteNotification:userInfo];
    NotificationObject *noti = [[NotificationObject alloc] init];
    if ([[userInfo objectForKey:@"tags"] intValue] == 1) {
        noti.notificationType = NotificationMessageType;
    }else{
        noti.notificationType = NOtificationEnterMeetingType;
    }
    noti.roomID = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"roomid"]];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationEntNotification object:noti userInfo:nil];
    [ToolUtils shead].notificationObject = noti;
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *realDeviceToken = [NSString stringWithFormat:@"%@",deviceToken];
    realDeviceToken = [realDeviceToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    realDeviceToken = [realDeviceToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    realDeviceToken = [realDeviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [JPUSHService registerDeviceToken:deviceToken];
    [JPUSHService setTags:[NSSet setWithObject:[SvUDIDTools shead].UUID] alias:[SvUDIDTools shead].UUID callbackSelector:nil object:nil];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"didReceiveRemoteNotification");
    [JPUSHService handleRemoteNotification:userInfo];
    NotificationObject *noti = [[NotificationObject alloc] init];
    if ([[userInfo objectForKey:@"tags"] intValue] == 1) {
        noti.notificationType = NotificationMessageType;
    }else{
        noti.notificationType = NOtificationEnterMeetingType;
    }
    noti.roomID = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"roomid"]];
   [[NSNotificationCenter defaultCenter] postNotificationName:NotificationEntNotification object:noti userInfo:nil];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
   // [JPUSHService showLocalNotificationAtFront:notification identifierKey:nil];
    NSDictionary *userInfo = notification.userInfo;
    NSLog(@"%@",[userInfo description]);
    NotificationObject *noti = [[NotificationObject alloc] init];
    if ([[userInfo objectForKey:@"tags"] intValue] == 1) {
        noti.notificationType = NotificationMessageType;
    }else{
        noti.notificationType = NOtificationEnterMeetingType;
    }
    noti.roomID = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"roomid"]];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationEntNotification object:noti userInfo:nil];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // 解析url
    if ([[url scheme] isEqualToString:@"teameeting"]){
        NSString* encodedString = [NSString stringWithFormat:@"%@",url];
        [self getUrlParamer:encodedString withFirstIn:NO];
        
    }
    return [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
}

- (void)getUrlParamer:(NSString*)URL withFirstIn:(BOOL)isFirst
{
    NSRange rangeleft = [URL rangeOfString:@"//"];
    if (rangeleft.length <= 0 || rangeleft.location+1>URL.length) {
        return;
    }
    
    NSString *mID = [URL substringFromIndex:rangeleft.location+rangeleft.length];
    if (mID.length>12) {
        mID = [mID substringToIndex:12];
    }
    NSLog(@"meetingName:%@",mID);
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    if (isFirst) {
        // 用户还没有启动一种处理
        [ToolUtils shead].meetingID = mID;
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:ShareMettingNotification object:mID userInfo:nil];
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return  [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    UIApplication*   app = [UIApplication sharedApplication];
    __block    UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
    
    [ToolUtils shead].isBack = YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [application setApplicationIconBadgeNumber:0];
    [ToolUtils shead].isBack = NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
