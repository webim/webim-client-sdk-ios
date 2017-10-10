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
    WMSessionOnlineStatusUnknown,
    WMSessionOnlineStatusOnline,
    WMSessionOnlineStatusBusyOnline,
    WMSessionOnlineStatusOffline,
    WMSessionOnlineStatusBusyOffline,
} WMSessionOnlineStatus;

typedef enum {
    WMSessionConnectionStatusUnknown,
    WMSessionConnectionStatusOnline,
    WMSessionConnectionStatusOffline,
} WMSessionConnectionStatus;

typedef void (^WMResponseCompletionBlock)(BOOL successful);


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


@interface WMSession : WMBaseSession

@property (nonatomic, weak) id <WMSessionDelegate> delegate;
@property (nonatomic, readonly, assign) WMSessionState state;
@property (nonatomic, readonly, assign) WMSessionOnlineStatus onlineStatus;
@property (nonatomic, strong) WMChat *chat;
@property (nonatomic, strong) WMVisitor *visitor;

@property (nonatomic, readonly) WMSessionConnectionStatus connectionStatus;


// MARK: Session initialization

/**
 Initialize session.
 
 @param accountName The name of an account in the webim service or custom service entry point.
 @param location Location is a set of predefined properties for a session, string value.
 @param appVersion Optional. Sets your app version if it is needed to pass to a server. E.g. '@"2.9.11"'.
 @param delegate Delegate which will handle WMSessionDelegate calls.
 @param visitorFields Optional. It is useful for your custom visitor identification.
 @param isMultiUser Optional. Substatiates if an app should be able to handle different users with local history on device.
 
 @return Initialized object of session.
 
 @see https://webim.ru/help/identification/
 */
- (id)initWithAccountName:(NSString *)accountName
                 location:(NSString *)location
               appVersion:(NSString *)appVersion
                 delegate:(id <WMSessionDelegate>)delegate
            visitorFields:(NSDictionary *)visitorFields
              isMultiUser:(BOOL)isMultiUser;
- (id)initWithAccountName:(NSString *)accountName
                 location:(NSString *)location
                 delegate:(id <WMSessionDelegate>)delegate
            visitorFields:(NSDictionary *)visitorFields
              isMultiUser:(BOOL)isMultiUser;
- (id)initWithAccountName:(NSString *)accountName
                 location:(NSString *)location
               appVersion:(NSString *)appVersion
                 delegate:(id<WMSessionDelegate>)delegate
            visitorFields:(NSDictionary *)visitorFields;
- (id)initWithAccountName:(NSString *)accountName
                 location:(NSString *)location
                 delegate:(id<WMSessionDelegate>)delegate
            visitorFields:(NSDictionary *)visitorFields;
- (id)initWithAccountName:(NSString *)accountName
                 location:(NSString *)location
               appVersion:(NSString *)appVersion
                 delegate:(id<WMSessionDelegate>)delegate;
- (id)initWithAccountName:(NSString *)accountName
                 location:(NSString *)location
                 delegate:(id<WMSessionDelegate>)delegate;

// MARK: Session methods
- (void)startSession:(WMResponseCompletionBlock)block;
- (void)stopSession;
- (void)refreshSessionWithCompletionBlock:(WMResponseCompletionBlock)block;
- (BOOL)areHintsEnabled; // Answers if the app should show hints to visitor when composing a new message

// MARK: Chat methods
- (NSString *)startChatWithClientSideId:(NSString *)clientSideId
                        completionBlock:(WMResponseCompletionBlock)completionBlock;
- (NSString *)startChat:(WMResponseCompletionBlock)block;
- (void)closeChat:(WMResponseCompletionBlock)block;
- (void)markChatAsRead:(WMResponseCompletionBlock)block;

// MARK: Messages methods

// MARK: Text (message)
- (NSString *)sendMessage:(NSString *)message
         withClientSideId:(NSString *)clientSideId
             successBlock:(void (^)(NSString *clientSideId))successBlock
             failureBlock:(void (^)(NSString *clientSideId, WMSessionError error))failureBlock;
- (NSString *)sendMessage:(NSString *)message
             successBlock:(void (^)(NSString *clientSideId))successBlock
             failureBlock:(void (^)(NSString *clientSideId, WMSessionError error))failureBlock;
// Those with optional argument isHint which is demonstrates to server if visitor choose a hint instead of composing message
- (NSString *)sendMessage:(NSString *)message
         withClientSideId:(NSString *)clientSideId
           isHintQuestion:(BOOL)isHintQuestion
             successBlock:(void (^)(NSString *clientSideId))successBlock
             failureBlock:(void (^)(NSString *clientSideId, WMSessionError error))failureBlock;
- (NSString *)sendMessage:(NSString *)message
           isHintQuestion:(BOOL)isHintQuestion
             successBlock:(void (^)(NSString *clientSideId))successBlock
             failureBlock:(void (^)(NSString *clientSideId, WMSessionError error))failureBlock;

// MARK: File (general case)
- (NSString *)sendFile:(NSData *)fileData
                  name:(NSString *)fileName
              mimeType:(NSString *)mimeType
      withClientSideId:(NSString *)clientSideId
          successBlock:(void (^)(NSString *clientSideId))succcessBlock
          failureBlock:(void(^)(NSString *clientSideId, WMSessionError error))failureBlock;
- (NSString *)sendFile:(NSData *)fileData
                  name:(NSString *)fileName
              mimeType:(NSString *)mimeType
          successBlock:(void (^)(NSString *clientSideId))succcessBlock
          failureBlock:(void(^)(NSString *clientSideId, WMSessionError error))failureBlock;

// MARK: Image
- (void)sendImage:(NSData *)imageData
             type:(WMChatAttachmentImageType)type
       completion:(WMResponseCompletionBlock)block __attribute__((deprecated("Use - (void)sendFile... instead")));

- (void)setComposingMessage:(BOOL)isComposing
                      draft:(NSString *)draft;

// MARK: Rate operator method
- (void)rateOperator:(NSString *)authorID
            withRate:(WMOperatorRate)rate
          completion:(WMResponseCompletionBlock)block;

// MARK: Token methods

- (void)setDeviceToken:(NSData *)deviceToken
            completion:(WMResponseCompletionBlock)block;
+ (void)setDeviceToken:(NSData *)deviceToken;
+ (void)setDeviceTokenString:(NSString *)token;

@end


@protocol WMSessionDelegate <NSObject>

- (void)sessionDidReceiveFullUpdate:(WMSession *)session;
- (void)sessionDidChangeStatus:(WMSession *)session;
- (void)sessionDidChangeChatStatus:(WMSession *)session;
- (void)session:(WMSession *)session
   didStartChat:(WMChat *)chat;
- (void)session:(WMSession *)session
didUpdateOperator:(WMOperator *)chatOperator;
- (void)session:(WMSession *)session
didReceiveMessage:(WMMessage *)message;
- (void)session:(WMSession *)session
didReceiveError:(WMSessionError)errorID;

@optional
- (void)session:(WMSession *)session
didChangeConnectionStatus:(WMSessionConnectionStatus)status;
- (void)session:(WMSession *)session
didChangeOnlineStatus:(WMSessionOnlineStatus)onlineStatus;
- (void)session:(WMSession *)session
didChangeOperatorTyping:(BOOL)typing;

/*
 Session unexpected behaviour.
 Session is stopped at this moment. Try to start it again or create a new instance instead.
 */
- (void)sessionRestartRequired:(WMSession *)session;

@end
