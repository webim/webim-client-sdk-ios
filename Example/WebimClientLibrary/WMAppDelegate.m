//
//  WMAppDelegate.m
//  Webim-Client
//
//  Copyright (c) 2015 WEBIM.RU Ltd. All rights reserved.
//

#import "WMAppDelegate.h"

#import "WebimController.h"

#define SYSTEM_VERSION_GREATER_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)

@implementation WMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [WebimController shared].pushNotification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
#if !(TARGET_IPHONE_SIMULATOR)
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [self requestAccessAndRegisterForRemoteNotifications];
#endif
}

- (void)requestAccessAndRegisterForRemoteNotifications {
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0")) {
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        UIRemoteNotificationType types = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [WMSession setDeviceToken:deviceToken];
    
    NSCharacterSet *matchSet = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:matchSet];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    [WebimController shared].deviceToken = token;
    [[NSNotificationCenter defaultCenter] postNotificationName:WebimNotifications.didReceivePushToken object:nil userInfo:@{@"token": token}];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
#ifdef DEBUG
    NSLog(@"Warning: failed to register for remote notifications with error:\n%@", error);
#endif
    if ([WebimController shared].deviceToken.length > 0) {
        [WMSession setDeviceTokenString:[WebimController shared].deviceToken];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateInactive) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        [WebimController shared].pushNotification = userInfo;
    }
}

@end
