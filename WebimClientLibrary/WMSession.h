//
//  WMSession.h
//  Webim-Client
//
//  Created by Oleg Bogumirsky on 9/5/13.
//  Copyright (c) 2013 WEBIM.RU Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WMBaseSession.h"

@protocol WMSessionDelegate;
@class WMChat;
@class WMVisitor;
@class WMMessage;
@class WMOperator;

typedef enum {
    WMSessionStateUnknown,
    WMSessionStateIdle,
    WMSessionStateIdleAfterChat,
    WMSessionStateChat,
    WMSessionStateOfflineMessage,
} WMSessionState;

typedef enum {
    WMSessionConnectionStatusUnknown,
    WMSessionConnectionStatusOnline,
    WMSessionConnectionStatusOffline,
} WMSessionConnectionStatus;

typedef enum {
    WMSessionOnlineStatusUnknown,
    WMSessionOnlineStatusOnline,
    WMSessionOnlineStatusBusyOnline,
    WMSessionOnlineStatusOffline,
    WMSessionOnlineStatusBusyOffline,
} WMSessionOnlineStatus;

// Optional keys for visitorData dictionary
extern NSString *const WMVisitorParameterDisplayName;
extern NSString *const WMVisitorParameterPhone;
extern NSString *const WMVisitorParameterEmail;
extern NSString *const WMVisitorParameterICQ;
extern NSString *const WMVisitorParameterProfileURL;
extern NSString *const WMVisitorParameterAvatarURL;
extern NSString *const WMVisitorParameterID;
extern NSString *const WMVisitorParameterLogin;
extern NSString *const WMVisitorParameterCRC; // Required, see http://webim.ru/help/identification/

typedef void (^WMResponseCompletionBlock)(BOOL successful);

@interface WMSession : WMBaseSession

@property (nonatomic, weak) id <WMSessionDelegate> delegate;
@property (nonatomic, readonly, assign) WMSessionState state;
@property (nonatomic, readonly, assign) WMSessionOnlineStatus onlineStatus;
@property (nonatomic, strong) WMChat *chat;
@property (nonatomic, strong) WMVisitor *visitor;

@property (nonatomic, readonly) WMSessionConnectionStatus connectionStatus;

/**
 Initialize session
 
 @param accountName The name of an account in the webim service or custom service entry point
 @param location Location is a set of predefined properties for a session, string value
 @param delegate Delegate which will handle WMSessionDelegate calls
 
 @return Initialized object of session
 */
- (id)initWithAccountName:(NSString *)accountName location:(NSString *)location delegate:(id<WMSessionDelegate>)delegate;

- (id)initWithAccountName:(NSString *)accountName location:(NSString *)location delegate:(id<WMSessionDelegate>)delegate visitorFields:(NSDictionary *)visitorFields;

- (id)initWithAccountName:(NSString *)accountName location:(NSString *)location delegate:(id <WMSessionDelegate>)delegate visitorFields:(NSDictionary *)visitorFields isMultiUser:(BOOL)isMultiUser;

- (void)startSession:(WMResponseCompletionBlock)block;
- (void)stopSession;
- (void)refreshSessionWithCompletionBlock:(WMResponseCompletionBlock)block;

- (NSString *)startChat:(WMResponseCompletionBlock)block;
- (NSString *)startChatWithClientSideId:(NSString *)clientSideId
                        completionBlock:(WMResponseCompletionBlock)completionBlock;

- (void)closeChat:(WMResponseCompletionBlock)block;
- (void)markChatAsRead:(WMResponseCompletionBlock)block;


- (NSString *)sendMessage:(NSString *)message
             successBlock:(void (^)(NSString *clientSideId))successBlock
             failureBlock:(void (^)(NSString *clientSideId, WMSessionError error))failureBlock;

- (NSString *)sendMessage:(NSString *)message
         withClientSideId:(NSString *)clientSideId
             successBlock:(void (^)(NSString *clientSideId))successBlock
             failureBlock:(void (^)(NSString *clientSideId, WMSessionError error))failureBlock;


- (NSString *)sendFile:(NSData *)fileData
                  name:(NSString *)fileName
              mimeType:(NSString *)mimeType
          successBlock:(void (^)(NSString *clientSideId))succcessBlock
          failureBlock:(void(^)(NSString *clientSideId, WMSessionError error))failureBlock;

- (NSString *)sendFile:(NSData *)fileData
                  name:(NSString *)fileName
              mimeType:(NSString *)mimeType
      withClientSideId:(NSString *)clientSideId
          successBlock:(void (^)(NSString *clientSideId))succcessBlock
          failureBlock:(void(^)(NSString *clientSideId, WMSessionError error))failureBlock;

- (void)sendImage:(NSData *)imageData type:(WMChatAttachmentImageType)type completion:(WMResponseCompletionBlock)block __attribute__((deprecated("Use - (void)sendFile... instead")));

- (void)setComposingMessage:(BOOL)isComposing draft:(NSString *)draft;

- (void)rateOperator:(NSString *)authorID withRate:(WMOperatorRate)rate completion:(WMResponseCompletionBlock)block;

- (void)setDeviceToken:(NSData *)deviceToken completion:(WMResponseCompletionBlock)block;

+ (void)setDeviceToken:(NSData *)deviceToken;
+ (void)setDeviceTokenString:(NSString *)token;

@end


@protocol WMSessionDelegate <NSObject>

- (void)sessionDidReceiveFullUpdate:(WMSession *)session;
- (void)sessionDidChangeStatus:(WMSession *)session;
- (void)sessionDidChangeChatStatus:(WMSession *)session;
- (void)session:(WMSession *)session didStartChat:(WMChat *)chat;
- (void)session:(WMSession *)session didUpdateOperator:(WMOperator *)chatOperator;
- (void)session:(WMSession *)session didReceiveMessage:(WMMessage *)message;
- (void)session:(WMSession *)session didReceiveError:(WMSessionError)errorID;

@optional
- (void)session:(WMSession *)session didChangeConnectionStatus:(WMSessionConnectionStatus)status;
- (void)session:(WMSession *)session didChangeOnlineStatus:(WMSessionOnlineStatus)onlineStatus;
- (void)session:(WMSession *)session didChangeOperatorTyping:(BOOL)typing;

/*
 Session unexpected behaviour.
 Session is stopped at this moment. Try to start it again or create a new instance instead. 
 */
- (void)sessionRestartRequired:(WMSession *)session;

@end
