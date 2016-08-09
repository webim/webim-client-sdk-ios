//
//  WebimController.h
//  WebimOffline
//
//  Copyright (c) 2015 WEBIM.RU Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WMOfflineSession.h"
#import "WMSession.h"
#import "WMChat.h"
#import "WMMessage.h"

extern const struct WebimNotifications {
    // Realtime session
    __unsafe_unretained NSString *onlineFullUpdate;
    __unsafe_unretained NSString *onlineNewMessage;
    __unsafe_unretained NSString *onlineOperatorUpdate;
    __unsafe_unretained NSString *onlineChatStart;
    __unsafe_unretained NSString *onlineChatStatusChange;
    __unsafe_unretained NSString *onlineSessionStatusChange;
    __unsafe_unretained NSString *onlineSessionHasOnlineOperatorChange;
    // Offline session
    __unsafe_unretained NSString *didReceiveUpdate;
    // System notifications
    __unsafe_unretained NSString *didReceivePushToken;
} WebimNotifications;

@interface WebimController : NSObject

@property (nonatomic, strong) WMOfflineSession *offlineSession;
@property (nonatomic, strong) WMSession *realtimeSession;
@property (nonatomic, strong) NSMutableDictionary *imagesMap;
@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, strong) NSDictionary *pushNotification;

+ (instancetype)shared;

+ (void)initializeWithConfig:(NSDictionary *)config;

+ (void)setUpdateInterval:(NSTimeInterval)timeInterval;
+ (BOOL)startObserveChanges;
+ (BOOL)stopObserveChanges;
+ (void)forceReloadHostory;

+ (BOOL)processCommonErrorInResponse:(NSError *)error;

@end
