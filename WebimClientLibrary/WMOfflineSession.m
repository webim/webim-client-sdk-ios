//
//  WMOfflineSession.m
//  WebimClientLibrary
//
//  Created by Oleg Bogumirsky on 09/07/14.
//  Copyright (c) 2014 Webim.ru. All rights reserved.
//

#import "WMOfflineSession.h"

#import "AFNetworking.h"
#import "WMOfflineSession+ResponseProcessor.h"

#import "WMChat+Private.h"
#import "WMMessage+Private.h"
#import "NSUserDefaults+ClientData.h"
#import "WMUIDGenerator.h"
#import "NSNull+Checks.h"

#ifdef DEBUG
#define WMDebugLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define WMDebugLog(format, ...)
#endif

static NSTimeInterval TimeBetweenPagePings = 30 * 60; // Server forgets pages after 30 mins of inactivity

static NSString *const APIDeltaPath =   @"/l/v/delta";
static NSString *const APIActionPath =  @"/l/v/action";
static NSString *const APIHistoryPath = @"/l/v/history";
static NSString *const APIUploadPath =  @"/l/v/upload";

NSString *const WMOfflineChatChangesNewChatsKey = @"chats";
NSString *const WMOfflineChatChangesModifiedChatsKey = @"mod_chats";
NSString *const WMOfflineChatChangesMessagesKey = @"messages";

static NSString *DefaultClientTitle = @"iOS Client"; //

@interface WMOfflineSession () <NSCoding>

@property (nonatomic, strong) NSDictionary *visitorFields;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSNumber *lastChangeTs;
@property (nonatomic, strong) NSString *platform;
@property (nonatomic, strong) AFHTTPClient *client;

//TODO: refactor
@property (nonatomic, strong) NSString *visitSessionID;
@property (nonatomic, strong) NSString *pageID;
@property (nonatomic, strong) NSNumber *revision;
@property (nonatomic, strong) NSDictionary *visitorObject;

@property (nonatomic, strong) NSLock *appealsLock;

@property (nonatomic, strong) NSDate *lastPagePing;

@property (nonatomic, strong) NSDictionary *userDefinedVisitorFields;

@property (nonatomic, assign) BOOL isCleaned;

@end

@implementation WMOfflineSession {
    BOOL                 isMultiUser_;
    NSString            *userId_; // only for multi user session
}

- (id)initWithAccountName:(NSString *)accountName location:(NSString *)location token:(NSString *)token platform:(NSString *)platform {
    return [self initWithAccountName:accountName location:location token:token platform:platform visitorFields:nil];
}

- (id)initWithAccountName:(NSString *)accountName location:(NSString *)location token:(NSString *)token platform:(NSString *)platform visitorFields:(NSDictionary *)visitorFields {
    return [self initWithAccountName:accountName location:location token:token platform:platform visitorFields:visitorFields isMultiUser:NO];
}

- (id)initWithAccountName:(NSString *)accountName location:(NSString *)location token:(NSString *)token platform:(NSString *)platform visitorFields:(NSDictionary *)visitorFields isMultiUser:(BOOL)isMultiUser {

    if ((self = [super initWithAccountName:accountName location:location])) {
        _appealsArray = [NSMutableArray array];
        self.token = token;
        self.platform = platform;
        self.lastChangeTs = @(0);
        self.appealsLock = [NSLock new];
        _userDefinedVisitorFields = visitorFields;
        
        NSURL *baseURL = [NSURL URLWithString:self.host];
        _client = [AFHTTPClient clientWithBaseURL:baseURL];
        [_client setParameterEncoding:AFFormURLParameterEncoding];
        [_client setDefaultHeader:@"Accept" value:@"text/json, application/json"];
        [_client registerHTTPOperationClass:[AFJSONRequestOperation class]];
        self.client.operationQueue.maxConcurrentOperationCount = 1;

        isMultiUser_ = isMultiUser;
        if(isMultiUser) {
            NSAssert([NSNull valueOf:visitorFields] != nil, @"visitorFields must be defined for multi user session");
            id uid = visitorFields[@"id"];
            NSAssert([NSNull valueOf:uid] != nil, @"Field 'id' must be defined in visitorFields");
            if ([uid isKindOfClass:[NSNumber class]])
                userId_ = [((NSNumber *)uid) stringValue];
            else
                userId_ = (NSString *)uid;
        }
        
        [self load];
    }
    
    return self;
}

- (NSMutableArray *)appealsArray {
    [self.appealsLock lock];
    NSMutableArray *retArray = [_appealsArray mutableCopy];
    [self.appealsLock unlock];
    return retArray;
}

- (void)setLocation:(NSString *)location {
    [super setLocation:location];
    self.pageID = nil;
}

- (NSDictionary *)unarchiveClientData {
    if(isMultiUser_)
        return [NSUserDefaults unarchiveClientDataMU:userId_];
    else
        return [NSUserDefaults unarchiveClientData];
}

- (void)archiveClientData:(NSDictionary *)dictionary {
    if(isMultiUser_)
        [NSUserDefaults archiveClientDataMU:userId_ dictionary:dictionary];
    else
        [NSUserDefaults archiveClientData:dictionary];
}

- (void)startSession:(void (^)(BOOL success, NSError *error))block {
    __block NSMutableDictionary *storedValues = [[self unarchiveClientData] mutableCopy];
    if (storedValues == nil) {
        storedValues = [NSMutableDictionary dictionary];
    }
    
    id visitor = storedValues[WMStoreVisitorKey];
    id visitSessionId = storedValues[WMStoreVisitSessionIDKey];
    id pageID = storedValues[WMStorePageIDKey];
    self.pageID = pageID;
    self.visitorObject = visitor;

    id extVisitorObject = nil;
    if (self.userDefinedVisitorFields != nil) {
        extVisitorObject = [self jsonizedStringFromObject:self.userDefinedVisitorFields];
    }
    if (extVisitorObject == nil) {
        extVisitorObject = [NSNull null];
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"event"] = @"init";
    params[@"since"] = @"0";
    params[@"location"] = self.location;
    params[@"title"] = DefaultClientTitle;
    params[@"platform"] = self.platform.length > 0 ? self.platform : @"ios",
    params[@"ts"] = @([[NSDate date] timeIntervalSince1970]);
    if (visitSessionId != nil) {
        params[@"visit-session-id"] = visitSessionId;
    }
    if (visitor != nil) {
        params[@"visitor"] = [self jsonizedStringFromObject:visitor];
    }
    if (self.token.length > 0) {
        params[@"push-token"] = self.token;
    }
    if (extVisitorObject != nil) {
        params[@"visitor-ext"] = extVisitorObject;
    }
    
    [self.client getPath:APIDeltaPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        id errorData = responseObject[@"error"];
        if (errorData != nil && ![errorData isKindOfClass:[NSNull class]]) {
            WMDebugLog(@"Init Delta Response Error:\n%@", responseObject);
            NSError *error = [NSError errorWithDomain:WMWebimErrorDomain
                                                 code:[self errorFromString:errorData]
                                             userInfo:nil];
            CALL_BLOCK(block, NO, error);
            return;
        }
        
        self.revision = responseObject[@"revision"];
        NSMutableDictionary *updateDictionary = responseObject[@"fullUpdate"];
        self.visitSessionID = updateDictionary[@"visitSessionId"];
        self.pageID = updateDictionary[@"pageId"];
        
        storedValues[WMStoreVisitorKey] = updateDictionary[@"visitor"];
        storedValues[WMStoreVisitSessionIDKey] = self.visitSessionID;
        storedValues[WMStorePageIDKey] = self.pageID;
        [self archiveClientData:storedValues];

        self.lastPagePing = [NSDate date];
        
        if (![self.visitorObject[@"id"] isEqualToString:updateDictionary[@"visitor"][@"id"]] && self.visitorObject != nil) {
            WMDebugLog(@"Removing storage file due to changes in visitor id");
            [self clearStorage];
        }
        self.visitorObject = updateDictionary[@"visitor"];
        
        CALL_BLOCK(block, YES, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.isCancelled) {
            CALL_BLOCK(block, NO, error);
            return;
        }
        WMDebugLog(@"Error: unable to start with location.\n%@", error);
        CALL_BLOCK(block, NO, error);
    }];
}

// In case of server-not-ready situation this methods tries to "init" given number of times
- (void)tryToRun:(int)runTimes currentRun:(int)curRun startOfflineSessionWithCompletion:(void (^)(BOOL successful, NSError *error))block {
    [self startSession:^(BOOL success, NSError *lerror) {
        if (success) {
            CALL_BLOCK(block, YES, nil);
        } else {
            if (runTimes == curRun + 1 || ![lerror.domain isEqualToString:WMWebimErrorDomain] ||
                lerror.code != WMSessionErrorServerNotReady) {
                CALL_BLOCK(block, NO, lerror);
            } else {
                [NSObject dispatchOnMainThreadAfterDelay:curRun + 1 block:^{
                    [self tryToRun:runTimes currentRun:curRun + 1 startOfflineSessionWithCompletion:block];
                }];
            }
        }
    }];
}

- (void)getHistoryForced:(BOOL)forced completion:(void (^)(BOOL, id, NSError *))block {
    NSDictionary *storeData = [self unarchiveClientData];
    if (storeData == nil || storeData[WMStoreVisitorKey] == nil || storeData[WMStoreVisitSessionIDKey] == nil) {
        [self tryToRun:3 currentRun:0 startOfflineSessionWithCompletion:^(BOOL successful, NSError *error) {
            if (successful) {
                [self doGetHistoryForced:forced completion:block];
            } else {
                CALL_BLOCK(block, NO, nil, error);
            }
        }];
    } else {
        [self doGetHistoryForced:forced completion:block];
    }
}

- (void)doGetHistoryForced:(BOOL)forced completion:(void (^)(BOOL, id, NSError *))block {
    NSDictionary *storeData = [self unarchiveClientData];
    NSString *visitorID = storeData[WMStoreVisitorKey][@"id"];
    if (visitorID.length == 0) {
        WMDebugLog(@"History will be available after first appeal");
        NSError *error = [NSError errorWithDomain:WMWebimErrorDomain
                                             code:WMSessionErrorVisitorNotSet
                                         userInfo: @{
                                                     NSLocalizedDescriptionKey: @"User's visitor id not ready",
                                                     NSLocalizedRecoverySuggestionErrorKey: @"History will be available after user's first message",
                                                     }];
        CALL_BLOCK(block, NO, nil, error);
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"visitor-id"] = visitorID;
    params[@"since"] = forced ? @(0) : self.lastChangeTs;
    [self.client getPath:APIHistoryPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *webimError = [self checkWebimErrorInResponse:responseObject];
        if (webimError != nil) {
            CALL_BLOCK(block, NO, nil, webimError);
        } else {
            self.lastChangeTs = responseObject[@"lastChangeTs"];
            NSDictionary *changes = [self processGetHistory:responseObject appeals:_appealsArray lock:self.appealsLock];
            [self save];
            CALL_BLOCK(block, YES, changes, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        WMDebugLog(@"%@", error);
        CALL_BLOCK(block, NO, nil, error);
    }];
}

- (void)doSendOfflineMessage:(NSString *)text chat:(WMChat *)chat fileDescriptors:(NSArray *)fileDescriptors subject:(NSString *)subject departmentKey:(NSString *)departmentKey onDataBlock:(void (^)(BOOL, WMChat *, WMMessage *, NSError *))block completion:(void (^)(BOOL))completion {
    NSError *pageError = [self checkPageIDForSession];
    if (pageError != nil) {
        WMDebugLog(@"Error: sending offline message without page id");
        CALL_BLOCK(block, NO, chat, nil, pageError);
        return;
    }
    NSAssert(text.length > 0 || fileDescriptors != nil, @"Text or file descriptor required");
    
    NSString *uid = [WMUIDGenerator generateUID];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"action"] = @"chat.offline_message";
    params[@"page-id"] = self.pageID;
    params[@"visitor-fields"] = self.visitorFields.count > 0 ? [self jsonizedStringFromObject:self.visitorFields] : @"{}";
    if (text.length > 0) {
        params[@"text"] = text;
    }
    if (chat != nil) {
        params[@"chat-id"] = chat.uid;
    }
    if (fileDescriptors.count > 0) {
        params[@"file-descs"] = [self jsonizedStringFromObject:fileDescriptors];
    }
    if (departmentKey.length > 0) {
        params[@"department-key"] = departmentKey;
    }
    if (uid.length > 0) {
        params[@"client-message-id"] = uid;
    }
    params[@"subject"] = subject.length > 0 ? subject : [NSNull null];
    
    [self.client postPath:APIActionPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *webimError = [self checkWebimErrorInResponse:responseObject];
        if (webimError != nil) {
            CALL_BLOCK(block, NO, chat, nil, webimError);
            CALL_BLOCK(completion, NO);
        } else {
            if (chat == nil) {
                WMChat *newChat = [self processNewAppealWithMessage:responseObject];
                if (newChat == nil) {
                    CALL_BLOCK(block, NO, nil, nil,
                               [NSError errorWithDomain:WMWebimErrorDomain
                                                   code:WMSessionErrorResponseDataError
                                               userInfo:@{NSLocalizedDescriptionKey: @"Unable to create chat object from server response"}]);
                    CALL_BLOCK(completion, NO);
                    return;
                }
                CALL_BLOCK(block, YES, newChat, newChat.messages.firstObject, nil);
                [self.appealsLock lock];
                [_appealsArray addObject:newChat];
                [self.appealsLock unlock];
            } else {
                WMMessage *newMessage = [self processNewMessage:responseObject];
                if (newMessage == nil) {
                    CALL_BLOCK(block, NO, nil, nil,
                               [NSError errorWithDomain:WMWebimErrorDomain
                                                   code:WMSessionErrorResponseDataError
                                               userInfo:@{NSLocalizedDescriptionKey: @"Unable to create message from server response"}]);
                    CALL_BLOCK(completion, NO);
                    return;
                }
                CALL_BLOCK(block, YES, chat, newMessage, nil);
                [chat.messages addObject:newMessage];
            }
            [self save];
            CALL_BLOCK(completion, YES);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        WMDebugLog(@"%@", error);
        CALL_BLOCK(block, NO, chat, nil, error);
        CALL_BLOCK(completion, NO);
    }];
}

- (NSError *)checkPageIDForSession {
    if (self.pageID.length == 0) {
        NSDictionary *storeData = [self unarchiveClientData];
        self.pageID = storeData[WMStorePageIDKey];
    }
    if (self.pageID.length == 0) {
        return [NSError errorWithDomain:WMWebimErrorDomain
                                   code:WMSessionErrorNotConfigured
                               userInfo:@{NSLocalizedDescriptionKey: @"Missing page-id for chat"}];
    }
    return nil;
}

- (NSError *)checkChatMessage:(NSString *)text {
    if (text.length == 0) {
        WMDebugLog(@"Error: not sending empty text");
        return [NSError errorWithDomain:WMWebimErrorDomain
                                   code:WMSessionErrorEmptyMessageText
                               userInfo:@{NSLocalizedDescriptionKey: @"Empty chat text message"}];
    }
    return nil;
}

- (NSError *)checkWebimErrorInResponse:(NSDictionary *)responseObject {
    id errorData = responseObject[@"error"];
    if (errorData != nil && ![errorData isKindOfClass:[NSNull class]]) {
        WMDebugLog(@"%@", errorData);
        return [NSError errorWithDomain:WMWebimErrorDomain
                                   code:[self errorFromString:errorData]
                               userInfo:@{NSLocalizedDescriptionKey: errorData}];
    }
    if (responseObject == nil) {
        WMDebugLog(@"Error: empty response");
    }
    return nil;
}

- (void)runMethodWithMainBlock:(void (^)())mainBlock recoverBlock:(void (^)())recoverBlock {
    if (self.lastPagePing == nil || [[NSDate date] timeIntervalSinceDate:self.lastPagePing] >= TimeBetweenPagePings) {
        recoverBlock();
    } else {
        mainBlock();
    }
}

- (BOOL)isReinitRequiredError:(NSError *)error {
    return [error.domain isEqualToString:WMWebimErrorDomain] && error.code == WMSessionErrorReinitRequired;
}

- (void)sendMessage:(NSString *)text inChat:(WMChat *)chat subject:(NSString *)subject departmentKey:(NSString *)departmentKey onDataBlock:(void (^)(BOOL, WMChat *, WMMessage *, NSError *))block completion:(void (^)(BOOL))completion {
    NSError *textError = [self checkChatMessage:text];
    if (textError != nil) {
        CALL_BLOCK(block, NO, chat, nil, textError);
        CALL_BLOCK(completion, NO);
        return;
    }
    
    void (^recoverBlock)() = ^() {
        [self tryToRun:3 currentRun:0 startOfflineSessionWithCompletion:^(BOOL successful, NSError *error) {
            if (successful) {
                [self doSendOfflineMessage:text chat:chat fileDescriptors:nil subject:nil departmentKey:departmentKey onDataBlock:block completion:completion];
            } else {
                CALL_BLOCK(block, NO, chat, nil, error);
                CALL_BLOCK(completion, NO);
            }
        }];
    };
    
    void (^mainBlock)() = ^() {
        void (^testBlock)(BOOL, WMChat *, WMMessage *, NSError *) = ^(BOOL result, WMChat *chat, WMMessage *message, NSError *error) {
            if ([self isReinitRequiredError:error]) {
                recoverBlock();
            } else {
                CALL_BLOCK(block, result, chat, message, error);
            }
        };
        [self doSendOfflineMessage:text chat:chat fileDescriptors:nil subject:nil departmentKey:departmentKey onDataBlock:testBlock completion:completion];
    };
    
    [self runMethodWithMainBlock:mainBlock recoverBlock:recoverBlock];
}

- (void)sendMessage:(NSString *)text inChat:(WMChat *)chat onDataBlock:(void (^)(BOOL, WMChat *, WMMessage *, NSError *))block completion:(void (^)(BOOL))completion {
    [self sendMessage:text inChat:chat subject:nil departmentKey:nil onDataBlock:block completion:completion];
}

- (void)sendMessage:(NSString *)text inChat:(WMChat *)chat departmentKey:(NSString *)departmentKey onDataBlock:(void (^)(BOOL, WMChat *, WMMessage *, NSError *))block completion:(void (^)(BOOL))completion {
    [self sendMessage:text inChat:chat subject:nil departmentKey:departmentKey onDataBlock:block completion:completion];
}

- (void)doDeleteChat:(WMChat *)chat completion:(void (^)(BOOL, NSError *))block {
    NSParameterAssert(chat != nil);
    NSError *pageError = [self checkPageIDForSession];
    if (pageError != nil || chat.uid == nil) {
        WMDebugLog(@"Error: attempt to delete chat without page id");
        CALL_BLOCK(block, NO, pageError);
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"action"] = @"chat.delete";
    params[@"page-id"] = self.pageID;
    params[@"chat-id"] = chat.uid;
    
    [self.client postPath:APIActionPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *webimError = [self checkWebimErrorInResponse:responseObject];
        if (webimError != nil && webimError.code != WMSessionErrorChatNotFound) {
            CALL_BLOCK(block, NO, webimError);
        } else {
            [self processDeleteChat:chat response:responseObject appeals:_appealsArray lock:self.appealsLock];
            [self save];
            CALL_BLOCK(block, YES, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        WMDebugLog(@"%@", error);
        CALL_BLOCK(block, NO, error);
    }];
}

- (void)deleteChat:(WMChat *)chat completion:(void (^)(BOOL, NSError *))block {
    
    void (^recoverBlock)() = ^() {
        [self tryToRun:3 currentRun:0 startOfflineSessionWithCompletion:^(BOOL successful, NSError *error) {
            if (successful) {
                [self doDeleteChat:chat completion:block];
            } else {
                CALL_BLOCK(block, NO, error);
            }
        }];
    };
    
    void (^mainBlock)() = ^() {
        [self doDeleteChat:chat completion:^(BOOL result, NSError *error) {
            if ([self isReinitRequiredError:error]) {
                recoverBlock();
            } else {
                CALL_BLOCK(block, result, error);
            }
        }];
    };
    
    [self runMethodWithMainBlock:mainBlock recoverBlock:recoverBlock];
}

- (void)doMarkChatAsRead:(WMChat *)chat completion:(void (^)(BOOL, NSError *))block {
    NSParameterAssert(chat != nil);
    NSError *pageError = [self checkPageIDForSession];
    if (pageError != nil || chat.uid == nil) {
        WMDebugLog(@"Error: attempt to delete chat without page id");
        CALL_BLOCK(block, NO, pageError);
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"action"] = @"chat.read_by_visitor";
    params[@"page-id"] = self.pageID;
    params[@"chat-id"] = chat.uid;
    
    [self.client postPath:APIActionPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *webimError = [self checkWebimErrorInResponse:responseObject];
        if (webimError != nil && webimError.code != WMSessionErrorChatNotFound) {
            CALL_BLOCK(block, NO, webimError);
        } else {
            [self processMarkAsReadChat:chat response:responseObject];
            [self save];
            CALL_BLOCK(block, YES, webimError);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        WMDebugLog(@"%@", error);
        CALL_BLOCK(block, NO, error);
    }];
}

- (void)markChatAsRead:(WMChat *)chat completion:(void (^)(BOOL, NSError *))block {
    
    void (^recoverBlock)() = ^() {
        [self tryToRun:3 currentRun:0 startOfflineSessionWithCompletion:^(BOOL successful, NSError *error) {
            if (successful) {
                [self doMarkChatAsRead:chat completion:block];
            } else {
                CALL_BLOCK(block, NO, error);
            }
        }];
    };
    
    void (^mainBlock)() = ^() {
        [self doMarkChatAsRead:chat completion:^(BOOL result, NSError *error) {
            if ([self isReinitRequiredError:error]) {
                recoverBlock();
            } else {
                CALL_BLOCK(block, result, error);
            }
        }];
    };
    
    [self runMethodWithMainBlock:mainBlock recoverBlock:recoverBlock];
}

- (void)doSendImage:(NSData *)imageData type:(WMChatAttachmentImageType)type inChat:(WMChat *)chat subject:(NSString *)subject departmentKey:(NSString *)departmentKey onDataBlock:(void (^)(BOOL, WMChat *, WMMessage *, NSError *))block completion:(void (^)(BOOL))completion {
    NSString *mimeType = type == WMChatAttachmentImageJPEG ? @"image/jpeg" : @"image/png";
    NSString *fileName = type == WMChatAttachmentImageJPEG ? @"ios_image.jpg" : @"ios_image.png";
    
    [self doSendFile:imageData name:fileName mimeType:mimeType inChat:chat subject:subject departmentKey:departmentKey onDataBlock:block completion:completion];
}

- (void)doSendFile:(NSData *)fileData name:(NSString *)fileName mimeType:(NSString *)mimeType inChat:(WMChat *)chat subject:(NSString *)subject departmentKey:(NSString *)departmentKey onDataBlock:(void (^)(BOOL, WMChat *, WMMessage *, NSError *))block completion:(void (^)(BOOL))completion {
    NSDictionary *storeData = [self unarchiveClientData];
    NSString *visitorID = storeData[WMStoreVisitorKey][@"id"];
    if (visitorID.length == 0) {
        WMDebugLog(@"History will be available after first appeal");
        NSError *error = [NSError errorWithDomain:WMWebimErrorDomain
                                             code:WMSessionErrorNotConfigured
                                         userInfo: @{
                                                     NSLocalizedDescriptionKey: @"User's visitor id not ready",
                                                     NSLocalizedRecoverySuggestionErrorKey: @"Unexpected error",
                                                     }];
        CALL_BLOCK(block, NO, chat, nil, error);
        CALL_BLOCK(completion, NO);
        return;
    }
    
    NSError *pageError = [self checkPageIDForSession];
    if (pageError != nil) {
        WMDebugLog(@"Error: attempt to send file without page id");
        CALL_BLOCK(block, NO, chat, nil, pageError);
        CALL_BLOCK(completion, NO);
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"chat-mode"] = @"offline";
    params[@"page-id"] = self.pageID;
    params[@"visit-session-id"] = visitorID;
    
    NSMutableURLRequest *request = [self.client multipartFormRequestWithMethod:@"POST"
                                                                          path:APIUploadPath
                                                                    parameters:params
                                                     constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                         [formData appendPartWithFileData:fileData name:@"webim_upload_file" fileName:fileName mimeType:mimeType];
                                                     }];
    AFHTTPRequestOperation *operation = [self.client HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *webimError = [self checkWebimErrorInResponse:responseObject];
        if (webimError != nil) {
            CALL_BLOCK(block, NO, chat, nil, webimError);
            CALL_BLOCK(completion, NO);
        } else {
            NSDictionary *descriptor = responseObject[@"data"];
            [self doSendOfflineMessage:nil chat:chat fileDescriptors:@[descriptor] subject:subject departmentKey:departmentKey onDataBlock:block completion:completion];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        CALL_BLOCK(block, NO, chat, nil, error);
        CALL_BLOCK(completion, NO);
    }];
    [self.client enqueueHTTPRequestOperation:operation];
}

- (void)sendImage:(NSData *)imageData type:(WMChatAttachmentImageType)type inChat:(WMChat *)chat onDataBlock:(void (^)(BOOL, WMChat *, WMMessage *, NSError *))block completion:(void (^)(BOOL))completion {
    [self sendImage:imageData type:type inChat:chat subject:nil departmentKey:nil onDataBlock:block completion:completion];
}

- (void)sendImage:(NSData *)imageData type:(WMChatAttachmentImageType)type inChat:(WMChat *)chat departmentKey:(NSString *)departmentKey onDataBlock:(void (^)(BOOL, WMChat *, WMMessage *, NSError *))block completion:(void (^)(BOOL))completion {
    [self sendImage:imageData type:type inChat:chat subject:nil departmentKey:departmentKey onDataBlock:block completion:completion];
}

- (void)sendImage:(NSData *)imageData type:(WMChatAttachmentImageType)type inChat:(WMChat *)chat subject:(NSString *)subject departmentKey:(NSString *)departmentKey onDataBlock:(void (^)(BOOL, WMChat *, WMMessage *, NSError *))block completion:(void (^)(BOOL))completion {
    
    void (^recoverBlock)() = ^() {
        [self tryToRun:3 currentRun:0 startOfflineSessionWithCompletion:^(BOOL successful, NSError *error) {
            if (successful) {
                [self doSendImage:imageData type:type inChat:chat subject:subject departmentKey:departmentKey onDataBlock:block completion:completion];
            } else {
                CALL_BLOCK(block, NO, chat, nil, error);
                CALL_BLOCK(completion, NO);
            }
        }];
    };
    
    void (^mainBlock)() = ^() {
        void (^testBlock)(BOOL, WMChat *, WMMessage *, NSError *) = ^(BOOL result, WMChat *chat, WMMessage *message, NSError *error) {
            if ([self isReinitRequiredError:error]) {
                recoverBlock();
            } else {
                CALL_BLOCK(block, result, chat, message, error);
            }
        };
        [self doSendImage:imageData type:type inChat:chat subject:subject departmentKey:departmentKey onDataBlock:testBlock completion:completion];
    };
    
    [self runMethodWithMainBlock:mainBlock recoverBlock:recoverBlock];
}

- (void)sendFile:(NSData *)fileData name:(NSString *)fileName mimeType:(NSString *)mimeType inChat:(WMChat *)chat subject:(NSString *)subject departmentKey:(NSString *)departmentKey onDataBlock:(void (^)(BOOL, WMChat *, WMMessage *, NSError *))block completion:(void (^)(BOOL))completion {
    
    void (^recoverBlock)() = ^() {
        [self tryToRun:3 currentRun:0 startOfflineSessionWithCompletion:^(BOOL successful, NSError *error) {
            if (successful) {
                [self doSendFile:fileData name:fileName mimeType:mimeType inChat:chat subject:subject departmentKey:departmentKey onDataBlock:block completion:completion];
            } else {
                CALL_BLOCK(block, NO, chat, nil, error);
                CALL_BLOCK(completion, NO);
            }
        }];
    };
    
    void (^mainBlock)() = ^() {
        void (^testBlock)(BOOL, WMChat *, WMMessage *, NSError *) = ^(BOOL result, WMChat *chat, WMMessage *message, NSError *error) {
            if ([self isReinitRequiredError:error]) {
                recoverBlock();
            } else {
                CALL_BLOCK(block, result, chat, message, error);
            }
        };
        [self doSendFile:fileData name:fileName mimeType:mimeType inChat:chat subject:subject departmentKey:departmentKey onDataBlock:testBlock completion:completion];
    };
    
    [self runMethodWithMainBlock:mainBlock recoverBlock:recoverBlock];
}

- (void)sendFile:(NSData *)fileData name:(NSString *)fileName mimeType:(NSString *)mimeType inChat:(WMChat *)chat departmentKey:(NSString *)departmentKey onDataBlock:(void (^)(BOOL, WMChat *, WMMessage *, NSError *))block completion:(void (^)(BOOL))completion {
    [self sendFile:fileData name:fileName mimeType:mimeType inChat:chat subject:nil departmentKey:departmentKey onDataBlock:block completion:completion];
}

- (void)enqueueHTTPRequestOperation:(id)operation {
    [self.client enqueueHTTPRequestOperation:operation];
}

- (void)save {
    if (self.isCleaned) {
        return;
    }
    NSDictionary *storeData = [self unarchiveClientData];
    NSString *visitorID = storeData[WMStoreVisitorKey][@"id"];
    if (visitorID.length == 0) {
        WMDebugLog(@"Not saving history because of empty visitor: %@", storeData[WMStoreVisitorKey]);
        return;
    }
    NSData *sessionInfo = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSString *filepath = [self storageFilePath];
    NSError *error = nil;
    [sessionInfo writeToFile:filepath options:NSDataWritingAtomic error:&error];
    if (error != nil) {
        WMDebugLog(@"%@", error);
    }
}

- (void)load {
    NSDictionary *storeData = [self unarchiveClientData];
    NSDictionary *visitorData = storeData[WMStoreVisitorKey];
    NSString *visitorID = visitorData[@"id"];
    if (visitorData == nil || visitorID == nil) {
        return;
    }

    NSString *filepath = [self storageFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filepath]) {
        return;
    }
    
    NSError *error = nil;
    NSData *sessionInfo = [NSData dataWithContentsOfFile:filepath options:NSDataReadingUncached error:&error];
    if (error != nil) {
        WMDebugLog(@"%@", error.localizedDescription);
        return;
    }
    @try {
        WMOfflineSession *session = [NSKeyedUnarchiver unarchiveObjectWithData:sessionInfo];
        if (session.visitorObject[@"id"] != nil && ![session.visitorObject[@"id"] isEqualToString:visitorID]) {
            WMDebugLog(@"Removing storage due to change of visitor id");
            [self removeStorageFile];
            return;
        }
        if (session.userDefinedVisitorFields != nil &&
            ![session.userDefinedVisitorFields isEqualToDictionary:self.userDefinedVisitorFields]) {
            WMDebugLog(@"Removing storage due to changes in user defined fields");
            [self removeStorageFile];
            return;
        }
        self.appealsArray = session.appealsArray;
        self.pageID = session.pageID;
        self.lastChangeTs = session.lastChangeTs;
        self.visitorObject = session.visitorObject;
        self.visitSessionID = session.visitSessionID;
        
        for (WMChat *chat in self.appealsArray) {
            for (WMMessage *message in chat.messages) {
                message.session = self;
            }
        }
    }
    @catch (NSException *exception) {
        WMDebugLog(@"%@", exception);
        [self clearStorage];
        return;
    }
}

- (void)clearStorage {
    [self removeStorageFile];
    [self clearInMemoryData];
}

- (void)removeStorageFile {
    NSString *filepath = [self storageFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager isDeletableFileAtPath:filepath]) {
        NSError *error = nil;
        if (![fileManager removeItemAtPath:filepath error:&error]) {
            WMDebugLog(@"Error removing file %@", error.localizedDescription);
        }
    }
}

- (NSString *)storageFilePath {
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *base = [pathArray[0] stringByAppendingPathComponent:@"webimstorage"];
    if(isMultiUser_) {
        return [base stringByAppendingString:userId_];
    } else {
        return base;
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithAccountName:[aDecoder decodeObjectForKey:@"account"] location:[aDecoder decodeObjectForKey:@"location"]];
    self.appealsArray = [aDecoder decodeObjectForKey:@"chats"];
    // In old version chat.uid was NSString
    for (WMChat *chat in _appealsArray) {
        if ([chat.uid isKindOfClass:[NSNumber class]]) {
            chat.uid = [((NSNumber *)chat.uid) stringValue];
        }
    }
    self.lastChangeTs = [aDecoder decodeObjectForKey:@"lastChangeTs"];
    self.visitorObject = [aDecoder decodeObjectForKey:@"visitorObject"];
    self.pageID = [aDecoder decodeObjectForKey:@"pageID"];
    self.visitSessionID = [aDecoder decodeObjectForKey:@"visitSessionID"];
    self.token = [aDecoder decodeObjectForKey:@"token"];
    self.platform = [aDecoder decodeObjectForKey:@"platfrom"];
    self.userDefinedVisitorFields = [aDecoder decodeObjectForKey:@"visitorExtFields"];
    
    for (WMChat *chat in self.appealsArray) {
        for (WMMessage *message in chat.messages) {
            message.session = self;
        }
    }
    
    if (self.lastChangeTs == nil) {
        self.lastChangeTs = @(0);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (self.lastChangeTs == nil) {
        self.lastChangeTs = @(0);
    }
    [self.appealsLock lock];
    [aCoder encodeObject:@(1) forKey:@"coder_version"];
    [aCoder encodeObject:_appealsArray forKey:@"chats"];
    [aCoder encodeObject:self.pageID forKey:@"pageID"];
    [aCoder encodeObject:self.lastChangeTs forKey:@"lastChangeTs"];
    [aCoder encodeObject:self.visitorObject forKey:@"visitorObject"];
    [aCoder encodeObject:self.visitSessionID forKey:@"visitSessionID"];
    [aCoder encodeObject:self.accountName forKey:@"account"];
    [aCoder encodeObject:self.location forKey:@"location"];
    [aCoder encodeObject:self.token forKey:@"token"];
    [aCoder encodeObject:self.platform forKey:@"platfrom"];
    [aCoder encodeObject:self.userDefinedVisitorFields forKey:@"visitorExtFields"];
    [self.appealsLock unlock];
}

#pragma mark -
//TODO: refactor

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
    } else if ([@"chat-not-found" isEqualToString:errorDescription]) {
        return WMSessionErrorChatNotFound;
    } else if ([@"message-length-exceeded" isEqualToString:errorDescription]) {
        return WMSessionErrorMessageSizeExceeded;
    } else if ([@"visitor_banned" isEqualToString:errorDescription]) {
        return WMSessionErrorVisitorBanned;
    } else if ([@"chat_count_limit_exceeded" isEqualToString:errorDescription]) {
        return WMSessionErrorChatCountLimitExceeded;
    }
    return WMSessionErrorUnknown;
}

- (WMChat *)chatForMessage:(WMMessage *)message {
    [self.appealsLock lock];
    for (WMChat *chat in _appealsArray) {
        if ([chat.messages containsObject:message]) {
            [self.appealsLock unlock];
            return chat;
        }
    }
    [self.appealsLock unlock];
    return nil;
}

- (void)clearInMemoryData {
    _appealsArray = [NSMutableArray array];
    self.lastChangeTs = @(0);
}

- (void)clearCachedUserData {
    self.isCleaned = YES;
    [self.client.operationQueue cancelAllOperations];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:@"visitor"];
    [userDefault removeObjectForKey:@"visitSessionId"];
    [userDefault removeObjectForKey:@"pageID"];
    [userDefault synchronize];
    _appealsArray = [NSMutableArray array];
    self.pageID = nil;
    self.visitorObject = nil;
    self.visitSessionID = nil;
    self.revision = nil;
    self.lastChangeTs = @(0);
    [self archiveClientData:nil];
    [self removeStorageFile];
}

@end
