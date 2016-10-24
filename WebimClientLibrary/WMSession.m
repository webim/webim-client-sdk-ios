//
//  WMSession.m
//  Webim-Client
//
//  Created by Oleg Bogumirsky on 9/5/13.
//  Copyright (c) 2013 WEBIM.RU Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WMSession.h"

#import "AFNetworking.h"

#import "WMChat.h"
#import "WMMessage.h"
#import "WMOperator.h"
#import "WMVisitor.h"

#import "WMChat+Private.h"
#import "WMMessage+Private.h"
#import "WMOperator+Private.h"
#import "NSUserDefaults+ClientData.h"
#import "WMUIDGenerator.h"

#ifdef DEBUG
#define WMDebugLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define WMDebugLog(format, ...)
#endif

static NSString *const APIDeltaPath =   @"/l/v/delta";
static NSString *const APIActionPath =  @"/l/v/action";
static NSString *const APIHistoryPath = @"/l/v/history";
static NSString *const APIUploadPath =  @"/l/v/upload";

static NSString *DefaultClientTitle = @"iOS Client";

static const NSTimeInterval ReconnectTimeInterval = 30; //< seconds
static const NSTimeInterval OnlineDeltaPatchTimeInterval = 30;
static const NSTimeInterval PatchTimerCheckTimeInterval = 4;

NSString *const WMVisitorParameterDisplayName = @"display_name";
NSString *const WMVisitorParameterPhone = @"phone";
NSString *const WMVisitorParameterEmail = @"email";
NSString *const WMVisitorParameterICQ = @"icq";
NSString *const WMVisitorParameterProfileURL = @"profile_url";
NSString *const WMVisitorParameterAvatarURL = @"avatar_url";
NSString *const WMVisitorParameterID = @"id";
NSString *const WMVisitorParameterLogin = @"login";
NSString *const WMVisitorParameterCRC = @"crc";

@interface WMSession ()

@property (nonatomic, strong) NSNumber *revision;

@property (nonatomic, assign) BOOL isStopped;

@end

@implementation WMSession {
    AFHTTPClient      *client_;
    NSNumber            *activeDeltaRevisionNumber_;
    BOOL                 sessionEstablished_;   // YES after successful response of initial delta
    BOOL                 sessionStarted_; // YES after first call to startSession method
    BOOL                 gettingInitialDelta_;
    NSDate              *lastFullUpdateDate_;
    NSTimer             *patchDeltaTimer_;
    NSDictionary        *userDefinedVisitorFields_;
    
    BOOL                 lastComposedSentIsTyping_;
    BOOL                 lastComposedCachedIsTyping_;
    NSString            *lastComposedSentDraft_;
    NSString            *lastComposedCachedDraft_;
    NSDate              *lastComposedSentDate_;
    NSTimer             *composingTimer_;
}

- (id)initWithAccountName:(NSString *)accountName location:(NSString *)location delegate:(id<WMSessionDelegate>)delegate visitorFields:(NSDictionary *)visitorFields {
    if ((self = [super initWithAccountName:accountName location:location])) {
        _delegate = delegate;
        userDefinedVisitorFields_ = visitorFields;
        NSURL *baseURL = [NSURL URLWithString:self.host];
        client_ = [AFHTTPClient clientWithBaseURL:baseURL];
        [client_ setParameterEncoding:AFFormURLParameterEncoding];
        [client_ setDefaultHeader:@"Accept" value:@"text/json, application/json"];
        [client_ registerHTTPOperationClass:[AFJSONRequestOperation class]];
        
        [self enableObservingForNotifications:YES];
    }
    
    return self;
}

- (id)initWithAccountName:(NSString *)accountName location:(NSString *)location delegate:(id<WMSessionDelegate>)delegate {
    return [self initWithAccountName:accountName location:location delegate:delegate visitorFields:nil];
}

- (void)dealloc {
    [self enableObservingForNotifications:NO];
}

- (WMSessionState)sesstionStateFromString:(NSString *)state {
    if ([@"idle" isEqualToString:state]) {
        return WMSessionStateIdle;
    } else if ([@"idle-after-chat" isEqualToString:state]) {
        return WMSessionStateIdleAfterChat;
    } else if ([@"chat" isEqualToString:state]) {
        return WMSessionStateChat;
    } else if ([@"offline-message" isEqualToString:state]) {
        return WMSessionStateOfflineMessage;
    }
    return WMSessionStateUnknown;
}

- (WMSessionOnlineStatus)onlineStatusFromString:(NSString *)status {
    NSDictionary *map = @{
                          @"online": @(WMSessionOnlineStatusOnline),
                          @"busy_online": @(WMSessionOnlineStatusBusyOnline),
                          @"offline": @(WMSessionOnlineStatusOffline),
                          @"busy_offline": @(WMSessionOnlineStatusBusyOffline),
                          };
    if (status.length == 0 || map[status] == nil) {
        return WMSessionOnlineStatusUnknown;
    }
    return (WMSessionOnlineStatus)[map[status] integerValue];
}

- (void)enableObservingForNotifications:(BOOL)enable {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    if (enable) {
        [nc addObserver:self
               selector:@selector(applicationDidBecomeActiveNotification:)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];
        [nc addObserver:self
               selector:@selector(applicationDidEnterBackgroundNotification:)
                   name:UIApplicationDidEnterBackgroundNotification
                 object:nil];
        [nc addObserver:self
               selector:@selector(deviceTokenNotification:)
                   name:@"WMDeviceTokenNotification"
                 object:nil];
    } else {
        [nc removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
        [nc removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
        [nc removeObserver:self name:@"WMDeviceTokenNotification" object:nil];
    }
}

- (NSString *)jsonizedStringFromObject:(id)inputObject {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:inputObject options:0 error:&error];
    if (error != nil) {
        NSLog(@"Unable to serialize jsonObject: %@", error.localizedDescription);
        return nil;
    }
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return output;
}

- (void)setLocation:(NSString *)location {
    [super setLocation:location];
    if (sessionStarted_) {
        [self cancelGettingDeltaWithComet];
        [self startSession:nil];
    }
}

#pragma mark - APIs

- (void)startSession:(WMResponseCompletionBlock)block {
    gettingInitialDelta_ = YES;
    sessionStarted_ = YES;
    self.isStopped = NO;

#if 0
    id visitor = [[NSUserDefaults standardUserDefaults] valueForKey:@"visitor"];
    id visitSessionId = [[NSUserDefaults standardUserDefaults] valueForKey:@"visitSessionId"];
    id pageID = [[NSUserDefaults standardUserDefaults] valueForKey:@"pageID"];
#endif
    NSDictionary *storedValues = [NSUserDefaults unarchiveClientData];
    id visitor = storedValues[WMStoreVisitorKey];
    id visitSessionId = storedValues[WMStoreVisitSessionIDKey];
    id pageID = storedValues[WMStorePageIDKey];
    id ext = storedValues[WMStoreVisitorExtKey];
    
    BOOL extFieldsTheSame = [self dictionary:ext isEqualToDictionary:userDefinedVisitorFields_];
    
    if (pageID != nil && extFieldsTheSame) {
        gettingInitialDelta_ = NO;
        [self getDeltaWithComet:NO completionBlock:^(NSDictionary *result) {
            if (result == nil) {
                sessionEstablished_ = YES;
            }
            CALL_BLOCK(block, result == nil);
        }];
        return;
    }
    
    id extVisitorObject = nil;
    if (userDefinedVisitorFields_ != nil) {
        extVisitorObject = [self jsonizedStringFromObject:userDefinedVisitorFields_];
    }
    if (extVisitorObject == nil) {
        extVisitorObject = [NSNull null];
    }
    
    NSDictionary *params =
        @{
            @"event": @"init",
            @"location": self.location,
            @"visit-session-id": visitSessionId == nil ? [NSNull null] : visitSessionId,
            @"title": DefaultClientTitle,
            @"since": @0,
            @"visitor": visitor == nil ? [NSNull null] : [self jsonizedStringFromObject:visitor],
            @"visitor-ext": extVisitorObject,
            @"ts": @([[NSDate date] timeIntervalSince1970]),
            @"platform": @"ios",
        };
    NSString *pushToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"WMDeviceTokenKey"];
    if ([pushToken isKindOfClass:[NSString class]] && pushToken.length > 0) {
        NSMutableDictionary *extParams = [params mutableCopy];
        [extParams setValue:pushToken forKey:@"push-token"];
        params = extParams;
    }
    if (activeDeltaRevisionNumber_ != nil) {
        CALL_BLOCK(block, NO);
        return;
    }
    activeDeltaRevisionNumber_ = @0;
    [client_ getPath:APIDeltaPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        activeDeltaRevisionNumber_ = nil;
        gettingInitialDelta_ = NO;
        WMDebugLog(@"Init Delta Response:\n%@", responseObject);
        BOOL hasError = [self handleErrorInResponse:responseObject];
        if (!hasError) {
            sessionEstablished_ = YES;
            [self processGetInitialDelta:responseObject];
            [self startGettingDeltaWithComet];
        }
        CALL_BLOCK(block, !hasError);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        activeDeltaRevisionNumber_ = nil;
        gettingInitialDelta_ = NO;
        if (operation.isCancelled) {
            CALL_BLOCK(block, NO);
            return;
        }
        WMDebugLog(@"Error: unable to start with location.\n%@", error);
        [self processErrorAPIResponse:operation error:error];
        CALL_BLOCK(block, NO);
    }];
}

- (void)stopSession {
    [patchDeltaTimer_ invalidate];
    patchDeltaTimer_ = nil;
    [composingTimer_ invalidate];
    composingTimer_ = nil;
    [self cancelGettingDeltaWithComet];
    self.isStopped = YES;
}

- (BOOL)dictionary:(NSDictionary *)left isEqualToDictionary:(NSDictionary *)right {
    if (left == nil || right == nil) {
        return NO;
    }
    if ((left != nil && right == nil) || (left == nil && right != nil)) {
        return YES;
    }
    return [left isEqualToDictionary:right];
}

- (void)processErrorAPIResponse:(AFHTTPRequestOperation *)operation error:(NSError *)error {
    if (operation.response == nil) {
        // Network problem
        [self postponeGettingDelta];
        if ([_delegate respondsToSelector:@selector(session:didReceiveError:)]) {
            [_delegate session:self didReceiveError:WMSessionErrorNetworkError];
        }
    }
}

- (void)refreshSessionWithCompletionBlock:(WMResponseCompletionBlock)block {
    [self cancelGettingDeltaWithComet];
    [self getDeltaWithComet:NO completionBlock:^(NSDictionary *statusData) {
        CALL_BLOCK(block, statusData == nil);
    }];
}

- (void)continueInLocation {
    [self cancelGettingDeltaWithComet];
    [self performSelector:@selector(startGettingDeltaWithComet) withObject:nil afterDelay:0.3];
}

- (void)postponeGettingDelta {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startGettingDeltaWithComet) object:nil];
    [self performSelector:@selector(startGettingDeltaWithComet) withObject:nil afterDelay:ReconnectTimeInterval];
}

- (void)startGettingDeltaWithComet {
    if (self.isStopped) {
        return;
    }
    [NSObject dispatchSyncOnMainThreadBlock:^{
        if (activeDeltaRevisionNumber_ != nil) {
            return;
        }
        if (!sessionEstablished_) {
            [self startSession:nil];
            return;
        }
        [self getDeltaWithComet:YES completionBlock:^(NSDictionary *errorData) {
            if (errorData == nil) {
                [self performSelector:@selector(startGettingDeltaWithComet) withObject:nil afterDelay:0.3];
            }
        }];
    }];
}

- (void)cancelGettingDeltaWithComet {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startGettingDeltaWithComet) object:nil];
    [client_ cancelAllHTTPOperationsWithMethod:@"GET" path:APIDeltaPath];
}

- (void)getDeltaWithCompletionBlock:(void (^)(NSDictionary *statusData))block {
    [self getDeltaWithComet:NO completionBlock:block];
}

- (void)getDeltaWithComet:(BOOL)useComet completionBlock:(void (^)(NSDictionary *))block {
    NSString *pageID = [NSUserDefaults unarchiveClientData][WMStorePageIDKey];
    if (client_ == nil && pageID.length == 0) {
        CALL_BLOCK(block, @{@"error": @"Uninitialized"});
        return;
    }
    if (pageID.length == 0) {
        // Lost archieved data. Session should be re-initialized.
        [self stopSession];
        if ([self.delegate respondsToSelector:@selector(sessionRestartRequired:)]) {
            [self.delegate sessionRestartRequired:self];
        }
        return;
    }
    if (self.revision == nil) {
        self.revision = @0;
    }
    if (activeDeltaRevisionNumber_ != nil) {
        [self cancelGettingDeltaWithComet];
    }
    
    NSDictionary *params =
        @{
            @"page-id": pageID,
            @"since": self.revision,
            @"ts": @([[NSDate date] timeIntervalSince1970]),
            @"respond-immediately" : useComet ? @"false" : @"true",
        };
    activeDeltaRevisionNumber_ = self.revision;
    [client_ getPath:APIDeltaPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        activeDeltaRevisionNumber_ = nil;
        WMDebugLog(@"Get Delta response:\n%@", responseObject);
        [self handleErrorInResponse:responseObject];
        [self processGetDelta:responseObject];
        if (!useComet) {
            [self startGettingDeltaWithComet];
        }
        if (block != nil) {
            block(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        activeDeltaRevisionNumber_ = nil;
        if (operation.isCancelled) {
            if (block != nil) block (nil);
            return;
        }
        WMDebugLog(@"Error: %@", error);
        if (operation.response == nil) {
            [self processErrorAPIResponse:operation error:error];
        }
        if (block != nil) {
            block( @{@"error": error});
        }
    }];
}

- (NSString *)startChat:(WMResponseCompletionBlock)block {
    return [self startChatWithClientSideId:nil completionBlock:block];
}

- (NSString *)startChatWithClientSideId:(NSString *)clientSideId completionBlock:(WMResponseCompletionBlock)block {
    NSString *pageID = [NSUserDefaults unarchiveClientData][WMStorePageIDKey];
    if (pageID.length == 0) {
        CALL_BLOCK(block, NO);
        return nil;
    }
    if (clientSideId.length == 0) {
        clientSideId = [WMUIDGenerator generateUID];
    }
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"action"] = @"chat.start";
    if (pageID.length > 0) {
        params[@"page-id"] = pageID;
    }
    if (clientSideId.length > 0) {
        params[@"client-side-id"] = clientSideId;
    }
    
    [client_ postPath:APIActionPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        WMDebugLog(@"Action: start chat - response:\n%@", responseObject);
        BOOL hasError = [self handleErrorInResponse:responseObject];
        CALL_BLOCK(block, !hasError);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        WMDebugLog(@"Action: start chat - error: %@", error);
        [self processErrorAPIResponse:operation error:error];
        CALL_BLOCK(block, NO);
    }];
    
    return clientSideId;
}

- (void)closeChat:(WMResponseCompletionBlock)block {
    NSString *pageID = [NSUserDefaults unarchiveClientData][WMStorePageIDKey];
    if (pageID.length == 0) {
        CALL_BLOCK(block, NO);
        return;
    }
    NSDictionary *params =
        @{
            @"page-id": pageID,
            @"action": @"chat.close",
        };
    [client_ postPath:APIActionPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        WMDebugLog(@"Action: close chat - response:\n%@", responseObject);
        BOOL hasError = [self handleErrorInResponse:responseObject];
        CALL_BLOCK(block, !hasError);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        WMDebugLog(@"Action: close chat - error: %@", error);
        [self processErrorAPIResponse:operation error:error];
        CALL_BLOCK(block, NO);
    }];
}

- (void)markChatAsRead:(WMResponseCompletionBlock)block {
    NSString *pageID = [NSUserDefaults unarchiveClientData][WMStorePageIDKey];
    if (pageID.length == 0) {
        CALL_BLOCK(block, NO);
        return;
    }
    NSDictionary *params =
    @{
      @"page-id": pageID,
      @"action": @"chat.read_by_visitor",
      };
    [client_ postPath:APIActionPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        WMDebugLog(@"Action: close chat - response:\n%@", responseObject);
        BOOL hasError = [self handleErrorInResponse:responseObject];
        CALL_BLOCK(block, !hasError);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        WMDebugLog(@"Action: close chat - error: %@", error);
        [self processErrorAPIResponse:operation error:error];
        CALL_BLOCK(block, NO);
    }];
}

- (NSString *)sendMessage:(NSString *)message successBlock:(void (^)(NSString *))successBlock failureBlock:(void (^)(NSString *, WMSessionError))failureBlock {
    return [self sendMessage:message withClientSideId:nil successBlock:successBlock failureBlock:failureBlock];
}

- (NSString *)sendMessage:(NSString *)message withClientSideId:(NSString *)clientSideId successBlock:(void (^)(NSString *))successBlock failureBlock:(void (^)(NSString *, WMSessionError))failureBlock {

    NSString *pageID = [NSUserDefaults unarchiveClientData][WMStorePageIDKey];
    if (clientSideId.length == 0) {
        clientSideId = [WMUIDGenerator generateUID];
    }
    
    if (pageID.length == 0) {
        CALL_BLOCK(failureBlock, nil, WMSessionErrorNotConfigured);
        return nil;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"action"] = @"chat.message";
    if (message.length > 0) {
        params[@"message"] = message;
    }
    if (pageID.length > 0) {
        params[@"page-id"] = pageID;
    }
    if (clientSideId.length > 0) {
        params[@"client-side-id"] = clientSideId;
    }
    [client_ postPath:APIActionPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        WMDebugLog(@"Action: send message - response:\n%@", responseObject);
        WMSessionError error = WMSessionErrorUnknown;
        BOOL hasError = [self handleErrorInResponse:responseObject error:&error];
        if (hasError) {
            CALL_BLOCK(failureBlock, clientSideId, error);
        } else {
            CALL_BLOCK(successBlock, clientSideId);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        WMDebugLog(@"Action: send message - error: %@", error);
        [self processErrorAPIResponse:operation error:error];
        CALL_BLOCK(failureBlock, clientSideId, WMSessionErrorNetworkError);
    }];
    
    return clientSideId;
}

- (void)sendImage:(NSData *)imageData type:(WMChatAttachmentImageType)type completion:(WMResponseCompletionBlock)block {
    NSString *mimeType = type == WMChatAttachmentImageJPEG ? @"image/jpeg" : @"image/png";
    NSString *fileName = type == WMChatAttachmentImageJPEG ? @"ios_file.jpg" : @"ios_file.png";
    
    [self sendFile:imageData name:fileName mimeType:mimeType successBlock:^(NSString *messageID) {
        CALL_BLOCK(block, YES);
    } failureBlock:^(NSString *messageID, WMSessionError error) {
        CALL_BLOCK(block, NO);
    }];
}

- (NSString *)percentEscapeString:(NSString *)string
{
    NSString *result = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (CFStringRef)string,
                                                                                 (CFStringRef)@" ",
                                                                                 (CFStringRef)@":/?@!$&'()*+,;=",
                                                                                 kCFStringEncodingUTF8));
    return [result stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}

- (NSString *)sendFile:(NSData *)fileData name:(NSString *)fileName mimeType:(NSString *)mimeType successBlock:(void (^)(NSString *))succcessBlock failureBlock:(void (^)(NSString *, WMSessionError))failureBlock {
    return [self sendFile:fileData name:fileName mimeType:mimeType withClientSideId:nil successBlock:succcessBlock failureBlock:failureBlock];
}

- (NSString *)sendFile:(NSData *)fileData name:(NSString *)fileName mimeType:(NSString *)mimeType withClientSideId:(NSString *)clientSideId successBlock:(void (^)(NSString *))succcessBlock failureBlock:(void (^)(NSString *, WMSessionError))failureBlock {

    NSDictionary *storeData = [NSUserDefaults unarchiveClientData];
    NSString *pageID = storeData[WMStorePageIDKey];
    if (clientSideId.length == 0) {
        clientSideId = [WMUIDGenerator generateUID];
    }
    
    if (pageID.length == 0) {
        CALL_BLOCK(failureBlock, nil, WMSessionErrorNotConfigured);
        return nil;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (pageID.length > 0) {
        params[@"page-id"] = pageID;
    }
    if (clientSideId.length > 0) {
        params[@"client-side-id"] = clientSideId;
    }
    
    void (^multipartConstructBlock)(id<AFMultipartFormData>) = ^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:fileData name:@"webim_upload_file" fileName:fileName mimeType:mimeType];
    };
    
    NSMutableURLRequest *request = [client_ multipartFormRequestWithMethod:@"POST"
                                                                      path:APIUploadPath
                                                                parameters:params
                                                 constructingBodyWithBlock:multipartConstructBlock];
    
    AFHTTPRequestOperation *operation = [client_ HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        WMSessionError error = 0;
        BOOL hasError = [self handleErrorInResponse:responseObject error:&error];
        if (hasError) {
            CALL_BLOCK(failureBlock, clientSideId, error);
        } else {
            CALL_BLOCK(succcessBlock, clientSideId);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        CALL_BLOCK(failureBlock, clientSideId, WMSessionErrorNetworkError);
    }];
    [client_ enqueueHTTPRequestOperation:operation];
    
    return clientSideId;
}

- (void)enqueueHTTPRequestOperation:(id)operation {
    [client_ enqueueHTTPRequestOperation:operation];
}

- (void)setupPushToken:(NSString *)pushToken completion:(WMResponseCompletionBlock)block {
    NSString *pageID = [NSUserDefaults unarchiveClientData][WMStorePageIDKey];
    if (pageID.length == 0 || pushToken.length == 0) {
        return;
    }
    
    NSDictionary *params =
        @{
            @"page-id": pageID,
            @"action": @"set_push_token",
            @"push-token": pushToken,
            @"platform": @"ios",
        };
    [client_ postPath:APIActionPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        WMDebugLog(@"Action: setup push token - response:\n%@", responseObject);
        if ([self handleErrorInResponse:responseObject]) {
            CALL_BLOCK(block, NO);
        } else {
            CALL_BLOCK(block, YES);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        WMDebugLog(@"Action: setup push token - error: %@", error);
        [self processErrorAPIResponse:operation error:error];
        CALL_BLOCK(block, NO);
    }];
}

- (void)clearCachedUserData {
    [NSUserDefaults archiveClientData:nil];
    self.revision = nil;
}

- (BOOL)draftChanged:(NSString *)draft {
    
    if (lastComposedSentDraft_.length == 0 && draft.length == 0) {
        return NO;
    } else if ((lastComposedSentDraft_.length == 0 && draft.length > 0) ||
               (lastComposedSentDraft_.length > 0 && draft.length == 0)) {
        return YES;
    } else {
        return ![lastComposedSentDraft_ isEqualToString:draft];
    }
}

- (void)setComposingMessage:(BOOL)isComposing draft:(NSString *)draft isTimer:(BOOL)isTimer {
    
    BOOL draftChanged = [self draftChanged:draft];
    
    NSString *pageID = [NSUserDefaults unarchiveClientData][WMStorePageIDKey];
    if (pageID.length == 0) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"action"] = @"chat.visitor_typing";
    params[@"page-id"] = pageID;
    params[@"typing"] = isComposing ? @"true" : @"false";
    if (draftChanged) {
        if (draft.length > 0) {
            params[@"message-draft"] = draft;
        } else {
            params[@"del-message-draft"] = @"true";
        }
        lastComposedSentDraft_ = draft;
    }
    
    [client_ postPath:APIActionPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self handleErrorInResponse:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self processErrorAPIResponse:operation error:error];
    }];
    lastComposedSentDate_ = [NSDate date];
}

- (void)setComposingByTimer:(NSTimer *)timer {
    
    composingTimer_ = nil;
    [self setComposingMessage:lastComposedCachedIsTyping_ draft:lastComposedCachedDraft_ isTimer:YES];
}

- (void)setComposingMessage:(BOOL)isComposing draft:(NSString *)draft {
    
    lastComposedCachedIsTyping_ = isComposing;
    lastComposedCachedDraft_ = draft;
    
    if (composingTimer_ != nil) {
        return;
    }

    if (lastComposedSentDate_ != nil && [[NSDate date] timeIntervalSinceDate:lastComposedSentDate_] < 2.f) {
        composingTimer_ = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(setComposingByTimer:) userInfo:nil repeats:NO];
        return;
    }
    
    [self setComposingMessage:isComposing draft:draft isTimer:NO];
}

- (void)rateOperator:(NSString *)authorID withRate:(WMOperatorRate)rate completion:(WMResponseCompletionBlock)block {
    NSDictionary *storedValues = [NSUserDefaults unarchiveClientData];
    NSString *pageID = storedValues[WMStorePageIDKey];
    NSString *visitSessionID = storedValues[WMStoreVisitSessionIDKey];
    
    if (pageID.length == 0 || visitSessionID.length == 0 || authorID.length == 0) {
        CALL_BLOCK(block, NO);
        return;
    }
    
    NSInteger rateInt = (NSInteger)rate;
    NSAssert(-2 <= rateInt && rateInt <= 2, @"Out of rage value for rate: %ld", (long)rate);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"action"] = @"chat.operator_rate_select";
    params[@"rate"] = @(rateInt);
    params[@"operator-id"] = authorID;
    params[@"page-id"] = pageID;
    params[@"visit-session-id"] = visitSessionID;
    
    [client_ postPath:APIActionPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BOOL hasError = [self handleErrorInResponse:responseObject];
        CALL_BLOCK(block, hasError);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self processErrorAPIResponse:operation error:error];
        CALL_BLOCK(block, NO);
    }];
}

#pragma mark - Error Processor

- (BOOL)handleErrorInResponse:(NSDictionary *)response {
    return [self handleErrorInResponse:response error:nil];
}

- (BOOL)handleErrorInResponse:(NSDictionary *)response error:(WMSessionError *)error {
    if (response && [response isKindOfClass:[NSDictionary class]] && response[@"error"] != nil) {
        [self cancelGettingDeltaWithComet];
        if (self.isStopped) {
            return NO;
        }
        WMSessionError errorID = [self errorFromString:response[@"error"]];
        if (error != NULL) {
            *error = errorID;
        }
        if ([_delegate respondsToSelector:@selector(session:didReceiveError:)]) {
            if (errorID == WMSessionErrorReinitRequired) {
                NSMutableDictionary *storage = [[NSUserDefaults unarchiveClientData] mutableCopy];
                [storage removeObjectForKey:WMStorePageIDKey];
                [NSUserDefaults archiveClientData:storage];

                activeDeltaRevisionNumber_ = nil;
                sessionEstablished_ = NO;
                [self performSelector:@selector(startGettingDeltaWithComet) withObject:nil afterDelay:0.1];
            }
            [_delegate session:self didReceiveError:errorID];
        }
        return YES;
    }
    return NO;
}

- (WMSessionError)errorFromString:(NSString *)errorDescription {
    if ([@"reinit-required" isEqualToString:errorDescription]) {
        return WMSessionErrorReinitRequired;
    } else if ([@"server-not-ready" isEqualToString:errorDescription]) {
        return WMSessionErrorServerNotReady;
    } else if ([@"account-blocked" isEqualToString:errorDescription]) {
        return WMSessionErrorAccountBlocked;
    } else if ([@"not_allowed_file_type" isEqualToString:errorDescription]) {
        return WMSessionErrorAttachmentTypeNotAllowed;
    } else if ([@"max_file_size_exceeded" isEqualToString:errorDescription]) {
        return WMSessionErrorAttachmentSizeExceeded;
    } else if ([@"max-message-length-exceeded" isEqualToString:errorDescription]) {
        return WMSessionErrorMessageSizeExceeded;
    } else if ([@"chat_count_limit_exceeded" isEqualToString:errorDescription]) {
        return WMSessionErrorChatCountLimitExceeded;
    } else if ([@"visitor_banned" isEqualToString:errorDescription]) {
        return WMSessionErrorVisitorBanned;
    } else if ([@"chat_count_limit_exceeded" isEqualToString:errorDescription]) {
        return WMSessionErrorChatCountLimitExceeded;
    }
    return WMSessionErrorUnknown;
}

#pragma mark - Processors

- (void)processGetInitialDelta:(id)response {
    if (response == nil || ![response isKindOfClass:[NSDictionary class]] || ((NSDictionary *)response).count == 0) {
        return;
    }
    if (self.isStopped) {
        return;
    }
    
    self.revision = response[@"revision"];
    
    NSMutableDictionary *fullUpdate = response[@"fullUpdate"];
    NSAssert([fullUpdate isKindOfClass:[NSDictionary class]], @"Unexpected result for initial delta");
    
    [self processDeltaFullUpdate:fullUpdate];
}

- (void)processGetDelta:(id)response {
    if (response == nil || ![response isKindOfClass:[NSDictionary class]] || ((NSDictionary *)response).count == 0) {
        return;
    }
    if (self.isStopped) {
        return;
    }
    self.revision = response[@"revision"];
    WMDebugLog(@"Received delta at %@ revision", self.revision);
    [self processDeltaFullUpdate:response[@"fullUpdate"]];
    [self processDeltaDeltaList:response[@"deltaList"]];
}

- (void)processDeltaFullUpdate:(NSMutableDictionary *)updateDictionary {
    lastFullUpdateDate_ = [NSDate date];
    if (patchDeltaTimer_ == nil) {
        patchDeltaTimer_ = [NSTimer scheduledTimerWithTimeInterval:PatchTimerCheckTimeInterval
                                                            target:self
                                                          selector:@selector(patchOnlineDelta)
                                                          userInfo:nil
                                                           repeats:YES];
    }
    if (updateDictionary == nil || ![updateDictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSMutableDictionary *storeValues = [NSMutableDictionary dictionary];
    storeValues[WMStoreVisitorKey] = updateDictionary[@"visitor"];
    storeValues[WMStoreVisitSessionIDKey] = updateDictionary[@"visitSessionId"];
    storeValues[WMStorePageIDKey] = updateDictionary[@"pageId"];
    storeValues[WMStoreVisitorExtKey] = userDefinedVisitorFields_;
    if (self.isStopped) {
        return;
    }
    [NSUserDefaults archiveClientData:storeValues];
    
    self.onlineStatus = [self onlineStatusFromString:updateDictionary[@"onlineStatus"]];
    [self updateSessionStateWithObject:updateDictionary[@"state"]];
    
    [self updateChatWithObject:updateDictionary[@"chat"]];
    if ([_delegate respondsToSelector:@selector(sessionDidReceiveFullUpdate:)]) {
        [_delegate sessionDidReceiveFullUpdate:self];
    }
}

- (void)processDeltaDeltaList:(NSDictionary *)deltaList {
    if (deltaList == nil || ![deltaList isKindOfClass:[NSArray class]]) {
        return;
    }
    
    for (NSDictionary *deltaDictionary in deltaList) {
        NSString *objectTypeString = deltaDictionary[@"objectType"];
        NSString *eventString = deltaDictionary[@"event"];
        NSMutableDictionary *dataDictionary = deltaDictionary[@"data"];
        
        if ([@"VISIT_SESSION_STATE" isEqualToString:objectTypeString]) {
            if ([@"upd" isEqualToString:eventString]) {
                [self updateSessionStateWithObject:dataDictionary];
            } else {
                WMDebugLog(@"Warning: %@ is not expected for %@", eventString, objectTypeString);
            }
        } else if ([@"CHAT" isEqualToString:objectTypeString]) {
            if ([@"upd" isEqualToString:eventString]) {
                [self updateChatWithObject:dataDictionary];
            } else {
                WMDebugLog(@"Warning: %@ is not expected for %@", eventString, objectTypeString);
            }
        } else if ([@"CHAT_MESSAGE" isEqualToString:objectTypeString]) {
            if ([@"add" isEqualToString:eventString]) {
                [self addChatMessageFromObject:dataDictionary];
            } else {
                WMDebugLog(@"Warning: %@ is not expected for %@", eventString, objectTypeString);
            }
        } else if ([@"CHAT_STATE" isEqualToString:objectTypeString]) {
            if ([@"upd" isEqualToString:eventString]) {
                [self updateChatStatusWithObject:dataDictionary];
            } else {
                WMDebugLog(@"Warning: %@ is not expected for %@", eventString, objectTypeString);
            }
        } else if ([@"CHAT_OPERATOR" isEqualToString:objectTypeString]) {
            if ([@"upd" isEqualToString:eventString]) {
                [self updateChatOperatorWithObject:dataDictionary];
            } else {
                WMDebugLog(@"Warning: %@ is not expected for %@", eventString, objectTypeString);
            }
        } else if ([@"CHAT_READ_BY_VISITOR" isEqualToString:objectTypeString]) {
            if ([@"upd" isEqualToString:eventString]) {
                [self updateChatReadByVisitorWithObject:dataDictionary];
            }
        } else if ([@"CHAT_OPERATOR_TYPING" isEqualToString:objectTypeString]) {
            if ([@"upd" isEqualToString:eventString]) {
                [self updateChatOperatorTypingWithObject:dataDictionary];
            }
        } else {
            WMDebugLog(@"Warning: ProcessDelta: uncotegorized object %@:\n%@",
                  objectTypeString, deltaDictionary);
        }
    }
}

- (void)updateSessionStateWithObject:(NSDictionary *)object {
    NSParameterAssert([object isKindOfClass:[NSString class]]);
    _state = [self sesstionStateFromString:(NSString *)object];
#if 1
    // Currently we have no chance to get fullDelta on changes in operator offline/online status,
    // so manually change this flag according to the session status
    if (_state == WMSessionStateOfflineMessage) {
        self.onlineStatus = WMSessionOnlineStatusOffline;
        // Close current offline chat to avoid conflicts in future
        [self closeChat:nil];
    }
#endif
    if ([_delegate respondsToSelector:@selector(sessionDidChangeStatus:)]) {
        [_delegate sessionDidChangeStatus:self];
    }
}

- (void)updateChatStatusWithObject:(NSDictionary *)object {
    NSParameterAssert([object isKindOfClass:[NSString class]]);
    if (_chat == nil) {
        // That ugly feeling...
        return;
    }
    _chat.state = [_chat chatStateFromString:(NSString *)object];
    if ([_delegate respondsToSelector:@selector(sessionDidChangeChatStatus:)]) {
        [_delegate sessionDidChangeChatStatus:self];
    }
}

- (void)updateChatWithObject:(NSDictionary *)object {
    if ([object isKindOfClass:[NSNull class]]) {
        _chat = nil;
    } else {
        if (_chat == nil) {
            _chat = [WMChat new];
        }
        [_chat initWithObject:object forSession:self];
        if ([_delegate respondsToSelector:@selector(session:didStartChat:)]) {
            [_delegate session:self didStartChat:_chat];
        }
    }
}

- (void)patchOnlineDelta {
    if (self.isStopped) {
        return;
    }
    if ([[NSDate date] timeIntervalSinceDate:lastFullUpdateDate_] > OnlineDeltaPatchTimeInterval) {
        if (_chat != nil && (_chat.state == WMChatStateQueue || _chat.state == WMChatStateChatting ||
                             _chat.state == WMChatStateClosedByOperator)) {
            // chat window present - nothing to do
        } else if (_chat == nil || _chat.state == WMChatStateClosed || _chat.state == WMChatStateClosedByVisitor) {
            // main window presented
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startGettingDeltaWithComet) object:nil];
            [self cancelGettingDeltaWithComet];
            self.revision = @0;
            activeDeltaRevisionNumber_ = nil;
            [self startGettingDeltaWithComet];
        }
    }
}

- (void)addChatMessageFromObject:(NSDictionary *)object {
    NSAssert(_chat != nil, @"Chat is not initialized");
    WMMessage *newMessage = [[WMMessage alloc] initWithObject:object forSession:self];
    [_chat.messages addObject:newMessage];
    if ([_delegate respondsToSelector:@selector(session:didReceiveMessage:)]) {
        [_delegate session:self didReceiveMessage:newMessage];
    }
}

- (void)updateChatOperatorWithObject:(NSDictionary *)object {
    NSAssert(_chat != nil, @"Chat object must exist before adding operator");
    if (object == nil || [object isKindOfClass:[NSNull class]]) {
        _chat.chatOperator = nil;
    } else {
        if (_chat.chatOperator == nil) {
            _chat.chatOperator = [[WMOperator alloc] initWithObject:object];
        } else {
            [_chat.chatOperator updateWithObject:object];
        }
    }
    if ([_delegate respondsToSelector:@selector(session:didUpdateOperator:)]) {
        [_delegate session:self didUpdateOperator:_chat.chatOperator];
    }
}

- (void)updateChatReadByVisitorWithObject:(id)object {
    BOOL chatReadByVisitor = [object boolValue];
    _chat.hasUnreadMessages = !chatReadByVisitor;
}

- (void)updateChatOperatorTypingWithObject:(id)object {
    BOOL operatorTyping = [object boolValue];
    _chat.operatorTyping = operatorTyping;
    if ([_delegate respondsToSelector:@selector(session:didChangeOperatorTyping:)]) {
        [_delegate session:self didChangeOperatorTyping:operatorTyping];
    }
}

+ (NSString *)deviceTokenStringFromData:(NSData *)deviceToken {
    NSCharacterSet *matchSet = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:matchSet];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    return token;
}

- (void)setDeviceToken:(NSData *)deviceToken completion:(WMResponseCompletionBlock)block {
    NSString *tokenString = [[self class] deviceTokenStringFromData:deviceToken];
    [self setupPushToken:tokenString completion:block];
}

+ (void)setDeviceTokenString:(NSString *)token {
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"WMDeviceTokenKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"WMDeviceTokenNotification" object:token userInfo:nil];
}

+ (void)setDeviceToken:(NSData *)deviceToken {
    NSString *token = [[self class] deviceTokenStringFromData:deviceToken];
    [WMSession setDeviceTokenString:token];
}

- (void)tryToSetupPushToken {
    if (sessionStarted_ && !sessionEstablished_) {
        [self performSelector:@selector(tryToSetupPushToken) withObject:nil afterDelay:3];
    } else if (sessionEstablished_) {
        NSString *pushToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"WMDeviceTokenKey"];
        [self setupPushToken:pushToken completion:nil];
    }
}

- (void)setOnlineStatus:(WMSessionOnlineStatus)onlineStatus {
    static NSString *name = @"onlineOperator";
    [self willChangeValueForKey:name];
    _onlineStatus = onlineStatus;
    [self didChangeValueForKey:name];
    
    if ([_delegate respondsToSelector:@selector(session:didChangeOnlineStatus:)]) {
        [_delegate session:self didChangeOnlineStatus:onlineStatus];
    }
}

#pragma mark - UIApplication Notifications

- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification {
    if (sessionStarted_ && !gettingInitialDelta_) {
#if 1
        self.revision = @0;
        //^ Reset revision to obtain fullUpdate (to be replaced when we'll get delta for changing
        //  offline/online status for operators
#endif
        if (self.isStopped) {
            return;
        }
        [self continueInLocation];
    }
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startGettingDeltaWithComet) object:nil];
    [self cancelGettingDeltaWithComet];
}

- (void)deviceTokenNotification:(NSNotification *)notification {
    [self tryToSetupPushToken];
}

@end
