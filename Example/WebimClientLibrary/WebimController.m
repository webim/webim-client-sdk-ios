//
//  WebimController.m
//  WebimOffline
//
//  Copyright (c) 2015 WEBIM.RU Ltd. All rights reserved.
//

#import "WebimController.h"

#import "WMChatViewController.h"
#import "WMOfflineChatViewController.h"
#import "WMHistoryTableViewController.h"

#import "WMMessage.h"

#import "CRToast.h"

#import <CommonCrypto/CommonCrypto.h>

static NSTimeInterval DefaultTimerTimeInterval = 20;

// Login parameters
static NSString *AccountName = @"demo";
static NSString *Location = @"ios";

static NSString *DeviceTokenUserDefaultsKey = @"WMSampleAppDeviceTokenKey";

const struct WebimNotifications WebimNotifications = {
    .onlineFullUpdate = @"WebimNotificationsOnlineFullUpdateNotification",
    .onlineNewMessage = @"WebimNotificationsOnlineNewMessageNotification",
    .onlineOperatorUpdate = @"WebimNotificationsOnlineOperatorUpdateNotification",
    .onlineChatStart = @"WebimNotificationsOnlineChatStartNotification",
    .onlineChatStatusChange = @"WebimNotificationsOnlineChatStatusChangeNotification",
    .onlineSessionStatusChange = @"WebimNotificationsOnlineSessionStatusChangeNotification",
    .onlineSessionHasOnlineOperatorChange = @"WebimNotificationsOnlineSessionHasOnlineOperatorChangeNotification",
    .didReceiveUpdate = @"WebimNotificationsDidReceiveUpdateNotification",
    .didReceivePushToken = @"WebimNotificationsDidReceivePushTokenNotification",
};

@interface WebimController () <WMSessionDelegate>

@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic, assign) BOOL didReceiveHistory;

@end

@implementation WebimController


+ (instancetype)shared {
    static WebimController *sharedInstance_;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance_ = [[WebimController alloc] init];
        sharedInstance_.imagesMap = [NSMutableDictionary dictionary];
        sharedInstance_.deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:DeviceTokenUserDefaultsKey];
    });
    return sharedInstance_;
}

+ (void)initializeWithConfig:(NSDictionary *)config {
    WebimController *sharedController = [WebimController shared];
    if (sharedController.deviceToken.length == 0) {
        sharedController.deviceToken = [WebimController deviceVendorIDToken];
#if TARGET_IPHONE_SIMULATOR
        [WMSession setDeviceTokenString:sharedController.deviceToken];
#endif
    }
    
    // Initialize realtime session
    sharedController.realtimeSession =
        [[WMSession alloc] initWithAccountName:AccountName
                                      location:Location
                                      delegate:[WebimController shared]
                                 visitorFields:nil];
    [sharedController.realtimeSession startSession:nil];
#if 0
    // Optionally realtime session could be initialized with user information
    NSMutableDictionary *visitorFieldsDictionary = [NSMutableDictionary dictionary];
    visitorFieldsDictionary[WMVisitorParameterDisplayName] = @"Eugeny";
    visitorFieldsDictionary[WMVisitorParameterEmail] = @"support@webim.ru";
    visitorFieldsDictionary[WMVisitorParameterPhone] = @"+7 812 3855337";
    visitorFieldsDictionary[WMVisitorParameterCRC] = @"cdc2c8b0542897dd311fe85754479860";
    //^ Those are hardcoded values only for test purposes
    //  Clients should calculate CRC server-side using their private key
    
    sharedController.realtimeSession = [[WMSession alloc] initWithAccountName:AccountName
                                                                     location:Location
                                                                     delegate:sharedController
                                                                visitorFields:visitorFieldsDictionary];
#endif
    
    // Initialize offline session
    sharedController.offlineSession =
        [[WMOfflineSession alloc] initWithAccountName:AccountName
                                             location:Location
                                                token:sharedController.deviceToken
                                             platform:nil];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:sharedController
           selector:@selector(webimDidReceivePushTokenNotification:)
               name:WebimNotifications.didReceivePushToken
             object:nil];
}

#pragma mark - Realtime session

- (void)sessionDidReceiveFullUpdate:(WMSession *)session {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:WebimNotifications.onlineFullUpdate
                    object:session];
    [self checkPushNotificationAndMaybeSwitchToRealtimeChat];
}

- (void)sessionDidChangeStatus:(WMSession *)session {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:WebimNotifications.onlineSessionStatusChange
                      object:session];
}

- (void)sessionDidChangeChatStatus:(WMSession *)session {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:WebimNotifications.onlineChatStatusChange
                      object:session.chat];
}

- (void)session:(WMSession *)session didStartChat:(WMChat *)chat {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:WebimNotifications.onlineChatStart
                      object:chat];
}

- (void)session:(WMSession *)session didUpdateOperator:(WMOperator *)chatOperator {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:WebimNotifications.onlineOperatorUpdate
                      object:chatOperator];
}

- (void)session:(WMSession *)session didReceiveMessage:(WMMessage *)message {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:WebimNotifications.onlineNewMessage
                      object:message];
    if ([self checkPushNotificationAndMaybeSwitchToRealtimeChat]) {
        return;
    }
    
    // There is only one possible instance of realtime chat, so if we have chatVC on top of
    // the navigation stack, don't show a toast notification
    if ([[self topViewController] isKindOfClass:[WMChatViewController class]]) {
        return;
    }
    
    NSMutableDictionary *options = [self commonToastOptions];
    if ([message isTextMessage]) {
        options[kCRToastTextKey] = WMLocString(@"ToastNewTextMessageTitle");
        options[kCRToastSubtitleTextKey] = [NSString stringWithFormat:@"\"%@\"", message.text];
    } else if ([message isFileMessage]) {
        options[kCRToastTextKey] = WMLocString(@"ToastNewImageMessageTitle");
    } else {
        return;
    }
    options[kCRToastInteractionRespondersKey] =
    @[[CRToastInteractionResponder interactionResponderWithInteractionType:CRToastInteractionTypeTap
                                                      automaticallyDismiss:YES
                                                                     block:^(CRToastInteractionType interactionType) {
                                                                         [self pushRealtimeChatViewControllerFrontmost];
                                                                         [CRToastManager dismissAllNotifications:NO];
                                                                     }]];
    
    [CRToastManager showNotificationWithOptions:options completionBlock:^{
    }];
}

- (void)session:(WMSession *)session didChangeHasOnlineOperatorStatus:(BOOL)hasOnlineOperator {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:WebimNotifications.onlineSessionHasOnlineOperatorChange
                      object:@(hasOnlineOperator)];
}

- (void)session:(WMSession *)session didReceiveError:(WMSessionError)errorID {
    if (errorID == WMSessionErrorAccountBlocked) {
        NSString *message = WMLocString(@"WMSessionErrorAccountBlocked");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:WMLocString(@"DialogDismissButton")
                                              otherButtonTitles:nil];
        [alert show];
    } else if (errorID == WMSessionErrorNetworkError) {
        static BOOL displayingNetworkErrorToast = NO;
        if (displayingNetworkErrorToast) {
            return;
        }
        NSMutableDictionary *options = [self commonToastOptions];
        options[kCRToastTextKey] = WMLocString(@"WMSessionErrorNetworkError");
        options[kCRToastInteractionRespondersKey] =
        @[[CRToastInteractionResponder interactionResponderWithInteractionType:CRToastInteractionTypeTap
                                                          automaticallyDismiss:YES
                                                                         block:^(CRToastInteractionType interactionType) {
                                                                             ;
                                                                         }]];
        [CRToastManager showNotificationWithOptions:options completionBlock:^{
            displayingNetworkErrorToast = NO;
        }];
    }
}

- (BOOL)checkPushNotificationAndMaybeSwitchToRealtimeChat {
    // If we had push notification, that means we came here after switching from bg to fg,
    // try to open realtime chat
    if (self.pushNotification != nil && [self pushNotificationChatID] == nil) {
        // Stay on realtime chat it it's already open. Present new chat on any other vc.
        if ([[self topViewController] isKindOfClass:[WMChatViewController class]]) {
            ;
        } else {
            [self pushRealtimeChatViewControllerFrontmost];
        }
        self.pushNotification = nil; // Clear push notification presence
        return YES;
    }
    return NO;
}

#pragma mark - Offline Session

+ (NSString *)deviceVendorIDToken {
    NSString *vendorID = [[UIDevice currentDevice].identifierForVendor UUIDString];
    NSData *tokenData = [WebimController sha1ForString:vendorID];
    NSString *result = [tokenData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    return result;
}

+ (NSData *)sha1ForString:(NSString *)input {
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (unsigned int) data.length, digest);
    
    return [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
}

+ (void)setUpdateInterval:(NSTimeInterval)timeInterval {
    [[WebimController shared] startTimerWithInterval:timeInterval];
}

+ (BOOL)startObserveChanges {
    [[WebimController shared] startTimerWithInterval:DefaultTimerTimeInterval];
    return YES;
}

+ (BOOL)stopObserveChanges {
    [[WebimController shared] stopTimer];
    return YES;
}

#pragma mark - Notifications

- (void)webimDidReceivePushTokenNotification:(NSNotification *)notification {
    if (self.offlineSession) {
        self.offlineSession = nil;
    }
    self.offlineSession = [[WMOfflineSession alloc] initWithAccountName:AccountName
                                                               location:Location
                                                                  token:[WebimController shared].deviceToken
                                                               platform:nil];
}

#pragma mark - Error processor

+ (BOOL)processCommonErrorInResponse:(NSError *)error {
    if ([error.domain isEqualToString:WMWebimErrorDomain]) {
        NSString *alertMessage = nil;
        if (error.code == WMSessionErrorUnknown) {
            alertMessage = WMLocString(@"WMSessionErrorUnknown");
        } else if (error.code == WMSessionErrorAccountBlocked) {
            alertMessage = WMLocString(@"WMSessionErrorAccountBlocked");
        } else if (error.code == WMSessionErrorNetworkError) {
            alertMessage = WMLocString(@"WMSessionErrorNetworkError");
        } else if (error.code == WMSessionErrorServerNotReady) {
            alertMessage = WMLocString(@"WMSessionErrorServerNotReady");
        }
        if (alertMessage.length > 0) {
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:alertMessage
                                       delegate:nil
                              cancelButtonTitle:WMLocString(@"DialogDismissButton")
                              otherButtonTitles:nil] show];
            return YES;
        }
    }
    return NO;
}

#pragma mark - private methods

- (void)setDeviceToken:(NSString *)deviceToken {
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:DeviceTokenUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _deviceToken = deviceToken;
}

- (void)startTimerWithInterval:(NSTimeInterval)timeInterval {
    self.updateTimer = [NSTimer timerWithTimeInterval:timeInterval
                                               target:self
                                             selector:@selector(timerFireCallback:)
                                             userInfo:nil
                                              repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSDefaultRunLoopMode];
    [self.updateTimer fire];
}

- (void)stopTimer {
    [self.updateTimer invalidate];
}

- (void)timerFireCallback:(id)userData {
    [self.offlineSession getHistoryForced:NO completion:^(BOOL successful, id changes, NSError *error) {
        if (successful) {
            BOOL shouldSendChanges = self.didReceiveHistory == YES;
            self.didReceiveHistory = YES;
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:WebimNotifications.didReceiveUpdate
                              object:nil
                            userInfo:shouldSendChanges ? changes : nil];
            if (shouldSendChanges) {
                if (![[WebimController shared] checkPushNotificationAndMaybeOpenOfflineChat]) {
                    [[WebimController shared] displayNofificationFromHistoryChanges:changes];
                }
            }
        }
    }];
}

+ (void)forceReloadHostory {
    [[WebimController shared].offlineSession getHistoryForced:YES completion:^(BOOL successful, id changes, NSError *error) {
        if (successful) {
            BOOL shouldSendChanges = [WebimController shared].didReceiveHistory == YES;
            [WebimController shared].didReceiveHistory = YES;
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:WebimNotifications.didReceiveUpdate
                              object:nil
                            userInfo:shouldSendChanges ? changes : nil];
            if (shouldSendChanges) {
                if (![[WebimController shared] checkPushNotificationAndMaybeOpenOfflineChat]) {
                    [[WebimController shared] displayNofificationFromHistoryChanges:changes];
                }
            }
        }
    }];
}

- (void)displayNofificationFromHistoryChanges:(NSDictionary *)changes {
    WMMessage *message = [changes[WMOfflineChatChangesMessagesKey] lastObject];
    if (message != nil && [self canDisplayToastUIForMessage:message]) {
        NSMutableDictionary *options = [self commonToastOptions];
        if ([message isTextMessage]) {
            options[kCRToastTextKey] = WMLocString(@"ToastNewTextMessageTitle");
            options[kCRToastSubtitleTextKey] = [NSString stringWithFormat:@"\"%@\"", message.text];
        } else if ([message isFileMessage]) {
            options[kCRToastTextKey] = WMLocString(@"ToastNewImageMessageTitle");
        } else {
            return;
        }
        options[kCRToastInteractionRespondersKey] =
        @[[CRToastInteractionResponder interactionResponderWithInteractionType:CRToastInteractionTypeTap
                                                          automaticallyDismiss:YES
                                                                         block:^(CRToastInteractionType interactionType) {
                                                                             [self pushOfflineChatViewControllerOnNotificationTapMessage:message];
                                                                             [CRToastManager dismissAllNotifications:NO];
                                                                         }]];
        
        [CRToastManager showNotificationWithOptions:options completionBlock:^{
        }];
    }
}

- (NSMutableDictionary *)commonToastOptions {
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    options[kCRToastNotificationTypeKey] = @(CRToastTypeNavigationBar);
    options[kCRToastTextAlignmentKey] = @(NSTextAlignmentLeft);
    options[kCRToastSubtitleTextAlignmentKey] = @(NSTextAlignmentLeft);
    options[kCRToastBackgroundColorKey] = [[UIColor darkGrayColor] colorWithAlphaComponent:0.8];
    options[kCRToastTimeIntervalKey] = @(3);
    options[kCRToastAnimationInTypeKey] = @(CRToastAnimationTypeGravity);
    options[kCRToastAnimationOutTypeKey] = @(CRToastAnimationTypeGravity);
    options[kCRToastAnimationInDirectionKey] = @(CRToastAnimationDirectionTop);
    options[kCRToastAnimationOutDirectionKey] = @(CRToastAnimationDirectionBottom);
    return options;
}

- (void)pushOfflineChatViewControllerOnNotificationTapMessage:(WMMessage *)message {
    if ([self canDisplayToastUIForMessage:message]) {
        UIViewController *topVC = [self topViewController];
        WMChat *chatForMessage = [_offlineSession chatForMessage:message];
        [self pushOfflineChatViewControllerOn:topVC withChat:chatForMessage];
    } else {
        [CRToastManager dismissAllNotifications:YES];
    }
}

- (void)pushOfflineChatViewControllerOn:(UIViewController *)parentVC withChat:(WMChat *)chat {
    NSString *identifier = NSStringFromClass([WMOfflineChatViewController class]);
    WMOfflineChatViewController *chatVC = [parentVC.storyboard instantiateViewControllerWithIdentifier:identifier];
    chatVC.chat = chat;
    [parentVC.navigationController pushViewController:chatVC animated:YES];
}

- (void)pushRealtimeChatViewControllerFrontmost {
    UIViewController *parentVC = [self topViewController];
    NSString *identifier = NSStringFromClass([WMChatViewController class]);
    WMChatViewController *chatVC = [parentVC.storyboard instantiateViewControllerWithIdentifier:identifier];
    [parentVC.navigationController pushViewController:chatVC animated:YES];
}

- (BOOL)canDisplayToastUIForMessage:(WMMessage *)message {
    WMChat *chatForMessage = [_offlineSession chatForMessage:message];
    if (chatForMessage == nil) {
        return NO;
    }
    UIViewController *topVC = [self topViewController];
    if ([topVC isKindOfClass:[WMOfflineChatViewController class]]) {
        WMOfflineChatViewController *appealVC = (WMOfflineChatViewController *)topVC;
        return !(appealVC.chat == nil || chatForMessage == appealVC.chat);
    }
    return YES;
}

- (UIViewController *)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

- (NSNumber *)pushNotificationChatID {
    return self.pushNotification[@"chat_id"];
}

- (BOOL)checkPushNotificationAndMaybeOpenOfflineChat {
    NSNumber *chatID = nil;
    if (self.pushNotification != nil && (chatID = [self pushNotificationChatID]) != nil) {
        WMChat *chat = [self findOfflineChatWithID:chatID];
        if ([self canDisplayToastUIForMessage:chat.messages.firstObject]) {
            [self pushOfflineChatViewControllerOn:[self topViewController] withChat:chat];
        }
        self.pushNotification = nil;
        return YES;
    }
    return NO;
}

- (WMChat *)findOfflineChatWithID:(NSString *)chatID {
    for (WMChat *chat in _offlineSession.appealsArray) {
        if ([chat.uid isEqualToString:chatID]) {
            return chat;
        }
    }
    return nil;
}

@end
